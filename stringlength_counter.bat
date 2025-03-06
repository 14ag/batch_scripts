@echo off
setlocal enabledelayedexpansion
set String=abcde12345

for /L %%x in (1,1,1000) do ( if "!String:~%%x!"=="" set Lenght=%%x & goto Result )

:Result 
echo Lenght: !Lenght!
endlocal