@ECHO off
:: this is commented because it opens the script in the directory of the script file instead of the current directory
@REM set "currentDirectory=%~dp0"
set currentDirectory="%CD%"

@echo off
setlocal
for /d %%d in (app-*) do (
  if exist "%%d\discord.exe" (
    start "" /d %currentDirectory% "%%d\discord.exe"
    goto :eof
  )
)
echo discord.exe not found.
pause
endlocal