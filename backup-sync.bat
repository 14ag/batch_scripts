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
        robocopy "%~1" "%BK2%" /E /XA:S /XJ /xo /xn /xc /njh /ndl /nfl >nul 2>&1
    ) else (
        robocopy "%~dp1" "%BK2ROOT%%~p1" "%~nx1" /XA:S /XJ /xo /xn /xc /njh /ndl /nfl >nul 2>&1
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
robocopy "%~1" "%~2" /L /E /XX /XA:S /XJ >nul 2>&1
if !ERRORLEVEL! EQU 0 (
    robocopy "%~2" "%~3" /E /MOVE /XA:S /XJ /xo /xn /xc /njh /ndl /nfl>nul 2>&1
) else (
    robocopy "%~1" "%~3" /E /XA:S /XJ /xo /xn /xc /njh /ndl /nfl>nul 2>&1
)
exit /b

rem -------------------------------------------------------

:CmpFile
set "H1="
set "H2="
call :Hash "%~1" H1
call :Hash "%~2" H2
if "!H1!" == "!H2!" (
    robocopy "%~dp2" "%~dp3" "%~nx2" /MOVE /XA:S /XJ /xo /xn /xc /njh /ndl /nfl>nul 2>&1
) else (
    robocopy "%~dp1" "%~dp3" "%~nx1" /XA:S /XJ /xo /xn /xc /njh /ndl /nfl>nul 2>&1
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
