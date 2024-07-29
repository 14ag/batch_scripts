@echo off
setlocal enabledelayedexpansion
(
echo %* | find "-help" 2>&1 >nul
) && (
echo  set0 [variable]=[command]
echo   - assigns the output of the command to the variable.
echo   - example: set0 var=echo foo bar
exit /b
)

(
echo %* | find "="
) && (
	for /f "tokens=1,* delims==" %%a in ("%*") do (
		for /f "usebackq tokens=*" %%c in (`%%b`) do (
			(endlocal & set "%%a=%%c") 2>&1 >nul
		)
	)
exit /b
	) || (
	echo use "set0 -help" to see help
	)