@echo off
setlocal enabledelayedexpansion

:: Set the backup file name
set "backupFile=%USERPROFILE%\Desktop\PowerShellColorPalette_Backup.reg"

:: Create the backup file
echo Windows Registry Editor Version 5.00 > "%backupFile%"
echo. >> "%backupFile%"
echo [HKEY_CURRENT_USER\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe] >> "%backupFile%"

:: Array of color names
set "colors=ColorTable00 ColorTable01 ColorTable02 ColorTable03 ColorTable04 ColorTable05 ColorTable06 ColorTable07 ColorTable08 ColorTable09 ColorTable10 ColorTable11 ColorTable12 ColorTable13 ColorTable14 ColorTable15"

:: Loop through each color and export its value
for %%c in (%colors%) do (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Console\%%SystemRoot%%_System32_WindowsPowerShell_v1.0_powershell.exe" /v %%c 2^>nul') do (
        echo "%%c"=dword:%%b >> "%backupFile%"
    )
)

echo Backup completed. File saved as: %backupFile%