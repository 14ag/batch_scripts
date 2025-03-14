REM @echo off

:: user variables
setlocal
set "extensions=.bat"
:: callback script
set "OTHER_SCRIPT=%userprofile%\sauce\batch_scripts\fire_wall.bat"



:: functional variables
set "currentDirectory=%~dp0"
set "currentDirectory=%currentDirectory:~0,-1%"
set "currentDirectory=%currentDirectory:"=%"
set "file="
set "loop="

for %%F in ("%OTHER_SCRIPT%") do (
    set "dpF=%%~dpF"
    set "nxF=%%~nxF"
)
where /r "%dpF:~0,-1%" %nxF%
REM >nul 2>&1
	if errorlevel 1 (
		echo :error a callback script is required
		pause
		exit /b
	) else (
		cls
		echo ok
	)
	
:: drag and drop
if "%~1"=="" (
    call :info you can Drag and drop a folder onto this script.
    goto getVars
) else (
    set "file=%~1"
    goto check
)


:: get variables
:getVars
set "file="
:: sets loop to happen if drag and drop is not happening
set "loop=1"
call :info Press Enter to process all %extensions%s in the current directory
set /p "file=::"
:: check if the current directory has any file
if not "%file: =%"=="" (
	call :check
    goto end
)

cd %currentDirectory%
dir /b %extensions% 2>nul | find "." >nul
if errorlevel 1 (
	call :error No compatible file found in current directory.
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
	:: install each file in the current directory
	for /r "%currentDirectory%" %%i in (%extensions%) do (
		call :main "%%~i"
		if errorlevel 0 set /a "ok_count+=1"
	)
	:: show number of files installed successfully
	call :info done. %ok_count% files processed successfully.
	goto end
)


:check
cls
set "file=%file:"=%"
setlocal enabledelayedexpansion
:: validate file type
if not exist "%file%" (
	call :error file not found.
)

::this loop each extension
for %%k in ("%file%") do (
	for %%j in (%extensions%) do (
		call :truncate_str %%j %%~nxk
		if /i not "%%j"=="!truncate_str!" (
			call :error not a supported file.
			)	)	)
endlocal
call :main %file%
exit /b






::---------------------------------------------------------------------------------------------------
:main
set "a=%1"
cls
call :info Installing '%a%'...



echo %OTHER_SCRIPT% %a%



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
set filename=%2
for /L %%a in (1,1,10) do (
    if "!control_extension:~%%a!"=="" (
        for /f "tokens=1" %%b in ("-%%a") do (
            for /f "tokens=1" %%c in ("!filename:~%%b!") do (
                endlocal & set "truncate_str=%%c"
            )   )   )   ) >nul 2>&1
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
