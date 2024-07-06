@echo off
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
    ) ELSE ( >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" )
IF '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
    ) ELSE ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
rem ------------------------------------------------------------------------------
cls
ipconfig /renew >nul
echo ---------
echo resetting. please wait...
cls
ipconfig /release >nul
cls
echo x--------
echo resetting. please wait...
ipconfig /flushdns >nul
cls
echo xx-------
echo resetting. please wait...
nbtstat -r >nul
cls
echo xxx------
echo resetting. please wait...
netsh winsock reset >nul
cls
echo xxxx-----
echo resetting. please wait...
netsh interface ipv4 reset >nul
cls
echo xxxxx----
echo resetting. please wait...
netsh interface ipv6 reset >nul
cls
echo xxxxxx---
echo resetting. please wait...
netsh winsock reset catalog >nul
cls
echo xxxxxxx--
echo resetting. please wait...
netsh int ipv4 reset reset.log >nul
cls
echo xxxxxxxx-
echo resetting. please wait...
netsh int ipv6 reset reset.log >nul
cls
echo xxxxxxxxx
echo resetting. please wait...
ipconfig /renew >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\POLICIES\MICROSOFT\Windows\NetworkConnectivityStatusIndicator" /v UseGlobalDNS /t REG_DWORD /d 1 /f
gpupdate /force >nul
echo press enter to restart your pc
pause >nul
REM shutdown /r /f /t 3 
exit
