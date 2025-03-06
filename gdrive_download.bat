@echo off
:: install gdrive, create shortcut of shared folder in yr drive, open it using windows explorer, get shared path, use tis tool to download todo 
:main
set /p "sauce=sauce: "
set /p "de=dest: "

for %%i in ("%sauce:"=%") do set "sauce=%%~i"
for %%i in ("%de:"=%") do set "de=%%~i"

robocopy "%sauce%" "%de%" /e /w:2 /njh

pause
cls
goto :main