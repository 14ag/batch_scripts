@echo off


call :adb_list

rem define "source_directory" variable here without quotes
set source_directory=C:\Users\Administrator\Sauce\sendoff
:install
set work_dir=%source_directory%
set drop=/storage/emulated/0/drop
if not defined source_directory (
	set /p source_directory="define source_directory variable here without quotes: "
	cls
	goto :install
)



rem make folder for dropping packages
if not exist %work_dir% mkdir %work_dir%
adb -s %device% shell if [ ! -d %drop% ]; then mkdir %drop%; fi
pause
pushd "%work_dir%"

goto :zips
rem apps
rem copy /y "%source_directory%\*.apk" "%work_dir%\*.apk" 2>&1 >nul
	
rem get list of apps (apk files)
for /r %%i IN (*.apk) do (
	rem This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	rem This line does nothing by itself, but it prevents a syntax error
	echo >nul
	(
	rem install list of apks and cleanup
	adb -s %device% install "%%i"
	) && (
		del /q "%%i" 2>&1 >nul
		) && (
			rem success
			echo %%~nxi installed
			echo.
			echo.
			)
	) || (
	rem failed
	echo %%~nxi not installed
	echo.
	echo.
	)
)
cls

:zips
rem zips
rem copy /y "%source_directory%\*.zip" "%work_dir%\*.zip" 2>&1 >nul
setlocal enabledelayedexpansion

rem getlist of modules (zip files)
for /r %%j IN (*.zip) do (
	adb -s %device% push --sync "%%j" "!drop!" 
	(
	echo.
	(
	rem install modules
	rem Prepare the module path, escaping special characters
	set "module=!drop!/%%~nxj" 2>&1 >nul
	set "module=!module:'='"'"'!" 2>&1 >nul
	rem Install the module
	adb -s %device% shell "su -c 'magisk --install-module \"!module!\"'" 
	) && (
		rem success cleanup
		echo %%~nxj installed
		adb -s %device% shell rm -f \"!module!\" 2>&1 >nul
		del /q "%%j" 2>&1 >nul
		echo.
		echo.
		) 
	) || (
	rem failed
	echo %%~nxj not installed
	echo install manually from folder %drop%
	rem adb -s %device% shell rm -f \"!module!\" 2>&1 >nul
	echo.
	echo.
	)
)



pause
exit



:adb_list
rem Make list of ADB devices
setlocal enabledelayedexpansion
set i=0
set sum_of_devices=0



rem Loop through ADB devices, skipping the "List of devices attached" line
for /f "eol=L tokens=1" %%a in ('adb devices ^| findstr "device"') do (
 set /a i+=1
 rem Create dynamic variable names (device_1, device_2, etc.) and assign device IDs
 for /f "tokens=1" %%b in ('echo device_!i!') do (
 set %%b=%%a
 set /a sum_of_devices+=1
 )
)



rem check for connected devices
if !sum_of_devices!==0 echo no devices connected & pause & exit

rem use the default device 
if !sum_of_devices!==1 set id=1 & goto set_adb_device




:device_selector
rem Display list of detected devices
for /l %%c in (1, 1, !sum_of_devices!) do echo device_%%c: !device_%%c!

rem Prompt user to choose a device
set id= & set /p id="Choose a device: "

rem Validate user's selection
(
 set device_%id% 2>&1 >nul
) || (
 cls
 echo Invalid choice
 echo.
 goto device_selector
)



:set_adb_device
rem Set the selected device as a variable that persists outside the local scope
for /f "tokens=1" %%d in ("device_%id%") do (
	for /f "tokens=1" %%e in ('set %%d') do (
		for /f "tokens=2 delims==" %%f in ("%%e") do (
			set x=%%f
		)
 )
)



endlocal & set device=%x%
exit /b
