@echo off
start cmd /k adb shell pm list packages ^| sort
:loop
SET /P PACKAGE="package : "
adb shell pm uninstall --user 0 %package% 2>&1 >nul
if errorlevel 1 (
	echo using force...
	adb shell pm disable-user --user 0 %package% 2>&1 >nul || echo failed to disable %package%
	)
goto loop