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
