@echo off
:loop
echo.
echo.
echo checkin ..
echo.

call checkftp.bat 192.168.100.23 2121

if %errorlevel%==0 (
    echo FTP is accessible
) else (
    echo FTP is NOT accessible
)
pause
goto loop