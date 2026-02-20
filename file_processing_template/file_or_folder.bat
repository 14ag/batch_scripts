@echo off
title file_or_folder
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:file_or_folder
:: checks path if it a path to folder or path to file
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
exit /b %errorlevel%