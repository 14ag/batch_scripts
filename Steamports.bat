@echo off
echo Configuring Windows Firewall for Steam ::ote Play & VR Streaming...
echo ---------------------------------------------------------------
echo [NOTE] Run this script as Administrator to avoid permission errors.
echo ---------------------------------------------------------------

:: Check for admin privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: This script requires administrator privileges!
    echo Right-click the file and select "Run as administrator"
    timeout /t 5
    exit /b 1
)

:: ::ote Play Port Rules
echo Adding ::ote Play rules...
netsh advfirewall firewall add rule name="Steam ::ote Play (UDP 27031)" dir=in action=allow protocol=UDP localport=27031
netsh advfirewall firewall add rule name="Steam ::ote Play (UDP 27036)" dir=in action=allow protocol=UDP localport=27036
netsh advfirewall firewall add rule name="Steam ::ote Play (TCP 27036)" dir=in action=allow protocol=TCP localport=27036
netsh advfirewall firewall add rule name="Steam ::ote Play (TCP 27037)" dir=in action=allow protocol=TCP localport=27037

:: VR Streaming Port Rules
echo Adding VR Streaming rules...
netsh advfirewall firewall add rule name="Steam VR Streaming (UDP 10400)" dir=in action=allow protocol=UDP localport=10400
netsh advfirewall firewall add rule name="Steam VR Streaming (UDP 10401)" dir=in action=allow protocol=UDP localport=10401

:: Completion message
echo ---------------------------------------------------------------
echo [SUCCESS] Firewall rules added for:
echo - TCP: 27036, 27037
echo - UDP: 27031, 27036, 10400, 10401
echo ---------------------------------------------------------------
echo Restart Steam if it's already running for changes to take effect
pause
timeout /t 10
