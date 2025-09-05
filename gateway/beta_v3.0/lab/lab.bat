@echo off
set x=q.w.e.rtyui

::learn trancating
 set y=%x:~0,-1%
 echo y="%y%"

:: learn parse into four tokens using "." as delimiter
@REM for /f "tokens=1-4 delims=." %%a in ("%x%") do (
@REM     echo %%a %%b %%c %%d
@REM )




@REM cscript //NoLogo "GetGateways_debug.vbs" verbose
@REM echo.
@REM echo.
@REM echo.
@REM for /f "delims=" %%G in ('cscript //NoLogo "GetGateways_debug.vbs" verbose') do set "gateways=%%G"
@REM echo using vbs   %gateways%



@REM set "get_gateways=ethernet_1.1.1.1 wifi_2.2.2.2 mobileHotspot_3.3.3.3"

@REM @REM if defined get_gateways (
@REM @REM 	for %%a in (%get_gateways%) do (
@REM @REM         for /f "tokens=1-2 delims=_" %%b in ("%%a") do (
@REM @REM             echo %%b %%c
@REM @REM             )
@REM @REM         )
@REM @REM     )

@REM call :selector ethernet_1.1.1.1,wifi_2.2.2.2,mobileHotspot_3.3.3.3
@REM echo selected %selector%
@REM pause
@REM exit

@REM :selector
@REM setlocal enabledelayedexpansion
@REM set "selector="
@REM set "arg_string=%*"
@REM set "i=0"
@REM set "choicelist="
@REM :: Replace every comma with a quote, a space, and another quote (" ") and Wrap the entire resulting string in quotes
@REM set "arg_list="%arg_string:,=" "%""
@REM echo Processing arguments:
@REM rem Loop through the new quoted, space-separated list
@REM for %%a in (%arg_list%) do (
@REM 	set /a i+=1
@REM 	:: Create dynamic variable names (_1, _2, etc.)
@REM 	for %%b in (_!i!) do (
@REM 		set "%%b=%%a"
@REM 		set "choicelist=!choicelist!!i!"
@REM         set "display_value=%%a"
@REM         set "display_value=!display_value:"=!"
@REM 		echo   [!i!].. !display_value!
@REM 	)   )

@REM call :reset_choice
@REM choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
@REM for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
@REM     if errorlevel %%c (
@REM     for %%d in (!_%%c!) do (
@REM             endlocal & set "selector=%%d"
@REM             goto :break
@REM     )   )   )
@REM :break
@REM set "selector=%selector:"=%"
@REM exit /b 0


@REM :reset_choice
@REM :: reset errorlevel for correct choice
@REM :: use immediately before choice command
@REM :: call :reset_choice
@REM exit /b 0















pause
