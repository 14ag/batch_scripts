::@echo off
set "currentDirectory=%~dp0"
set "foo=%currentDirectory%foo.txt"
echo %foo%
pause


goto :2
:2
set /a "settimeoutx=0"
echo %settimeoutx%>%foo%
set /a "settimeouty=3"

call :settimeout 9 echo 9secs
call :settimeout 8 echo 8secs 
call :settimeout 1 echo 1secs
call :check_assync
echo all done
pause
goto :eof


:check_assync
set /p "settimeoutx=<%foo%"
echo %settimeoutx% __________________________
if not "%settimeoutx%"=="%settimeouty%" pause & goto :check_assync
exit /b 0


:settimeout 
:: usage call :settimeout [#] [single line command with escaped chars. reccommended to be a callback]
:: trying to make asyncronous
:: increases the value of 'settimeoutx' by 1 on each completion
set "args=%*"
if not defined args goto :eosettimeout
setlocal enabledelayedexpansion       
set "t="
set "command="
set "first_arg_found=0"

for /F "tokens=1,* delims= " %%a in ("%args%") do (
    endlocal & ( set "t=%%a" & set "command=%%b")
)
start /b cmd /v:on /c "timeout /t %t% /nobreak >nul && ( %command% & set /p "x=<%foo%" & set /a "x+=1" & echo %x%>%foo% )"
echo. >nul
:eosettimeout
exit /b


:eof
exit /b



output:
"0"=="3"
Press any key to continue . . . 1secs
Invalid attempt to call batch label outside of batch script.
settimeoutx=0
8secs
Invalid attempt to call batch label outside of batch script.
settimeoutx=0
9secs
Invalid attempt to call batch label outside of batch script.
settimeoutx=0

"0"=="3"
Press any key to continue . . .
"0"=="3"
Press any key to continue . . .
"0"=="3"
Press any key to continue . . .
....