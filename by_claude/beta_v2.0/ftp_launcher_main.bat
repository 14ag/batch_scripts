@echo off
:: FTP_PHONE_LAUNCHER.bat - Main launcher for FTP phone connection
setlocal enabledelayedexpansion
title FTP Phone Connection System
:: color 09

:: Check for first run
if not exist ftp_config.ini (
    echo ================================================
    echo      Welcome to FTP Phone Connection Setup
    echo ================================================
    echo.
    echo This appears to be your first run.
    echo Let's set up your configuration...
    echo.
    pause
    call ftp_config_manager.bat
)

:main_menu
cls
echo ================================================
echo         FTP Phone Connection System
echo ================================================
echo.
echo   Quick Actions:
echo   [1] Connect Now (Smart Detection)
echo   [2] Quick Connect (Use Cache)
echo.
echo   Tools:
echo   [3] Network Monitor (Background)
echo   [4] Configuration Manager
echo   [5] Test Setup
echo.
echo   Advanced:
echo   [6] Full Network Scan
echo   [7] PowerShell Scanner
echo   [8] Manual Connection
echo.
echo   [0] Exit
echo.
echo ================================================
set /p CHOICE="Select option (1-8, 0): "

if "%CHOICE%"=="1" goto :smart_connect
if "%CHOICE%"=="2" goto :quick_connect
if "%CHOICE%"=="3" goto :start_monitor
if "%CHOICE%"=="4" goto :config_manager
if "%CHOICE%"=="5" goto :test_setup
if "%CHOICE%"=="6" goto :full_scan
if "%CHOICE%"=="7" goto :ps_scanner
if "%CHOICE%"=="8" goto :manual_connect
if "%CHOICE%"=="0" goto :exit_app

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :main_menu

:smart_connect
cls
echo ================================================
echo           Smart Connection Mode
echo ================================================
echo.

if exist auto_ftp_connector.bat (
    call auto_ftp_connector.bat
) else (
    echo ERROR: auto_ftp_connector.bat not found!
    echo Please ensure all scripts are in the same directory.
    pause
)
goto :check_continue

:quick_connect
cls
echo ================================================
echo           Quick Connect (Cache)
echo ================================================
echo.

if exist quick_ftp_launcher.bat (
    call quick_ftp_launcher.bat
) else (
    echo Creating quick launcher...
    call :create_quick_launcher
)
goto :check_continue

:start_monitor
cls
echo ================================================
echo         Starting Network Monitor
echo ================================================
echo.
echo The monitor will run in a new window.
echo It will notify you when your phone connects.
echo.

if exist network_monitor.bat (
    start "Phone Network Monitor" network_monitor.bat
    echo Monitor started successfully!
) else (
    echo ERROR: network_monitor.bat not found!
)

pause
goto :main_menu

:config_manager
if exist ftp_config_manager.bat (
    call ftp_config_manager.bat
) else (
    echo ERROR: Configuration manager not found!
    pause
)
goto :main_menu

:test_setup
cls
echo ================================================
echo           Testing FTP Setup
echo ================================================
echo.

if exist test_ftp_setup.bat (
    call test_ftp_setup.bat
) else (
    echo Running basic tests...
    call :basic_test
)
goto :check_continue

:full_scan
cls
echo ================================================
echo           Full Network Scan
echo ================================================
echo.
echo This will thoroughly scan all network ranges.
echo It may take 1-2 minutes to complete.
echo.
set /p CONFIRM="Continue with full scan? (Y/N): "

if /i "%CONFIRM%"=="Y" (
    echo.
    echo Scanning all networks...
    
    :: Method 1: Check all possible networks
    for %%n in (192.168.43 192.168.49 172.20 192.168.137 192.168.100 192.168.1 192.168.0 10.0.0) do (
        echo Scanning %%n.x ...
        call :scan_network %%n
        if not "!PHONE_IP!"=="" goto :found_phone
    )
    
    echo.
    echo Phone not found on any network.
    pause
)
goto :main_menu

:ps_scanner
cls
echo ================================================
echo        PowerShell Network Scanner
echo ================================================
echo.

:: Check PowerShell availability
powershell -Command "Write-Host 'PowerShell is available'" 2>nul
if !errorlevel! NEQ 0 (
    echo ERROR: PowerShell is not available or restricted.
    echo.
    echo To enable PowerShell, run as Administrator:
    echo   powershell Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    pause
    goto :main_menu
)

if exist network_scanner.ps1 (
    echo Starting PowerShell scanner...
    powershell -ExecutionPolicy Bypass -File network_scanner.ps1 scan
    pause
) else (
    echo ERROR: network_scanner.ps1 not found!
    pause
)
goto :main_menu

:manual_connect
cls
echo ================================================
echo          Manual Connection
echo ================================================
echo.
echo Enter connection details:
echo.

set /p MANUAL_IP="Phone IP Address: "
set /p MANUAL_USER="FTP Username [14ag]: "
set /p MANUAL_PASS="FTP Password: "
set /p MANUAL_PORT="FTP Port [2121]: "

if "%MANUAL_USER%"=="" set MANUAL_USER=14ag
if "%MANUAL_PORT%"=="" set MANUAL_PORT=2121

echo.
echo Connecting to ftp://%MANUAL_USER%@%MANUAL_IP%:%MANUAL_PORT%
start explorer ftp://%MANUAL_USER%:%MANUAL_PASS%@%MANUAL_IP%:%MANUAL_PORT%

pause
goto :main_menu

:check_continue
echo.
echo ================================================
echo.
echo [1] Return to menu
echo [2] Try another method
echo [3] Exit
echo.
set /p NEXT="Select option: "

if "%NEXT%"=="1" goto :main_menu
if "%NEXT%"=="2" goto :main_menu
if "%NEXT%"=="3" goto :exit_app

goto :main_menu

:exit_app
cls
echo ================================================
echo         Thank you for using
echo      FTP Phone Connection System
echo ================================================
echo.

:: Check if monitor is running
tasklist | findstr /i "network_monitor" >nul
if !errorlevel!==0 (
    echo Network monitor is still running.
    set /p STOP_MONITOR="Stop monitor? (Y/N): "
    if /i "!STOP_MONITOR!"=="Y" (
        taskkill /fi "WINDOWTITLE eq Phone Network Monitor*" /f >nul 2>&1
    )
)

echo Goodbye!
timeout /t 2 >nul
exit /b

:: ============== Helper Functions ==============

:scan_network
set NET=%1
set PHONE_IP=

for /l %%i in (1,1,254) do (
    ping -n 1 -w 100 %NET%.%%i >nul 2>&1
    if !errorlevel!==0 (
        :: Check MAC
        arp -a %NET%.%%i 2>nul | findstr /i "64-dd-e9-5c-e3-f3" >nul
        if !errorlevel!==0 (
            set PHONE_IP=%NET%.%%i
            exit /b
        )
    )
)
exit /b

:found_phone
echo.
echo ================================================
echo            Phone Found!
echo ================================================
echo IP Address: !PHONE_IP!
echo.
echo Opening FTP connection...
start explorer ftp://14ag:qwertyui@!PHONE_IP!:2121
pause
goto :main_menu

:basic_test
echo Running basic connectivity tests...
echo.

echo [1] Network adapters:
ipconfig | findstr /i "IPv4" && echo    [OK] Network connected || echo    [FAIL] No network

echo.
echo [2] Gateway detection:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /v "::"') do (
    echo    Gateway: %%a
)

echo.
echo [3] ARP cache check:
arp -a | findstr /i "64-dd-e9" >nul && echo    [OK] Phone MAC in cache || echo    [INFO] Phone not in cache

echo.
echo [4] Script files:
if exist auto_ftp_connector.bat echo    [OK] Main script present
if exist network_helper.vbs echo    [OK] VBS helper present
if exist network_scanner.ps1 echo    [OK] PS scanner present

echo.
pause
exit /b

:create_quick_launcher
:: Create a minimal quick launcher if it doesn't exist
(
echo @echo off
echo set PHONE_IP=
echo if exist phone_cache.txt for /f %%a in (phone_cache.txt^) do set PHONE_IP=%%a
echo if defined PHONE_IP (
echo     ping -n 1 -w 500 %%PHONE_IP%% ^>nul 2^>^&1
echo     if %%errorlevel%%==0 (
echo         start explorer ftp://14ag:qwertyui@%%PHONE_IP%%:2121
echo         echo Connected to cached IP: %%PHONE_IP%%
echo     ^) else (
echo         echo Cached IP not responding
echo         call auto_ftp_connector.bat
echo     ^)
echo ^) else (
echo     call auto_ftp_connector.bat
echo ^)
echo pause
) > quick_ftp_launcher.bat

call quick_ftp_launcher.bat
exit /b

endlocal