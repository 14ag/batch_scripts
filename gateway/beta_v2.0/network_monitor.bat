@echo off
:: network_monitor.bat - Background monitor for phone connection
setlocal enabledelayedexpansion
title Phone Network Monitor
mode con: cols=60 lines=20
color 0A

:: Configuration
set PHONE_MAC=64-dd-e9-5c-e3-f3
set CHECK_INTERVAL=10
set NOTIFICATION_SOUND=1
set LOG_FILE=monitor_log.txt
set NOTIFICATION_FILE=phone_detected.flag

:: Initialize
echo ===============================================
echo        Phone Network Monitor v1.0
echo ===============================================
echo.
echo Monitoring for phone: %PHONE_MAC%
echo Check interval: %CHECK_INTERVAL% seconds
echo.
echo Press Ctrl+C to stop monitoring
echo -----------------------------------------------
echo.

:: Clear previous detection flag
if exist %NOTIFICATION_FILE% del %NOTIFICATION_FILE%

:: Monitoring loop
:monitor_loop
set FOUND=0
set PHONE_IP=
set NETWORK_TYPE=

:: Check Method 1: ARP Cache
for /f "tokens=1" %%a in ('arp -a 2^>nul ^| findstr /i "%PHONE_MAC:-=-%"') do (
    set PHONE_IP=%%a
    set FOUND=1
    set NETWORK_TYPE=ARP Cache
)

:: Check Method 2: Gateway (if phone is hotspot)
if !FOUND!==0 (
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /v "::"') do (
        for /f "tokens=1" %%b in ("%%a") do (
            :: Check if gateway is likely phone hotspot
            echo %%b | findstr "192.168.43 192.168.49 172.20" >nul
            if !errorlevel!==0 (
                ping -n 1 -w 500 %%b >nul 2>&1
                if !errorlevel!==0 (
                    set PHONE_IP=%%b
                    set FOUND=1
                    set NETWORK_TYPE=Phone Hotspot
                )
            )
        )
    )
)

:: Check Method 3: Quick scan of likely IPs
if !FOUND!==0 (
    call :quick_network_scan
)

:: Display status
cls
echo ===============================================
echo        Phone Network Monitor v1.0
echo ===============================================
echo.
echo Time: %date% %time%
echo.

if !FOUND!==1 (
    color 0A
    echo [ONLINE] Phone Detected!
    echo.
    echo IP Address: !PHONE_IP!
    echo Network Type: !NETWORK_TYPE!
    echo MAC Address: %PHONE_MAC%
    
    :: Create notification flag
    echo !PHONE_IP! > %NOTIFICATION_FILE%
    
    :: Log detection
    echo %date% %time% - Phone detected at !PHONE_IP! (!NETWORK_TYPE!) >> %LOG_FILE%
    
    :: Sound notification
    if %NOTIFICATION_SOUND%==1 (
        powershell -c "[console]::beep(800,200); [console]::beep(1000,200)"
    )
    
    :: Offer to connect
    echo.
    echo -----------------------------------------------
    echo.
    echo Press [F] to open FTP
    echo Press [C] to continue monitoring
    echo Press [X] to exit
    
    choice /c FCX /t %CHECK_INTERVAL% /d C /n >nul
    
    if !errorlevel!==1 (
        :: Open FTP
        start explorer ftp://14ag:qwertyui@!PHONE_IP!:2121
        echo.
        echo FTP connection opened!
        timeout /t 3 >nul
    ) else if !errorlevel!==3 (
        exit /b
    )
) else (
    color 0E
    echo [SEARCHING] Phone Not Detected
    echo.
    echo Scanning network...
    echo Last check: %time%
    echo.
    echo Checked:
    echo - ARP cache
    echo - Default gateway
    echo - Common IP ranges
    
    :: Remove notification flag if exists
    if exist %NOTIFICATION_FILE% del %NOTIFICATION_FILE%
)

echo.
echo -----------------------------------------------
echo Next check in %CHECK_INTERVAL% seconds...
echo Press Ctrl+C to stop

:: Wait interval
timeout /t %CHECK_INTERVAL% /nobreak >nul 2>&1

goto :monitor_loop

:quick_network_scan
:: Quick scan common device IPs
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=1-3 delims=." %%b in ("%%a") do (
        set NET_PREFIX=%%b.%%c.%%d
        
        :: Check most common phone IPs
        for %%i in (1 2 10 20 23 30 40 50 100) do (
            ping -n 1 -w 100 !NET_PREFIX!.%%i >nul 2>&1
            if !errorlevel!==0 (
                :: Force ARP update
                arp -a !NET_PREFIX!.%%i 2>nul | findstr /i "%PHONE_MAC:-=-%" >nul
                if !errorlevel!==0 (
                    set PHONE_IP=!NET_PREFIX!.%%i
                    set FOUND=1
                    set NETWORK_TYPE=Network Scan
                    exit /b
                )
            )
        )
    )
)
exit /b