@echo off
set "args=%*"
if defined args goto %args%
call :set_timeout 2 call %~n0 oooo

@REM call :set_timeout 8 echo 8secs
@REM call :set_timeout 1 echo 1secs
call :check_assync
echo all done!
goto :eof



:oooo
call :eeee
exit /b 0

:eeee
echo eeee
exit /b 0






:set_timeout
:: usage call :set_timeout [#] [single line command with escaped chars. reccommended to be a callback]
:: then call :check_assync to wait for all to finish 

if defined check_assync ( set /a "set_timeouty+=1" & goto :set_timeout_a ) 
set "foo=%~dp0foo.txt"
(echo %set_timeoutx%)>%foo%
set /a "set_timeouty=1"
set /a "set_timeoutx=0"
(echo %set_timeoutx%)>%foo%

:set_timeout_a
set "args=%*"
if not defined args goto :eo_set_timeout
setlocal enabledelayedexpansion       
set "t="
set "command="
set "first_arg_found=0"
for /F "tokens=1,* delims= " %%a in ("%args%") do (
    endlocal & ( set "t=%%a" & set "command=%%b")
) 

start /b cmd /v:on /c "timeout /t %t% /nobreak >nul && (%command% & (for /f %%x in (%foo%) do set /a x=%%x+1) >nul & echo ^!x^!>%foo%)"
set "check_assync=v"
goto :eo_set_timeout

:check_assync
set /p "set_timeoutx="<%foo%

if not "%set_timeoutx%"=="%set_timeouty%" (
    timeout /t 1 /nobreak >nul 2>nul
    goto :check_assync
) else (
    set "check_assync="
    del "%foo%" >nul 2>nul
    goto :eo_set_timeout
)
:eo_set_timeout
exit /b





:eof
exit /b
