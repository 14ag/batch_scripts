@echo off
set "a=apple"


:or
set "items=0"
set "count=0"
for %%i in (apple,banana) do (
	if not "%a%"=="%%i" (
		set /a count+=1
	)
	set /a items+=1
)
echo %count%
if "%count%" geq "%items%" (
	echo not fruit
	) else (
	echo fruit
	)

pause
exit /b

