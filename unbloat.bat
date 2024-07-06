@echo off
start cmd /k adb shell pm list packages ^| sort
:loop
setlocal ENABLEDELAYEDEXPANSION
SET /P PACKAGE="package : "
adb shell pm uninstall --user 0 %package%
if errorlevel 1 (
	echo using force...
	adb shell pm disable-user --user 1 %package%
	)
endlocal
goto loop