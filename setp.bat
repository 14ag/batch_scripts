@echo off
setlocal
set currentDirectory=%CD%

set "c=0"
for %%a in ("%PATH:;=" "%") do (
	if /i "%%~a"=="%currentDirectory%" (
		set /a c+=1
		)  
	)

if "%c%" lss "1" (
	setx path "%currentDirectory%;%path%" /M
	echo Current directory added to PATH.
	) ELSE (
		echo Current directory is already in PATH.
		)

endlocal
pause
exit /b
