::file processing template
::---------------------------------------------------------------------------------------------------
@REM @echo off

:: user variables
setlocal
set "extensions=.txt"
:: callback script
set "OTHER_SCRIPT="



:: functional variables
set "currentDirectory=%~dp0"
set "allow_block=%~2"
set "in_out_all=%~3"
set "file=%~1"
set "loop="


:: validate callback script exists and is executable
if not defined OTHER_SCRIPT (
	echo :error Callback script not specified
	pause
	exit /b 1
)
for %%F in ("%OTHER_SCRIPT%") do (
	set "dpF=%%~dpF"
	set "nxF=%%~nxF"
)
where /r "%dpF:~0,-1%" "%nxF%" >nul 2>&1
if errorlevel 1 (
	echo :error Callback script '%OTHER_SCRIPT%' not found or not executable
	pause
	exit /b 1
) else (
	cls
)

:: Validate allow_block parameter
set "items=0"
set "count=0"
for %%i in (allow,block) do (
	if not "%allow_block%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
if "%count%" geq "%items%" goto usage


:: Validate in_out_all parameter
set "items=0"
set "count=0"
for %%i in (in,out,all) do (
	if not "%in_out_all%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
if "%count%" geq "%items%" goto usage

goto file_or_folder0



:getVars
:: sets loop to happen if drag and drop is not happening
set "loop=1"
set "allow_block="
set "in_out_all="
set "file="
call :info Press Enter to process all files with the following extensions (%extensions%) in the current directory
set /p "file=::"

:file_or_folder0
if defined file (
	call :file_or_folder %file%
	if "%file_or_folder%"=="folder" (
		set "currentDirectory=%file%"
		goto directory_processing
	) else if "%file_or_folder%"=="file" (
        if not defined allow_block call :in_out_all
        if not defined allow_block call :allow_block
		call :check
    	goto end
	)	) else (
		if "%loop%"=="0" (
            goto usage
        )    )


:directory_processing
set "currentDirectory=%currentDirectory:"=%"
if "%currentDirectory:~-1%"=="\" (
	set "currentDirectory=%currentDirectory:~0,-1%"
)
:: check for compatible files
cd %currentDirectory%
set "found_files=0"
for %%j in (%extensions%) do (
    dir /b *%%j 2>nul | find "." >nul && set /a "found_files+=1"
)
if %found_files% equ 0 (
    call :error No compatible files found in "%currentDirectory%"
    goto getVars
)

cls
call :in_out_all
call :allow_block
call :info the following files will be %allow_block%ed:
for %%j in (%extensions%) do (
	dir /b *%%j
)

setlocal enabledelayedexpansion
:: confirm install all files in the current directory
call :reset_choice
echo.
CHOICE /C yn /N /M "\\\\\\\\ continue? [Y]es, [N]o ///////////"
if %errorlevel% equ 2 (
	cls
	goto :getVars
) else if %errorlevel% equ 1 (
	set "ok_count=0"
	set "error_count=0"
	:: install each file in the current directory
	for %%j in (%extensions%) do (
		for /r "%currentDirectory%" %%i in (*%%j) do (
		    call :subRoutine %%~i
			if errorlevel 0 set /a "ok_count+=1"
		)   )
		
	:: show number of files installed successfully
	call :info done. !ok_count! files processed successfully.
	endlocal
	goto end
)


:check
REM cls
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
call :subRoutine %file%
exit /b




::---------------------------------------------------------------------------------------------------
:subRoutine
::---------------------------------------------------------------------------------------------------
set "x=%~1"
if "%in_out_all%"=="all" (
    set "in_out_all=out"
    call :main %x%
    set "in_out_all=in"
    call :main %x% 
    goto :eof
	) else (
		call :main %x%
		goto :eof
	)


:main
set "program_full_path=%~1"
call :info Processing '%program_full_path%'...
for %%i in ("%program_full_path:"=%") do set "rule_name=%%~ni"


::test
echo name="%rule_name%" dir=%in_out_all% program="%program_full_path:"=%" profile=any action=%allow_block% enable=yes

:: feedback on processing

::---------------------------------------------------------------------------------------------------
exit /b %errorlevel%


:in_out_all
call :reset_choice
echo.
echo 1. in
echo 2. out
echo 3. all
choice /c 123 /n /m "Press 1 or 2 or 3: "
if errorlevel 3 (
    set "in_out_all=all"
) else if errorlevel 2 (
    set "in_out_all=out"
) else if errorlevel 1 (
    set "in_out_all=in"
)
exit /b 0


:allow_block
call :reset_choice
echo.
echo 1. allow
echo 2. block
choice /c 12 /n /m "Press 1 or 2: "
if errorlevel 2 (
    set "allow_block=block"
) else if errorlevel 1 (
    set "allow_block=allow"
)
exit /b 0


:: Display usage information and instructions
:usage
cls
call :info Usage: %~nx0 "path\to\program.exe" ^[allow^|block^] ^[in^|out^|all^]
goto getVars


:: reset errorlevel for correct choice
:reset_choice
exit /b 0
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


:file_or_folder
setlocal enabledelayedexpansion
set "b=%1"
set "b=%b:"=%"
for %%I in ("%b%") do (
    set "attrs=%%~aI"
    REM Check if the first attribute is 'd' (directory)
    if "!attrs:~0,1!" == "d" (
        endlocal & set "file_or_folder=folder" 
    ) else (
        endlocal & set "file_or_folder=file"
    )   )
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
