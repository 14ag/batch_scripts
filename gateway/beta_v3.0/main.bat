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
set debug=1

call :debug script started
call :debug initial parameters: FTP_USER=%FTP_USER% FTP_PASS=%FTP_PASS% FTP_PORT=%FTP_PORT% PHONE_MAC=%PHONE_MAC%
call :debug fetching gateways

call :get_gateways

call :debug detected gateways: %get_gateways%
call :debug starting connection methods


:method_1
:: detect phone ip from arp table using mac address

call :debug attempting to detect phone IP from MAC address %PHONE_MAC%
call :debug searching ARP table for MAC address %PHONE_MAC%


call :detect_macAdress %PHONE_MAC%


call :debug result of MAC address detection: %detect_macAdress%
if defined detect_macAdress (
	set PHONE_IP=%detect_macAdress%

	call :debug result of PHONE_IP: %PHONE_IP%
	call :debug attempting to connect to PHONE_IP %PHONE_IP%

	call :connect 
)

call :debug method 1 complete, moving to method 2 if needed

:method_2
:: search ip in the local subnet by pinging all possible ips

call :debug starting method 2 - subnet scan

if not defined get_gateways (
	call :get_gateways
)
call :debug gateways to scan: %get_gateways%

for %%g in (%get_gateways%) do (

	for /f "tokens=1-2 delims=_" %%b in ("%%g") do (
		echo %%b %%c

		call :debug scanning network type %%b with gateway %%c

		call :network_bits %%c

		call :debug network bits: %network_bits%

		if defined network_bits (

			rem inner numeric loop variable renamed to %%h to avoid reuse of outer variables
			for /L %%h in (1,1,254) do (
				echo. >nul
				(
				ping -n 1 -w 10 %network_bits%.%%h | find "TTL=" >nul
				) && (
				:: if ping successful
				call :debug ping successful for %network_bits%.%%h
				set "PHONE_IP=%network_bits%.%%h"
				call :connect
				)
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


:connect
call :debug entering :connect with PHONE_IP=%PHONE_IP%
(
call :checkftp %PHONE_IP% %FTP_PORT%
) && ( 
	call :debug checkftp successful for %PHONE_IP%:%FTP_PORT%. Opening explorer.
	explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT% >nul
	exit
) || ( 
	call :debug checkftp failed for %PHONE_IP%:%FTP_PORT%.
	echo ftp server not found
)
exit /b 1





:checkftp
:: Usage: checkftp <IP_address> <PORT>
set IP=%1
set PORT=%2
call :debug entering :checkftp with IP=%IP% PORT=%PORT%
(
:: Run PowerShell silently without showing the progress bar
powershell -Command "$ProgressPreference='SilentlyContinue'; if (Test-NetConnection -ComputerName %IP% -Port %PORT% -InformationLevel Quiet -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
) >nul
call :debug :checkftp result for %IP%:%PORT% is %errorlevel%
exit /b %errorlevel%


:selector
:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector arg1,arg2,arg3,...
setlocal enabledelayedexpansion
call :debug entering :selector with args: %*
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
call :debug :selector result: %selector%
exit /b 0



:get_gateways
call :debug entering :get_gateways
set "get_gateways="
for /f "delims=" %%G in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateways=%%G" >nul
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


:detect_macAdress
:: Usage: detect_macAdress <MAC_address>
call :debug entering :detect_macAdress with MAC: %1
set "macAddress="
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
call :debug :detect_macAdress result: %detect_macAdress%
call :reset_choice
exit /b

:debug
if not defined debug exit /b
set "log=%*"
(
echo [DEBUG] : %log%
) >> debug.log
exit /b