' Define the computer to query ('. ' for the local computer)
strComputer = "."

' Connect to the WMI service
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")

' Loop through each network adapter configuration
For Each objItem In colItems
    ' Use a single If statement to check for both properties
    If Not IsNull(objItem.IPAddress) And Not IsNull(objItem.DefaultIPGateway) Then
        Wscript.Echo "Adapter: " & objItem.Description
        
        ' Loop through the IP addresses
        For Each strIPAddress In objItem.IPAddress
            ' Filter for IPv4 addresses
            If InStr(strIPAddress, ":") = 0 Then
                Wscript.Echo "  IPv4 Address: " & strIPAddress
            End If
        Next
        
        ' Loop through the default gateways
        For Each strGateway In objItem.DefaultIPGateway
            Wscript.Echo "  Default Gateway: " & strGateway
        Next
        
        Wscript.Echo
    End If
Next

' Clean up objects
Set colItems = Nothing
Set objWMIService = Nothing