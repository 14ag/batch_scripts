@echo off

goto end
:: location_you_want_the_shortcut actual_file 
:: ======== on desktop
:: sauce 
junction "%userprofile%\desktop\sauce" "%userprofile%\sauce"

:: note_10
junction "%userprofile%\desktop\note_10" "D:\note_10"

:: x64
junction "%userprofile%\desktop\x64" "%userprofile%\sauce\x64"

:: tmp
junction "%userprofile%\desktop\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


:: =========== on sauce
:: documents
junction "%userprofile%\sauce\documents" "%userprofile%\documents"

:: note_10
junction "%userprofile%\sauce\note_10" "D:\note_10"

:: presets
junction "%userprofile%\sauce\presets" "G:\My Drive\presets"

:: reads
junction "%userprofile%\sauce\reads" "%userprofile%\Documents\library\pc reads"

:: tmp
junction "%userprofile%\sauce\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


:: ============ on note_10
:: sauce
junction "D:\note_10\sauce" "%userprofile%\sauce"

:: tmp
junction "D:\note_10\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"


:: ============ on tmp
:: note_10
junction "C:\Xiaomi\XiaomiTool2\res\tmp\note_10" "D:\note_10"

:: sauce
junction "C:\Xiaomi\XiaomiTool2\res\tmp\sauce" "%userprofile%\sauce"


:: ============ on apk
:: sendoff
junction "D:\note_10\apk\sendoff" "%userprofile%\sauce\sendoff"

:: ============ on magisk modules 
:: sendoff
junction "D:\note_10\magisk_modules\sendoff" "%userprofile%\sauce\sendoff"

:: ============= on sendoff
:: apk
junction "%userprofile%\sauce\sendoff\apk" "D:\note_10\apk"

:: magisk
junction "%userprofile%\sauce\sendoff\magisk_modules" "D:\note_10\magisk_modules"

:: app2
junction "%userprofile%\sauce\sendoff\app2" "D:\note_10\magisk_modules\app2"


:: ============= on downloads
:: note_10
junction "%userprofile%\downloads\note_10" "D:\note_10"

:: sauce
junction "%userprofile%\downloads\sauce" "%userprofile%\sauce"


:: ============ on 01
:: tmp
junction "D:\tmp" "C:\Xiaomi\XiaomiTool2\res\tmp"

:: ============ on yts2
:: yts
junction "D:\yts2\more_movies" "%userprofile%\Videos\yts"


:: ================== on yts
:: yts2
junction "%userprofile%\Videos\yts\more_movies" "D:\yts2"

:end
pause





