@echo off
rem date parser
setlocal enabledelayedexpansion
:: hh mm
for /f "tokens=1-3 delims=:" %%a in ('time /t') do (
	echo x%%a x%%b x%%c
	)
::dd mm yyyy
for /f "tokens=1-3 delims=/" %%a in ('date /t') do (
	echo x%%a x%%b x%%c
	)
endlocal
pause
exit /b