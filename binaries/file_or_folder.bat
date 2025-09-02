@echo off
set "pathToCheck=C:\Users\philip\sauce\batch_scripts\dpi.txt"
call :file_or_folder "%pathToCheck%"
echo %file_or_folder%


set "pathToCheck=C:\Users\philip\sauce\batch_scripts\"
call :file_or_folder "%pathToCheck%"
echo %file_or_folder%

exit/b


:file_or_folder
setlocal enabledelayedexpansion
set "b=%1"
set "b=%b:"=%"
for %%I in ("%b%") do (
    set "attrs=%%~aI"
    echo !attrs!
    REM Check if the first attribute is 'd' (directory)
    if "!attrs:~0,1!" == "d" (
        endlocal & set "file_or_folder=folder" 
    ) else (
        endlocal & set "file_or_folder=file"
    )   )
exit/b