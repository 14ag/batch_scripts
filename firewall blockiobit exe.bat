REM @echo off
set ruleName=windows10manager
set programFullPath="C:\Program Files\Yamicsoft\Windows 10 Manager\Windows10Manager.exe"
set allowblock= block


netsh advfirewall firewall add rule name="%ruleName%" dir=out program=%programFullPath% profile=any action=%allowblock%
netsh advfirewall firewall add rule name="%ruleName%" dir=in program=%programFullPath% profile=any action=%allowblock%
pause