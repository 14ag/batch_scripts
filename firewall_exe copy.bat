@echo off

:: user variables
setlocal
set "extensions=.exe"
set "OTHER_SCRIPT=%userprofile%\sauce\batch_scripts\fire_wall.bat"



:: functional variables
set "currentDirectory=%~dp0"
set "currentDirectory=%currentDirectory:~0,-1%"
set "currentDirectory=%currentDirectory:"=%"
set "files="
set "loop="

where %OTHER_SCRIPT% >nul 2>&1
if errorlevel 1 (
    call :error a callback script is required
    exit /b 1
)

:: drag and drop
if "%~1"=="" (
    call :info you can Drag and drop a folder onto this script.
    goto getVars
) else (
    set "files=%~1"
    goto check
)

:: get variables
:getVars
:: sets loop to happen if drag and drop is not happening
set "loop=1"
call :info Press Enter to process all %extensions%s in the current directory
set /p "files=::"
:: check if the current directory has any files
if "%files: =%"=="" (
cd %currentDirectory%
    dir /b %extensions% 2>nul | find "." >nul
    if errorlevel 1 (
        call :error No compatible files found in current directory.
    )
    cls
    call :info Found the following files:
    for /r "%currentDirectory%" %%i in (%extensions%) do (
        echo %%~nxi
    )
    :: confirm install all files in the current directory
    call :resetChoice
    CHOICE /C yn /N /M "continue? [Y]es, [N]o"
    if %errorlevel% equ 2 (
        pause
        goto :getVars
    ) else if %errorlevel% equ 1 (
        set "ok_count=0"
        set "error_count=0"
        :: install all files in the current directory
        for /r "%currentDirectory%" %%i in (%extensions%) do (
            call :main "%%~i"
            if errorlevel 0 set /a "ok_count+=1"
        )
        :: show number of files installed successfully
        call :info done. %ok_count% files processed successfully.
        goto end
    )
) else (
    call :check
    goto end
)

:check
:: handle quotes in the file path omg
for %%i in ("%files:"=%") do (
        set "files=%%~i"
    )
:: validate file type
if exist "%files%" (
    ::this loop returns the files
    for %%i in (%extensions%) do (
        for /r "%currentDirectory%" %%j in (%extensions%) do (
            call :truncate_str %%i %%~nxj
            if /i not "%%i"=="%truncate_str%" (
                call :error not a supported file.
            )   )   )
) else (
    call :error file not found.
)

call :main "%files%"
exit /b






::---------------------------------------------------------------------------------------------------
:main
set "a=%1"
cls
call :info Installing '%files%'...







:: feedback on install
if errorlevel 1 (
    call :error failed. Check for error messages above.
) else (
    call :info ok.
    exit /b 0
)
::---------------------------------------------------------------------------------------------------






:: reset errorlevel for correct choice
:resetChoice
exit /b 0

:: error handling
:error
echo error: %*
pause
cls
goto getVars

:: info handling
:info
echo.
echo info: %*
echo.
exit /b 0

:: call :truncate_str file.name extension
:: returns extension of file.name in variable [truncate_str]
:truncate_str
setlocal enabledelayedexpansion
set control_extension=%1
set filename=%*
for /L %%a in (1,1,10) do (
    if "!control_extension:~%%a!"=="" (
        for /f "tokens=1" %%b in ("-%%a") do (
            for /f "tokens=1" %%c in ("!filename:~%%b!") do (
                endlocal & set "truncate_str=%%c"
            )   )   )   )
exit /b

:: loops if drag and drop is not happening
:end
if "%loop%"=="1" (
    pause
    cls
    goto getVars
) else (
    exit /b 0
)
endlocal
