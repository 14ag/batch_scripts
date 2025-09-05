@echo off
mode con: cols=60 lines=20
title FTP 

:: FTP Configuration
set FTP_USER=14ag
set FTP_PASS=qwertyui
set FTP_PORT=2121
set PHONE_MAC=64-dd-e9-5c-e3-f3
set PHONE_IP=
set NETWORK_TYPE=
set "debug=1"
goto :connect0
call :debug script started
call :debug initial parameters: FTP_USER=%FTP_USER% FTP_PASS=%FTP_PASS% FTP_PORT=%FTP_PORT% PHONE_MAC=%PHONE_MAC%

if not defined PHONE_MAC echo setup PHONE_MAC for fast connection & goto method_2

:method_1
:: detect phone ip from arp table using mac address
if not defined macAddress_lookup (
	call :debug searching ARP table for MAC address %PHONE_MAC%
	call :macAddress_lookup %PHONE_MAC%
)
call :debug result of MAC address detection: %macAddress_lookup%

set PHONE_IP=%macAddress_lookup%

call :debug attempting to connect with ip %PHONE_IP%

call :connect 

call :debug method 1 complete
pause >nul



:method_2
:: search ip in the local subnet by pinging all possible ips

call :debug starting method 2 -ip scan

if not defined get_gateways (

	call :debug fetching gateways

	call :get_gateways

	call :debug detected gateways: %get_gateways%

)
call :debug gateways to scan: %get_gateways%

setlocal enabledelayedexpansion
for %%a in (%get_gateways%) do (

	for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
		echo %%b %%c

		call :debug scanning network type %%b with gateway %%c

		call :network_bits %%c

		call :debug network bits: %network_bits%

		if defined network_bits (

			for /L %%d in (1,1,254) do (
				echo. >nul
				(
				ping -n 1 -w 10 %network_bits%.%%d | find "TTL=" >nul
				) && (
				:: if ping successful
				call :debug ping successful for %network_bits%.%%d
				set "PHONE_IP=%network_bits%.%%d"
				call :connect
				) || (
				:: if ping failed
				call :debug ping failed for %network_bits%.%%d

			)
		)
	)
)

call :debug method 2 complete, moving to method 3 if needed



:method_3
:: method 3 - manual input of phone ip address
call :debug starting method 3 - manual input
set "count=0"
if not defined get_gateways (
	call :get_gateways
)

rem Count gateways properly using arithmetic expansion
for %%a in (%get_gateways%) do (
	set /a count+=1
)
call :debug gateway count: %count%

if %count% gtr 1 (
	call :debug multiple gateways found, prompting user for selection
	set "x="
	for %%a in (%get_gateways%) do (
		for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
			set x=%%b %%c,%x%
		)
	)

call :selector %x%
for /f "tokens=1-2 delims= " %%a in ("%selector%") do (
	set NETWORK_TYPE=%%a
	set get_gateways=%%b
	)
	call :debug user selected NETWORK_TYPE=%NETWORK_TYPE% and gateway=%get_gateways%
)

call :network_bits %get_gateways% 


cls
for /L %%a in (1,1,6) do ( echo.)
set /p "host_bits=enter the last digits %network_bits%."
call :debug user entered host_bits: %host_bits%
set PHONE_IP=%network_bits%.%host_bits%
call :debug constructed PHONE_IP: %PHONE_IP%
call :connect
if errorlevel 1 (
	echo failed to connect to %PHONE_IP%
	call :debug connection failed for %PHONE_IP%, restarting method 3
	echo please check the ip address and try again
	pause
	goto :method_3
	exit /b 1
)

:: connection debug
:connect0
set PHONE_IP=192.168.100.23
set FTP_PORT=2121
(
ping -n 1 -w 10 %PHONE_IP% | find "TTL=" >nul
) && (
	echo ping successful 
	call :connect
)
echo end of test & pause
goto :connect0


:connect
:: (search) && ((found) && (killed) || (unkilled)) || (unfound)
( 
	call :checkftp %PHONE_IP% %FTP_PORT% 
	) && ( 
		::ftp server found
		@REM explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT% >nul
		echo connection successful on %PHONE_IP% & exit /b 0
		 ) || ( 
			::ftp server not found
			echo not found on %PHONE_IP% & exit /b 1 
			)


:checkftp
:: Usage: checkftp <IP_address> <PORT>
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
for /L %%a in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%a (
    for %%b in (!_%%a!) do (
            endlocal & set "selector=%%b"
            goto :break
    )   )   )
:break
set "selector=%selector:"=%"
exit /b 0



:get_gateways
call :debug entering :get_gateways
set "get_gateways="
for /f "delims=" %%a in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateways=%%a" >nul
call :debug :get_gateways result: %get_gateways%
exit /b
	

:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0


:network_bits
:: Usage: network_bits <IP_address>
call :debug entering :network_bits with IP: %1
set "network_bits="
set "ip=%1"
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%a in ("%ip%") do (
	set network_bits=%%a.%%b.%%c
)
call :debug :network_bits result: %network_bits%
exit /b


:macAddress_lookup
:: Usage: macAddress_lookup <MAC_address>
set "macAddress="
set "macAddress=%1"
(
arp -a | find /i "%macAddress%" >nul
) && (
	:: found
	for /f "tokens=1" %%a in ('arp -a ^| find /i "%macAddress%"') do (
		set "macAddress_lookup=%%a"
		)
	) || (
	:: phone not found in arp table
	set "macAddress_lookup="
	)
exit /b

:debug
if not defined debug exit /b
if not defined new set "new=1" & echo. > debug.log
set "log=%*"
setlocal enabledelayedexpansion
(
for /f "tokens=1-2 delims= " %%a in ('time /t') do (
	for /f "tokens=1-2 delims=:" %%b in ("%time%") do (
		set "hour=%%b"
		set "minute=%%c"
		set "second=!time:~6,2!"
	)
	echo [!hour!:!minute!:!second!] : %log%
)) >> debug.log
endlocal
exit /b


:error
exit /b 1


:EOF