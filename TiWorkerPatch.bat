@echo off
:: v1.2
:: set interaction to 1 for console logs

set interaction=0
set executableName=TiWorker.exe
if "interaction"=="1" echo hey. ill take it from here
:patch
:: (search) && ((found) && (killed) || (unkilled)) || (unfound)
(
tasklist | find /I /N "%executableName%%" >nul 2>&1
) && (
	:: found
	:: This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	taskkill /f /im %executableName% >nul 2>&1
	) && (
		:: killed
		if "interaction"=="1" (
			if not defined x (
				echo gottem.
				set x=1
				) else (
				echo gottem again.
				)
			)
			goto wait
	) || (
		:: unkilled
		if "interaction"=="1" (
			echo sorry it came to this. this script is now weak
			pause >nul
			) else (
			msg %USERNAME% /server:%COMPUTERNAME% sorry it came to this. this script is now weak
			)
		exit /b
	)
) || (
	:: unfound
	goto wait
)
:wait
timeout /t 25 /nobreak >nul
goto patch