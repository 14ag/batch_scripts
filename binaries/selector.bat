@echo off

call :selector "echo absence & echo mountain & echo lecture & echo stress & echo joy"
echo.
echo %selector% ==================================================
exit /b

:: call :selector "[command that outputs list eg echo a & echo b & echo c]"
:: & is just a command separator, while && is a conditional operator
:selector
echo.
setlocal enabledelayedexpansion
set command=%* >nul
set "i=0"
set "selector="
set "choicelist="
:: Loop through a list, act on each line
for /f "eol=L tokens=1" %%a in ('!command!') do (
    set /a i+=1
    :: Create dynamic variable names (_1, _2, etc.)
    for %%b in (_!i!) do (
        set "%%b=%%a"
        set "choicelist=!choicelist!!i!"
        echo !i!. %%a
    )   )

call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1,1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
    for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
    )   )   )
:break
exit /b

:reset_choice
exit /b 0
