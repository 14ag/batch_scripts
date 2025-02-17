@echo off
rem the lessi nteractive version
set executableName=TiWorker.exe
:patch
(
tasklist | find /I /N "%executableName%" >nul 2>&1
) && (
	:: found
	REM This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	taskkill /f /im %executableName% >nul 2>&1
	) && (
		:: killed
		goto wait
	) || (
		:: unkilled
		msg %USERNAME% /server:%COMPUTERNAME% sorry it came to this. this script is now weak
		exit /b
	)
) || (
	:: unfound
	goto wait
)
:wait
timeout /t 25 /nobreak >nul
goto patch