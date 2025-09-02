@ echo off
rd %userprofile%\AppData\Local\Temp\ /s/q
REM if %errorlevel% EQU 0 mkdir %userprofile%\AppData\Local\Temp
REM if exist %userprofile%\AppData\Local\Temp goto pause
REM :pause
REM pause
exit
