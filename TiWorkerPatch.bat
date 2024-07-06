@echo off
set executableName=TiWorker.exe
echo hey. ill take it from here
:patch
(
tasklist | find /I /N "%executableName%%" >nul 2>&1
) && (
	:: found
	REM This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	taskkill /f /im %executableName% >nul 2>&1
	) && (
		:: killed
		if not defined x (
		echo gottem.
		set x=1
		goto wait
		)
		echo gottem again.
	) || (
		:: unkilled
		echo sorry it came to this. this script is now weak
		pause >nul && exit /b
	)
) || (
	:: unfound
	goto wait
)
:wait
timeout /t 25 /nobreak >nul
goto patch