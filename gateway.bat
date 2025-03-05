@echo off
setlocal enabledelayedexpansion
for /f "tokens=*" %%a in ('cscript //nologo gateway.vbs') do (
::it is worth noting that we do the ||endlocal & set thing because thats something
	echo %%a >nul | find /i "." || endlocal & set g=%%a 
	)
	
	
	
	
	
:: explorer ftp://14ag:qwertyui@%g: =%:2121 >nul
explorer ftp://14ag:qwertyui@192.168.100.181:2121 >nul