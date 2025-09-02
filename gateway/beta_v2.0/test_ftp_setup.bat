@echo off
setlocal enabledelayedexpansion
color 0E
title FTP Phone Connection Test Suite

echo ===============================================
echo         FTP Phone Connection Test Suite
echo ===============================================
echo.

:: Configuration check
echo [TEST 1] Checking Configuration...
echo -----------------------------------------
set PHONE_MAC=64-dd-e9-5c-e3-f3
set FTP_PORT=2121
echo Phone MAC: %PHONE_MAC%
echo FTP Port: %FTP_PORT%
echo.

:: Script availability check
echo [TEST 2] Checking Required Scripts...
echo -----------------------------------------
set SCRIPTS_OK=1

if exist auto_ftp_connector.bat (
    echo [OK] auto_ftp_connector.bat found
) else (
    echo [MISSING] auto_ftp_connector.bat
    set SCRIPTS_OK=0
)

if exist gateway.vbs (
    echo [OK] gateway.vbs found
) else (
    echo [OPTIONAL] gateway.vbs not found
)

if exist network_helper.vbs (
    echo [OK] network_helper.vbs found
) else (
    echo [OPTIONAL] network_helper.vbs not found
)

if exist network_scanner.ps1 (
    echo [OK] network_scanner.ps1 found
) else (
    echo [OPTIONAL] network_scanner.ps1 not found
)
echo.

:: Network adapter check
echo [TEST 3] Checking Network Adapters...
echo -----------------------------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    echo Found IP: %%a
)
echo.

:: Gateway check
echo [TEST 4] Checking Default Gateway...
echo -----------------------------------------
set GATEWAY_FOUND=0
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /v "::"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        echo Gateway: %%b
        set GATEWAY_FOUND=1
        
        :: Check gateway type
        echo %%b | findstr "192.168.43" >nul && echo    Type: Android Hotspot
        echo %%b | findstr "192.168.49" >nul && echo    Type: Samsung/LG Hotspot
        echo %%b | findstr "172.20" >nul && echo    Type: iPhone Hotspot
        echo %%b | findstr "192.168.137" >nul && echo    Type: Windows Hotspot
        echo %%b | findstr "192.168.100" >nul && echo    Type: Router Network
    )
)
if !GATEWAY_FOUND!==0 echo No gateway found
echo.

:: PowerShell check
echo [TEST 5] Checking PowerShell...
echo -----------------------------------------
powershell -Command "Write-Host 'PowerShell Version:' $PSVersionTable.PSVersion.Major" 2>nul
if !errorlevel!==0 (
    echo [OK] PowerShell is available
    
    :: Check execution policy
    powershell -Command "Get-ExecutionPolicy -Scope CurrentUser" 2>nul | findstr /i "Restricted" >nul
    if !errorlevel!==0 (
        echo [WARNING] PowerShell execution policy may be restricted
        echo Run as admin: powershell Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ) else (
        echo [OK] PowerShell execution policy is set
    )
) else (
    echo [WARNING] PowerShell not available or restricted
)
echo.

:: ARP cache check for phone
echo [TEST 6] Checking ARP Cache for Phone...
echo -----------------------------------------
set PHONE_FOUND=0
:: Normalize MAC for comparison (remove colons, convert to dashes)
set SEARCH_MAC=%PHONE_MAC:-=%
set SEARCH_MAC=%SEARCH_MAC::=-%

arp -a | findstr /i "%SEARCH_MAC%" >nul 2>&1
if !errorlevel!==0 (
    echo [FOUND] Phone MAC detected in ARP cache!
    for /f "tokens=1" %%a in ('arp -a ^| findstr /i "%SEARCH_MAC%"') do (
        echo    IP Address: %%a
        set PHONE_IP=%%a
        set PHONE_FOUND=1
    )
) else (
    echo Phone MAC not in ARP cache (phone may be offline or on different network)
)
echo.

:: FTP port test (if phone found)
if !PHONE_FOUND!==1 (
    echo [TEST 7] Testing FTP Connection...
    echo -----------------------------------------
    echo Testing %PHONE_IP%:%FTP_PORT%...
    
    :: Try PowerShell port test
    powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%PHONE_IP%', %FTP_PORT%); $tcp.Close(); Write-Host '[OK] FTP port is open' -ForegroundColor Green } catch { Write-Host '[FAILED] FTP port is closed or unreachable' -ForegroundColor Red }" 2>nul
    
    if !errorlevel!==0 (
        :: Fallback to telnet if available
        telnet 2>nul | findstr /i "telnet" >nul
        if !errorlevel!==0 (
            echo [INFO] Try: telnet %PHONE_IP% %FTP_PORT%
        )
    )
    echo.
)

:: Quick network scan
echo [TEST 8] Quick Network Scan...
echo -----------------------------------------
set /p SCAN="Perform quick network scan? (Y/N): "
if /i "%SCAN%"=="Y" (
    echo Scanning for devices with open port %FTP_PORT%...
    
    :: Determine current network
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr "192.168"') do (
        for /f "tokens=1-3 delims=." %%b in ("%%a") do (
            set NET_PREFIX=%%b.%%c.%%d
        )
    )
    
    if defined NET_PREFIX (
        echo Scanning %NET_PREFIX%.1-20 (quick scan)...
        set FOUND_FTP=0
        
        for /l %%i in (1,1,20) do (
            ping -n 1 -w 100 %NET_PREFIX%.%%i >nul 2>&1
            if !errorlevel!==0 (
                powershell -Command "$tcp = New-Object System.Net.Sockets.TcpClient; try { $tcp.Connect('%NET_PREFIX%.%%i', %FTP_PORT%); $tcp.Close(); Write-Host '%NET_PREFIX%.%%i - FTP OPEN' -ForegroundColor Green; } catch { }" 2>nul
            )
        )
    ) else (
        echo Unable to determine network prefix
    )
)
echo.

:: Summary
echo ===============================================
echo                   SUMMARY
echo ===============================================
if !SCRIPTS_OK!==1 (
    echo [READY] Core scripts are present
) else (
    echo [ACTION] Missing required scripts
)

if !PHONE_FOUND!==1 (
    echo [READY] Phone detected at %PHONE_IP%
    echo.
    echo You can now run: auto_ftp_connector.bat
) else (
    echo [INFO] Phone not detected on current network
    echo.
    echo Possible reasons:
    echo - Phone FTP server is not running
    echo - Phone is on different network
    echo - Phone is using different IP than before
    echo.
    echo Try running: auto_ftp_connector.bat
    echo It will perform a comprehensive search
)
echo.

:: Generate test report
set /p REPORT="Generate detailed test report? (Y/N): "
if /i "%REPORT%"=="Y" (
    (
        echo Test Report Generated: %date% %time%
        echo =====================================
        echo.
        echo System Info:
        systeminfo | findstr /i "OS Host Domain"
        echo.
        echo Network Configuration:
        ipconfig /all
        echo.
        echo ARP Cache:
        arp -a
        echo.
        echo Network Statistics:
        netstat -an | findstr ":%FTP_PORT%"
        echo.
        echo Route Table:
        route print
    ) > test_report_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt
    
    echo Report saved: test_report_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt
)

echo.
pause
exit /b