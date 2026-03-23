@echo off

set "AGENTS=%USERPROFILE%\.agents"

echo Ensuring %AGENTS% exists...
if not exist "%AGENTS%" (
    mkdir "%AGENTS%"
    echo       Created %AGENTS%
    ) else (
        echo       Already exists - skipping mkdir
    )
echo.

SETLOCAL ENABLEDELAYEDEXPANSION

::gemini
call :junctionMigrate "%USERPROFILE%\.gemini"

::antigravity
call :junctionMigrate "%USERPROFILE%\.gemini\antigravity"
call :junctionMigrate "%USERPROFILE%\.antigravity_cockpit"
call :junctionMigrate "%USERPROFILE%\.antigravity"

::claude
call :junctionMigrate "%USERPROFILE%\.claude"

::gh-copilot/codex-cli (both use .copilot)
call :junctionMigrate "%USERPROFILE%\.copilot"

::opencode
setx OPENCODE_CONFIG_DIR "%AGENTS%"



EXIT /B 0





:junctionMigrate
set "old_cursor_path=%1"
ECHO Processing !old_cursor_path!...
PAUSE

:: Remove trailing backslash if present
if "!old_cursor_path:~-1!"=="\" set "old_cursor_path=!old_cursor_path:~0,-1!"
for %%I in ("!old_cursor_path!") do set "folder_name=%%~nxI"

echo [Junction] Redirecting !old_cursor_path! to .agent
if exist "!old_cursor_path!\" (
    
    :: Check if it's already a junction/symlink
    for /f "tokens=*" %%A in ('dir /a:l "%USERPROFILE%" 2^>nul ^| findstr /i "!folder_name!"') do (
        echo       .gemini is already a reparse point  skipping
        exit /b 0
    )

    :: It's a real directory – migrate contents then remove it
    echo       Migrating existing !old_cursor_path! contents to .agents...
    xcopy /E /I /Y /Q "!old_cursor_path!\" "%AGENTS%\" >nul 2>&1
    if errorlevel 1 (
        echo       WARNING: xcopy encountered errors during migration.
        echo                Check !old_cursor_path! manually before proceeding.
        exit /b 1
    )

    rmdir /S /Q "!old_cursor_path!"
    if errorlevel 1 (
        echo       ERROR: Could not remove !old_cursor_path!. Junction not created.
        echo              Close any apps that lock the directory and re-run.
        exit /b 1
    )
    echo       Migration complete - old .gemini removed.
)

mklink /J "!old_cursor_path!" "%AGENTS%"
if errorlevel 1 (
    echo       ERROR: mklink /J failed. You may need to run as Administrator
    echo              or your volume may not support junctions.
    ) else (
        echo       Junction created: !old_cursor_path!
    )
exit /b 0

