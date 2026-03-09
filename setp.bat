@echo off
setlocal
set currentDirectory=%~dp0
set currentDirectory=%currentDirectory:~0,-1%
echo %currentDirectory%
pause
set "c=0"
for %%a in ("%PATH:;=" "%") do (
	if /i "%%~a"=="%currentDirectory%" (
		set /a c+=1
		)  
	)

if "%c%" lss "1" (
	setx path "%currentDirectory%;%path%" /M 2>&1 >nul && echo Current directory added to PATH. || echo failed.
	) ELSE (
		echo Current directory is already in PATH.
		)

endlocal
pause
exit /b
