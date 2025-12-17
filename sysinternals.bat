@echo off
if "%1"=="-h" (
	echo systeminternals [tool]
	echo.
	echo tools:
	powershell ls "C:\Program_Files\utilities\systeminternals"
	powershell ls "C:\Program_Files\utilities\x64"
	)
if exist "C:\Program_Files\utilities\systeminternals\%1.exe" (
	start "%1" "C:\Program_Files\utilities\systeminternals\%1.exe"
	)
if exist "C:\Program_Files\utilities\x64\%1.exe" (
	start "%1" "C:\Program_Files\utilities\x64\%1.exe"
	)
exit /b