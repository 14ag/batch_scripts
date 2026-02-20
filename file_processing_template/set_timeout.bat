@echo off
title set_timeout
set "lines=20"
@rem mode con: cols=60 lines=%lines%
set "append="%~f0" :io ww"

:set_timeout
:: usage call :set_timeout [time in sec.] [single line command with escaped chars. recommended to be a callback]
:: then call :check_async to wait for all to finish
if not exist check_async ( 

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

echo v>check_async
start /b cmd /v:on /c "timeout /t !t! /nobreak >nul & (!command!) && (call %append% %foo% !task_id_%set_timeout%!)"

for %%i in (task_id_%set_timeout%) do (
	set "x=set "%%i=!%%i!""
	)

endlocal & %x% & echo v>check_async

exit /b %errorlevel%