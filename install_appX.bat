:: This script installs .appx, .msix, and .appxbundle packages using PowerShell.
:: Usage: Drag and drop a package onto this script or run it to install all packages in the current directory.
@echo off
:: Check if Add-AppxPackage is available (PowerShell)
where powershell >nul 2>&1
if errorlevel 1 (
    echo Error: PowerShell is required to install Appx packages.
    pause
    exit /b 1
)

setlocal

set "errors="
set "infos="
set "package="
set "loop="

if "%~1"=="" (
    set "loop=1"
    goto getVars
) else (
    set "infos=you can Drag and drop an .appx or .appxbundle file onto this script."
    call :info
    set "package=%~1"
    goto check
)


:getVars
cls
set "infos=Press Enter to install all packages in the current directory"
call :info
set /p "package= or enter the path of the package: " >nul
if "%package%"=="" (
    dir /b *.appx *.msix *.appxbundle 2>nul | find "." >nul
    if errorlevel 1 (
        set "errors=No compatible packages found in current directory."
        goto error
    )
    cls
    set "infos=Found the following packages:"
    call :info
    for %%i in (*.appx *.msix *.appxbundle) do (
        echo %%i
    )
    call :resetChoice
    CHOICE /C yn /N /M "continue? y = Yes, n = No"
    if %errorlevel% equ 2 (
        goto :getVars
    ) else if %errorlevel% equ 1 (
        set "ok_count=0"
        set "error_count=0"
        for %%i in (*.appx, *.msix, *.appxbundle) do (
            set "package=%%i"
            call :install
            if errorlevel 0 set /a "ok_count+=1"
        )
        set "infos=done. %ok_count% packages installed successfully."
        call :info
        goto end
    )
) else (
    call :check
    goto :end
)


:check
if exist "%package%" (
    if /i not "%package:~-5%"==".appx" if /i not "%package:~-10%"==".appxbundle" if /i not "%package:~-4%"==".msix" (
    set "errors=Invalid file type. Only .appx .msix and .appxbundle files are supported."
    goto error
    )
) else (
    set "errors=Package not found."
    goto error
)
goto install
:install
set "infos=Installing '%package%'..."
call :info
:: Install the package using PowerShell. The -ForceDeployment option is useful for updates.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Add-AppxPackage -Path '%package%' -ForceDeployment -ErrorAction Stop } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    set "errors=Package installation failed. Check for error messages above."
    call :error
) else (
    set "infos= ok."
    call :info
    echo.
)
exit /b 0


:resetChoice
exit /b 0


:error
echo error: %errors%
set "errors="
pause
cls
goto getVars


:info
echo.
echo info: %infos%
set "infos="
echo.
exit /b 0


:end
if "%loop%"=="1" (
    goto getVars
) else (
    exit /b 0
)
endlocal
