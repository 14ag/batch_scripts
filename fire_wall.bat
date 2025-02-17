@echo off
REM     Usage: fire_wall.bat "path\to\program.exe" ^[allow^|block^] ^[in^|out^|all^]

setlocal enabledelayedexpansion
set "program_full_path="%~1""
set "allow_block=%~2"
set "dir=%~3"

REM Validate path parameter
if "%~1"=="" goto usage

REM Validate rule parameter
set "items=0"
set "count=0"
for %%i in (allow,block) do (
	if not "%allow_block%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
if "%count%" geq "%items%" goto usage

REM Validate dir parameter
set "items=0"
set "count=0"
for %%i in (in,out,all) do (
	if not "%dir%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
if "%count%" geq "%items%" goto usage

rem lesgooooooo
goto :subRoutine

:getVars
set "program_full_path="
set /p "program_full_path=Type full path with quotes :: "
REM Uncomment file existence check if needed
REM if not exist "%program_full_path%" (
REM     echo Error: Invalid file path.
REM     goto getVars
REM )


:allow_blockChoice
call :resetChoice
echo.
echo 1. allow
echo 2. block
choice /c 12 /n /m "Press 1 or 2: "
if errorlevel 2 (
    set "allow_block=block"
) else if errorlevel 1 (
    set "allow_block=allow"
)

:dirChoice
call :resetChoice
echo.
echo 1. in
echo 2. out
echo 3. all
choice /c 123 /n /m "Press 1 or 2 or 3: "
if errorlevel 3 (
    set "dir=all"
) else if errorlevel 2 (
    set "dir=out"
) else if errorlevel 1 (
    set "dir=in"
)

:subRoutine
if "%dir%"=="all" (
    set "dir=out"
    call :main
    set "dir=in"
    call :main
    goto :eof
	) else (
		call :main
		goto :eof
		)

:main
for %%i in ("%program_full_path%") do set "rule_name=%%~ni"
netsh advfirewall firewall add rule name="%rule_name%" dir=%dir% program=%program_full_path% profile=any action=%allow_block% enable=yes
exit /b

:usage
echo.
echo Usage: %~nx0 "path\to\program.exe" ^[allow^|block^] ^[in^|out^|all^]
echo.
goto getVars

:resetChoice
exit /b 0

:eof
pause
exit /b