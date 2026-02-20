@echo off
title get_gateway
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:get_gateway
:: use call :get_gateway
:: returns an array of gateways of your pc in format [abc_123.123.123.123 xyz_456.456.456.456]

setlocal enabledelayedexpansion
set "get_gateway="
for /f "delims=" %%m in ('cscript //NoLogo "GetGateways.vbs"') do set "get_gateway=%%m" >nul

set /a "count=0"
for %%m in (%get_gateway%) do (
	set /a "count+=1"
    )

if %count% gtr 1 (

	set "x="
	for %%m in (%get_gateway%) do (
		for /f "tokens=1-2 delims=_" %%n in ("%%m") do (
			set "x=%%n %%o,!x!"
	)	)

    :: removing trailing comma
    if defined x set "x=!x:~0,-1!"
    echo  select the network your ftp server is connected to:

    call :selector !x!
	for /F "tokens=2 delims= " %%m in ("!selector!") do (
		endlocal & set "get_gateway=%%m" 
		)

	) else if %count% equ 1 (

	for /f "tokens=1-2 delims=_" %%m in ("%get_gateway%") do (
		endlocal & set "get_gateway=%%n"
		)
	)


exit /b %errorlevel%