' gateway.vbs - Enhanced gateway detection for phone hotspot
' This version provides better detection of mobile hotspots

Option Explicit

Dim objWMI, objNetwork, strComputer
Dim colAdapters, objAdapter
Dim strGateway, strBestGateway, intPriority
Dim strIPAddress, strDescription

strComputer = "."
strBestGateway = ""
intPriority = 999

Set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set objNetwork = CreateObject("WScript.Network")

' Get all network adapters with IP enabled
Set colAdapters = objWMI.ExecQuery(_
    "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")

For Each objAdapter in colAdapters
    If Not IsNull(objAdapter.DefaultIPGateway) Then
        If IsArray(objAdapter.DefaultIPGateway) Then
            strGateway = objAdapter.DefaultIPGateway(0)
            strIPAddress = objAdapter.IPAddress(0)
            strDescription = objAdapter.Description
            
            ' Determine priority based on gateway pattern
            ' Priority 1: Known mobile hotspot ranges
            If InStr(strGateway, "192.168.43.") > 0 Then
                ' Android default hotspot
                strBestGateway = strGateway
                intPriority = 1
                Exit For
            ElseIf InStr(strGateway, "192.168.49.") > 0 Then
                ' Some Samsung/LG hotspots
                strBestGateway = strGateway
                intPriority = 1
                Exit For
            ElseIf InStr(strGateway, "172.20.10.") > 0 Then
                ' iPhone hotspot
                strBestGateway = strGateway
                intPriority = 1
                Exit For
            ElseIf InStr(strGateway, "192.168.42.") > 0 Then
                ' USB tethering (Android)
                strBestGateway = strGateway
                intPriority = 2
            ElseIf InStr(strGateway, "192.168.137.") > 0 Then
                ' Windows Mobile Hotspot (PC as gateway)
                If intPriority > 3 Then
                    strBestGateway = strGateway
                    intPriority = 3
                End If
            ElseIf InStr(strGateway, "192.168.1.") > 0 Or _
                   InStr(strGateway, "192.168.0.") > 0 Or _
                   InStr(strGateway, "192.168.100.") > 0 Then
                ' Common router ranges (lowest priority)
                If intPriority > 4 Then
                    strBestGateway = strGateway
                    intPriority = 4
                End If
            Else
                ' Unknown gateway
                If intPriority > 5 Then
                    strBestGateway = strGateway
                    intPriority = 5
                End If
            End If
            
            ' Debug output (comment out in production)
            ' WScript.Echo "Found: " & strGateway & " Priority: " & intPriority & " Desc: " & strDescription
        End If
    End If
Next

' Output the best gateway found
If strBestGateway <> "" Then
    WScript.Echo strBestGateway
Else
    ' No gateway found
    WScript.Echo ""
End If