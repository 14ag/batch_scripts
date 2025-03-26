::file processing template
:: ==============================================================================
:: File: file_processing_template.bat
:: ------------------------------------------------------------------------------
:: Description:
::     This script processes files and directories. It validates input,
::     checks for file compatibility based on defined extensions, and triggers
::     subroutines for further processing of each file.
::
:: Usage:
::     - Drag and drop a file or folder onto the script,
::       or execute the script and follow the on-screen prompts.
::     - Ensure that the required file extensions (e.g., .txt) are correctly
::       specified.
::
:: Author:
::     Philip
:: Date:
::     2023-10-10
::
:: Notes:
::     - This script is designed for batch processing of files in a given directory.
::     - It requires administrative permissions if used on protected folders.
:: ==============================================================================
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
set "_path=%~1"
set "empty_var="


:: validate callback script exists and is executable function goes here


::check if theres need to show usage in single instance mode
call :validate "'%_path%'" '%empty_var%'
if "%validate%"=="true" call :usage

::file validation
if "%_path%"=="" (
	set "loop=1" 
	goto :getFile
) 

goto :file_or_folder0


:getVars
cls
:: sets loop to happen if drag and drop is not happening
set "loop=1"


:getFile
call :info enter the file or folder to be processed here or
call :info Press Enter to process all files with the extensions "%extensions%" in the current directory
set "_path="
set /p "_path=::"
if not defined _path (
	set "_path=%currentDirectory%"
)	

:file_or_folder0
set "workingDirectory="
set "file="
call :file_or_folder %_path%
if "%file_or_folder%"=="folder" (
	set "workingDirectory=%_path%"
	goto :directory_processing
) else if "%file_or_folder%"=="file" (
	set "file=%_path%"
	goto :fileProcessing
) else if "%file_or_folder%"=="" (
	call :error "...%_path:~-10%" not found
	goto :getFile
) else goto :getfile

:directory_processing
cls
call :info "%workingDirectory%" in use
set "workingDirectory=%workingDirectory:"=%"
if "%workingDirectory:~-1%"=="\" (
	set "workingDirectory=%workingDirectory:~0,-1%"
)

:: check for compatible files
cd %workingDirectory%
set "found_files=0"
for %%j in (%extensions%) do (
    dir /b *%%j 2>nul | find "." >nul && set /a "found_files+=1"
)
if %found_files% equ 0 (
    call :error No compatible files found in "...%workingDirectory:~-10%"
	pause
	cls
    goto :getFile
)



cls
call :info the following files will be %allow_block%ed:
for %%j in (%extensions%) do (
	dir /b *%%j
)


setlocal enabledelayedexpansion
:: confirm install all files in the current directory
echo.
call :reset_choice
CHOICE /C yn /N /M "\\\\\\\\ continue? [Y]es, [N]o ///////////"
if %errorlevel% equ 2 (
	cls
	goto :getVars
) else if %errorlevel% equ 1 (
	cls
	set "ok_count=0"
	set "all_count=0"
	:: install each file in the current directory
	for %%j in (%extensions%) do (
		for /r "%workingDirectory%" %%i in (*%%j) do (
		    call :subRoutine "%%~i"
			set /a "all_count+=1"
			if errorlevel 0 set /a "ok_count+=1"
		)   )
	:: show number of files installed successfully
	call :info done. !ok_count!/!all_count! files processed.
	endlocal
	goto :end
) else exit /b 1


:fileProcessing
call :check "%file%" "%extensions%"
if "%check%"=="fail" goto :getFile
call :subRoutine "%file%"
if errorlevel 0 (
	call :info \\\\\\\ done ///////
	) else if not errorlevel 0 (
		call :error /////// failed \\\\\\\
		)
goto :end


::---------------------------------------------------------------------------------------------------
:subRoutine
::---------------------------------------------------------------------------------------------------
set "x=%*"
call :main %x%
exit /b %errorlevel%


:main
set "program_full_path=%*"
:: call :info Processing %program_full_path%...
for %%i in ("%program_full_path:"=%") do set "name=%%~ni"
::test
echo.
echo \\\\\\\ name="%name%" ///////
exit /b %errorlevel%
::---------------------------------------------------------------------------------------------------

::.........additional functions go here.........::
:: Display usage information and instructions here






:::::::::::::::::::::::::::::::::::::::::::helper functions (don't touch)::::::::::::::::::::::::::::::::::::::::::::::

:: reset errorlevel for correct choice
:: use immediately before choice command
:: call :reset_choice
:reset_choice
exit /b 0


:: error handling
:: has a beep
:: call :error "error message"
:error
Echo 1n| CHOICE /N >nul 2>&1 & :: BEL
echo error: %*
pause
exit /b 1


:: info handling
:: does not have a beep
:: call :info "info message"
:info
echo.
echo info: %*
exit /b 0


:: shortens filename to control_extensionl.length() characters 
:: returns shortened filename in variable [truncate_str]
:: filename is the name of the file with extension
:: extension is the extension to be truncated
:: call :truncate_str file.name extension
:truncate_str
set "truncate_str="
setlocal enabledelayedexpansion
set "control_extension=%1"
set "filename=%2"
for /L %%a in (1,1,10) do (
    if "!control_extension:~%%a!"=="" (
        for /f "tokens=1" %%b in ("-%%a") do (
            for /f "tokens=1" %%c in ("!filename:~%%b!") do (
                endlocal & set "truncate_str=%%c"
            )   )   )   ) >nul 2>&1
exit /b 0


:: checks if [%1] is a file or folder
:: returns "file" or "folder" in variable [file_or_folder]
:: file_or_folder is the path to the file or folder
::call :file_or_folder file_or_folder
:file_or_folder
set "file_or_folder="
setlocal enabledelayedexpansion
set "b=%1"
set "b=%b:"=%"
if exist "%b%" (
	for %%I in ("%b%") do (
		set "attrs=%%~aI"
		:: Check if the first attribute is 'd' (directory)
		if "!attrs:~0,1!" == "d" (
			endlocal & set "file_or_folder=folder" 
		) else (
			endlocal & set "file_or_folder=file"
		)   )
)
exit /b 0


:: items_to_test is a single string
:: control is a string of items separated by spaces
:: checks if any item_to_test is in control
:: returns true or false in variable [validate]
:: call :validate "control" %items_to_test%
:validate
set "validate="
set "control=%1"
set "item_to_test=%2"
set "items=0"
set "count=0"
for %%i in (%control:"=%) do (
	if not "%item_to_test%"=="%%i" set /a count+=1
	set /a items+=1
)
if "%count%" geq "%items%" (
	set "validate=false"
) else (
	set "validate=true"
)
exit /b 0


:: creates a dynamic list of choices from a command that outputs a list
:: & is just a command separator, while && is a conditional operator
:: call :selector "[command that outputs list eg echo a & echo b & echo c]"
:selector
echo.
set "selector="
setlocal enabledelayedexpansion
set command=%* >nul
set "i=0"
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
for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
exit /b 0


:: tests to find out if filename [%1] has any of these extensions [%2]
:: call :check "filename" "extensions"
:check
set "check="
set "filename=%1"
set "extensions=%2"
set "filename=%filename:"=%"
set "extensions=%extensions:"=%"
setlocal enabledelayedexpansion
:: verify file existence & validate its type
if exist "%filename%" (
	::this loops thru each extension
	for %%k in ("%filename%") do (
		for %%j in (%extensions%) do (
			call :truncate_str %%j %%~nxk
			if /i not "%%j"=="!truncate_str!" (
				call :error not a supported file.
				endlocal & set "check=fail" 
				) else (
					endlocal & set "check=pass"
				) 	)	)
) else if not exist "%filename%" (
	call :error "%filename%" not found
	endlocal & set "check=fail"
)
exit /b 0


:: this is it guys...
:: loops if drag and drop is not happening
:end
if "%loop%"=="1" (
    pause
    cls
    goto getVars
) else (
    endlocal & exit /b %errorlevel%
)
