@echo off
setlocal enabledelayedexpansion


:main_menu
call :header
echo Main Menu:
echo 1. File Operations
echo 2. System Information
echo 3. Network Tools
echo 4. Exit
echo.
set /p "choice=Enter your choice: "

if "%choice%"=="1" goto file_menu
if "%choice%"=="2" goto system_menu
if "%choice%"=="3" goto network_menu
if "%choice%"=="4" goto end

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto main_menu

:file_menu
call :header
echo File Operations:
echo 1. List files in current directory
echo 2. Create a new file
echo 3. Delete a file
echo 4. Back to main menu
echo.
set /p "file_choice=Enter your choice: "

if "%file_choice%"=="1" (
    dir
    pause
    goto file_menu
)
if "%file_choice%"=="2" (
    set /p "filename=Enter filename: "
    type nul > "%filename%"
    echo File created: %filename%
    pause
    goto file_menu
)
if "%file_choice%"=="3" (
    set /p "filename=Enter filename to delete: "
    del "%filename%"
    echo File deleted: %filename%
    pause
    goto file_menu
)
if "%file_choice%"=="4" goto main_menu

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto file_menu

:system_menu
call :header
echo System Information:
echo 1. Display system info
echo 2. List running processes
echo 3. Back to main menu
echo.
set /p "sys_choice=Enter your choice: "

if "%sys_choice%"=="1" (
    systeminfo
    pause
    goto system_menu
)
if "%sys_choice%"=="2" (
    tasklist
    pause
    goto system_menu
)
if "%sys_choice%"=="3" goto main_menu

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto system_menu

:network_menu
call :header
echo Network Tools:
echo 1. Display IP configuration
echo 2. Ping a website
echo 3. Back to main menu
echo.
set /p "net_choice=Enter your choice: "

if "%net_choice%"=="1" (
    ipconfig /all
    pause
    goto network_menu
)
if "%net_choice%"=="2" (
    set /p "website=Enter website to ping: "
    ping %website%
    pause
    goto network_menu
)
if "%net_choice%"=="3" goto main_menu

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto network_menu

:end
echo Thank you for using the Dynamic Batch Menu!
pause
exit /b


:header
cls
echo ================================
echo      Dynamic Batch Menu
echo ================================
echo.
exit /b