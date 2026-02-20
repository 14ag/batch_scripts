@echo off
title get_folder_name
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:get_folder_name
:: call :get_folder_name [path]
:: returns the name of the folder whose path was provided in the variable !get_folder_name!
set "path=%*"
:check_backslash
:: Check if the string contains a backslash
echo "%path%" | find "\" >nul && (
	:: Strip everything up to the first backslash and repeat
	set "path=%path:*\=%"
	goto :check_backslash
) || (
    set "get_folder_name=%path%"
)
exit /b %errorlevel%