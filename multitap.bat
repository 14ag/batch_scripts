@echo off

:: i made this for multitapping phone using adb
title waiting
::time to tap out 848
echo waiting for active task
timeout /t 5 /nobreak 
taskkill /fi "IMAGENAME eq cmd.exe" /fi "CPUTIME gt 00:00:15" /im *

:: time to refill energy 1905
echo waiting for energy refill
timeout /t 10 /nobreak
title active
start multitap
echo tapping
:tap
adb shell input tap 566 1449 2>&1 >nul
goto tap