# network_scanner.ps1 - Enhanced network scanning for phone FTP detection
param(
    [Parameter(Position=0)]
    [string]$Action = "scan",
    
    [Parameter(Position=1)]
    [string]$Network = ""
)

# Configuration
$PhoneMAC = "64-dd-e9-5c-e3-f3"
$FTPPort = 2121

# Function to normalize MAC address for comparison
function Normalize-MAC {
    param([string]$MAC)
    return $MAC.Replace(":", "").Replace("-", "").ToUpper()
}

# Function to get current network information
function Get-NetworkInfo {
    $adapters = Get-NetIPConfiguration | Where-Object { 
        $_.IPv4DefaultGateway -ne $null -and 
        $_.IPv4Address.IPAddress -ne $null 
    }
    
    $networks = @()
    foreach ($adapter in $adapters) {
        $ip = $adapter.IPv4Address.IPAddress
        $gateway = $adapter.IPv4DefaultGateway.NextHop
        
        # Determine network type
        $networkType = "Unknown"
        if ($gateway -match "192\.168\.43\.|192\.168\.49\.|172\.20\.") {
            $networkType = "Phone Hotspot"
        } elseif ($ip -match "192\.168\.137\.") {
            $networkType = "PC Hotspot"
        } elseif ($ip -match "192\.168\.100\.") {
            $networkType = "Router"
        }
        
        $networks += [PSCustomObject]@{
            Interface = $adapter.InterfaceAlias
            IP = $ip
            Gateway = $gateway
            Type = $networkType
            Subnet = ($ip -replace '\.\d+$', '')
        }
    }
    
    return $networks
}

# Function to scan network using parallel jobs
function Scan-Network {
    param(
        [string]$NetworkPrefix,
        [int]$StartHost = 1,
        [int]$EndHost = 254
    )
    
    Write-Host "Scanning $NetworkPrefix.0/24 network..." -ForegroundColor Yellow
    
    # Create jobs for parallel scanning
    $jobs = @()
    $batchSize = 25
    
    for ($i = $StartHost; $i -le $EndHost; $i += $batchSize) {
        $end = [Math]::Min($i + $batchSize - 1, $EndHost)
        
        $jobs += Start-Job -ScriptBlock {
            param($prefix, $start, $end)
            
            $results = @()
            for ($host = $start; $host -le $end; $host++) {
                $ip = "$prefix.$host"
                $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1
                
                if ($ping) {
                    # Try to get hostname
                    $hostname = ""
                    try {
                        $dns = [System.Net.Dns]::GetHostEntry($ip)
                        $hostname = $dns.HostName
                    } catch { }
                    
                    # Check if FTP port is open
                    $ftpOpen = $false
                    try {
                        $tcpClient = New-Object System.Net.Sockets.TcpClient
                        $connect = $tcpClient.BeginConnect($ip, 2121, $null, $null)
                        $wait = $connect.AsyncWaitHandle.WaitOne(500, $false)
                        if ($wait -and !$tcpClient.Connected) {
                            $ftpOpen = $false
                        } else {
                            $ftpOpen = $true
                        }
                        $tcpClient.Close()
                    } catch { }
                    
                    $results += [PSCustomObject]@{
                        IP = $ip
                        Hostname = $hostname
                        FTPOpen = $ftpOpen
                    }
                }
            }
            return $results
        } -ArgumentList $NetworkPrefix, $i, $end
    }
    
    # Wait for all jobs and collect results
    $allDevices = @()
    $completed = 0
    
    while ($jobs.Count -gt 0) {
        $done = @()
        foreach ($job in $jobs) {
            if ($job.State -eq 'Completed') {
                $devices = Receive-Job -Job $job
                $allDevices += $devices
                Remove-Job -Job $job
                $done += $job
                $completed++
                Write-Progress -Activity "Scanning Network" -Status "$completed batches completed" -PercentComplete (($completed / ($EndHost/$batchSize)) * 100)
            }
        }
        foreach ($d in $done) {
            $jobs = $jobs | Where-Object { $_.Id -ne $d.Id }
        }
        Start-Sleep -Milliseconds 100
    }
    
    Write-Progress -Activity "Scanning Network" -Completed
    
    # Check ARP cache for MAC address
    $arpCache = arp -a | Out-String
    $normalizedPhoneMAC = Normalize-MAC -MAC $PhoneMAC
    
    foreach ($device in $allDevices) {
        # Check if this IP has our phone's MAC
        $arpEntry = $arpCache | Select-String -Pattern "$($device.IP)\s+([0-9a-fA-F-]+)" -AllMatches
        
        if ($arpEntry) {
            $mac = $arpEntry.Matches[0].Groups[1].Value
            $normalizedMAC = Normalize-MAC -MAC $mac
            
            if ($normalizedMAC -eq $normalizedPhoneMAC) {
                Write-Host "`n[FOUND] Phone detected at $($device.IP)" -ForegroundColor Green
                if ($device.FTPOpen) {
                    Write-Host "        FTP port 2121 is OPEN" -ForegroundColor Green
                } else {
                    Write-Host "        FTP port 2121 is CLOSED" -ForegroundColor Yellow
                }
                return $device.IP
            }
        }
    }
    
    # If MAC not found, show all devices with open FTP ports
    $ftpDevices = $allDevices | Where-Object { $_.FTPOpen }
    
    if ($ftpDevices.Count -gt 0) {
        Write-Host "`nDevices with FTP port 2121 open:" -ForegroundColor Cyan
        $i = 1
        foreach ($device in $ftpDevices) {
            Write-Host "  [$i] $($device.IP)" -NoNewline
            if ($device.Hostname) {
                Write-Host " ($($device.Hostname))" -ForegroundColor Gray
            } else {
                Write-Host ""
            }
            $i++
        }
        
        $choice = Read-Host "`nIs your phone one of these? Enter number or press Enter to skip"
        if ($choice -match '^\d+$') {
            $index = [int]$choice - 1
            if ($index -ge 0 -and $index -lt $ftpDevices.Count) {
                return $ftpDevices[$index].IP
            }
        }
    }
    
    return $null
}

# Function to find phone across all networks
function Find-Phone {
    $networks = Get-NetworkInfo
    
    Write-Host "=== Network Detection ===" -ForegroundColor Cyan
    foreach ($net in $networks) {
        Write-Host "Interface: $($net.Interface)"
        Write-Host "  IP: $($net.IP)"
        Write-Host "  Gateway: $($net.Gateway)"
        Write-Host "  Type: $($net.Type)"
        Write-Host ""
    }
    
    # Priority order: Phone Hotspot -> PC Hotspot -> Router
    $priorityOrder = @("Phone Hotspot", "PC Hotspot", "Router", "Unknown")
    
    foreach ($priority in $priorityOrder) {
        $network = $networks | Where-Object { $_.Type -eq $priority } | Select-Object -First 1
        
        if ($network) {
            Write-Host "`nChecking $($network.Type) network..." -ForegroundColor Yellow
            
            if ($network.Type -eq "Phone Hotspot") {
                # Gateway is likely the phone itself
                Write-Host "Testing gateway: $($network.Gateway)" -ForegroundColor Gray
                if (Test-Connection -ComputerName $network.Gateway -Count 1 -Quiet) {
                    # Test FTP port
                    try {
                        $tcpClient = New-Object System.Net.Sockets.TcpClient
                        $tcpClient.Connect($network.Gateway, $FTPPort)
                        $tcpClient.Close()
                        Write-Host "[FOUND] Phone at gateway: $($network.Gateway)" -ForegroundColor Green
                        return $network.Gateway
                    } catch { }
                }
            } else {
                $phoneIP = Scan-Network -NetworkPrefix $network.Subnet
                if ($phoneIP) {
                    return $phoneIP
                }
            }
        }
    }
    
    return $null
}

# Main execution
switch ($Action) {
    "scan" {
        $result = Find-Phone
        if ($result) {
            Write-Output $result
        } else {
            Write-Output "NOT_FOUND"
        }
    }
    
    "quick" {
        # Quick scan specific network
        if ($Network) {
            $result = Scan-Network -NetworkPrefix $Network -StartHost 1 -EndHost 50
            if ($result) {
                Write-Output $result
            } else {
                Write-Output "NOT_FOUND"
            }
        }
    }
    
    "info" {
        Get-NetworkInfo | Format-Table -AutoSize
    }
    
    default {
        Write-Host "Usage: .\network_scanner.ps1 [scan|quick|info] [network]"
    }
}
