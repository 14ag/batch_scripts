@echo off
set x=q.w.e.rtyui

::trancating
REM set y=%x:~-1,1%
REM echo y= %y%

:: parse into four tokens using "." as delimiter
for /f "tokens=1-4 delims=." %%a in ("%x%") do (
    echo %%a %%b %%c %%d
)




































pause
