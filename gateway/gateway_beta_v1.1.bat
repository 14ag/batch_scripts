@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%a in ('cscript //nologo gateway.vbs') do (
::it is worth noting that we do the ||endlocal & set thing because thats something
:: Specify the IP address to test
	echo %%a >nul | find /i "." || endlocal & set "ip_address=%%a"
		)

:: Specify the port to test
set "port=2121"

:: Test the connection using PowerShell and capture the result
for /f "tokens=*" %%A in ('powershell -Command "Test-NetConnection -ComputerName !ip_address! -Port !port! | Select-String -Pattern 'TcpTestSucceeded' -CaseSensitive"') do (
    set "result=%%A"
)

:: Parse the result and determine the output
if "!result!"=="TcpTestSucceeded : True" (
	explorer ftp://14ag@%ip_address: =%:2121 >nul
) else (
    echo false
	set /p "c=ip adress: 192.168."
	explorer ftp://14ag@192.168.%c: =%:2121 >nul

)

pause

