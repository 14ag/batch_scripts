@echo off

goto end
rem location_you_want_the_shortcut actual_file 
REM ======== on desktop
REM sauce 
junction "%userprofile%\desktop\sauce" "%userprofile%\sauce"

REM note_10
junction "%userprofile%\desktop\note_10" "D:\note_10"

REM x64
junction "%userprofile%\desktop\x64" "%userprofile%\sauce\x64"

REM tmp
junction "%userprofile%\desktop\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


REM =========== on sauce
REM documents
junction "%userprofile%\sauce\documents" "%userprofile%\documents"

REM note_10
junction "%userprofile%\sauce\note_10" "D:\note_10"

REM presets
junction "%userprofile%\sauce\presets" "G:\My Drive\presets"

REM reads
junction "%userprofile%\sauce\reads" "%userprofile%\Documents\library\pc reads"

REM tmp
junction "%userprofile%\sauce\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


REM ============ on note_10
REM sauce
junction "D:\note_10\sauce" "%userprofile%\sauce"

REM tmp
junction "D:\note_10\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


REM ============ on tmp
REM note_10
junction "C:\Xiaomi\XiaomiTool2\res\tmp\note_10" "D:\note_10"

REM sauce
junction "C:\Xiaomi\XiaomiTool2\res\tmp\sauce" "%userprofile%\sauce"


REM ============ on apk
REM sendoff
junction "D:\note_10\apk\sendoff" "%userprofile%\sauce\sendoff"

REM ============ on magisk modules 
REM sendoff
junction "D:\note_10\magisk_modules\sendoff" "%userprofile%\sauce\sendoff"

REM ============= on sendoff
REM apk
junction "%userprofile%\sauce\sendoff\apk" "D:\note_10\apk"

REM magisk
junction "%userprofile%\sauce\sendoff\magisk_modules" "D:\note_10\magisk_modules"

REM app2
junction "%userprofile%\sauce\sendoff\app2" "D:\note_10\magisk_modules\app2"


REM ============= on downloads
REM note_10
junction "%userprofile%\downloads\note_10" "D:\note_10"

REM sauce
junction "%userprofile%\downloads\sauce" "%userprofile%\sauce"


REM ============ on 01
REM tmp
junction "D:\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"

REM ============ on yts2
REM yts
junction "D:\yts2\more_movies" "%userprofile%\Videos\yts"


REM ================== on yts
REM yts2
junction "%userprofile%\Videos\yts\more_movies" "D:\yts2"

:end
pause





