@echo off
set "lines=20"
mode con: cols=60 lines=%lines%
title FTP 

:: FTP Configuration
set PHONE_IP=
set NETWORK_TYPE=
set LOGPATH=%userprofile%\desktop\
set "INI=%USERPROFILE%\Desktop\ftp_settings.ini"


setlocal EnableDelayedExpansion
:: Path to INI on Desktop 
:create
if not exist "%INI%" (
    echo creating config file on your desktop...
    (
      echo FTP_USER=
      echo FTP_PASS=
      echo FTP_PORT=
      echo PHONE_MAC=
      echo debug= 
    ) > %INI%
    echo config file created. Press any key to open it for editing.
    pause >nul
    start notepad.exe %INI%
    echo.
    echo Please edit and save the config file, then press any key to continue.
    pause >nul
)

for /f "usebackq delims=" %%A in ("%INI%") do (
  set "line=%%A"

  for /f "tokens=* delims= " %%B in ("!line!") do set "line=%%B"

  if defined line (
    set "firstChar=!line:~0,1!"

    if NOT "!firstChar!"==";" if NOT "!firstChar!"=="#" (

      echo "!line!" | findstr /c:"=" >nul
      if not errorlevel 1 (

        for /f "tokens=1* delims==" %%K in ("!line!") do (
          set "value=%%L"
          for /f "tokens=* delims=" %%Y in ("!value!") do set "value=%%Y"
          
		  set "key=%%K"
          for /f "tokens=* delims= " %%X in ("!key!") do set "key=%%X"
          set "keys=!keys! !key!"
          set !key!=!value!
    
        )
      )
    )
  )
)
for %%a in (!keys:~1!) do (
  set "x=!x! & set %%a=!%%a!"
  )

set "x=%x:~3%"
endlocal & %x%



call :debug initial parameters: FTP_USER=%FTP_USER% FTP_PASS=%FTP_PASS% FTP_PORT=%FTP_PORT% PHONE_MAC=%PHONE_MAC%


goto :method_1




:method_1
call :formatting 8
echo detecting phone ip ...this won't take long
:: detecting phone ip from arp table using mac address
if not defined PHONE_MAC echo setup PHONE_MAC for fast connection & goto method_2
set "macAddress_lookup="
if not defined macAddress_lookup (
	call :debug searching ARP table for MAC address %PHONE_MAC%
	call :macAddress_lookup %PHONE_MAC%
)
call :debug result of MAC address detection: %macAddress_lookup%

if not defined macAddress_lookup (
	echo arp lookup failed, attempting slow search
	goto :method_2
)

call :debug result of MAC address detection: %macAddress_lookup%

set PHONE_IP=%macAddress_lookup%

call :debug attempting to connect with ip %PHONE_IP%
(
call :connect && goto :eof
) || (
	echo quick connect failed , retrying...
	if defined method_1 goto :method_2
	netsh interface ip delete arpcache
	set "method_1=1"
	call :debug could not connect with method 1,
	goto :method_1
)

call :debug end of method 1



:method_2
set "PHONE_IP="
:: search ip in the local subnet by pinging all possible ips
set method_2=1
call :debug starting ip scan method

call :debug fetching gateways

call :get_gateways

call :debug detected gateways: %get_gateways%

set "count=0"
for %%a in (%get_gateways%) do (
	set /a count+=1
)

call :debug gateways to scan: %get_gateways%

echo  please wait...

for %%a in (%get_gateways%) do (
	for /f "tokens=1-2 delims=_" %%b in ("%%a") do (

		call :debug scanning network type %%b with gateway %%c

		echo scanning the %%b gateway for ftp servers

		call :debug attempting connection with ip %%c

		(
		call :connect %%c && goto :eof
		) || (
			call :debug no ftp servers could be found on %%c
		)
	)
)

setlocal enabledelayedexpansion
set /a i=0
for %%a in (%get_gateways%) do (
	set /a i+=1
	for /f "tokens=1-2 delims=_" %%b in ("%%a") do (

		call :debug scanning network type %%b with gateway %%c

		echo scanning the %%b network for ftp servers

		call :network_bits %%c

		call :debug network bits: !network_bits!
		
		for /L %%d in (1,1,254) do (
			if !network_bits!.%%d neq %%c (
				
				echo. >nul
				(
				ping -n 1 -w 10 !network_bits!.%%d | find "TTL=" >nul
				) && (
				:: if ping successful
				call :debug ping successful for !network_bits!.%%d
				set "PHONE_IP=!network_bits!.%%d"
				call :connect && goto :eof
				) || (
					:: if ping failed
					call :debug ping failed for !network_bits!.%%d
					if "!i!"=="%count%" (
						:: last network, so if we reach here with d=254 then no ftp servers found
						if %%d equ 254 (
							call :debug end of method 2, search failed
							call :method_2a no ftp servers could be found.						
						)
					)
				)
			) else (
				call :debug skipping %%c
			)
		)
	)
)
:method_2a
set "method_2="
call :formatting 5
echo %*
call :selector try again,manual input,exit
if /i "%selector%"=="exit" goto :eof
if /i "%selector%"=="manual input" goto :method_3
if /i "%selector%"=="try again" goto :method_1
goto :menu



:method_3
set "PHONE_IP="
:: method 3 - manual input of phone host bits
setlocal enabledelayedexpansion
call :debug starting method 3 quick manual input

call :formatting 6

echo switching to manual input mode.
echo.

call :get_gateways

call :debug gateways found "%get_gateways%"

REM set "get_gateways=wifi_192.168.600.1 lan_192.168.900.1"

set /a "count=0"
for %%a in (%get_gateways%) do (
	set /a count+=1
)

if %count% gtr 1 (
	call :debug multiple gateways found, prompting user for selection
	set "x="
	for %%a in (%get_gateways%) do (
		for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
			set "x=%%b %%c,!x!"
		)
	)

:: removing trailing comma
if defined x set "x=%x:~0,-1%"
echo "%x%" "!x!"
call :debug starting :selector !x!

echo  select the network your phone is connected to:
call :selector %x%
)
set selector=wifi_192.168.100.1
for /f "tokens=1-2 delims=_" %%a in ("%selector%") do (
	set NETWORK_TYPE=%%a
	set IP=%%b
	)

set "get_gateways=%IP%"
call :debug user selected NETWORK_TYPE=%NETWORK_TYPE% and gateway=%get_gateways%

call :network_bits %get_gateways% 

set /p "host_bits=enter the last digits %network_bits%."

call :debug user entered host_bits: %host_bits%

set PHONE_IP=%network_bits%.%host_bits%

call :debug PHONE_IP: %PHONE_IP%
(
call :connect && goto :eof
) || (
	call :debug connect failed for %PHONE_IP%
	echo no ftp servers could be found, switching to manual ip input mode.
	call :debug end of method 3
	goto :method_4
	)
			




:method_4
:: method 4 - direct input of full phone ip address, im so sorry this is what i tried to avoid pls forgive me
call :debug starting method 4 direct input
echo im so sorry this is what i tried to avoid 
echo.
set /p "PHONE_IP=enter the full ip address of the phone:"
call :network_bits %PHONE_IP%
set a=%network_bits%
if defined get_gateways call :network_bits %get_gateways%
if not "%a%"=="%network_bits%" ( 
	call :method_4a your phone and pc are not on the same network
	)

call :debug ping %PHONE_IP%

(
ping -n 1 -w 10 %PHONE_IP% | find "TTL=" >nul
) && (
	echo. >nul
	(
	call :connect && goto :eof
	) || (
		call :method_4a ftp server not found on %PHONE_IP%
	)
) || (
	call :method_4a ping failed for %PHONE_IP%
	)

:method_4a
call :formatting 5
echo %*
call :selector try again,quick input,exit
if /i "%selector%"=="exit" goto :eof
if /i "%selector%"=="quick input" goto :method_3
if /i "%selector%"=="try again" goto :method_4
goto :menu




:connect
set "connect=%*"
if defined connect set "PHONE_IP=%*" 
:: (search) && ((found) && (killed) || (unkilled)) || (unfound)
( 
call :check_ftp %PHONE_IP% %FTP_PORT% 
) && ( 
	::ftp server found
	explorer ftp://%FTP_USER%:%FTP_PASS%@%PHONE_IP%:%FTP_PORT% >nul
	call :debug connection successful on %PHONE_IP%
	exit /b 0
	) || ( 
		::ftp server not found
		call :debug connection failed on %PHONE_IP%
		exit /b 1		 
		)



:menu
call :formatting 7
echo  menu
call :selector method 1  fast search,method 2  slow search,method 3  quick input,method 4  manual input,exit
if /i "%selector%"=="exit" goto :eof
for /f "tokens=2 delims= " %%a in ("%selector%") do (
	echo.
	echo you selected %selector%
	echo method_%%a
	pause
	goto :method_%%a
	exit /b
)

cls
call :error
call :formatting 1
echo something went wrong
pause & exit


:check_ftp
:: Usage: check_ftp <IP_address> <PORT>
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
set "log=%*"
set "tstamp="
setlocal enabledelayedexpansion
for /f "tokens=1-2 delims= " %%a in ('time /t') do (
	for /f "tokens=1-3 delims=:" %%b in ("%%a") do (
		endlocal & set "tstamp=[%%b:%%c]"
	)
) 
if not defined newLogFile set "newLogFile=1" & echo %tstamp% : script started > %LOGPATH%debug.log
echo %tstamp% : %log% >> %LOGPATH%debug.log
exit /b


:formatting
set "args=%*"
set /a spacing=%lines%-%args%
set /a spacing=%spacing%/2
:: formatting just because
:: Usage: formatting <number_of_blank_lines>
cls
for /L %%a in (1,1,%spacing%) do ( echo.)
exit /b 0


:error
exit /b 1


:eof
exit