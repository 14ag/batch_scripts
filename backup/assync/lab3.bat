
@echo off
setlocal enabledelayedexpansion

for /l %%v in (1,50,250) do (
    set "start=%%v"
    set /a "stop=!start!+49"
    if !start! equ 241 set /a "stop=!start!+13"
    for /l %%w in (!start!,10,!stop!) do (
        set "ipRangeStart=%%w"
        set /a "ipRangeStop=!ipRangeStart!+9"
        if !ipRangeStart! equ 241 set /a "ipRangeStop=!ipRangeStart!+13"
        echo !ipRangeStart!-!ipRangeStop!
    )
    echo.
)
pause
exit

    set "stop=!start!+%checkrange%"
     
