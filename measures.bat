@echo off
TIMEOUT /T 240 /NOBREAK
if exist "C:\Users\philip\Desktop\New Text Document.txt" (
	del /q /f /s "C:\Users\philip\Desktop\New Text Document.txt"
    exit
) else (
    shutdown /l /f
)