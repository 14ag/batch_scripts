@echo off
::skip header
goto main
:: contains header
call "C:\Users\philip\Desktop\windows\batproject\dots.bat"
:: install gdrive, create shortcut of shared folder in yr drive, open it using windows explorer, get shared path, use tis tool to download todo 
:main
title gdrive_download
set /p "sauce=sauce: "
set /p "de=dest: "

for %%i in ("%sauce:"=%") do set "sauce=%%~i"
for %%i in ("%de:"=%") do set "de=%%~i"

robocopy "%sauce%" "%de%" /e /w:2 /njh

pause
cls
goto :main


: main1
cls
color 0f
set /p DISCDRIVELETTER=Input the disc drive letter____
: main2
color 0f
cls
echo o
echo o
echo o
echo o
echo o
echo o
echo o
echo o
echo o                      this batch file is for coppying contents of disc to
echo o                                 "%USERPROFILE%\DESKTOP\disc"
echo o                      from          "%DISCDRIVELETTER%:\."
echo o
echo o
echo o
echo o
echo o
echo o
pause
cls
color 02
robocopy "%DISCDRIVELETTER%:\." "%USERPROFILE%\DESKTOP\disc" /e /r:3 /w:1
if %errorlevel% gtr 0 ("F:\Desktop\setups\bat\copy from disc - Copy.bat")
echo                                             done 
pause
CLS
color 0b
echo  _______________________________________________________________________________
echo O                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                     insert next disc.......                                   o
echo o                       ...............if no other close programme              o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o                                                                               o
echo o_______________________________________________________________________________o
pause
cls
GOTO main2