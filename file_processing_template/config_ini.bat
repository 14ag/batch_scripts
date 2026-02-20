@echo off
title config_ini
set "lines=20"
@rem mode con: cols=60 lines=%lines%

:config_ini

set "INI=%USERPROFILE%\Desktop\ftp_settings.ini"

setlocal EnableDelayedExpansion
:create
if not exist "%INI%" (
    echo creating config file on your desktop...
    (
      echo FTP_USER=
      echo FTP_PASS=
      echo FTP_PORT=
	  echo.
      echo ; mac address format xx-xx-xx-xx-xx-xx
      echo MAC_ADDRESS=
	  echo.
      echo ; set debug to 0 ^(default^) for off or 1 to get log file on your desktop folder
      echo debug=0
    ) > %INI%
    echo config file created. Press any key to open it for editing.
    pause >nul
    start notepad.exe %INI%
    echo.
    echo Please edit and save the config file, then press any key to continue.
    pause >nul
    goto :config_ini
)

for /f "usebackq delims=" %%a in ("%INI%") do (
	set "line=%%a"

	for /f "tokens=* delims= " %%b in ("!line!") do set "line=%%b"

		if defined line (
		set "firstChar=!line:~0,1!"

			if NOT "!firstChar!"==";" if NOT "!firstChar!"=="#" (

				echo "!line!" | findstr /c:"=" >nul
				if not errorlevel 1 (

				for /f "tokens=1* delims==" %%c in ("!line!") do (
					set "value=%%d"
					for /f "tokens=* delims=" %%e in ("!value!") do set "value=%%e"
					
					set "key=%%c"
					for /f "tokens=* delims= " %%e in ("!key!") do set "key=%%e"
					set "keys=!keys! !key!"
					set "!key!=!value!"
)	)	)	)	)

for %%a in (!keys:~1!) do (
  set "x=!x! & set "%%a=!%%a!""
  )

set "x=%x:~3%"
endlocal & %x%

exit /b %errorlevel%