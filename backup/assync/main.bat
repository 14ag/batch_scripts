@echo off

:: callback config
setlocal enabledelayedexpansion       
set "args=%*"
for /F "tokens=1,* delims= " %%a in ("%args%") do (
    endlocal & ( set "function=%%a" & set "args=%%b")
)

if defined function call %function% %args% & exit /b

:: tool config
title FTP 
prompt $g$g$s
set "lines=20"
mode con: cols=60 lines=%lines%
del foo >nul 2>&1
del found >nul 2>&1
set "read="%~f0" :io r"
set "write="%~f0" :io w"
set "append="%~f0" :io ww"

:: init
set "ip_address="
set LOGPATH=%userprofile%\desktop\
set "INI=%USERPROFILE%\Desktop\ftp_settings.ini"

setlocal EnableDelayedExpansion
:create
if not exist "%INI%" (
    echo creating config file on your desktop...
    (
      echo FTP_USER=
      echo FTP_PASS=
      echo FTP_PORT=
	  echo.
      echo ; mac address format xx-xx-xx-xx-xx-xx
      echo MAC_ADDRESS=
	  echo.
      echo ; set debug to 0 ^(default^) for off or 1 to get log file on your desktop folder
      echo debug=0
    ) > %INI%
    echo config file created. Press any key to open it for editing.
    pause >nul
    start notepad.exe %INI%
    echo.
    echo Please edit and save the config file, then press any key to continue.
    pause >nul
    goto :create
)

for /f "usebackq delims=" %%a in ("%INI%") do (
	set "line=%%a"

	for /f "tokens=* delims= " %%b in ("!line!") do set "line=%%b"

		if defined line (
		set "firstChar=!line:~0,1!"

			if NOT "!firstChar!"==";" if NOT "!firstChar!"=="#" (

				echo "!line!" | findstr /c:"=" >nul
				if not errorlevel 1 (

				for /f "tokens=1* delims==" %%c in ("!line!") do (
					set "value=%%d"
					for /f "tokens=* delims=" %%e in ("!value!") do set "value=%%e"
					
					set "key=%%c"
					for /f "tokens=* delims= " %%e in ("!key!") do set "key=%%e"
					set "keys=!keys! !key!"
					set "!key!=!value!"
)	)	)	)	)

for %%a in (!keys:~1!) do (
  set "x=!x! & set "%%a=!%%a!""
  )

set "x=%x:~3%"
endlocal & %x%

call :debug initial parameters: FTP_USER=%FTP_USER% FTP_PASS=%FTP_PASS% FTP_PORT=%FTP_PORT% mac_address=%mac_address%



:method_1
:: detecting phone ip from arp table using mac address
call :formatting 8 searching for ftp server ...this won't take long

if not defined mac_address echo setup mac_address for fast connection & goto method_2
set "macAddress_lookup="
if not defined macAddress_lookup (
	call :debug searching ARP table for MAC address %mac_address%

	call :macAddress_lookup %mac_address%
)
call :debug result of MAC address detection: %macAddress_lookup%

if not defined macAddress_lookup (
	goto :method_2
)

set "ip_address=%macAddress_lookup%"

call :debug attempting to connect with ip %ip_address%
(
call :connect %ip_address% && goto :eoff
) || (
	echo  retrying...
	if defined method_1 goto :method_2
	netsh interface ip delete arpcache
	set "method_1=1"
	goto :method_1
)



:method_2
:: search ip in the local subnet by pinging all possible ips
set "ip_address="
set "found_ips=found"
set "ping_handler=call "%~f0" :ping_handler"

call :debug #2 starting ip scan

call :debug #2 fetching gateways

call :get_gateway

call :debug #2 detected gateways: _%get_gateway%_

call :formatting 3   please wait...

echo scanning %get_gateway% for ftp servers

call :debug #2 attempting connection to gateway ip %get_gateway%

(
	call :connect %get_gateway% && goto :eoff
) || (
	call :debug #2 no ftp servers could be found on gateway %get_gateway%
)	

echo scanning ips in gateway %get_gateway% for ftp servers
call :debug #2 scanning ips in gateway %get_gateway%

call :network_bits %get_gateway%

call :debug #2 network bits: %network_bits%

setlocal enabledelayedexpansion
for /l %%a in (1,50,250) do (

    set "start=%%a"
    set /a "stop=!start!+49"
    if !start! equ 241 set /a "stop=!start!+13"
    for /l %%b in (!start!,10,!stop!) do (

        set "ipRangeStart=%%b"
        set /a "ipRangeStop=!ipRangeStart!+9"
        if !ipRangeStart! equ 241 set /a "ipRangeStop=!ipRangeStart!+13"
        call :set_timeout 1 %ping_handler% %get_gateway% %network_bits% !ipRangeStart!-!ipRangeStop!
    )
    call :check_async
	
	for /f "usebackq tokens=* delims=" %%b in ("%found_ips%") do (
		for %%c in (%%b) do (
			call :connect %%c && goto :eoff
	)	)

	del found >nul 2>&1
)



:method_2a
call :formatting 5 couldnt find ftp server on %get_gateway%

call :selector scan again,enter ip address

call :debug #2a option selected _%selector%_

if /i "%selector%"=="enter ip address" goto :method_3
if /i "%selector%"=="scan again" goto :method_1
 goto :error



:method_3
:: method 3 - quick input ip address
set "ip_address="

setlocal enabledelayedexpansion

call :formatting 6 switching to manual input mode.

echo.
call :get_gateway

call :debug #3 user selected !NETWORK_TYPE! gateway=!get_gateway!

call :network_bits !get_gateway!

set /p "host_bits=enter the last digits !network_bits!."
call :debug #3 user entered host_bits: %host_bits%

set "ip_address=%network_bits%.%host_bits%"
call :debug #3 ip_address: %ip_address%

(
	call :connect %ip_address% && goto :eoff
	) || (
		endlocal
		call :method_3a no ftp servers could be found on %ip_address%
		)



:method_3a

call :formatting 5 %*

call :selector select different gateway,scan for server,enter full ip address

call :debug #3a option selected _%selector%_

if /i "%selector%"=="enter full ip address" goto :method_4
if /i "%selector%"=="select different gateway" goto :method_3
if /i "%selector%"=="scan for server" goto :method_2
goto :error



:method_4
:: method 4 - direct input of full phone ip address, im so sorry this is what i tried to avoid pls forgive me
call :formatting 5 im so sorry this is what i tried to avoid
:input
echo.
set /p "user_ip_address=just enter the full ip address of the phone: "
call :network_bits %user_ip_address% 

set "UIP_network_bits=%network_bits%"
call :debug #4 user input network bits %UIP_network_bits%

call :get_gateway

call :network_bits %get_gateway%

call :debug #4 user device gateway %get_gateway%

if not "%UIP_network_bits%"=="%network_bits%" ( 
	call :formatting 4 it seems like your phone and pc are not on the same network
	goto :input
	)

for /f "tokens=4 delims=." %%a in ("%user_ip_address%") do (
    set "host=%%a"
	)

call :debug #4 pinging %user_ip_address%

(
call :ping_handler %user_ip_address% %UIP_network_bits% %host%-%host%
) && (
	echo. >nul
	(
		call :connect %user_ip_address% && goto :eoff

	) || (
		call :method_4a ftp server not found on %user_ip_address%
	)
) || (
	call :method_4a %user_ip_address% is unreachable
	)



:method_4a
call :formatting 5 %*

echo.
call :selector try again,quick input,scan for server,exit

if /i "%selector%"=="exit" goto :eoff
if /i "%selector%"=="quick input" goto :method_3
if /i "%selector%"=="try again" goto :method_4
if /i "%selector%"=="scan for server" goto :method_2a
goto :error



:connect
:: define %FTP_PORT%
:: use connect [ip address]
set "ip_address=%*"
:: (search) && ((found) && (killed) || (unkilled)) || (unfound)
(
	call :check_ftp %ip_address% %FTP_PORT%

) && ( 
	::ftp server found
	call :debug ftp server found on _%ip_address%_
	explorer ftp://%FTP_USER%:%FTP_PASS%@%ip_address%:%FTP_PORT% >nul
	exit /b 0
	) || ( 
		::ftp server not found
		call :debug no ftp on _%ip_address%_
		exit /b 1		 
		)



:ping_handler
:: use call :ping_handler [#start-stop] [gateway] [networkbits]
set "args=%*"

setlocal enabledelayedexpansion       
for /F "tokens=1,2,3 delims= " %%e in ("%args%") do (

	for /F "tokens=1,2 delims=-" %%h in ("%%g") do (
		endlocal & ( set "p_gateway=%%e" & set "p_network_bits=%%f" & set "start=%%h" & set "stop=%%i" )
)	) 

for /l %%e in (%start%,1,%stop%) do (
	if not "%p_network_bits%.%%e"=="%p_gateway%" (
					
		echo. >nul
		(
		ping -n 1 -w 10 %network_bits%.%%e | find "TTL=" >nul
		) && (
		:: if ping successful
		call :debug ping successful for %network_bits%.%%e

        if %start% equ %stop% exit /b 0
		call %append% %found_ips% %network_bits%.%%e

		) || (
			:: if ping failed
			call :debug no ping response from %network_bits%.%%e

            if %start% equ %stop% exit /b 1
			:: last network, so if we reach here with d=254 then no ftp servers found
			if %%e equ %stop% (
				call :debug end of range
	)	)	)	)

exit /b



:check_ftp
:: Usage: check_ftp <IP_address> <PORT>
:: returns errorlevel 0 if ftp server is reachable and 1 if not
set "IP=%1"
set "PORT=%2"
(
	:: Run PowerShell silently without showing the progress bar
	powershell -Command "$ProgressPreference='SilentlyContinue'; if (Test-NetConnection -ComputerName %IP% -Port %PORT% -InformationLevel Quiet -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
) >nul
exit /b %errorlevel%



:get_gateway
:: use call :get_gateway
:: returns an array of gateways of your pc in format [abc_123.123.123.123 xyz_456.456.456.456]

setlocal enabledelayedexpansion
set "get_gateway="
for /f "delims=" %%m in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateway=%%m" >nul

set /a "count=0"
for %%m in (%get_gateway%) do (
	set /a "count+=1"
    )

if %count% gtr 1 (

	call :debug multiple gateways found, prompting user for selection
	set "x="
	for %%m in (%get_gateway%) do (
		for /f "tokens=1-2 delims=_" %%n in ("%%m") do (
			set "x=%%n %%o,!x!"
	)	)

    :: removing trailing comma
    if defined x set "x=!x:~0,-1!"
    echo  select the network your ftp server is connected to:
    call :debug starting :selector !x!

    call :selector !x!
	for /F "tokens=2 delims= " %%m in ("!selector!") do (
		endlocal & set "get_gateway=%%m" 
		)

	) else if %count% equ 1 (

	for /f "tokens=1-2 delims=_" %%m in ("%get_gateway%") do (
		endlocal & set "get_gateway=%%n"
		)
	)


call :debug :get_gateway result: %get_gateway%
exit /b %errorlevel%



:network_bits
:: Usage: network_bits <IP_address>
set "network_bits="
set "ip=%1"
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%w in ("%ip%") do (
	set "network_bits=%%w.%%x.%%y"
)
call :debug :network_bits result: %network_bits%

exit /b %errorlevel%



:macAddress_lookup
:: Usage: macAddress_lookup <MAC_address>
set "macAddress=%1"
(
arp -a | find /i "%macAddress%" >nul
) && (
	:: found
	for /f "tokens=1" %%z in ('arp -a ^| find /i "%macAddress%"') do (
		set "macAddress_lookup=%%z"
		)
	) || (
	:: phone not found in arp table
	set "macAddress_lookup="
	exit /b 1
	)
exit /b 0



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
for %%y in (%arg_list%) do (
	set /a i+=1

	:: Create dynamic variable names (_1, _2, etc.)
	for %%z in (_!i!) do (

		set "%%z=%%y"
		set "choicelist=!choicelist!!i!"
        set "display_value=%%y"
        set "display_value=!display_value:"=!"
		echo   [!i!].. !display_value!
	)   )

call :reset_choice

choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%y in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%y (

		for %%z in (!_%%y!) do (
				endlocal & set "selector=%%z"
				goto :break
    )   )   )
:break
set "selector=%selector:"=%"
exit /b 0



:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0



:debug
::define "logpath" and "newLogFile=" before your code
if "%debug%"=="0" @exit /b 0 >nul 2>&1
if not defined debug @exit /b 0 >nul 2>&1
set "log=%*"
set "tstamp="

setlocal enabledelayedexpansion
for /f "tokens=1-2 delims= " %%x in ('time /t') do (

	for /f "tokens=1-3 delims=:" %%y in ("%%x") do (
		endlocal & set "tstamp=[%%y:%%z]"
	)	)
	
if not defined newLogFile (
	set "newLogFile=1"
	echo %tstamp% : script started > %LOGPATH%debug.log
	)
echo %tstamp% : %log%>>%LOGPATH%debug.log 2>nul

@exit /b 0 >nul 2>&1



:set_timeout
:: usage call :set_timeout [time in sec.] [single line command with escaped chars. recommended to be a callback]
:: then call :check_async to wait for all to finish
if not defined check_async ( 

	set "foo="%~dp0foo""
	set /a "set_timeout=1"
	) else (
		set /a "set_timeout+=1"
	)

set "args=%*"

setlocal enabledelayedexpansion
set "task_id_%set_timeout%=%random%"
for /F "tokens=1,* delims= " %%i in ("%args%") do (
    set "t=%%i"
	set "command=%%j"
	) 

set "check_async=v"
start /b cmd /v:on /c "timeout /t !t! /nobreak >nul & (!command!) && (call %append% %foo% !task_id_%set_timeout%!)"

for %%i in (task_id_%set_timeout%) do (
	set "x=set "%%i=!%%i!""
	)

endlocal & %x% & set "check_async=v"
goto :eo_set_timeout


:check_async
set "count=0"
:check_async0
setlocal enabledelayedexpansion
if %count% equ 61 echo ##001 something went wrong & goto :eoff
set /a "count+=1"
if not exist "foo" (
	call :debug waiting no task completed yet
	timeout /t 1 /nobreak >nul 2>&1
	goto :check_async
	)
for /f "usebackq delims=" %%i in (%foo%) do (

	set "line=%%i"
	(
	echo !progress_id! | find "!line!" >nul
	) || (
		set "progress_id=!line!!progress_id!"
	)	)

for /l %%i in (1,1,%set_timeout%) do (
	for /f "tokens=2 delims==" %%j in ('set task_id_%%i') do ( set "task_id=%%j" )
	(
	echo !progress_id! | find "!task_id!" >nul
	) && (
		call :debug !task_id! found in !progress_id!
	) || (
		timeout /t 1 /nobreak >nul 2>&1
		goto :check_async0
	)	)

set "check_async="
del %foo% >nul 2>&1
:eo_set_timeout
endlocal
exit /b 0



:io
:: define "read="%~f0" io r" "write="%~f0" io w" "append="%~f0" io ww" at the beginning of script
:: usage call :io [r|w|ww] [filename] [data]
:: [w] overwrites [ww] appends [r] reads data to/from [filename]
:: stores data in var %io% when doing [r] operation
call :debug entering :io with args [%*]
set "args=%*"
set "MAX_TRY=5"
setlocal enabledelayedexpansion
for /F "tokens=1,2,* delims= " %%s in ("%args%") do (
    set "rw=%%s" 
    set "file=%%t" 
    set "data=%%u"
	)

set "LOCK_DIR="!file:"=!Lock""
set /a TRY_COUNT=0

:TryLock
( 
mkdir %LOCK_DIR% 2>nul
) && (
    if "!rw!"=="r" (
        set /p "io="<!file! || call :debug ERROR reading [!file!]
    ) else if "!rw!"=="w" (
            echo !data!>!file! || call :debug ERROR writing [!data!] to [!file!]
	) else if "!rw!"=="ww" (
		echo !data!>>!file! || call :debug ERROR writing [!data!] to [!file!]
	)
	call :debug io [!rw!] operation on file [!file!] with data [!data!!io!]
) || (
    timeout /t 3 /nobreak >nul
    set /a TRY_COUNT+=1
    if !TRY_COUNT! lss %MAX_TRY% goto TryLock
    echo max wait.
)

rmdir "!LOCK_DIR!" 2>nul
for /F "tokens=* delims= " %%s in ("!io!") do (
    endlocal & set "io=%%s" 
	)
exit /b



:formatting
:: formatting just because
:: Usage: formatting <number_of_blank_lines>
cls
set "args=%*"
for /F "tokens=1,* delims= " %%y in ("%args%") do (
    set "n=%%y" 
    set "i=%%z" 
	)
set /a "spacing=(%lines%-%n%)/2"
for /L %%y in (1,1,%spacing%) do (
	if %%y equ %spacing% (
		if defined i (
			echo %i%
		) else (
			echo.
		)
	) else (
		echo.
	)	)

exit /b 0



:error
call :error

call :formatting 1

echo something went wrong
start notepad.exe %LOGPATH%
pause & goto :eoff



:eoff
del found >nul 2>&1
exit