@echo off
setlocal enabledelayedexpansion

:menu
cls
echo PowerShell Color Customizer
echo ==========================
echo 1. View current colors
echo 2. Modify a color
echo 3. Reset to default colors
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto viewcolors
if "%choice%"=="2" goto modifycolor
if "%choice%"=="3" goto resetcolors
if "%choice%"=="4" exit
goto menu

:viewcolors
echo.
echo Current PowerShell Colors:
echo --------------------------
for /l %%i in (0,1,15) do (
    set /a "colorNum=1000+%%i"
    set "colorName=ColorTable!colorNum:~-2!"
    for /f "tokens=2*" %%a in ('reg query "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v !colorName! 2^>nul') do (
        echo !colorName!: %%b
    )
)
pause
goto menu

:modifycolor
echo.
set /p colorNum="Enter color number to modify (0-15): "
set /a "colorNum=1000+%colorNum%"
set "colorName=ColorTable%colorNum:~-2%"
set /p colorValue="Enter new color value in hexadecimal (e.g., 00FF00 for green): "
reg add "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v %colorName% /t REG_DWORD /d 0x%colorValue% /f
echo Color updated successfully.
pause
goto menu

:resetcolors
echo.
echo Resetting colors to default...
reg delete "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /f
echo Colors reset to default.
pause
goto menu