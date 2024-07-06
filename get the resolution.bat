REM @echo off
setlocal
for /f %%i in ('wmic path Win32_VideoController get CurrentHorizontalResolution^,CurrentVerticalResolution /value ^| find "="') do set "%%i"
REM set pwidth=%CurrentVerticalResolution%/2
set /a ypixels=%CurrentHorizontalResolution%-%pwidth%


echo CreateObject("Wscript.Shell").Run "cmd /c scrcpy.exe --window-height %CurrentVerticalResolution% --window-y %ypixels% --window-x 0", 0, false > "%temp%\philip.vbs"
"%temp%\philip.vbs"

del "%temp%\philip.vbs"

exit /B