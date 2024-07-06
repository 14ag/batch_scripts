@echo OFF
mode con:cols=62 lines=37
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
    ) ELSE ( >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" )
IF '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
    ) ELSE ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
@echo OFF
TITLE HOSTED NETWORK
color 0B
mode con:cols=62 lines=39
goto 8
:0
    echo.
    echo      1. Set up
    echo      2. Start
    echo      3. Turn off
    echo      4. Refresh
    echo      5. Show info
    echo.
    choice /C:123456 /N /M "Enter your choice : "
IF errorlevel 5 ( goto 11 )
IF errorlevel 4 ( goto 10 )
IF errorlevel 3 ( goto 9 )
IF errorlevel 2 ( goto 7 )
IF errorlevel 1 ( goto 7 )
:7
    cls
    setlocal ENABLEDELAYEDEXPANSION
    SET /P NNAME="Type the network SSID or press enter cancel : "
:71
    SET /P NKEY="Give the network a password or enter to cancel : "
(
    IF not defined NKEY (
        IF not defined NNAME (
            goto 0
            ) ELSE (
                netsh wlan set hostednetwork ssid=!NNAME!>nul
                goto 0
                )
    ) ELSE (
        for /f %%i in ("!NKEY!") do (
            set str=%%i
            set eighthK=!str:~7!
            )
    IF not DEFINED eighthK (
        cls
        echo      The password must contain at least 8 characters.
        SET NKEY=
        goto 71
    )
        netsh wlan set hostednetwork key=!NKEY!>nul
        )
    IF defined NNAME (
        netsh wlan set hostednetwork ssid=!NNAME!>nul
        )
    endlocal
) || (
    echo      Run as admin to change these.
    pause
    )
    goto 0
:8
    cls
    echo.
    (
        netsh wlan set hostednetwork mode=allow>nul && netsh wlan start hostednetwork>nul
    ) || (
        echo      Hosted network not started.
        goto 0
    )
    echo      Hosted network started.
    goto 0
:9
    cls
    echo.
    netsh wlan stop hostednetwork>nul
    netsh wlan set hostednetwork mode=disallow>nul
    echo      Hosted network stopped.
    goto 0
:10
    echo      Restarting...
    netsh wlan stop hostednetwork>nul
    netsh wlan start hostednetwork>nul
    cls
    echo      Network has been refreshed.
    goto 0
:11
    cls
    netsh wlan show hostednetwork
    netsh wlan show hostednetwork setting=security
    pause
    cls
    goto 0