@echo off
setlocal

if "%~1"=="" (
    echo Drag and drop an .appx or .appxbundle file onto this script.
    pause
    exit /b 1
)

set "package=%~1"

echo Installing package: "%package%"

if not exist "%package%" (
    echo Error: Package not found.
    pause
    exit /b 1
)

if /i not "%package:~-5%"==".appx" if /i not "%package:~-10%"==".appxbundle" (
    echo Error: Invalid file type. Only .appx and .appxbundle files are supported.
    pause
    exit /b 1
)

:: Check if Add-AppxPackage is available (PowerShell)
where powershell >nul 2>&1
if errorlevel 1 (
    echo Error: PowerShell is required to install Appx packages.
    pause
    exit /b 1
)

:: Install the package using PowerShell. The -ForceDeployment option is useful for updates.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%package%'"

if errorlevel 1 (
    echo Error: Package installation failed. Check for error messages above.
    pause
    exit /b 1
) else (
    echo Package installed successfully.
)

pause
endlocal