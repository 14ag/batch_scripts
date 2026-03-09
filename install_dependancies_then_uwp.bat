@echo off
setlocal enabledelayedexpansion

set currentDirectory=%cd%
echo %currentDirectory%

cd /d "%currentDirectory%"

for %%i in (*.appx, *.msix) do (
    echo Installing %%i...
    powershell -Command "Add-AppxPackage -Path '%%i'"
    if !errorlevel! neq 0 (
        echo Failed to install %%i
    ) else (
        echo Successfully installed %%i
    )
)

for %%i in (*.appxbundle,*.msixbundle) do (
    echo Installing %%i...
    powershell -Command "Add-AppxPackage -Path '%%i'"
    if !errorlevel! neq 0 (
        echo Failed to install %%i
    ) else (
        echo Successfully installed %%i
    )
)

pause
