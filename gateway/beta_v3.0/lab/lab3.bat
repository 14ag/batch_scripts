::@echo off
goto :2

:2
set /a "settimeoutx=0"
set /a "settimeouty=3"
call :settimeout 9 echo 9secs
echo %settimeoutx% XXXXXXXXXXXXXX
::call :settimeout 8 echo 8secs 
::call :settimeout 1 echo 1secs
::call :check_assync
echo all done
pause
goto :eof


:check_assync
echo "%settimeoutx%"=="%settimeouty%"
if not "%settimeoutx%"=="%settimeouty%" pause & goto :check_assync
exit /b 0


:increment
set /a "settimeoutx+=1" >nul
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
::start /b cmd /c "%settimeoutx% >nul 2>&1 & timeout /t %t% /nobreak >nul & %command% & ( set /a "settimeoutx=%1" & set /a "settimeoutx+=1") >nul echo %settimeoutx%"
set command2=start /b cmd /c "%settimeoutx% ^>nul 2^>^&1 ^& ^( set /a "settimeoutx=%1" ^& set /a "settimeoutx+=1") ^>nul ^& echo %settimeoutx%"
for /f "tokens=1" %%a in ('%command2%') do set settimeoutx=%%a 
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