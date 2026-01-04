@echo off
:: install gdrive, create shortcut of shared folder in yr drive, open it using windows explorer, get shared path, use tis tool to download todo 
:loop1
set /p "so=source file or folder: "
set /p "de=dest: "
set "file=*.*"


for %%i in ("%so:"=%") do set "so=%%~i"
for %%j in ("%de:"=%") do set "de=%%~j"

setlocal enabledelayedexpansion
call :file_or_folder "%so%"
if "%file_or_folder%"=="file" (
	for %%l in ("%so%") do (
		set "source0=%%~dpl"
		set "file=%%~nxl"
		set "destination=%de%"
	)
	set "source=!source0:~0,-1!"
) else if "%file_or_folder%"=="folder" (
	call :get_folder_name "%so%"
	set "de=%de%\!get_folder_name!"
	set "destination=!de!"
	set "source=%so%"
) else if "%file_or_folder%"=="" (
	echo something went wrong 
	echo press any key to exit
	pause >nul 2>&1
	exit
)

:main
robocopy "%source%" "%destination%" "%file%" /e /w:2 /njh /ndl /MT:127
pause
endlocal
cls
goto :loop1



:file_or_folder
:: call :file_or_folder file_or_folder
:: returns "file" or "folder" in variable [file_or_folder]
:: file_or_folder is the path to the file or folder
set "file_or_folder="
setlocal enabledelayedexpansion
set "b=%*"
set "b=%b:"=%"
if exist "%b%" (
	for %%z in ("%b%") do (
		set "attrs=%%~az"
		REM Check if the first attribute is 'd' (directory)
		if "!attrs:~0,1!" == "d" (
			endlocal & set "file_or_folder=folder" 
		) else (
			endlocal & set "file_or_folder=file"
		)   )
)
exit /b 0


:get_folder_name
:: call :get_folder_name [path]
:: returns the name of the folder whose path was provided in the variable !get_folder_name!
set "path=%*"
:check_backslash
:: Check if the string contains a backslash
echo "%path%" | find "\" >nul && (
	:: Strip everything up to the first backslash and repeat
	set "path=%path:*\=%"
	goto :check_backslash
) || (
    set "get_folder_name=%path%"
)
exit /b 0
