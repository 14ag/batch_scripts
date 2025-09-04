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


:method_1
:: detect phone ip from arp table using mac address
call :detect_macAdress %PHONE_MAC%
if defined detect_macAdress (
	set PHONE_IP=%detect_macAdress%
	(
	call :checkftp %PHONE_IP% %FTP_PORT%
	) && ( 
		goto :connect 
	) || ( 
		echo ftp server unreachable
		pause
	)
)


:method_2
:: search ip in the local subnet by pinging all possible ips
call :get_gateways
if defined get_gateways (

	for %%a in (%get_gateways%) do (

        for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
            echo %%b %%c
			call :network_bits %%c

			if defined network_bits (
				call :ipSearch %network_bits%

				if defined ipSearch (
					set PHONE_IP=%ipSearch%
					(
					call :checkftp %PHONE_IP% %FTP_PORT%
					) && ( 
						goto :connect 
					) || ( 
						echo ftp server unreachable 
					)
				)
            )
        )
    )
)




:method_3
:: method 3 - manual input of phone ip address
set "count=0"
call :get_gateways
if defined get_gateways (
	for %%a in (%get_gateways%) do (
		set count+=1
	)
	if %count% gtr 1 (
		call :selector echo %get_gateways%
	)
	for %%a in (%get_gateways%) do (
		for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
            echo %%b %%c
		)
	)
)
cls
for /L %%a in (1,1,6) do ( echo.)
set /p "host_bits=enter the last digits %network_bits%." >nul
set manual_input=%network_bits%.%host_bits%
exit /b



:connect
explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT% >nul
goto :eof
exit /b



















:checkftp
:: Usage: checkftp.bat <IP_address> <PORT>
set IP=%1
set PORT=%2
(
:: Run PowerShell silently without showing the progress bar
powershell -Command "$ProgressPreference='SilentlyContinue'; if (Test-NetConnection -ComputerName %IP% -Port %PORT% -InformationLevel Quiet -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
) >nul
exit /b %errorlevel%


:selector
:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector arg1,arg2,arg3,...
setlocal enabledelayedexpansion
set "selector="
set "arg_string=%*"
set "i=0"
set "choicelist="
:: Replace every comma with a quote, a space, and another quote (" ") and Wrap the entire resulting string in quotes
set "arg_list="%arg_string:,=" "%""
echo Processing arguments:
rem Loop through the new quoted, space-separated list
for %%a in (%arg_list%) do (
	set /a i+=1
	:: Create dynamic variable names (_1, _2, etc.)
	for %%b in (_!i!) do (
		set "%%b=%%a"
		set "choicelist=!choicelist!!i!"
        set "display_value=%%a"
        set "display_value=!display_value:"=!"
		echo   [!i!].. !display_value!
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
set "selector=%selector:"=%"
exit /b 0



:get_gateways
for /f "delims=" %%G in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateways=%%G"
exit /b
	

:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0


:network_bits
set ip=%1
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%a in ("%ip%") do (
	set network_bits=%%a.%%b.%%c
)
exit /b


:detect_macAdress
:: Usage: detect_macAdress <MAC_address>
set "macAddress=%1"
(
arp -a | find /i "%macAddress%" >nul
) && (
	:: found
	for /f "tokens=1" %%a in ('arp -a ^| find /i "%macAddress%"') do (
		set "detect_macAdress=%%a"
		)
	) || (
	:: phone not found in arp table
	set "detect_macAdress="
	)
call reset_choice
exit /b


:ipSearch
:: Usage: ipSearch gatewayIP
set "gatewayIP=%1"
for /L %%a in (1,1,254) do (
	echo. >nul
	(
	ping -n 1 -w 10 192.168.1.%%a | find "TTL="
	) && (
	:: if ping successful
	set "ipSearch=192.168.1.%%a"
	(
		call :checkftp %ipSearch% %PORT%
		) && (
		:: ftp server reachable
		exit /b 0
		)
	)
)
set "ipSearch="
exit /b 1