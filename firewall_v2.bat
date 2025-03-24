::file processing template
::---------------------------------------------------------------------------------------------------
@echo off

:: user variables
setlocal
set "extensions=.txt"
:: callback script
set "OTHER_SCRIPT="



:: functional variables
set "loop=0"
set "currentDirectory=%~dp0"
set "file=%~1"
set "allow_block=%~2"
set "in_out_all=%~3"


:: validate callback script exists and is executable function goes here


::file validation
if "%file%"=="" call usage & goto getFile
:: Validate allow_block parameter
call :validate "allow block" %allow_block%
if "%validate%"=="false" goto usage & goto file_or_folder0

:: Validate in_out_all parameter
call :validate "in out all" %in_out_all%
if "%validate%"=="false" goto usage & goto file_or_folder0

goto fileProcessing


:getVars
:: sets loop to happen if drag and drop is not happening
set "loop=1"
set "allow_block="
set "in_out_all="
set "file="

:getFile
call :info Press Enter to process all files with the following extensions (%extensions%) in the current directory
set /p "file=::"
if not defined file (
	if "%loop%"=="0" (
        goto usage
    )	)

:file_or_folder0
call :file_or_folder %file%
if "%file_or_folder%"=="folder" (
	set "currentDirectory=%file%"
	goto directory_processing
) else if "%file_or_folder%"=="file" (
	if not defined allow_block call :in_out_all
	if not defined allow_block call :allow_block
	goto fileProcessing
)


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
		    call :subRoutine "%%~i"
			if errorlevel 0 set /a "ok_count+=1"
		)   )
		
	:: show number of files installed successfully
	call :info done. !ok_count! files processed successfully.
	endlocal
	goto end
)


:fileProcessing
call :check "%file%" "%extensions%"
if errorlevel 1 goto :getvars
call :subRoutine "%file%"
goto end


::---------------------------------------------------------------------------------------------------
:subRoutine
::---------------------------------------------------------------------------------------------------
set "x=%*"
if "%in_out_all%" neq "all" (
	call :main %x%
) else if "%in_out_all%" equ "all" (
		set "in_out_all=in"
		call :main %x%
		set "in_out_all=out"
		call :main %x%
		set "in_out_all=all"
	)
exit /b %errorlevel%


:main
set "program_full_path=%*"
REM call :info Processing %program_full_path%...
for %%i in ("%program_full_path:"=%") do set "rule_name=%%~ni"
::test
echo   dir=!in_out_all!  action=%allow_block%  name="%rule_name%"
REM netsh advfirewall firewall add rule name="%rule_name%" dir=%in_out_all% program="%program_full_path:"=%" profile=any action=%allow_block% enable=yes
exit /b
::---------------------------------------------------------------------------------------------------


:: Display usage information and instructions
:usage
cls
set "loop=1"
call :info Usage: %~nx0 "path\to\program.exe" ^[allow^|block^] ^[in^|out^|all^]
exit /b


:in_out_all
echo.
call :selector "echo in & echo out & echo all"
set "in_out_all=%selector%"
exit /b 0


:allow_block
echo.
call :selector "echo allow & echo block"
set "allow_block=%selector%"
exit /b 0













:::::::::::::::::::::::::::::::::::::::::::helper functions::::::::::::::::::::::::::::::::::::::::::::::

:: reset errorlevel for correct choice
:reset_choice
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
:: file.name is the name of the file with extension
:: extension is the extension to be truncated
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


::call :file_or_folder file_or_folder
:: returns "file" or "folder" in variable [file_or_folder]
:: file_or_folder is the path to the file or folder
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


:: call :validate "control" %items_to_test%
:: returns true or false in variable [validate]
:: control is a string of items separated by spaces
:validate
set "control=%1"
set "items_to_test=%2"
set "items=0"
set "count=0"
for %%i in (%control:"=%) do (
	if not "%items_to_test%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
if "%count%" geq "%items%" (
	set "validate=false"
) else (
	set "validate=true"
)
exit /b 0


:: call :selector "[command that outputs list eg echo a & echo b & echo c]"
:: & is just a command separator, while && is a conditional operator
:selector
echo.
setlocal enabledelayedexpansion
set command=%* >nul
set "i=0"
set "selector="
set "choicelist="
:: Loop through a list, act on each line
for /f "eol=L tokens=1" %%a in ('!command!') do (
	if errorlevel 1 (
		echo Error: Failed to execute command: !command!
		endlocal & exit /b 1
	)
	set /a i+=1
	:: Create dynamic variable names (_1, _2, etc.)
	for %%b in (_!i!) do (
		set "%%b=%%a"
		set "choicelist=!choicelist!!i!"
		echo !i!. %%a
	)   )

call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1,1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
exit /b


::tests to find out if filename [%1] has any of these extensions [%2]
:check
call :reset_choice
set "filename=%1"
set "extensions=%2"
set "filename=%filename:"=%"
set "extensions=%extensions:"=%"
setlocal enabledelayedexpansion
:: validate file type
if not exist "%filename%" (
	call :error file not found.
)
::this loop each extension
for %%k in ("%filename%") do (
	for %%j in (%extensions%) do (
		call :truncate_str %%j %%~nxk
		if /i not "%%j"=="!truncate_str!" (
			call :error not a supported file.
			)	)	)
endlocal
exit /b %errorlevel%


:: loops if drag and drop is not happening
:end
if "%loop%"=="1" (
    pause
    cls
    goto getVars
) else (
    endlocal & exit /b %errorlevel%
)
