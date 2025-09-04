@echo off
setlocal enabledelayedexpansion

set "PHONE_MAC=64-dd-e9-5c-e3-f3"
set "FTP_USER=14ag"
set "FTP_PASS=qwertyui"
set "FTP_PORT=2121"
set "LOG_FILE=log.txt"
set "VBS_INPUT=input_ip.vbs"

echo %DATE% %TIME% - Starting FTP connection script > %LOG_FILE%

set "PHONE_IP="

echo %DATE% %TIME% - Scanning ARP cache for phone with MAC address %PHONE_MAC%... >> %LOG_FILE%

for /f "tokens=1,2" %%a in ('arp -a ^| findstr /i "%PHONE_MAC%"') do (
    set "PHONE_IP=%%a"
)

if defined PHONE_IP (
    goto found_ip
)

echo %DATE% %TIME% - Phone not found in ARP cache. Pinging all devices on connected subnets... >> %LOG_FILE%

for /f "tokens=*" %%a in ('ipconfig ^| findstr /i "IPv4 Address"') do (
    for /f "tokens=2" %%b in ("%%a") do (
        set "ip=%%b"
        for /f "tokens=1-3 delims=." %%c in ("!ip!") do (
            set "subnet=%%c.%%d.%%e"
            echo %DATE% %TIME% - Pinging subnet !subnet!.0/24 >> %LOG_FILE%
            for /l %%i in (1,1,254) do (
                start /b ping -n 1 -w 100 !subnet!.%%i >nul
            )
        )
    )
)

echo %DATE% %TIME% - Waiting for pings to complete... >> %LOG_FILE%
timeout /t 10 /nobreak >nul

echo %DATE% %TIME% - Rescanning ARP cache... >> %LOG_FILE%
for /f "tokens=1,2" %%a in ('arp -a ^| findstr /i "%PHONE_MAC%"') do (
    set "PHONE_IP=%%a"
)

:found_ip
if defined PHONE_IP (
    for /f "tokens=* delims= " %%i in ("%PHONE_IP%") do set PHONE_IP=%%i
    echo %DATE% %TIME% - Phone found at %PHONE_IP%. Connecting to FTP... >> %LOG_FILE%
    explorer "ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT%" >nul
    echo %DATE% %TIME% - FTP connection command issued. >> %LOG_FILE%
    goto :eof
)

echo %DATE% %TIME% - Phone not found automatically. Prompting for manual input. >> %LOG_FILE%

set "gateway_ip="
for /f "tokens=*" %%g in ('cscript //nologo C:\Users\philip\sauce\gateway\gateway.vbs') do (
    if not "%%g"=="" (
        set "gateway_ip=%%g"
    )
)

set "MANUAL_IP="
for /f "tokens=*" %%a in ('cscript //nologo %VBS_INPUT% "Enter the full IP address of the phone" "Manual IP Entry" ""') do (
    set "MANUAL_IP=%%a"
)

if defined MANUAL_IP (
    echo %DATE% %TIME% - Manual IP address entered: %MANUAL_IP%. Connecting to FTP... >> %LOG_FILE%
    explorer "ftp://%FTP_USER%:%FTP_PASS%@%MANUAL_IP%:%FTP_PORT%" >nul
    echo %DATE% %TIME% - Manual FTP connection command issued. >> %LOG_FILE%
) else (
    echo %DATE% %TIME% - No IP address entered. Script finished. >> %LOG_FILE%
)

endlocal