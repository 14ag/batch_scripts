@echo off
(
echo %* | find "-help" 2>&1 >nul
) && (
:: goto :hel_p
:: :hel_p
echo help goes here
exit /b
)

:adb_device
:: Make list of ADB devices
setlocal enabledelayedexpansion
set i=0
set sum_of_devices=0

:: Loop through ADB devices, skipping the "List of devices attached" line
for /f "eol=L tokens=1" %%a in ('adb devices ^| findstr "device"') do (
    set /a i+=1
    :: Create dynamic variable names (device_1, device_2, etc.) and assign device IDs
    for /f "tokens=1" %%b in ('echo device_!i!') do (
        set %%b=%%a
        set /a sum_of_devices+=1
    )
)

:: check for connected devices
if !sum_of_devices!==0 echo no devices connected & exit /b

:: use the default device 
if !sum_of_devices!==1 set id=1 & goto set_adb_device

:device_selector
:: store devices in variable
for /l %%c in (1, 1, !sum_of_devices!) do (
	set list_of_devices=%list_of_devices% "device_%%c:_!device_%%c!" 
	)
set0 id=device_selector !sum_of_devices! !list_of_devices!
	

:set_adb_device
:: Set the selected device as a variable that persists outside the local scope
for /f "tokens=1" %%d in ("device_%id%") do (
	for /f "tokens=1" %%e in ('set %%d') do (
		for /f "tokens=2 delims==" %%f in ("%%e") do (
			set x=%%f
		)
    )
)
endlocal & set device=%x%
echo %device%











