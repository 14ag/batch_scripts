@echo off
set x=q.w.e.rtyui

::learn trancating
REM set y=%x:~-1,1%
REM echo y= %y%

:: learn parse into four tokens using "." as delimiter
@REM for /f "tokens=1-4 delims=." %%a in ("%x%") do (
@REM     echo %%a %%b %%c %%d
@REM )




@REM cscript //NoLogo "GetGateways_Strict_Debug.vbs" verbose

@REM echo.
@REM echo.
@REM echo.
@REM for /f "delims=" %%G in ('cscript //NoLogo "GetGateways_Strict_Debug.vbs"') do set "gateways=%%G"
@REM echo using vbs   %gateways%



set "get_gateways=ethernet_1.1.1.1 wifi_2.2.2.2 mobileHotspot_3.3.3.3"

@REM if defined get_gateways (
@REM 	for %%a in (%get_gateways%) do (
@REM         for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
@REM             echo %%b %%c
@REM             )
@REM         )
@REM     )

call :selector ethernet_1.1.1.1,wifi_2.2.2.2,mobileHotspot_3.3.3.3
echo selected %selector%
pause
exit

:selector
setlocal enabledelayedexpansion
set "selector="
set "arg_string=%*"
set "i=0"
set "choicelist="
:: Replace every comma with a quote, a space, and another quote (" ") and Wrap the entire resulting string in quotes
set "arg_list="%arg_string:,=" "%""
echo Processing arguments:
rem Loop through the new quoted, space-separated list
for %%a in (%arg_list%) do (
	set /a i+=1
	:: Create dynamic variable names (_1, _2, etc.)
	for %%b in (_!i!) do (
		set "%%b=%%a"
		set "choicelist=!choicelist!!i!"
        set "display_value=%%a"
        set "display_value=!display_value:"=!"
		echo   [!i!].. !display_value!
	)   )

call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
set "selector=%selector:"=%"
exit /b 0


:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0















pause
