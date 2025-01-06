@echo off
reg add "HKEY_CLASSES_ROOT\.ps1" /ve /t REG_SZ /d "powershellscript" /f
reg add "HKEY_CLASSES_ROOT\powershellscript" /ve /t REG_SZ /d "Windows PowerShell Script File" /f
reg add "HKEY_CLASSES_ROOT\powershellscript\shell\open\command" /ve /t REG_SZ /d "powershell.exe -File \"%1\"" /f
pause