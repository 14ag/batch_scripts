@echo off
REM set x=q.w.e.rtyui

::learn trancating
REM set y=%x:~-1,1%
REM echo y= %y%

:: learn parse into four tokens using "." as delimiter
@REM for /f "tokens=1-4 delims=." %%a in ("%x%") do (
@REM     echo %%a %%b %%c %%d
@REM )




cscript //NoLogo "GetGateways_Strict_Debug.vbs" verbose

echo.
echo.
echo.
for /f "delims=" %%G in ('cscript //NoLogo "GetGateways_Strict_Debug.vbs"') do set "gateways=%%G"
echo using vbs   %gateways%
































pause
