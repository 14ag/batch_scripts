@echo off
title formatting
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:formatting
:: formatting just because
:: Usage: formatting <number_of_blank_lines>
cls
set "args=%*"
for /F "tokens=1,* delims= " %%y in ("%args%") do (
    set "n=%%y" 
    set "i=%%z" 
	)
set /a "spacing=(%lines%-%n%)/2"
for /L %%y in (1,1,%spacing%) do (
	if %%y equ %spacing% (
		if defined i (
			echo %i%
		) else (
			echo.
		)
	) else (
		echo.
	)	)

exit /b %errorlevel%