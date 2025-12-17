@echo off


:: callback config
setlocal enabledelayedexpansion       
set "args=%*"
for /F "tokens=1,* delims= " %%a in ("%args%") do (
    endlocal & ( set "function=%%a" & set "args=%%b")
)
if defined function call %function% %args% & exit /b



:: tool config
prompt $g$g$s
set "lines=20"
@REM mode con: cols=60 lines=%lines%

title FTP 
set "read="%~f0" :io r"
set "write="%~f0" :io w"
set "append="%~f0" :io ww"



:: FTP Configuration
set ip_address=
set NETWORK_TYPE=
@REM set LOGPATH=%userprofile%\desktop\
set LOGPATH=%userprofile%\sauce\batch_scripts\ftp_gateway\
set "INI=%USERPROFILE%\Desktop\ftp_settings.ini"
del foo >nul 2>&1
del found >nul 2>&1

setlocal EnableDelayedExpansion
:: Path to INI on Desktop 
:create
if not exist "%INI%" (
    echo creating config file on your desktop...
    (
      echo FTP_USER=
      echo FTP_PASS=
      echo FTP_PORT=
	  echo.
      echo ; mac address format xx-xx-xx-xx-xx-xx
      echo PHONE_MAC=
	  echo.
      echo ; set debug to 0 for off or 1 to get log file on your desktop folder
      echo debug=
    ) > %INI%
    echo config file created. Press any key to open it for editing.
    pause >nul
    start notepad.exe %INI%
    echo.
    echo Please edit and save the config file, then press any key to continue.
    pause >nul
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

call :debug initial parameters: FTP_USER=%FTP_USER% FTP_PASS=%FTP_PASS% FTP_PORT=%FTP_PORT% PHONE_MAC=%PHONE_MAC%

goto :method_2















::==================================================================================================================================================



:method_2

:: search ip in the local subnet by pinging all possible ips
set "ip_address="
set "method_2=1"
set "found_ips=found"
set "ping_handler=call "%~f0" :ping_handler"

call :debug starting ip scan

call :debug fetching gateways

call :get_gateways

call :debug detected gateways: %get_gateways%

set "count=0"
for %%a in (%get_gateways%) do (
	set /a count+=1
)

echo  please wait...

for %%a in (%get_gateways%) do (
	for /f "tokens=1-2 delims=_" %%b in ("%%a") do (

		call :debug scanning %%b with gateway %%c

		echo scanning the %%b gateway for ftp servers

		call :debug attempting connection to ip %%c

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

		echo scanning the %%b for ftp servers

		call :network_bits %%c

		call :debug network bits: !network_bits!
		
		call :set_timeout 1 %ping_handler% 1-50 %%c !network_bits!
		call :set_timeout 1 %ping_handler% 51-65 %%c !network_bits!
		call :set_timeout 1 %ping_handler% 66-90 %%c !network_bits!
		call :set_timeout 1 %ping_handler% 91-150 %%c !network_bits!
		call :set_timeout 1 %ping_handler% 151-199 %%c !network_bits!
			
		
		call :check_async
		set #=0
		for /f "usebackq tokens=* delims=" %%d in ("%found_ips%") do (
			for %%e in (%%d) do (
				@REM echo _%%e_
				set /a "#+=1"
				@REM call :connect && goto :eof
			)
			
		)


	)
)
echo !#!
endlocal
exit /b
exit /b
exit /b
exit /b



:method_2a
set "method_2="
call :formatting 5
echo %*
call :selector try again,manual input,exit
if /i "%selector%"=="exit" goto :eof
if /i "%selector%"=="enter phone ip" goto :method_3
if /i "%selector%"=="try again" goto :method_1
goto :menu



::==================================================================================================================================================



























:connect
set "connect=%*"
if defined connect set "ip_address=%*" 
:: (search) && ((found) && (killed) || (unkilled)) || (unfound)
( 
call :check_ftp_simulator %ip_address% %FTP_PORT% 
) && ( 
	::ftp server found
	rem explorer ftp://%FTP_USER%:%FTP_PASS%@%ip_address%:%FTP_PORT% >nul
	msg * /server:127.0.0.1 /w "ftp://%FTP_USER%:%FTP_PASS%@%ip_address%:%FTP_PORT%"
	call :debug ftp server found on %ip_address%
	exit /b 0
	) || ( 
		::ftp server not found
		call :debug no ftp on %ip_address%
		exit /b 1		 
		)



:ping_handler
:: use call :ping_handler [#start-stop] [gateway] [networkbits]
set "args=%*"
setlocal enabledelayedexpansion       
for /F "tokens=1,2,3 delims= " %%a in ("%args%") do (

	for /F "tokens=1,2 delims=-" %%d in ("%%a") do (
		endlocal & ( set "p_gateway=%%b" & set "p_network_bits=%%c" & set "start=%%d" & set "stop=%%e" )
	) 
)

for /l %%a in (%start%,1,%stop%) do (
	if not "%p_network_bits%.%%a"=="%p_gateway%" (
					
		echo. >nul
		(
		::ping -n 1 -w 10 %network_bits%.%%a | find "TTL=" >nul
		call :ping_simulator %%a
		) && (
		:: if ping successful
		call :debug ping successful for %network_bits%.%%a
		call %append% %found_ips% %network_bits%.%%a
		) || (
			:: if ping failed
			call :debug no ping response from %network_bits%.%%a
			:: last network, so if we reach here with d=254 then no ftp servers found
			if %%a equ %stop% (
				call :debug end of range
			)			
		)
	)
)

exit /b



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
)


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
@rem Loop through the new quoted, space-separated list
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
set "get_gateways="
for /f "delims=" %%a in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateways=%%a" >nul
call :debug :get_gateways result: %get_gateways%
exit /b %errorlevel%
	

:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0


:network_bits
:: Usage: network_bits <IP_address>
set "network_bits="
set "ip=%1"
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%a in ("%ip%") do (
	set network_bits=%%a.%%b.%%c
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
	for /f "tokens=1" %%a in ('arp -a ^| find /i "%macAddress%"') do (
		set "macAddress_lookup=%%a"
		)
	) || (
	:: phone not found in arp table
	set "macAddress_lookup="
	exit /b 1
	)
exit /b 0



:debug
@exit /b 0 >nul 2>&1
if "%debug%"=="0" goto :eo_debug
if not defined debug goto :eo_debug
set "log=%*"
set "tstamp="
setlocal enabledelayedexpansion
for /f "tokens=1-2 delims= " %%a in ('time /t') do (
	for /f "tokens=1-3 delims=:" %%b in ("%%a") do (
		endlocal & set "tstamp=[%%b:%%c]"
	)
) 
if not defined newLogFile (
	set "newLogFile=1"
	echo %tstamp% : script started > %LOGPATH%debug.log
) else (
	echo %tstamp% : %log% >> %LOGPATH%debug.log
)
:eo_debug 
@exit /b 0 >nul 2>&1





:set_timeout
:: usage call :set_timeout [time in sec.] [single line command with escaped chars. recommended to be a callback]
:: then call :check_async to wait for all to finish 

if not defined check_async ( 
	set foo="%~dp0foo"
	set /a "set_timeout=1" 
	) else (
		set /a "set_timeout+=1"
	)

set "args=%*"
setlocal enabledelayedexpansion
set "task_id_%set_timeout%=%random%"
for /F "tokens=1,* delims= " %%a in ("%args%") do (
    set "t=%%a"
	set "command=%%b"
) 

set "check_async=v"
start /b cmd /v:on /c "timeout /t !t! /nobreak >nul & (!command!) && (call %append% %foo% !task_id_%set_timeout%!)"

for %%a in (task_id_%set_timeout%) do (
  set "x=set "%%a=!%%a!""
)

endlocal & %x% & set "check_async=v"
goto :eo_set_timeout

:check_async
setlocal enabledelayedexpansion
if not exist "foo" (
	call :debug waiting no task completed yet
	timeout /t 1 /nobreak >nul 2>&1
	goto :check_async
)
for /f "usebackq delims=" %%a in (%foo%) do (
	set "line=%%a"
	(
	echo !progress_id! | find "!line!" >nul
	) || (
		set "progress_id=!line!!progress_id!"
		)
)

for /l %%a in (1,1,%set_timeout%) do (
	for /f "tokens=2 delims==" %%b in ('set task_id_%%a') do ( set "task_id=%%b" )
	(
	echo !progress_id! | find "!task_id!" >nul
	) && (
		call :debug !task_id! found in !progress_id!
	) || (
		call :debug waiting for task !task_id!
		timeout /t 7 /nobreak >nul 2>&1
		goto :check_async
	)
)

set "check_async="
@REM del %foo% >nul 2>&1
:eo_set_timeout
endlocal
exit /b 0



:io
@REM set "read="%~f0" io r"
@REM set "write="%~f0" io w"
@REM set "append="%~f0" io ww"
:: usage call :io [r|w|ww] [filename] [data]
:: stores data in var %io% when doing read operation
call :debug entering :io with args [%*]
set "args=%*"
set "MAX_TRY=5"
setlocal enabledelayedexpansion
for /F "tokens=1,2,* delims= " %%a in ("%args%") do (
    set "rw=%%a" 
    set "file=%%b" 
    set "data=%%c"
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
            echo !data! >!file! || call :debug ERROR writing [!data!] to [!file!]
	) else if "!rw!"=="ww" (
		echo !data! >>!file! || call :debug ERROR writing [!data!] to [!file!]
	)
	call :debug io [!rw!] operation on file [!file!] with data [!data! !io!]
) || (
    timeout /t 5 /nobreak >nul
    set /a TRY_COUNT+=1
    if !TRY_COUNT! lss %MAX_TRY% goto TryLock
    echo max wait.
)

rmdir "!LOCK_DIR!" 2>nul
for /F "tokens=* delims= " %%a in ("!io!") do (
    endlocal & set "io=%%a" 
)
exit /b


:ping_simulator
:: filters odd number hosts
set "args=%*"
set /a "ddd=args/2"
set /a "dds=args-(ddd*2)"
if %dds% equ 1 (
	exit /b 0
) else (
	exit /b 1
)

:check_ftp_simulator
:: filters hosts divisible by 5
set "args=%*"
set /a "ddd=args/100"
set /a "dds=args-(ddd*100)"
if %dds% equ 1 (
	exit /b 0
) else (
	exit /b 1
)

:formatting
:: formatting just because
:: Usage: formatting <number_of_blank_lines>
set "args=%*"
set /a spacing=%lines%-%args%
set /a spacing=%spacing%/2

for /L %%a in (1,1,%spacing%) do ( echo.)
exit /b 0


:error
exit /b 1


:eof
exit