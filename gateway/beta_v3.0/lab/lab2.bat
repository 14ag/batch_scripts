@echo off
rem -------------------------------
rem Read an INI-style file from Desktop and set variables
rem - Skips blank lines and lines starting with ; or #
rem - Accepts lines in the form KEY=VALUE
rem - Trims leading spaces, removes surrounding quotes from values
rem -------------------------------

setlocal EnableDelayedExpansion

rem Path to INI on Desktop (change filename if needed)
set "INI=%USERPROFILE%\Desktop\ftp_settings.ini"
:create
if not exist "%INI%" (
    echo creating config file on your desktop...
    (
  echo FTP_USER=
  echo FTP_PASS=
  echo FTP_PORT=
  echo PHONE_MAC=
  echo debug=
  echo 
    ) > %INI%
    config file created. press any key to open it
    pause >nul
    start notepad.exe %INI%
    goto :create
)

rem Read the file line by line
for /f "usebackq delims=" %%A in ("%INI%") do (
  rem store raw line in a variable
  set "line=%%A"

  rem trim leading spaces (tokens=* removes leading whitespace)
  for /f "tokens=* delims= " %%B in ("!line!") do set "line=%%B"

  rem skip empty lines
  if defined line (
    rem get first character to detect comment markers
    set "firstChar=!line:~0,1!"

    rem skip comments starting with ; or #
    if NOT "!firstChar!"==";" if NOT "!firstChar!"=="#" (

      rem only process lines containing an '='
      echo "!line!" | findstr /c:"=" >nul
      if not errorlevel 1 (

        rem split on the first '=' into key and value
        for /f "tokens=1* delims==" %%K in ("!line!") do (
          set "key=%%K"
          set "value=%%L"

          rem trim trailing/leading spaces from key
          for /f "tokens=* delims= " %%X in ("!key!") do set "key=%%X"

          rem trim leading spaces from value (preserve internal spaces)
          for /f "tokens=* delims=" %%Y in ("!value!") do set "value=%%Y"

          rem remove surrounding double quotes if present
          if "!value:~0,1!"=="\"" set "value=!value:~1!"
          if "!value:~-1!"=="\"" set "value=!value:~0,-1!"

          rem finally set the environment variable (key name must be valid)
          rem Use delayed expansion to preserve special chars in value.
          set "!key!=!value!"
        )
      )
    )
  )
)

rem (optional) show what was loaded - comment out if not needed
echo --- loaded variables from "%INI%" ---
for %%V in (FTP_USER FTP_PASS FTP_PORT PHONE_MAC PHONE_IP NETWORK_TYPE LOGPATH debug) do (
  if defined %%V echo %%V=%%V
)
echo -------------------------------------

echo FTP_USER=%FTP_USER%
pause
rem keep variables for the rest of the script (no endlocal here)
rem continue your script below...
