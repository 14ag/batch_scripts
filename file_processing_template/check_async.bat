@echo off
title check_async
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:check_async
set "count=0"
:check_async0
setlocal enabledelayedexpansion
if %count% equ 61 echo ##001 something went wrong & goto :eoff
set /a "count+=1"
if not exist "foo" (
	timeout /t 1 /nobreak >nul 2>&1
	goto :check_async
	)
for /f "usebackq delims=" %%i in (%foo%) do (

	set "line=%%i"
	(
	echo !progress_id! | find "!line!" >nul
	) || (
		set "progress_id=!line!!progress_id!"
	)	)

for /l %%i in (1,1,%set_timeout%) do (
	for /f "tokens=2 delims==" %%j in ('set task_id_%%i') do ( set "task_id=%%j" )
	(
	echo !progress_id! | find "!task_id!" >nul
	) && (
	) || (
		timeout /t 1 /nobreak >nul 2>&1
		goto :check_async0
	)	)

set "check_async="
del %foo% >nul 2>&1
endlocal
exit /b %errorlevel%