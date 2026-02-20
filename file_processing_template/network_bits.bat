@echo off
title network_bits
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:network_bits
:: Usage: network_bits <IP_address>
set "network_bits="
set "ip=%1"
:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%w in ("%ip%") do (
	set "network_bits=%%w.%%x.%%y"
)
exit /b %errorlevel%