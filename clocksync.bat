@echo off
setlocal
for /F "tokens=1-6" %%a in ('adb shell date') do (
	set "month=%%b"
	set "day=%%c"
	set "time=%%d"
	set "year=%%f"
	)
REM Convert month abbreviation to a number
for %%x in ("Jan=01" "Feb=02" "Mar=03" "Apr=04" "May=05" "Jun=06" "Jul=07" "Aug=08" "Sep=09" "Oct=10" "Nov=11" "Dec=12") do (
    for /F "tokens=1,2 delims==" %%i in (%%x) do (
        if "%%i"=="%month%" set "month=%%j"
		)
	)
REM Format time in HH:MM:SS format
set "nowClock=%time:~0,8%"
REM Format date in MM/DD/YYYY format
set "nowDate=%day%/%month%/%year%"
rem setting time
time %nowClock%
date %nowDate%
endlocal
