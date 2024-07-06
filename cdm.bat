@echo off
title ContentDeliveryManager
mode con: cols=50 lines=10
md "%USERPROFILE%\desktop\cdm"
xcopy "%USERPROFILE%\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets" "%USERPROFILE%\desktop\cdm" /y /q 
cd "%USERPROFILE%\desktop\cdm"
ren *.* *.jpg
cd
pause