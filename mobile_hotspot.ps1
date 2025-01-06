



# Check for admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    Read-Host -Prompt "Press Enter to exit"
    Read-Host -Prompt "Press Enter to exit"
    exit 1
}


# Check for loopback adapter
function Check-LoopbackAdapter {
    $loopbackAdapter = Get-NetAdapter | Where-Object { $_.Name -like "*Loopback*" }
    return $loopbackAdapter
}

# Install the Microsoft Loopback Adapter
function Install-LoopbackAdapter {
    # Specify the path to the INF file
    $infPath = "C:\Windows\INF\netloop.inf"

    # Ensure the INF file exists
    if (-not (Test-Path -Path $infPath)) {
        Write-Error "The specified INF file does not exist: $infPath"
        Read-Host -Prompt "Press Enter to exit"
        exit 1
    }

    # Install the driver using PnPUtil
    try {
        Write-Host "Installing driver from INF file: $infPath" -ForegroundColor Green
        $installResult = Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver `"$infPath`" /install" -NoNewWindow -Wait -PassThru

        if ($installResult.ExitCode -eq 0) {
            Write-Host "Driver installed successfully." -ForegroundColor Green
        }
        else {
            Write-Error "Failed to install the driver. Exit code: $($installResult.ExitCode)"
        }
    }
    catch {
        Write-Error "An error occurred while installing the driver: $_"
    }

}

# Share Internet using PowerShell networking cmdlets
function Share-Internet {
    $loopbackAdapter = Check-LoopbackAdapter
    if (-Not $loopbackAdapter) {
        Write-Error "Loopback adapter not found. Install it before proceeding."
        return
    }

    $internetAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -ne $loopbackAdapter.Name } | Select-Object -First 1
    if (-Not $internetAdapter) {
        Write-Error "No active internet adapter found for sharing."
        return
    }

    # Configure IP for the loopback adapter
    Write-Host "Configuring static IP for the loopback adapter..."
    New-NetIPAddress -InterfaceAlias $loopbackAdapter.Name -IPAddress 192.168.137.1 -PrefixLength 24 -DefaultGateway 192.168.137.1 -Confirm:$false

    # Enable ICS (Internet Connection Sharing)
    Write-Host "Enabling Internet Connection Sharing..."
    $icsService = Get-Service -Name SharedAccess
    if ($icsService.Status -ne "Running") {
        Start-Service -Name SharedAccess
    }

    Set-NetConnectionSharing -ConnectionName $internetAdapter.Name -SharingMode "Shared" -SharedConnection $loopbackAdapter.Name

    Write-Host "Internet sharing configured successfully."
}

# Main script execution
$loopbackAdapter = Check-LoopbackAdapter

if (-Not $loopbackAdapter) {
    Write-Host "Loopback adapter not found. Attempting installation..."
    Install-LoopbackAdapter
    Start-Sleep -Seconds 5
}

if ($loopbackAdapter) {
    Write-Host "Loopback adapter found. Configuring internet sharing..."
    Share-Internet
}
else {
    Write-Error "Failed to install or find the loopback adapter. Exiting."
}
