@echo off

REM define "source_directory" variable here without quotes
set source_directory=C:\Users\Administrator\Sauce\sendoff
:install
set work_dir=%source_directory%
REM set drop=/storage/emulated/0/

if not defined source_directory (
	set /p source_directory="define source_directory variable here without quotes: "
	cls
	goto :install
)

:: make folder for dropping packages
if not exist %work_dir% mkdir %work_dir% 2>&1 >nul
adb shell if [ -d %drop% ]; then mkdir %drop%; fi 2>&1 >nul
cd /d "%work_dir%"

::apps
	
REM copy /y "%source_directory%\*.apk" "%work_dir%\*.apk" 2>&1 >nul
	
:: get list of apps (apk files)
for /r %%i IN (*.apk) do (
	rEM This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	REM This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	:: install list of apks and cleanup
	adb install "%%i" 2>&1 >nul
	) && (
		del /q "%%i" 2>&1 >nul
		) && (
			:: success
			echo %%~nxi installed
			echo.
			echo.
			)
	) || (
	:: failed
	echo %%~nxi not installed
	echo.
	echo.
	)
)
cls
::zips


REM copy /y "%source_directory%\*.zip" "%work_dir%\*.zip" 2>&1 >nul
setlocal enabledelayedexpansion
:: getlist of modules (zip files)
for /r %%j IN (*.zip) do (
	adb push --sync "%%j" "!drop!" 2>nul
	(
	echo.
	(
	:: install modules
	REM Prepare the module path, escaping special characters
	set "module=!drop!/%%~nxj"
	set "module=!module:'='"'"'!"
	
	REM Install the module
	adb shell "su -c 'magisk --install-module \"!module!\"'" 
	) && (
		:: success cleanup
		echo %%~nxj installed
		adb shell rm \"!module!\" 2>&1 >nul
		del /q "%%j" 2>&1 >nul
		echo.
		echo.
		) 
	) || (
	:: failed
	echo %%~nxj not installed
	adb shell "su -c 'rm -f \"!module!\"'" 2>&1 >nul
	echo.
	echo.
	)
)

pause