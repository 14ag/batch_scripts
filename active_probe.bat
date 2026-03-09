 @echo off  REM LINT:IGNORE-LINE S007
REM LINT:IGNORE W041, S011, S020
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\POLICIES\MICROSOFT\Windows\NetworkConnectivityStatusIndicator" /v UseGlobalDNS /t REG_DWORD /d 1 /f
gpupdate /force
pause