@echo off
mode con: cols=60 lines=20
REM echo console size test
REM pause
REM exit


:: FTP Configuration
set FTP_USER=14ag
set FTP_PASS=qwertyui
set FTP_PORT=2121
set PHONE_MAC=64-dd-e9-5c-e3-f3
set PHONE_IP=
set NETWORK_TYPE=


call get_gateway
set get_gateway=%get_gateway: =%

::add option to select from multiple gateways returned if wifi and mobile hotspot and ethernet are on
:: modify get_gateway to return all connected gateways in format gatewayName_[IP]
::


:: connect if phone is providing hotspot
::
::


:: connect if pc is providing hotspot
if "%get_gateway:~-1:1%"=="1" (
	call manual_input
	set PHONE_IP=%manual_input%
	)
call connect


:: connect if they both on same router
::
::



:connect
call checkftp %PHONE_IP% %FTP_PORT%
if %errorlevel%==0 (
    explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT% >nul
) else (
	echo ftp server unreachable
	)
exit /b


:checkftp
REM Usage: checkftp.bat <IP_address> <PORT>
set IP=%1
set PORT=%2
(
REM Run PowerShell silently without showing the progress bar
powershell -Command "$ProgressPreference='SilentlyContinue'; if (Test-NetConnection -ComputerName %IP% -Port %PORT% -InformationLevel Quiet -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
) >nul
exit /b %errorlevel%


:selector
:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector "[command that outputs list eg echo a & echo b & echo c]"
echo.
set "selector="
setlocal enabledelayedexpansion
set command=%* >nul
set "i=0"
set "choicelist="
:: Loop through a list, act on each line
for /f "eol=L tokens=1" %%a in ('!command!') do (
	if errorlevel 1 (
		echo Error: Failed to execute command: !command!
		endlocal & exit /b 1
	)
	set /a i+=1
	:: Create dynamic variable names (_1, _2, etc.)
	for %%b in (_!i!) do (
		set "%%b=%%a"
		set "choicelist=!choicelist!!i!"
		echo !i!. %%a
	)   )

call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
exit /b 0



:get_gateway
:: returns ip adress in the var 'get_gateway'
setlocal enabledelayedexpansion
for /f "tokens=*" %%a in ('cscript //nologo gateway.vbs') do (
::it is worth noting that we do the ||endlocal & set thing because thats something
	echo %%a >nul | find /i "." || endlocal & set get_gateway=%%a 
	)
	
	
:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0


:manual_input
set ip=%1
cls
for /L %%a in (1,1,6) do (
	echo.
	)
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%a in ("%ip%") do (
	set network_bits=%%a.%%b.%%c
)
set /p "host_bits=enter the last digits %network_bits%." >nul
set manual_input=%network_bits%.%host_bits%
exit /b