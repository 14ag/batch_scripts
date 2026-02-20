@echo off
title io
set "lines=20"
@rem mode con: cols=60 lines=%lines%
:io
:: define "read="%~f0" io r" "write="%~f0" io w" "append="%~f0" io ww" at the beginning of script
:: usage call :io [r|w|ww] [filename] [data]
:: [w] overwrites [ww] appends [r] reads data to/from [filename]
:: stores data in var %io% when doing [r] operation
echo entering :io with args [%*]
set "args=%*"
set "MAX_TRY=5"
setlocal enabledelayedexpansion
for /F "tokens=1,2,* delims= " %%s in ("%args%") do (
    set "rw=%%s" 
    set "file=%%t" 
    set "data=%%u"
	)

set "LOCK_DIR="!file:"=!Lock""
set /a TRY_COUNT=0

:TryLock
( 
mkdir %LOCK_DIR% 2>nul
) && (
    if "!rw!"=="r" (
        set /p "io="<!file! || echo ERROR reading [!file!]
    ) else if "!rw!"=="w" (
            echo !data!>!file! || echo ERROR writing [!data!] to [!file!]
	) else if "!rw!"=="ww" (
		echo !data!>>!file! || echo ERROR writing [!data!] to [!file!]
	)
	echo io [!rw!] operation on file [!file!] with data [!data!!io!]
) || (
    timeout /t 2 /nobreak >nul
    set /a TRY_COUNT+=1
    if !TRY_COUNT! lss %MAX_TRY% goto TryLock
    echo max wait.
)

rmdir "!LOCK_DIR!" 2>nul
for /F "tokens=* delims= " %%s in ("!io!") do (
    endlocal & set "io=%%s" 
	)
exit /b %errorlevel%