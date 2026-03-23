@echo off
set "path_=C:\Users\philip\AppData\Roaming\game\Uninstall"

:: Extract the last element using path modifiers
if "!old_cursor_path:~-1!"=="\" set "old_cursor_path=!old_cursor_path:~0,-1!"
for %%I in ("!old_cursor_path!") do set "folder_name=%%~nxI"

echo %folder_name%
pause