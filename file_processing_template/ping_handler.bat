@echo off
title ping_handler
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:ping_handler
:: use call :ping_handler [#start-stop] [gateway] [networkbits]
set "args=%*"

setlocal enabledelayedexpansion       
for /F "tokens=1,2,3 delims= " %%e in ("%args%") do (

	for /F "tokens=1,2 delims=-" %%h in ("%%g") do (
		endlocal & ( set "p_gateway=%%e" & set "p_network_bits=%%f" & set "start=%%h" & set "stop=%%i" )
)	) 

for /l %%e in (%start%,1,%stop%) do (
	if not "%p_network_bits%.%%e"=="%p_gateway%" (
					
		echo. >nul
		(
		ping -n 1 -w 10 %network_bits%.%%e | find "TTL=" >nul
		) && (
		:: if ping successful
		call :debug ping successful for %network_bits%.%%e

        if %start% equ %stop% exit /b 0
		call %append% %found_ips% %network_bits%.%%e

		) || (
			:: if ping failed
			call :debug no ping response from %network_bits%.%%e

            if %start% equ %stop% exit /b 1
			:: last network, so if we reach here with d=254 then no ftp servers found
			if %%e equ %stop% (
				call :debug end of range
	)	)	)	)

exit /b %errorlevel%