@echo off
set "targetDir=%USERPROFILE%\Desktop"
set "shortcutPath=%targetDir%\Desktop.lnk"
set "vbsFile=%temp%\MakeShortcut.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%vbsFile%"
echo sLinkFile = "%shortcutPath%" >> "%vbsFile%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%vbsFile%"
echo oLink.TargetPath = "C:\Windows\explorer.exe" >> "%vbsFile%"
echo oLink.Arguments = "shell:Desktop" >> "%vbsFile%"
echo oLink.IconLocation = "shell32.dll, 34" >> "%vbsFile%"
echo oLink.Save >> "%vbsFile%"

cscript /nologo "%vbsFile%"
del "%vbsFile%"

echo Shortcut created on your desktop. now drag to pin to taskbar
pause
