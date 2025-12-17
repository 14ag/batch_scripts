@REM @echo off
prompt $g$g$s


set "args=%*"
if defined args goto %args%



call :set_timeout 2 echo 2secs
call :set_timeout 5 echo 5secs
call :set_timeout 1 echo 1secs
call :set_timeout 8 echo 8secs
pause
call :check_async
echo all done!
goto :eof

@REM call :io w test.txt abc
@REM call :io r test.txt
@REM echo %io%

@REM call :set_timeout 1 echo 1secs






:oooo
call :eeee
exit /b 0

:eeee
echo eeee
exit /b 0






:set_timeout
:: usage call :set_timeout [time in sec.] [single line command with escaped chars. recommended to be a callback]
:: then call :check_async to wait for all to finish 

if defined check_async ( set /a "set_timeouty+=1" & goto :set_timeout_a ) 
set "check_async=v"
set foo="%~dp0foo.tmp"
set /a "set_timeouty=1"
set /a "set_timeoutx=0"
(echo %set_timeoutx%)>%foo%

:set_timeout_a
set "args=%*"
if not defined args goto :eo_set_timeout
setlocal enabledelayedexpansion       
for /F "tokens=1,* delims= " %%a in ("%args%") do (
    endlocal & ( set "t=%%a" & set "command=%%b")
) 

start /b cmd /v:on /c "timeout /t %t% /nobreak >nul && (%command% & (for /f %%x in (%foo%) do set /a x=%%x+1) >nul & echo ^!x^!>%foo%)"
set /p "set_timeoutx="<%foo%
echo task %set_timeoutx% complete
goto :eo_set_timeout

:check_async
set /p "set_timeoutx="<%foo%
if not "%set_timeoutx%"=="%set_timeouty%" (
	timeout /t 1 /nobreak >nul 2>nul
	goto :check_async
) else (
	set "check_async="
	del %foo% >nul 2>nul
	goto :eo_set_timeout
)
:eo_set_timeout
exit /b



:io
:: usage call :io [r|w] [filename] [data]
:: stores data in var %io% when doing read operation
set "args=%*"
set "MAX_WAIT=30"
setlocal enabledelayedexpansion
for /F "tokens=1,2,* delims= " %%a in ("%args%") do (
    set "rw=%%a" 
    set "file=%%b" 
    set "data=%%c"
)

set "LOCK_DIR=!file!Lock"
set /a WAIT_COUNT=0

:TryLock
mkdir "%LOCK_DIR%" 2>nul
if %ERRORLEVEL% equ 0 (
    if "!rw!"=="r" (
        set /p "io="<!file!
    ) else if "!rw!"=="w" (
            echo !data! >>!file!
        )
) else (
    timeout /t 1 /nobreak >nul
    set /a WAIT_COUNT+=1
    if !WAIT_COUNT! lss %MAX_WAIT% goto TryLock
    echo max wait.
    
)

rmdir "!LOCK_DIR!" 2>nul
for /F "tokens=* delims= " %%a in ("!io!") do (
    endlocal & set "io=%%a" 
)

exit /b






goto :skip_ping_handler
:ping_handler
:: use call :ping_handler [#start-stop] [gateway] [networkbits]
set "args=%*"
setlocal enabledelayedexpansion       
for /F "tokens=1,2,3 delims= " %%a in ("%args%") do (

	for /F "tokens=1,2 delims=-" %%d in ("%%a") do (
		endlocal & ( set "p_gateway=%%b" & set "p_networkbits=%%c" & set "start=%%d" & set "stop=%%e" )
	) 
)
for /l %%a in (%start%,1,%stop%) do (
	if %p_network_bits%.%%a neq %p_gateway% (
					
		echo. >nul
		(
		ping -n 1 -w 10 %network_bits%.%%a | find "TTL=" >nul
		) && (
		:: if ping successful
		call :debug ping successful for %network_bits%.%%a
		call :io w %found_ips% %network_bits%.%%a
		) || (
			:: if ping failed
			call :debug ping failed for %network_bits%.%%a
			:: last network, so if we reach here with d=254 then no ftp servers found
			if %%a equ %stop% (
				call :debug end of method 2, search failed
			)			
		)
	) else (
		call :debug skipping %p_gateway%
	)
)
exit /b
:skip_ping_handler













:eof
exit /b
