@echo off
rem install gdrive, create shortcut of shared folder in yr drive, open it using windows explorer, get shared path, use tis tool to download todo 
set /p sauce="sauce: "
set /p de="dest: "
robocopy "%sauce%" "%de%" /e /w:2 /njh
pause