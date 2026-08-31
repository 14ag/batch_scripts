@echo off
setlocal enabledelayedexpansion

set "BKROOT=D:\backup"
set "BK2ROOT=D:\backup2"
set "LISTFILE=backup-directories.txt"

call :Main
exit /b 0

rem -------------------------------------------------------

:Main
for /f "usebackq eol=| delims=" %%L in ("%LISTFILE%") do (
    if not "%%L"=="" call :Process "%%L"
)
exit /b

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
        call :backup "%~1" "%BK2%" "nul" /E
    ) else (
echo process
        call :backup "%~dp1" "%BK2ROOT%%~p1" "%~nx1" 
    )
    exit /b
)
rem backup exists route to dir or file handler
if exist "%~1\*" (
    call :CmpDir "%~1" "%BKUP%" "%BK2%"
) else (
    call :CmpFile "%~1" "%BKUP%" "%BK2%"
)
exit /b

rem -------------------------------------------------------

:CmpDir
rem listonly compare source vs backup
rem exit 0 means no files differ identical per MS KB954404
rem exit 1 means files would be copied ie differ
call :backup "%~1" "%~2" "/E /L /XX"
if !ERRORLEVEL! EQU 0 (
    call :backup "%~2" "%~3" "/E /MOVE"
) else (
    call :backup "%~1" "%~3" "nul" /E
)
exit /b

rem -------------------------------------------------------

:CmpFile
set "H1="
set "H2="
call :Hash "%~1" H1
call :Hash "%~2" H2
if "!H1!" == "!H2!" (
    call :backup "%~dp2" "%~dp3" "%~nx2" /MOVE
) else (
)
exit /b

rem -------------------------------------------------------

:Hash
rem filter header and footer lines certutil and hash keyword
rem tokens 1 grabs hex string only goto eof exits on first hit
for /f "tokens=1" %%H in ('certutil -hashfile "%~1" SHA256 2^>nul ^| findstr /v /i /c:"certutil" /c:"hash"') do (
    set "%~2=%%H"
    goto :eof
)
exit /b



:backup
set "source=%1"
set "source=%source:"=%"
if "%source:~-1%"=="\" set "source=%source:~0,-1%"

set "dest=%2"
set "dest=%dest:"=%"
if "%dest:~-1%"=="\" set "dest=%dest:~0,-1%"

set "file=%3"
if "%file%"=="nul" (
    set "file="
) else (
    set "file=%file:"=%"
)

set "flags=%4"
if defined flags set "flags=%flags:"=%"

robocopy "%source%" "%dest%" "%file%" %flags% /XA:S /XJ /xo /xn /xc /njh /ndl /nfl
exit /b
