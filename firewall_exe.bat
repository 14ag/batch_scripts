
@echo off
rem usage:  firewall_exe.bat "path\to\target folder"
setlocal enabledelayedexpansion

rem Define the directory to search (current directory by default)
set "SEARCH_DIR=%CD%"

rem If an argument is provided, use it as the directory
if "%~1" NEQ "" (
    set "SEARCH_DIR=%~1"
)

:loop
if "SEARCH_DIR" == "" (
	set x=1
    set /p "SEARCH_DIR=search_dir?? ::"
)
rem Define the path to the second script (adjust this as needed)
set "OTHER_SCRIPT=c:\users\philip\sauce\batch_scripts\fire_wall.bat"

rem Recursively search for .exe files and pass each path to the second script
for /r "%SEARCH_DIR%" %%F in (*.exe) do (
    call "%OTHER_SCRIPT%" "%%F" block all
)

endlocal
if "%x%" == "1" (
	pause
    goto :loop
)

exit /b