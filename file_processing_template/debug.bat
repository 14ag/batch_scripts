@echo off
title debug
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:debug
::define "logpath" and "newLogFile=" before your code
if "%debug%"=="0" @exit /b 0 >nul 2>&1
if not defined debug @exit /b 0 >nul 2>&1
set "log=%*"
set "tstamp="

setlocal enabledelayedexpansion
for /f "tokens=1-2 delims= " %%x in ('time /t') do (

	for /f "tokens=1-3 delims=:" %%y in ("%%x") do (
		endlocal & set "tstamp=[%%y:%%z]"
	)	)
	
if not defined newLogFile (
	set "newLogFile=1"
	echo %tstamp% : script started > %LOGPATH%debug.log
	)
echo %tstamp% : %log%>>%LOGPATH%debug.log 2>nul

@exit /b 0 >nul 2>&1