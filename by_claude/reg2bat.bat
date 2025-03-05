@echo off
setlocal enabledelayedexpansion

:: Check if a file was provided as an argument
if "%~1"=="" (
    echo Usage: %0 input.reg
    exit /b 1
)

:: Check if the input file exists
if not exist "%~1" (
    echo Error: File "%~1" not found.
    exit /b 1
)

:: Set the output file name
set "output=%~n1.bat"

:: Create the output file and write the header
(
    echo @echo off
    echo :: This script was generated from %~nx1
    echo.
    echo :: Disable echoing of commands
    echo @echo off
    echo.
    echo :: Check for administrator privileges
    echo net session ^>nul 2^>^&1
    echo if %%errorlevel%% neq 0 ^(
    echo     echo This script requires administrator privileges.
    echo     echo Please run as administrator.
    echo     pause
    echo     exit /b 1
    echo ^)
    echo.
) > "%output%"

:: Process the input file
for /f "usebackq delims=" %%a in ("%~1") do (
    set "line=%%a"
    
    :: ::ove quotes from the line
    set "line=!line:"=!"
    
    :: Skip empty lines and comments
    if not "!line!"=="" if not "!line:~0,1!"==";" if not "!line:~0,1!"=="[" (
        :: Extract the key and value
        for /f "tokens=1,* delims==" %%b in ("!line!") do (
            set "key=%%b"
            set "value=%%c"
            
            :: Escape special characters in the value
            set "value=!value:^=^^!"
            set "value=!value:&=^&!"
            set "value=!value:|=^|!"
            set "value=!value:<=^<!"
            set "value=!value:>=^>!"
            
            :: Write the REG ADD command to the output file
            echo REG ADD "!key!" /v "!value!" /f >> "%output%"
        )
    )
)

:: Add a pause at the end of the script
echo. >> "%output%"
echo pause >> "%output%"

echo Conversion complete. Output saved to %output%