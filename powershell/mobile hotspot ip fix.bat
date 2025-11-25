@echo off
REM fix_mobile_hotspot.bat
REM Batch wrapper that runs PowerShell to toggle ICS (enable->disable), restart ICS service,
REM reset network stacks, and attempt to refresh the internet-facing adapter so Mobile Hotspot can get an IP.

:: --- Elevation check & relaunch as admin if needed ---
openfiles >nul 2>&1
if %errorlevel% neq 0 (
  echo Requesting elevation...
  powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo Running as Administrator -- proceeding...
timeout /t 1 >nul

:: --- Run embedded PowerShell for the main logic ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try { ^
    Write-Host '--- Step 1: Identify internet-facing adapter (has default gateway)...'; ^
    $ipcfg = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1; ^
    if (-not $ipcfg) { Write-Warning 'No adapter with default gateway found. Will attempt to use the first up Ethernet/Wi-Fi adapter.'; ^
        $ipcfg = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1 | ForEach-Object { Get-NetIPConfiguration -InterfaceIndex $_.ifIndex } ^
    } ^
    if (-not $ipcfg) { throw 'Could not determine an internet-connected adapter. Aborting ICS toggle.' } ^
    $ifaceAlias = $ipcfg.InterfaceAlias; ^
    Write-Host \"Internet adapter identified: $ifaceAlias\"; ^
    Write-Host ''; ^
    #
    # Step 2: Toggle ICS through the HNetCfg COM interface (enable -> disable)
    # Note: EnableSharing takes a numeric type: 0 = Public, 1 = Private (common scripts use 0 for Internet-facing). 
    # If EnableSharing fails due to policy or Windows version, we catch and report it.
    Write-Host '--- Step 2: Attempt ICS enable -> disable cycle using HNetCfg (COM)...'; ^
    $h = New-Object -ComObject HNetCfg.HNetShare; ^
    $allConns = $h.EnumEveryConnection() ; ^
    $targetConn = $null; ^
    foreach ($c in $allConns) { ^
        $props = $h.NetConnectionProps($c); ^
        if ($props.Name -eq $ifaceAlias) { $targetConn = $c; break } ^
    } ^
    if (-not $targetConn) { Write-Warning \"Adapter '$ifaceAlias' not found in HNetCfg connections. Skipping COM-based ICS toggle.\" } else { ^
        $cfg = $h.INetSharingConfigurationForINetConnection($targetConn); ^
        # If ICS is not enabled, EnableSharing; if enabled, note that and still proceed to enable then disable per original procedure.
        try { ^
            Write-Host 'Enabling ICS on the adapter (type: Public = 0)...'; ^
            $cfg.EnableSharing(0); ^
            Start-Sleep -Seconds 1; ^
            Write-Host 'Now disabling ICS on the adapter...'; ^
            $cfg.DisableSharing(); ^
            Write-Host 'ICS enable->disable cycle completed.'; ^
        } catch { Write-Warning \"COM ICS toggle failed: $($_.Exception.Message)\" } ^
    } ^
    #
    Write-Host ''; ^
    Write-Host '--- Step 3: Restart Windows ICS service (SharedAccess) to apply changes...'; ^
    $svc = Get-Service -Name SharedAccess -ErrorAction SilentlyContinue; ^
    if ($svc) { ^
        if ($svc.Status -ne 'Stopped') { Write-Host 'Stopping SharedAccess...'; Stop-Service -Name SharedAccess -Force -ErrorAction SilentlyContinue } ^
        Start-Sleep -Seconds 1; ^
        Write-Host 'Starting SharedAccess...'; Start-Service -Name SharedAccess -ErrorAction SilentlyContinue; ^
        Start-Sleep -Seconds 2; ^
        Write-Host 'SharedAccess service restarted.'; ^
    } else { Write-Warning 'SharedAccess service not found. Skipping service restart.' } ^
    #
    Write-Host ''; ^
    Write-Host '--- Step 4: Reset network stacks (Winsock, TCP/IP) and refresh adapter IP...'; ^
    Write-Host 'Running: netsh winsock reset'; ^
    netsh winsock reset | Out-Null; ^
    Write-Host 'Running: netsh int ip reset'; ^
    netsh int ip reset | Out-Null; ^
    Write-Host 'Releasing and renewing IPv4 addresses...'; ^
    ipconfig /release | Out-Null; Start-Sleep -Seconds 1; ipconfig /renew | Out-Null; ^
    #
    Write-Host ''; ^
    Write-Host '--- Step 5: Soft restart of the adapter to apply changes (if possible)...'; ^
    try { ^
        $ifIndex = $ipcfg.InterfaceIndex; ^
        if ($ifIndex) { ^
            Write-Host \"Restarting adapter (InterfaceIndex = $ifIndex)...\"; ^
            Disable-NetAdapter -InterfaceIndex $ifIndex -Confirm:$false -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Enable-NetAdapter -InterfaceIndex $ifIndex -Confirm:$false -ErrorAction SilentlyContinue; ^
            Write-Host 'Adapter restarted.'; ^
        } ^
    } catch { Write-Warning \"Adapter restart failed: $($_.Exception.Message)\" } ^
    #
    Write-Host ''; ^
    Write-Host '--- Final instructions & notes ---'; ^
    Write-Host '1) Open Settings -> Network & Internet -> Mobile hotspot, toggle Mobile Hotspot ON.'; ^
    Write-Host '2) When using Mobile Hotspot, make sure the checkboxes in the Sharing tab of the adapter properties are UNCHECKED (the Windows UI can be inconsistent).'; ^
    Write-Host '3) If Mobile Hotspot still shows \"Couldn''t get IP address\", please try a full reboot and re-run this script if necessary.'; ^
    Write-Host ''; ^
    Write-Host 'Completed. If you want, run this script again after a reboot.'; ^
    exit 0; ^
} catch { Write-Error \"Fatal error: $($_.Exception.Message)\"; exit 2 }"

echo.
echo Done. If Windows still shows 'Couldn't get IP address', reboot and run the script again, then open Settings -> Network & Internet -> Mobile hotspot and toggle it on manually.
pause
