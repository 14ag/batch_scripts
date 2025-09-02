@echo off
setlocal enabledelayedexpansion
title Automated FTP Phone Connector
color 0A

:: FTP Configuration
set FTP_USER=14ag
set FTP_PASS=qwertyui
set FTP_PORT=2121
set PHONE_MAC=64-dd-e9-5c-e3-f3
set PHONE_IP=
set NETWORK_TYPE=

echo ===============================================
echo     Automated FTP Phone Connection Script
echo ===============================================
echo.

:: Method 1: Check phone's hotspot (gateway method - least intensive)
echo [1/3] Checking if connected to phone's hotspot...
call :check_gateway
if not "!PHONE_IP!"=="" goto :connect_ftp

:: Method 2: Check PC's hotspot (192.168.137.x network)
echo [2/3] Checking PC's hotspot network (192.168.137.x)...
call :check_pc_hotspot
if not "!PHONE_IP!"=="" goto :connect_ftp

:: Method 3: Check router network (192.168.100.x)
echo [3/3] Checking router network (192.168.100.x)...
call :check_router_network
if not "!PHONE_IP!"=="" goto :connect_ftp

:: Method 4: Manual selection with device list
echo.
echo Unable to automatically detect phone. Scanning for devices...
call :manual_device_selection
if not "!PHONE_IP!"=="" goto :connect_ftp

:: Method 5: Last resort - manual IP input
echo.
call :manual_ip_input
if not "!PHONE_IP!"=="" goto :connect_ftp

:: If all methods fail
echo.
echo ERROR: Unable to establish connection to phone's FTP server.
call :write_error_report
pause
exit /b 1

:: =================== FUNCTIONS ===================

:check_gateway
:: Use existing gateway.vbs method if available
if exist gateway.vbs (
    for /f "tokens=*" %%a in ('cscript //nologo gateway.vbs 2^>nul') do (
        echo %%a | find /i "." >nul && (
            set PHONE_IP=%%a
            set NETWORK_TYPE=Phone Hotspot
            echo    [+] Phone detected on hotspot: !PHONE_IP!
        )
    )
) else (
    :: Alternative method using ipconfig
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /v "::"') do (
        for /f "tokens=1" %%b in ("%%a") do (
            :: Check if this is likely a mobile hotspot (common ranges)
            echo %%b | findstr /r "^192\.168\.43\. ^192\.168\.49\. ^172\." >nul && (
                ping -n 1 -w 500 %%b >nul 2>&1
                if !errorlevel!==0 (
                    set PHONE_IP=%%b
                    set NETWORK_TYPE=Phone Hotspot
                    echo    [+] Possible phone hotspot detected: %%b
                )
            )
        )
    )
)
exit /b

:check_pc_hotspot
:: Check if PC's mobile hotspot is active
netsh wlan show hostednetwork | findstr /i "Status.*:.*Started" >nul 2>&1
if !errorlevel!==0 (
    echo    PC hotspot is active. Scanning 192.168.137.x network...
    call :scan_network 192.168.137 2 254
) else (
    :: Check Windows 10/11 mobile hotspot
    netsh interface show interface | findstr /i "Local Area Connection.*Connected" >nul 2>&1
    if !errorlevel!==0 (
        echo    PC hotspot detected. Scanning...
        call :scan_network 192.168.137 2 254
    )
)
exit /b

:check_router_network
:: Check if we're on 192.168.100.x network
ipconfig | findstr /i "192.168.100" >nul 2>&1
if !errorlevel!==0 (
    echo    Connected to router network. Scanning...
    call :scan_network 192.168.100 1 254
)
exit /b

:scan_network
:: Parameters: %1=network prefix, %2=start host, %3=end host
set NET_PREFIX=%1
set START_HOST=%2
set END_HOST=%3
set FOUND_DEVICES=0

echo    Scanning %NET_PREFIX%.x network for phone (MAC: %PHONE_MAC%)...

:: First, try ARP cache
arp -a | findstr /i "%PHONE_MAC:-=-%" >nul 2>&1
if !errorlevel!==0 (
    for /f "tokens=1" %%a in ('arp -a ^| findstr /i "%PHONE_MAC:-=-%"') do (
        set PHONE_IP=%%a
        set NETWORK_TYPE=%NET_PREFIX% Network
        echo    [+] Phone found in ARP cache: %%a
        exit /b
    )
)

:: Quick ping scan (parallel processing for speed)
echo    Quick scan in progress...
for /l %%i in (%START_HOST%,1,%END_HOST%) do (
    start /b cmd /c "ping -n 1 -w 200 %NET_PREFIX%.%%i >nul 2>&1 && echo %NET_PREFIX%.%%i>>temp_alive.txt"
)

:: Wait for pings to complete
timeout /t 3 /nobreak >nul

:: Check alive hosts for our MAC
if exist temp_alive.txt (
    for /f %%a in (temp_alive.txt) do (
        :: Force ARP update
        ping -n 1 %%a >nul 2>&1
        arp -a %%a 2>nul | findstr /i "%PHONE_MAC:-=-%" >nul && (
            set PHONE_IP=%%a
            set NETWORK_TYPE=%NET_PREFIX% Network
            echo    [+] Phone found: %%a
            del temp_alive.txt 2>nul
            exit /b
        )
    )
    del temp_alive.txt 2>nul
)
exit /b

:manual_device_selection
echo.
echo ===============================================
echo         Manual Device Selection
echo ===============================================

:: Detect current network
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr "192.168"') do (
    for /f "tokens=1-3 delims=." %%b in ("%%a") do (
        set CURRENT_NET=%%b.%%c.%%d
    )
)

if not defined CURRENT_NET (
    echo No suitable network detected.
    exit /b
)

echo Scanning %CURRENT_NET%.x network for active devices...
echo.

:: Collect active devices
set DEVICE_COUNT=0
if exist device_list.tmp del device_list.tmp

for /l %%i in (1,1,254) do (
    ping -n 1 -w 200 %CURRENT_NET%.%%i >nul 2>&1
    if !errorlevel!==0 (
        set /a DEVICE_COUNT+=1
        echo !DEVICE_COUNT!: %CURRENT_NET%.%%i >> device_list.tmp
        echo    [!DEVICE_COUNT!] %CURRENT_NET%.%%i
        
        :: Try to get hostname
        for /f "skip=3 tokens=1" %%h in ('nslookup %CURRENT_NET%.%%i 2^>nul') do (
            echo         Hostname: %%h
        )
    )
)

if !DEVICE_COUNT!==0 (
    echo No devices found on network.
    if exist device_list.tmp del device_list.tmp
    exit /b
)

echo.
echo ===============================================
set /p DEVICE_CHOICE="Select device number (1-%DEVICE_COUNT%) or 0 to skip: "

if "%DEVICE_CHOICE%"=="0" (
    if exist device_list.tmp del device_list.tmp
    exit /b
)

:: Validate choice
if %DEVICE_CHOICE% GTR 0 if %DEVICE_CHOICE% LEQ %DEVICE_COUNT% (
    for /f "tokens=2" %%a in ('findstr "^%DEVICE_CHOICE%:" device_list.tmp') do (
        set PHONE_IP=%%a
        set NETWORK_TYPE=Manual Selection
        echo    [+] Selected: %%a
    )
)

if exist device_list.tmp del device_list.tmp
exit /b

:manual_ip_input
echo.
echo ===============================================
echo         Manual IP Input (Last Resort)
echo ===============================================
echo.
echo Select network type:
echo   [1] PC's Hotspot (192.168.137.x)
echo   [2] Router Network (192.168.100.x)
echo   [3] Other/Custom
echo.

set /p NET_CHOICE="Enter choice (1-3): "

if "%NET_CHOICE%"=="1" (
    set IP_PREFIX=192.168.137
) else if "%NET_CHOICE%"=="2" (
    set IP_PREFIX=192.168.100
) else if "%NET_CHOICE%"=="3" (
    set /p IP_PREFIX="Enter network prefix (e.g., 192.168.1): "
) else (
    echo Invalid choice.
    exit /b
)

echo.
set /p HOST_OCTET="Enter last octet of phone IP (1-254): "

:: Validate input
if %HOST_OCTET% GTR 0 if %HOST_OCTET% LEQ 254 (
    set PHONE_IP=%IP_PREFIX%.%HOST_OCTET%
    set NETWORK_TYPE=Manual Input
    
    :: Test connection
    echo Testing connection to %PHONE_IP%...
    ping -n 1 -w 1000 %PHONE_IP% >nul 2>&1
    if !errorlevel!==0 (
        echo    [+] Device responds at %PHONE_IP%
    ) else (
        echo    [!] Warning: Device not responding at %PHONE_IP%
        set /p CONTINUE="Continue anyway? (Y/N): "
        if /i not "!CONTINUE!"=="Y" set PHONE_IP=
    )
) else (
    echo Invalid octet value.
)
exit /b

:connect_ftp
echo.
echo ===============================================
echo         Connecting to FTP Server
echo ===============================================
echo.
echo Network Type: %NETWORK_TYPE%
echo Phone IP: %PHONE_IP%
echo FTP URL: ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT%
echo.
echo Opening FTP connection...

:: Open FTP in Windows Explorer
start explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT%

:: Log successful connection
echo %date% %time% - Connected to %PHONE_IP% via %NETWORK_TYPE% >> ftp_connection_log.txt

echo.
echo [SUCCESS] FTP connection initiated!
echo.
pause
exit /b 0

:write_error_report
echo Writing error report...

exit /b

endlocal