mode con lines=5 cols=50
@echo off
color 02
adb push "%1" /storage/emulated/0/ 
if %errorlevel% neq 0 (
	cls
	color 0c
	echo error
	pause 
	)