@echo off
setlocal enabledelayedexpansion

:: Set the output file name with date and time
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set datetime=%datetime:~0,8%-%datetime:~8,6%
set "output_file=WindowsThemeBackup_%datetime%.reg"

:: Export the relevant registry keys
echo Exporting Windows theme settings...

reg export "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes" "%output_file%" /y
if %errorlevel% neq 0 (
    echo Failed to export Themes key.
    goto :error
)

reg export "HKEY_CURRENT_USER\Control Panel\Colors" "%output_file%" /y
if %errorlevel% neq 0 (
    echo Failed to export Colors key.
    goto :error
)

reg export "HKEY_CURRENT_USER\Control Panel\Desktop" "%output_file%" /y
if %errorlevel% neq 0 (
    echo Failed to export Desktop key.
    goto :error
)

echo Windows theme settings have been successfully backed up to %output_file%
goto :end

:error
echo An error occurred while backing up the theme settings.
exit /b 1

:end
pause
exit /b 0