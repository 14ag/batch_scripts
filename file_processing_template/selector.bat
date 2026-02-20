@echo off
title selector
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:selector
:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector arg1,arg2,arg3,...
setlocal enabledelayedexpansion
set "selector="
set "arg_string=%*"
set "i=0"
set "choicelist="
:: Replace every comma with a quote, a space, and another quote (" ") and Wrap the entire resulting string in quotes
set "arg_list="%arg_string:,=" "%""
rem Loop through the new quoted, space-separated list
for %%y in (%arg_list%) do (
	set /a i+=1

	:: Create dynamic variable names (_1, _2, etc.)
	for %%z in (_!i!) do (

		set "%%z=%%y"
		set "choicelist=!choicelist!!i!"
        set "display_value=%%y"
        set "display_value=!display_value:"=!"
		echo   [!i!].. !display_value!
	)   )

call :reset_choice

choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%y in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%y (

		for %%z in (!_%%y!) do (
				endlocal & set "selector=%%z"
				goto :break
    )   )   )
:break
set "selector=%selector:"=%"
exit /b %errorlevel%


:reset_choice
:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
exit /b 0