@echo off
setlocal
set "currentDirectory=%~dp0"
set "currentDirectory=%currentDirectory:~0,-1%"

set "c=0"
for %%a in ("%PATH:;=" "%") do (
  if /i "%%~a"=="%currentDirectory%" (
    set /a c+=1
  )  
)
echo.
if "%c%" lss "1" (
  setx path "%currentDirectory%;%path%" /M
  echo.
) ELSE (
  echo Current directory is already in PATH.
)

endlocal
pause
exit /b
