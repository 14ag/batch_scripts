@echo off
title check_ftp
set "lines=20"
@rem mode con: cols=60 lines=%lines%
setlocal enabledelayedexpansion
:check_ftp
:: Usage: check_ftp <IP_address> <PORT>
:: returns errorlevel 0 if ftp server is reachable and 1 if not
set "IP=%1"
set "PORT=%2"
(
	:: Run PowerShell silently without showing the progress bar
	powershell -Command "$ProgressPreference='SilentlyContinue'; if (Test-NetConnection -ComputerName %IP% -Port %PORT% -InformationLevel Quiet -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
) >nul
endlocal
exit /b %errorlevel%