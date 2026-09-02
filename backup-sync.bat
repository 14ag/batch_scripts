@echo off
setlocal enabledelayedexpansion

set "BKROOT=D:\backup"
set "BK2ROOT=D:\backup2"
set "LISTFILE=backup-directories.txt"

for /f "usebackq eol=| delims=" %%L in ("%LISTFILE%") do (
    if not "%%L"=="" call :Process "%%L"
)
exit /b 0


rem -------------------------------------------------------

:Process
rem guard empty or missing path
if "%~1"=="" exit /b
if not exist "%~1" exit /b


rem build backup paths using tilde expansion not substring slice
set "BKUP=%BKROOT%%~p1%~nx1"
set "BK2=%BK2ROOT%%~p1%~nx1"

if not exist "%BKUP%" (
    rem no backup exists copy source directly to backup2
    if exist "%~1\*" (
        for /R "%~1" %%F in (*) do (
			call :backup "%%~dpF" "%BK2ROOT%%%~pF" "%%~nxF" || ( echo could not process _%source%\%file%_ _%flags%_ & echo _%%F_ )	
		)
    ) else (
        call :backup "%~dp1" "%BK2ROOT%%~p1" "%~nx1" 
    )
    exit /b
)

rem backup exists route to file handler
if exist "%~1\*" (
	for /R "%~1" %%G in (*) do (
		call :CmpFile "%%~G" "%BKUP%" "%BK2%"
	)
) else (
    call :CmpFile "%~1" "%BKUP%" "%BK2%"
)
exit /b


:CmpFile
set "H1="
set "H2="
call :Hash "%~1" H1
call :Hash "%~2" H2
if "!H1!" == "!H2!" (
    call :backup "%~dp2" "%~dp3" "%~nx2" "/MOVE "
) else (
)
exit /b


:Hash
rem filter header and footer lines certutil and hash keyword
rem tokens 1 grabs hex string only goto eof exits on first hit
for /f "tokens=1" %%H in ('certutil -hashfile "%~1" SHA256 2^>nul ^| findstr /v /i /c:"certutil" /c:"hash"') do (
    set "%~2=%%H"
)
exit /b


:backup
rem %~1 and not %1 because %~1 safely removes quotes
set "source=%~1"
if "%source:~-1%"=="\" set "source=%source:~0,-1%"

set "dest=%~2"
if "%dest:~-1%"=="\" set "dest=%dest:~0,-1%"

set "file=%~3"
set "file=%file:"=%"


rem there should be a white space after the flag see line57
set "flags=%~4"

robocopy "%source%" "%dest%" "%file%" %flags%/XA:S /XJ /xo /xn /xc /njh /ndl /nfl >nul 2>&1

exit /b
:end