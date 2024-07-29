@echo off
:device_selector
REM Display list of detected devices
for /l %%a in (1, 1, %~1) do (
	for /f "tokens=%%a delims= " %%b in ("%~2") do (
		echo %%b
	)
)

REM Prompt user to choose a device
set id= & set /p id="Choose a device: "

REM Validate user's selection
(
    set device_%id% 2>&1 >nul
) || (
    cls
    echo Invalid choice
    echo.
    goto device_selector
)
echo %id%
exit /b