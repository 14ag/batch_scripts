::@echo off
set x=0

doskey command2=cmd /v:on /c "%x% ^>nul 2^>^&1 ^& set /a "y=%x%" ^>nul ^& set /a "y+=1" ^>nul ^& echo !y!"
command2

setlocal enabledelayedexpansion
for /f "tokens=1" %%a in ('command2') do set x=%%a 
echo %x%_!x!
pause
exit /b
pause
:: i want to increase %x% by passing it to a child cmd as the argument %1 then assign it to %x% 
::and then retrieve it using echo and reassign using a for /f loop. i must use 'start /b cmd /c'. no temporary files should be created.