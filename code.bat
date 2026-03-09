@ECHO off
:: this is commented because it opens the script in the directory of the script file instead of the current directory
@REM set "currentDirectory=%~dp0"

set "currentDirectory=%CD:"=%"
start "" /d "%currentDirectory%" "C:\Users\philip\AppData\Local\Programs\Microsoft VS Code Insiders\Code - Insiders.exe" .

