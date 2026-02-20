@echo off
title macAddress_lookup
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:macAddress_lookup
:: Usage: macAddress_lookup <MAC_address>
set "macAddress=%1"
(
arp -a | find /i "%macAddress%" >nul
) && (
	:: found
	for /f "tokens=1" %%z in ('arp -a ^| find /i "%macAddress%"') do (
		set "macAddress_lookup=%%z"
		)
	) || (
	:: phone not found in arp table
	set "macAddress_lookup="
	exit /b 1
	)
exit /b %errorlevel%