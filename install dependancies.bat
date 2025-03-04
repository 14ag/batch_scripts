@echo off
setlocal enabledelayedexpansion


cd /d "%currentDirectory%"

for %%i in (*.appx, *.msix, *.appxbundle) do (
    echo Installing %%i...
    powershell -Command "Add-AppxPackage -Path '%%i'"
    if !errorlevel! neq 0 (
        echo Failed to install %%i
    ) else (
        echo Successfully installed %%i
    )
)


pause
