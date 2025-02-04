@echo off
if "%~1" == "" goto usage
if "%~2" == "" goto usage
set programFullPath=%~1
set allowblock=%~2
set dir=%~3
if %dir%==all(
    set dir=out && call :main 
    set dir=in && goto main
)

:usage
echo Usage: %~nx0 "path\to\program.exe" allow^|block in^|out^|all
echo.

:getVars
set /p programFullPath="Type full path with the quotes :: "
REM if not exist "%programFullPath%" (
    REM echo Error: Invalid file path. Please try again.
    REM goto getVars
    REM )

echo.
echo 1. allow
echo 2. block
choice /c 12 /n /m "press 1  or  2 : "
if errorlevel 2 set allowblock=block
if errorlevel 1 set allowblock=allow

echo.
echo 1. in
echo 2. out
echo 3. all
choice /c 123 /n /m "press 1  or  2  or  3 : "
if errorlevel 3 (
    set dir=out && call :main 
    set dir=in && goto main
)
if errorlevel 2 set dir=out && goto main
if errorlevel 1 set dir=in && goto main


:main
for %%i in ("%programFullPath%") do set ruleName=%%~ni
netsh advfirewall firewall add rule name="%ruleName%" dir=%dir% program=%programFullPath% profile=any action=%allowblock%
exit /b