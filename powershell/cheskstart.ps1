Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern int GetWindowTextLength(IntPtr hWnd);
}
"@

function Get-ForegroundWindowTitle {
    $hWnd = [User32]::GetForegroundWindow()
    if ($hWnd -eq [IntPtr]::Zero) {
        return $null
    }

    $length = [User32]::GetWindowTextLength($hWnd)
    if ($length -le 0) {
        return $null
    }

    $sb = New-Object System.Text.StringBuilder ($length + 1)
    [User32]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
    return $sb.ToString()
}

$foregroundTitle = Get-ForegroundWindowTitle
if ($foregroundTitle -eq "Start") {
    Write-Output "The Start menu is currently open."
} else {
    Write-Output "The Start menu is not open."
}
