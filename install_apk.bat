::---------------------------------------------------------------------------------------------------
:: File: install_apk.bat
:: commandline usage: install_apk.bat "path\to\app.apk"
::                    install_apk.bat "path\to\app.apks"
::                    install_apk.bat "path\to\folder"
::
:: Description:
::     installs an apk or apks file on a connected adb device
::     accepts a folder instead of a file and offers to install every apk or apks found in it
::     checks for a connected device before doing anything else
::     builds a dynamic list of connected devices and lets the user pick one with the selector function
::     reads the package name with aapt2 dump badging
::     for an apks file it first extracts the splits base master apk then reads that instead
::     reads the device screen density and locale then installs apks files with bundletool
::     bundletool matches the correct density abi and locale splits on its own
::     asks the user to confirm with the selector function before installing
::     shows a success or failure message and pauses at the end
::
:: References:
::     https://developer.android.com/tools/adb
::     https://developer.android.com/tools/aapt2
::     https://developer.android.com/tools/bundletool
::     https://developer.android.com/guide/topics/resources/localization
::
::---------------------------------------------------------------------------------------------------
@echo off

:: user configurable settings come first
:: fill these in with the full path to each binary
set "ADB="
set "AAPT2="
set "JAVA="
set "BUNDLETOOL_JAR="

:: internal state and functional vars come after
set "_path=%~1"
set "ext="
set "is_apks=0"
set "device_serial="
set "install_result="

:startupValidation
if not defined _path (
    call :error usage install_apk bat "path to apk apks file or folder"
    goto :end
)

:getFile
call :info enter the file or folder to be processed here or
call :info Press Enter to process all files with the extensions "%extensions%" in the current directory
set "_path="
set /p "_path=::"
if not defined _path (
	set "_path=%currentDirectory:"=%"
) else if defined _path (
		set "_path=%_path:"=%"
	)



set "_path=%_path:"=%"

if not defined ADB (
    call :error ADB path is not set edit this script and fill in the ADB variable
    goto :end
)
if not defined AAPT2 (
    call :error AAPT2 path is not set edit this script and fill in the AAPT2 variable
    goto :end
)

call :file_or_folder "%_path%"

if "%file_or_folder%"=="folder" (
    if not defined JAVA (
        call :error JAVA path is not set edit this script and fill in the JAVA variable
        goto :end
    )
    if not defined BUNDLETOOL_JAR (
        call :error BUNDLETOOL_JAR path is not set edit this script and fill in the BUNDLETOOL_JAR variable
        goto :end
    )
    call :install_folder "%_path%"
    goto :end
)

if not "%file_or_folder%"=="file" (
    call :error "...%_path:~-20%" not found
    goto :end
)

for %%e in ("%_path%") do set "ext=%%~xe"
if /I "%ext%"==".apk" (
    set "is_apks=0"
) else if /I "%ext%"==".apks" (
    set "is_apks=1"
) else (
    call :error only apk or apks files are supported
    goto :end
)
if "%is_apks%"=="1" if not defined JAVA (
    call :error JAVA path is not set edit this script and fill in the JAVA variable
    goto :end
)
if "%is_apks%"=="1" if not defined BUNDLETOOL_JAR (
    call :error BUNDLETOOL_JAR path is not set edit this script and fill in the BUNDLETOOL_JAR variable
    goto :end
)

:main
:: step 1 check for a connected device and let the user pick one if there is more than one
call :adb_device_list
if not defined adb_device_list (
    call :error no adb device connected connect a device and enable usb debugging
    goto :end
)
echo %adb_device_list%| findstr "," >nul
if not errorlevel 1 (
    call :info more than one device is connected pick one below
    call :selector %adb_device_list%
    set "device_serial=%selector%"
) else (
    set "device_serial=%adb_device_list%"
)

:: step 2 read the app name
call :apk_name "%_path%"
if not defined apk_name (
    call :error could not read the package name from "%_path%"
    goto :end
)

:: step 3 apks files also need the device density and locale for bundletool
if "%is_apks%"=="1" (
    call :device_dpi
    call :device_locale
    call :info device screen density is %device_dpi% dpi locale is %device_locale%
    call :info bundletool will match the correct density abi and locale splits
)

:: step 4 ask the user to confirm with the selector function before installing
echo.
call :info install "%apk_name%"
call :selector yes,no
if /I "%selector%"=="no" (
    call :info installation cancelled by user
    goto :end
)

if "%is_apks%"=="1" (
    call :install_apks "%_path%"
) else (
    call :install_apk "%_path%"
)

if "%install_result%"=="0" (
    call :info "%apk_name%" installed successfully
    pause
) else (
    call :error failed to install "%apk_name%"
)
goto :end

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:install_folder
:: scans a folder for apk and apks files and offers to install all of them
:: shows a final count of how many installed successfully and how many failed
:: call :install_folder "folder path"
setlocal enabledelayedexpansion
set "_dir=%~1"
if "!_dir:~-1!"=="\" set "_dir=!_dir:~0,-1!"

set "found_count=0"
for %%f in ("%_dir%\*.apk" "%_dir%\*.apks") do (
    if exist "%%f" set /a "found_count+=1"
)
if "%found_count%"=="0" (
    call :error no apk or apks files found in "%_dir%"
    endlocal
    exit /b 0
)

call :info found %found_count% apk or apks files in "%_dir%"
for %%f in ("%_dir%\*.apk" "%_dir%\*.apks") do (
    if exist "%%f" echo   %%~nxf
)

call :adb_device_list
if not defined adb_device_list (
    call :error no adb device connected connect a device and enable usb debugging
    endlocal
    exit /b 0
)
echo !adb_device_list!| findstr "," >nul
if not errorlevel 1 (
    call :info more than one device is connected pick one below
    call :selector !adb_device_list!
    set "device_serial=!selector!"
) else (
    set "device_serial=!adb_device_list!"
)

call :info install all %found_count% packages found
call :selector yes,no
if /I "!selector!"=="no" (
    call :info installation cancelled by user
    endlocal
    exit /b 0
)

set "ok_count=0"
set "error_count=0"
for %%f in ("%_dir%\*.apk" "%_dir%\*.apks") do (
    if exist "%%f" (
        set "_path=%%~ff"
        set "ext=%%~xf"
        if /I "!ext!"==".apks" (set "is_apks=1") else (set "is_apks=0")
        call :apk_name "!_path!"
        if "!is_apks!"=="1" (
            call :install_apks "!_path!"
        ) else (
            call :install_apk "!_path!"
        )
        if "!install_result!"=="0" (
            call :info "!apk_name!" installed successfully
            set /a "ok_count+=1"
        ) else (
            call :error failed to install "!apk_name!"
            set /a "error_count+=1"
        )
    )
)
call :info done %ok_count% installed successfully and %error_count% failed
pause
endlocal
exit /b 0

:adb_device_list
:: builds a comma separated list of every connected adb device serial
:: stores each serial in a dynamic indexed variable the same way as adb_device_selector.bat
:: returns the comma separated list in variable adb_device_list
:: returns an empty string when no device is connected
:: call :adb_device_list
set "adb_device_list="
setlocal enabledelayedexpansion
set "device_count=0"
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
    if "%%b"=="device" (
        set /a "device_count+=1"
        set "device_!device_count!=%%a"
    )
)
for /l %%i in (1,1,!device_count!) do (
    if defined adb_device_list (
        set "adb_device_list=!adb_device_list!,!device_%%i!"
    ) else (
        set "adb_device_list=!device_%%i!"
    )
)
endlocal & set "adb_device_list=%adb_device_list%"
exit /b 0

:apk_name
:: reads the package name from an apk or apks file using aapt2 dump badging
:: for an apks file it first extracts the splits base master apk then reads that instead
:: returns the package name in variable apk_name
:: call :apk_name "path to apk or apks file"
set "apk_name="
set "_target=%~1"
set "_cleanup="
if /I "%~x1"==".apks" (
    set "_tmp_dir=%TEMP%\apkinstall_%RANDOM%"
    md "%_tmp_dir%" >nul 2>&1
    powershell -NoProfile -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $z=[System.IO.Compression.ZipFile]::OpenRead('%~1'); $e=$z.Entries | Where-Object { $_.FullName -eq 'splits/base-master.apk' }; if ($e) { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e,'%_tmp_dir%\base.apk',$true) }; $z.Dispose()" >nul 2>&1
    if exist "%_tmp_dir%\base.apk" (
        set "_target=%_tmp_dir%\base.apk"
        set "_cleanup=%_tmp_dir%"
    )
)
for /f "tokens=2 delims='" %%n in ('"%AAPT2%" dump badging "%_target%" ^| findstr /b "package:"') do (
    if not defined apk_name set "apk_name=%%n"
)
if defined _cleanup rd /s /q "%_cleanup%" >nul 2>&1
exit /b 0

:device_dpi
:: reads the physical screen density of the connected device
:: returns device_dpi
:: call :device_dpi
set "device_dpi="
for /f "tokens=2 delims=:" %%d in ('"%ADB%" -s "%device_serial%" shell wm density ^| findstr /b "Physical density"') do (
    set "device_dpi=%%d"
)
set "device_dpi=%device_dpi: =%"
exit /b 0

:device_locale
:: reads the current locale of the connected device
:: returns device_locale
:: call :device_locale
set "device_locale="
for /f %%l in ('"%ADB%" -s "%device_serial%" shell getprop persist.sys.locale') do (
    set "device_locale=%%l"
)
exit /b 0

:install_apk
:: installs a single apk file to the connected device
:: returns install_result
:: call :install_apk "path to apk file"
"%ADB%" -s "%device_serial%" install -r "%~1"
set "install_result=%errorlevel%"
exit /b %install_result%

:install_apks
:: installs an apks file using bundletool matched to the connected device
:: bundletool detects density abi locale and sdk version on its own via adb
:: returns install_result
:: call :install_apks "path to apks file"
"%JAVA%" -jar "%BUNDLETOOL_JAR%" install-apks --apks="%~1" --device-id="%device_serial%"
set "install_result=%errorlevel%"
exit /b %install_result%

:selector
:: creates a dynamic numbered list from comma separated args
:: returns the chosen item in variable selector
:: call :selector arg1,arg2,arg3
setlocal enabledelayedexpansion
set "selector="
set "arg_string=%*"
set "i=0"
set "choicelist="
REM replace every comma with a space separated quoted token
set "arg_list="%arg_string:,=" "%""
for %%a in (%arg_list%) do (
    set /a i+=1
    for %%b in (_!i!) do (
        set "%%b=%%a"
        set "choicelist=!choicelist!!i!"
        set "display_value=%%a"
        set "display_value=!display_value:"=!"
        echo   [!i!].. !display_value!
    )   )
call :reset_choice
choice /c %choicelist% /n /m "pick option btn %choicelist:~0,1% and %choicelist:~-1,1% ::"
for /L %%c in (%choicelist:~-1%,-1,%choicelist:~0,1%) do (
    if errorlevel %%c (
        for %%d in (!_%%c!) do (
            endlocal & set "selector=%%d"
            goto :break
        )   )   )
:break
set "selector=%selector:"=%"
exit /b 0

:reset_choice
:: reset errorlevel for correct choice
:: required by selector before every choice command
:: call :reset_choice
exit /b 0

:file_or_folder
:: checks if a path is a file or folder
:: returns file or folder in variable file_or_folder
:: returns empty string if path does not exist
:: call :file_or_folder "path"
set "file_or_folder="
setlocal enabledelayedexpansion
set "b=%*"
set "b=%b:"=%"
if exist "%b%" (
    for %%I in ("%b%") do (
        set "attrs=%%~aI"
        REM check if the first attribute char is d meaning directory
        if "!attrs:~0,1!" == "d" (
            endlocal & set "file_or_folder=folder"
        ) else (
            endlocal & set "file_or_folder=file"
        )   )
)
exit /b 0

:error
:: error handling
:: has a beep
:: call :error "error message"
Echo 1n| CHOICE /N >nul 2>&1 & :: BEL
echo error: %*
pause
exit /b 1

:info
:: info handling
:: does not have a beep
:: call :info "info message"
echo.
echo info: %*
exit /b 0

:end
exit /b
