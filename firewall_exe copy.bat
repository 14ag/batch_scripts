@echo off

:: set variables
setlocal
set "extensions=*.exe"
set "currentDirectory=%~dp0"
set "currentDirectory=%currentDirectory:~0,-1%"
set "currentDirectory=%currentDirectory:"=%"
set "errors="
set "infos="
set "files="
set "loop="
set "OTHER_SCRIPT=%userprofile%\sauce\batch_scripts\fire_wall.bat"

where %OTHER_SCRIPT% >nul 2>&1
if errorlevel 1 (
    set "errors=a callback script is required"
    call error
    exit /b 1
)

:: drag and drop
if "%~1"=="" (
    set "infos=you can Drag and drop a folder onto this script."
    call :info
    goto getVars
) else (
    set "files=%~1"
    goto check
)

:: get variables
:getVars
:: sets loop to happen if drag and drop is not happening
set "loop=1"
set "infos=Press Enter to process all %extensions%s in the current directory"
call :info
set /p "files=::"
:: check if the current directory has any files
if "%files: =%"=="" (
cd %currentDirectory%
    dir /b %extensions% 2>nul | find "." >nul
    if errorlevel 1 (
        set "errors=No compatible files found in current directory."
        goto error
    )
    cls
    set "infos=Found the following files:"
    call :info
    for /r "%currentDirectory%" %%i in (%extensions%) do (
        echo %%~nxi
    )
    :: confirm install all files in the current directory
    call :resetChoice
    CHOICE /C yn /N /M "continue? y = Yes, n = No"
    if %errorlevel% equ 2 (
        pause
        goto :getVars
    ) else if %errorlevel% equ 1 (
        set "ok_count=0"
        set "error_count=0"
        :: install all files in the current directory
        for /r "%currentDirectory%" %%i in (%extensions%) do (
            set "files="%%~i""
            call :install
            if errorlevel 0 set /a "ok_count+=1"
        )
        :: show number of files installed successfully
        set "infos=done. %ok_count% files processed successfully."
        call :info
        goto end
    )
) else (
    call :check
    goto :end
)


:check
:: handle quotes in the file path omg
for %%i in ("%files:"=%") do (
        set "files=%%~i"
    )
:: validate file type
if exist "%files%" (
    if /i not "%files:~-5%"==".appx" (
        if /i not "%files:~-5%"==".msix" (
            if /i not "%files:~-11%"==".appxbundle" (
                set "errors=not a supported file."
                goto error
            )
        )
    )
) else (
    set "errors=file not found."
    goto error
)

goto install


:install
cls
set "infos=Installing '%files%'..."
call :info
:: Install the file using PowerShell command 
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Add-AppxPackage -Path '%files%' -ForceDeployment -ErrorAction Stop } catch { exit 1 }" >nul 2>&1

:: feedback on install
if errorlevel 1 (
    set "errors=file installation failed. Check for error messages above."
    call :error
) else (
    set "infos= ok."
    call :info
    echo.
    pause
    exit /b 0
)

:: reset errorlevel for correct choice
:resetChoice
exit /b 0

:: error handling
:error
echo error: %errors%
set "errors="
pause
cls
goto getVars

:: info handling
:info
echo.
echo info: %infos%
set "infos="
echo.
exit /b 0

:: loops if drag and drop is not happening
:end
if "%loop%"=="1" (
    pause
    cls
    goto getVars
) else (
    exit /b 0
)
endlocal
