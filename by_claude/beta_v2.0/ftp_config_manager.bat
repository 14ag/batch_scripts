@echo off
:: ftp_config_manager.bat - Manage FTP phone connection settings
setlocal enabledelayedexpansion
title FTP Configuration Manager
:: color 0B

set CONFIG_FILE=ftp_config.ini
set PROFILES_FILE=phone_profiles.ini

:main_menu
cls
echo ================================================
echo          FTP Configuration Manager
echo ================================================
echo.
echo [1] View Current Configuration
echo [2] Edit Configuration
echo [3] Manage Network Profiles
echo [4] Test Configuration
echo [5] Reset to Defaults
echo [6] Import/Export Settings
echo [7] Advanced Options
echo [0] Exit
echo.
set /p CHOICE="Select option: "

if "%CHOICE%"=="1" goto :view_config
if "%CHOICE%"=="2" goto :edit_config
if "%CHOICE%"=="3" goto :manage_profiles
if "%CHOICE%"=="4" goto :test_config
if "%CHOICE%"=="5" goto :reset_config
if "%CHOICE%"=="6" goto :import_export
if "%CHOICE%"=="7" goto :advanced_options
if "%CHOICE%"=="0" exit /b

goto :main_menu

:view_config
cls
echo ================================================
echo         Current Configuration
echo ================================================
echo.

:: Load configuration
call :load_config

echo FTP Settings:
echo   Username: %FTP_USER%
echo   Password: %FTP_PASS%
echo   Port: %FTP_PORT%
echo.
echo Phone Settings:
echo   MAC Address: %PHONE_MAC%
echo   Device Name: %PHONE_NAME%
echo.
echo Network Settings:
echo   Scan Timeout: %SCAN_TIMEOUT%ms
echo   Check Interval: %CHECK_INTERVAL%s
echo   Max Hosts to Scan: %MAX_HOSTS%
echo.
echo Preferred Networks:
echo   1. Phone Hotspot Ranges: %HOTSPOT_RANGES%
echo   2. PC Hotspot: %PC_HOTSPOT_RANGE%
echo   3. Router Network: %ROUTER_RANGE%
echo.
echo Performance:
echo   Use Parallel Scanning: %USE_PARALLEL%
echo   Use PowerShell: %USE_POWERSHELL%
echo   Cache Results: %USE_CACHE%
echo.

pause
goto :main_menu

:edit_config
cls
echo ================================================
echo          Edit Configuration
echo ================================================
echo.
echo [1] FTP Credentials
echo [2] Phone MAC Address
echo [3] Network Ranges
echo [4] Performance Settings
echo [5] Save Configuration
echo [0] Back
echo.
set /p EDIT_CHOICE="Select option: "

if "%EDIT_CHOICE%"=="1" goto :edit_ftp
if "%EDIT_CHOICE%"=="2" goto :edit_mac
if "%EDIT_CHOICE%"=="3" goto :edit_networks
if "%EDIT_CHOICE%"=="4" goto :edit_performance
if "%EDIT_CHOICE%"=="5" goto :save_config
if "%EDIT_CHOICE%"=="0" goto :main_menu

goto :edit_config

:edit_ftp
echo.
set /p FTP_USER="FTP Username [current: %FTP_USER%]: "
set /p FTP_PASS="FTP Password [current: %FTP_PASS%]: "
set /p FTP_PORT="FTP Port [current: %FTP_PORT%]: "
echo Configuration updated!
pause
goto :edit_config

:edit_mac
echo.
echo Current MAC: %PHONE_MAC%
echo.
echo [1] Enter MAC manually
echo [2] Detect from network
echo [3] Select from ARP cache
echo.
set /p MAC_CHOICE="Select option: "

if "%MAC_CHOICE%"=="1" (
    set /p PHONE_MAC="Enter MAC address (format: XX-XX-XX-XX-XX-XX): "
) else if "%MAC_CHOICE%"=="2" (
    echo Scanning network for devices...
    call :detect_devices
) else if "%MAC_CHOICE%"=="3" (
    call :select_from_arp
)

echo MAC Address updated: %PHONE_MAC%
pause
goto :edit_config

:edit_networks
echo.
echo Network Configuration:
echo.
set /p HOTSPOT_RANGES="Phone hotspot ranges [current: %HOTSPOT_RANGES%]: "
set /p PC_HOTSPOT_RANGE="PC hotspot range [current: %PC_HOTSPOT_RANGE%]: "
set /p ROUTER_RANGE="Router range [current: %ROUTER_RANGE%]: "
echo.
echo Networks updated!
pause
goto :edit_config

:edit_performance
echo.
echo Performance Settings:
echo.
set /p USE_PARALLEL="Use parallel scanning? (Y/N) [current: %USE_PARALLEL%]: "
set /p USE_POWERSHELL="Use PowerShell? (Y/N) [current: %USE_POWERSHELL%]: "
set /p USE_CACHE="Cache results? (Y/N) [current: %USE_CACHE%]: "
set /p SCAN_TIMEOUT="Scan timeout (ms) [current: %SCAN_TIMEOUT%]: "
set /p MAX_HOSTS="Max hosts to scan [current: %MAX_HOSTS%]: "
echo.
echo Performance settings updated!
pause
goto :edit_config

:manage_profiles
cls
echo ================================================
echo         Network Profile Manager
echo ================================================
echo.
echo [1] View Saved Profiles
echo [2] Add New Profile
echo [3] Edit Profile
echo [4] Delete Profile
echo [5] Auto-Detect Current Network
echo [0] Back
echo.
set /p PROFILE_CHOICE="Select option: "

if "%PROFILE_CHOICE%"=="1" goto :view_profiles
if "%PROFILE_CHOICE%"=="2" goto :add_profile
if "%PROFILE_CHOICE%"=="3" goto :edit_profile
if "%PROFILE_CHOICE%"=="4" goto :delete_profile
if "%PROFILE_CHOICE%"=="5" goto :detect_network
if "%PROFILE_CHOICE%"=="0" goto :main_menu

goto :manage_profiles

:view_profiles
echo.
echo Saved Network Profiles:
echo -----------------------
if exist %PROFILES_FILE% (
    type %PROFILES_FILE%
) else (
    echo No profiles saved.
)
echo.
pause
goto :manage_profiles

:add_profile
echo.
set /p PROFILE_NAME="Profile name (e.g., Home, Office): "
set /p PROFILE_SSID="WiFi SSID: "
set /p PROFILE_IP="Phone IP on this network: "
set /p PROFILE_RANGE="Network range (e.g., 192.168.1): "

echo %PROFILE_NAME%=%PROFILE_SSID%:%PROFILE_IP%:%PROFILE_RANGE% >> %PROFILES_FILE%
echo Profile saved!
pause
goto :manage_profiles

:detect_network
echo.
echo Detecting current network...
echo.

:: Get current SSID
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /i "SSID" ^| findstr /v "BSSID"') do (
    set CURRENT_SSID=%%a
    set CURRENT_SSID=!CURRENT_SSID:~1!
)

:: Get current IP range
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=1-3 delims=." %%b in ("%%a") do (
        set CURRENT_RANGE=%%b.%%c.%%d
    )
)

echo Current Network:
echo   SSID: !CURRENT_SSID!
echo   Range: !CURRENT_RANGE!.x
echo.
set /p SAVE_PROFILE="Save as profile? (Y/N): "

if /i "%SAVE_PROFILE%"=="Y" (
    call :add_profile
)

pause
goto :manage_profiles

:test_config
cls
echo ================================================
echo         Testing Configuration
echo ================================================
echo.

call :load_config

echo [1] Testing FTP credentials format...
if not "%FTP_USER%"=="" (
    echo    [OK] Username configured
) else (
    echo    [ERROR] Username not set
)

if not "%FTP_PASS%"=="" (
    echo    [OK] Password configured
) else (
    echo    [WARNING] Password not set
)

echo.
echo [2] Testing MAC address format...
echo %PHONE_MAC% | findstr /r "^[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]-[0-9A-Fa-f][0-9A-Fa-f]$" >nul
if !errorlevel!==0 (
    echo    [OK] MAC address format valid
) else (
    echo    [ERROR] Invalid MAC format
)

echo.
echo [3] Testing network connectivity...
ping -n 1 8.8.8.8 >nul 2>&1
if !errorlevel!==0 (
    echo    [OK] Internet connection available
) else (
    echo    [WARNING] No internet connection
)

echo.
echo [4] Checking for phone in ARP cache...
arp -a | findstr /i "%PHONE_MAC:-=-%" >nul
if !errorlevel!==0 (
    echo    [OK] Phone MAC found in ARP cache
    for /f "tokens=1" %%a in ('arp -a ^| findstr /i "%PHONE_MAC:-=-%"') do (
        echo    IP: %%a
    )
) else (
    echo    [INFO] Phone not in ARP cache
)

echo.
echo [5] Testing PowerShell availability...
powershell -Command "Write-Host '[OK] PowerShell available'" 2>nul
if not !errorlevel!==0 (
    echo    [WARNING] PowerShell not available
)

echo.
pause
goto :main_menu

:save_config
echo.
echo Saving configuration...

(
    echo [FTP]
    echo Username=%FTP_USER%
    echo Password=%FTP_PASS%
    echo Port=%FTP_PORT%
    echo.
    echo [Phone]
    echo MAC=%PHONE_MAC%
    echo Name=%PHONE_NAME%
    echo.
    echo [Network]
    echo HotspotRanges=%HOTSPOT_RANGES%
    echo PCHotspot=%PC_HOTSPOT_RANGE%
    echo Router=%ROUTER_RANGE%
    echo ScanTimeout=%SCAN_TIMEOUT%
    echo CheckInterval=%CHECK_INTERVAL%
    echo MaxHosts=%MAX_HOSTS%
    echo.
    echo [Performance]
    echo UseParallel=%USE_PARALLEL%
    echo UsePowerShell=%USE_POWERSHELL%
    echo UseCache=%USE_CACHE%
) > %CONFIG_FILE%

echo Configuration saved to %CONFIG_FILE%
pause
goto :main_menu

:load_config
:: Set defaults
set FTP_USER=14ag
set FTP_PASS=qwertyui
set FTP_PORT=2121
set PHONE_MAC=64-dd-e9-5c-e3-f3
set PHONE_NAME=MyPhone
set HOTSPOT_RANGES=192.168.43 192.168.49 172.20
set PC_HOTSPOT_RANGE=192.168.137
set ROUTER_RANGE=192.168.100
set SCAN_TIMEOUT=500
set CHECK_INTERVAL=10
set MAX_HOSTS=254
set USE_PARALLEL=Y
set USE_POWERSHELL=Y
set USE_CACHE=Y

:: Load from file if exists
if exist %CONFIG_FILE% (
    for /f "tokens=1,2 delims==" %%a in (%CONFIG_FILE%) do (
        if "%%a"=="Username" set FTP_USER=%%b
        if "%%a"=="Password" set FTP_PASS=%%b
        if "%%a"=="Port" set FTP_PORT=%%b
        if "%%a"=="MAC" set PHONE_MAC=%%b
        if "%%a"=="Name" set PHONE_NAME=%%b
        if "%%a"=="HotspotRanges" set HOTSPOT_RANGES=%%b
        if "%%a"=="PCHotspot" set PC_HOTSPOT_RANGE=%%b
        if "%%a"=="Router" set ROUTER_RANGE=%%b
        if "%%a"=="ScanTimeout" set SCAN_TIMEOUT=%%b
        if "%%a"=="CheckInterval" set CHECK_INTERVAL=%%b
        if "%%a"=="MaxHosts" set MAX_HOSTS=%%b
        if "%%a"=="UseParallel" set USE_PARALLEL=%%b
        if "%%a"=="UsePowerShell" set USE_POWERSHELL=%%b
        if "%%a"=="UseCache" set USE_CACHE=%%b
    )
)
exit /b

:reset_config
echo.
set /p CONFIRM="Reset all settings to defaults? (Y/N): "
if /i "%CONFIRM%"=="Y" (
    if exist %CONFIG_FILE% del %CONFIG_FILE%
    if exist %PROFILES_FILE% del %PROFILES_FILE%
    if exist phone_cache.txt del phone_cache.txt
    echo Configuration reset to defaults!
) else (
    echo Reset cancelled.
)
pause
goto :main_menu

:import_export
cls
echo ================================================
echo         Import/Export Settings
echo ================================================
echo.
echo [1] Export current configuration
echo [2] Import configuration
echo [3] Backup all settings
echo [4] Restore from backup
echo [0] Back
echo.
set /p IE_CHOICE="Select option: "

if "%IE_CHOICE%"=="1" (
    set /p EXPORT_FILE="Export filename [ftp_config_export.txt]: "
    if "!EXPORT_FILE!"=="" set EXPORT_FILE=ftp_config_export.txt
    copy %CONFIG_FILE% !EXPORT_FILE! >nul 2>&1
    echo Configuration exported to !EXPORT_FILE!
    pause
) else if "%IE_CHOICE%"=="2" (
    set /p IMPORT_FILE="Import filename: "
    if exist !IMPORT_FILE! (
        copy !IMPORT_FILE! %CONFIG_FILE% >nul 2>&1
        echo Configuration imported from !IMPORT_FILE!
    ) else (
        echo File not found!
    )
    pause
) else if "%IE_CHOICE%"=="3" (
    set BACKUP_DIR=ftp_backup_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%
    mkdir !BACKUP_DIR! 2>nul
    copy *.ini !BACKUP_DIR!\ >nul 2>&1
    copy *.txt !BACKUP_DIR!\ >nul 2>&1
    echo Backup created in !BACKUP_DIR!
    pause
) else if "%IE_CHOICE%"=="4" (
    echo Available backups:
    dir /b /ad ftp_backup_*
    set /p RESTORE_DIR="Enter backup folder name: "
    if exist !RESTORE_DIR! (
        copy !RESTORE_DIR!\*.* . >nul 2>&1
        echo Restored from !RESTORE_DIR!
    ) else (
        echo Backup not found!
    )
    pause
)

goto :main_menu

:advanced_options
cls
echo ================================================
echo           Advanced Options
echo ================================================
echo.
echo [1] Generate diagnostic report
echo [2] Clear all caches
echo [3] Install Windows features
echo [4] Create scheduled task
echo [5] View connection logs
echo [0] Back
echo.
set /p ADV_CHOICE="Select option: "

if "%ADV_CHOICE%"=="1" (
    call :generate_report
) else if "%ADV_CHOICE%"=="2" (
    del /q phone_cache.txt 2>nul
    del /q temp_alive.txt 2>nul
    del /q device_list.tmp 2>nul
    arp -d * 2>nul
    echo All caches cleared!
    pause
) else if "%ADV_CHOICE%"=="3" (
    echo Installing helpful Windows features...
    echo.
    echo [1] Telnet Client
    dism /online /Enable-Feature /FeatureName:TelnetClient /quiet
    echo [2] Windows Subsystem for Linux (requires restart)
    echo    Run as admin: dism /online /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux
    echo.
    pause
) else if "%ADV_CHOICE%"=="4" (
    echo Creating scheduled task...
    set /p TASK_NAME="Task name [FTP_Phone_Monitor]: "
    if "!TASK_NAME!"=="" set TASK_NAME=FTP_Phone_Monitor
    schtasks /create /tn "!TASK_NAME!" /tr "%CD%\network_monitor.bat" /sc onlogon /ru %USERNAME%
    echo Task created!
    pause
) else if "%ADV_CHOICE%"=="5" (
    if exist ftp_connection_log.txt (
        type ftp_connection_log.txt | more
    ) else (
        echo No logs found.
    )
    pause
)

goto :main_menu

:generate_report
echo Generating diagnostic report...
(
    echo FTP Phone Connection Diagnostic Report
    echo ======================================
    echo Generated: %date% %time%
    echo.
    call :load_config
    echo Configuration:
    echo   FTP: %FTP_USER%@port:%FTP_PORT%
    echo   MAC: %PHONE_MAC%
    echo.
    echo Network Status:
    ipconfig /all
    echo.
    echo ARP Cache:
    arp -a
    echo.
    echo Network Profiles:
    if exist %PROFILES_FILE% type %PROFILES_FILE%
) > diagnostic_report.txt
echo Report saved to diagnostic_report.txt
pause
exit /b

:detect_devices
echo Scanning for devices...
:: Implementation would go here
pause
exit /b

:select_from_arp
echo.
echo Devices in ARP cache:
echo ---------------------
set /a count=0
for /f "tokens=1,2" %%a in ('arp -a ^| findstr /v "Interface" ^| findstr /v "Internet"') do (
    set /a count+=1
    echo [!count!] IP: %%a  MAC: %%b
    set device_!count!=%%b
)
echo.
set /p SELECTION="Select device number: "
set PHONE_MAC=!device_%SELECTION%!
exit /b

endlocal