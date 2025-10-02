@echo off
:: quick_ftp_launcher.bat - Fast FTP connection with caching
setlocal enabledelayedexpansion
title Quick FTP Phone Launcher

:: Configuration
set FTP_USER=14ag
set FTP_PASS=qwertyui
set FTP_PORT=2121
set PHONE_MAC=64-dd-e9-5c-e3-f3
set CACHE_FILE=phone_cache.txt
set MAX_CACHE_AGE=300

:: Quick launch banner
cls
echo [FTP] Connecting to phone...

:: Method 1: Check cache (fastest)
if exist %CACHE_FILE% (
    :: Get file age in seconds
    for %%F in (%CACHE_FILE%) do set CACHE_TIME=%%~tF
    
    :: Read cached IP
    for /f "tokens=1" %%a in (%CACHE_FILE%) do set CACHED_IP=%%a
    
    :: Quick ping test
    ping -n 1 -w 500 !CACHED_IP! >nul 2>&1
    if !errorlevel!==0 (
        echo [OK] Using cached: !CACHED_IP!
        goto :connect_cached
    )
)

:: Method 2: Check last 10 IPs from history (fast)
if exist ftp_connection_log.txt (
    echo [..] Checking recent connections...
    :: Get last 10 unique IPs from log
    for /f "tokens=6" %%a in ('type ftp_connection_log.txt ^| findstr /i "Connected to"') do (
        ping -n 1 -w 300 %%a >nul 2>&1
        if !errorlevel!==0 (
            echo [OK] Found at previous: %%a
            set PHONE_IP=%%a
            goto :update_cache
        )
    )
)

:: Method 3: Smart scan based on current network
echo [..] Smart scanning...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /v "::"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set GW=%%b
        
        :: Hotspot detection
        echo !GW! | findstr "192.168.43 192.168.49 172.20" >nul
        if !errorlevel!==0 (
            ping -n 1 -w 500 !GW! >nul 2>&1
            if !errorlevel!==0 (
                powershell -Command "$tcp = New-Object System.Net.Sockets.TcpClient; try { $tcp.Connect('!GW!', 2121); $tcp.Close(); exit 0 } catch { exit 1 }" 2>nul
                if !errorlevel!==0 (
                    echo [OK] Phone hotspot: !GW!
                    set PHONE_IP=!GW!
                    goto :update_cache
                )
            )
        )
    )
)

:: Method 4: Quick partial scan
call :quick_scan
if not "!PHONE_IP!"=="" goto :update_cache

:: Method 5: Fall back to main script
echo [!!] Quick methods failed, running full scan...
if exist auto_ftp_connector.bat (
    call auto_ftp_connector.bat
    exit /b
)

echo [ERROR] Phone not found
pause
exit /b 1

:quick_scan
:: Scan most likely IP ranges based on network
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=1-3 delims=." %%b in ("%%a") do (
        set NET=%%b.%%c.%%d
        
        :: Common phone IP ranges (customizable)
        for %%i in (1 2 10 20 23 30 40 50 100 101 102 103) do (
            ping -n 1 -w 200 !NET!.%%i >nul 2>&1
            if !errorlevel!==0 (
                :: Quick MAC check
                arp -a !NET!.%%i 2>nul | findstr /i "%PHONE_MAC:-=-%" >nul
                if !errorlevel!==0 (
                    set PHONE_IP=!NET!.%%i
                    echo [OK] Found phone: !NET!.%%i
                    exit /b
                )
            )
        )
    )
)
exit /b

:update_cache
:: Save IP to cache
echo !PHONE_IP! > %CACHE_FILE%
echo %date% %time% >> %CACHE_FILE%

:connect_cached
if not defined PHONE_IP set PHONE_IP=!CACHED_IP!

:: Open FTP
echo [>>] Opening ftp://%FTP_USER%@%PHONE_IP%:%FTP_PORT%
start explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT%

:: Log connection
echo %date% %time% - Connected to %PHONE_IP% (quick) >> ftp_connection_log.txt

:: Success animation
echo.
echo     [SUCCESS]
timeout /t 1 /nobreak >nul
exit /b 0