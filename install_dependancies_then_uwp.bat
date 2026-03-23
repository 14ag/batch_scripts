@echo off
setlocal enabledelayedexpansion

set "currentDirectory=%~dp0"
cd /d %currentDirectory%

set found=0

for %%i in (*.appx *.msix *.appxbundle *.msixbundle) do (
    if exist "%%i" (
        set found=1
        set "package=%%i"
        call :install
        call :errorHandling
    )
)

if !found! equ 0 (
    echo No packages found.
)

pause
endlocal
exit /b

:install
set "package=!package:"=!"
echo Installing !package!...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '!package!' -ForceApplicationShutdown -ForceUpdateFromAnyVersion"
exit /b

:errorHandling
if !errorlevel! neq 0 (
    echo Failed to install !package!
) else (
    echo Successfully installed !package!
)
exit /b