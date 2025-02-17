Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Keyboard {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
}
"@

# Simulate the Windows key press
[Keyboard]::keybd_event(0x5B, 0, 0, 0) # 0x5B is the left Windows key
[Keyboard]::keybd_event(0x5B, 0, 2, 0) # Release the Windows key
