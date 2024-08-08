@echo off
setlocal enabledelayedexpansion

REM Function to retrieve wireless gateway
:FindWirelessGateway
for /f "tokens=1,2* delims=:" %%a in ('ipconfig ^| findstr /i "Wireless LAN adapter Wi-Fi"') do (
    if "%%a %%b"=="Default Gateway" (
        set gateway=%%c
        goto :DisplayGateway
    )
)
goto :NoGatewayFound

REM Function to display the gateway address
:DisplayGateway
echo The gateway of your wireless network connection is: %gateway%

echo %gateway%
pause
goto :eof

REM If no gateway is found
:NoGatewayFound
echo Unable to find the wireless gateway.
goto :eof
