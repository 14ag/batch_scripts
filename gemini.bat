@echo off
rem this is commented because it opens the script in the directory of the script file instead of the current directory
rem set "currentDirectory=%~dp0"

set currentDirectory="%CD%"
(
echo %currentDirectory% | find /i "C:\windows\system32" >nul
	) && (
	:: err 0 (found)
		set currentDirectory=%userprofile%
	) || (
	::not err0	(un found)
		echo. >nul
)
start "" /d %currentDirectory% "%APPDATA%\npm\gemini.cmd"