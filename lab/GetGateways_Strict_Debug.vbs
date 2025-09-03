' GetGateways_Strict_Debug.vbs
' Returns connected gateways in format: adapterType_IP (space-separated)

Option Explicit

Dim objWMIService, colAdapters, objAdapter
Dim colNetworkConfigs, objConfig
Dim wifi, ethernet, hotspot, gateways
Dim isVerbose, args
Dim wifiConnected, ethernetConnected, hotspotActive
Dim strComputer

' Initialize variables
wifi = ""
ethernet = ""
hotspot = ""
gateways = ""
wifiConnected = False
ethernetConnected = False
hotspotActive = False
strComputer = "."

' Check for verbose argument
Set args = WScript.Arguments
isVerbose = False
If args.Count > 0 Then
    If LCase(args(0)) = "verbose" Then
        isVerbose = True
    End If
End If

Sub LogVerbose(message)
    If isVerbose Then
        WScript.Echo "[LOG] " & message
    End If
End Sub

LogVerbose "Starting GetGateways_Strict_Debug.vbs"
LogVerbose "Verbose mode: ENABLED"

' Connect to WMI
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")

' Get network adapter configurations
Set colNetworkConfigs = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")

LogVerbose "Querying network adapter configurations..."

For Each objConfig In colNetworkConfigs
    Dim adapterName, defaultGateway, adapterType, strIPAddress
    adapterName = ""
    adapterType = ""
    
    ' Get the associated network adapter
    On Error Resume Next
    Set colAdapters = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE Index = " & objConfig.Index)
    
    For Each objAdapter In colAdapters
        adapterName = objAdapter.Name
        LogVerbose "Found adapter: " & adapterName & " (Index: " & objConfig.Index & ")"
        
        ' Check adapter status
        If objAdapter.NetConnectionStatus = 2 Then ' Connected
            LogVerbose "  Status: Connected"
            
            ' Get default gateway
            If Not IsNull(objConfig.DefaultIPGateway) Or _
                Not IsNull(objConfig.IPAddress) Then
                strIPAddress = objConfig.IPAddress(0) ' Take the first IP address
                If UBound(objConfig.DefaultIPGateway) >= 0 Or _
                   InStr(strIPAddress, ":") = 0 Then
                    defaultGateway = objConfig.DefaultIPGateway(0)
                    LogVerbose "  Gateway: " & defaultGateway
                    
                    ' Determine adapter type based on name
                    ' Check for Mobile Hotspot (Microsoft Wi-Fi Direct Virtual Adapter)
                    If InStr(LCase(adapterName), "microsoft wi-fi direct") > 0 Or _
                       InStr(LCase(adapterName), "hosted network") > 0 Or _
                       InStr(LCase(adapterName), "virtual adapter") > 0 Then
                        adapterType = "mobileHotspot"
                        LogVerbose "  Type: Mobile Hotspot"
                        If hotspot = "" Then
                            hotspot = "mobileHotspot_" & strIPAddress
                            hotspotActive = True
                            LogVerbose "  Stored as: " & hotspot
                        End If
                        
                    ' Check for Ethernet
                    ElseIf InStr(LCase(adapterName), "ethernet") > 0 Or _
                           InStr(LCase(adapterName), "realtek") > 0 Or _
                           InStr(LCase(adapterName), "intel") > 0 And _
                           Not (InStr(LCase(adapterName), "wireless") > 0 Or _
                                InStr(LCase(adapterName), "wi-fi") > 0 Or _
                                InStr(LCase(adapterName), "wifi") > 0) Then
                        If InStr(LCase(adapterName), "virtual") = 0 Then
                            adapterType = "ethernet"
                            LogVerbose "  Type: Ethernet"
                            If ethernet = "" Then
                                ethernet = "ethernet_" & defaultGateway
                                ethernetConnected = True
                                LogVerbose "  Stored as: " & ethernet
                            End If
                        End If
                        
                    ' Check for WiFi
                    ElseIf InStr(LCase(adapterName), "wi-fi") > 0 Or _
                           InStr(LCase(adapterName), "wifi") > 0 Or _
                           InStr(LCase(adapterName), "wireless") > 0 Or _
                           InStr(LCase(adapterName), "802.11") > 0 Or _
                           InStr(LCase(adapterName), "wlan") > 0 Then
                        ' Make sure it's not the virtual adapter
                        If InStr(LCase(adapterName), "virtual") = 0 And _
                           InStr(LCase(adapterName), "direct") = 0 Then
                            adapterType = "wifi"
                            LogVerbose "  Type: WiFi"
                            If wifi = "" Then
                                wifi = "wifi_" & defaultGateway
                                wifiConnected = True
                                LogVerbose "  Stored as: " & wifi
                            End If
                        End If
                    End If
                Else
                    LogVerbose "  No gateway configured"
                End If
            Else
                LogVerbose "  No gateway configured"
            End If
        Else
            LogVerbose "  Status: Not connected (Status code: " & objAdapter.NetConnectionStatus & ")"
        End If
    Next
    On Error GoTo 0
Next

LogVerbose ""
LogVerbose "Summary:"
LogVerbose "  WiFi: " & IIf(wifiConnected, wifi, "Not connected")
LogVerbose "  Ethernet: " & IIf(ethernetConnected, ethernet, "Not connected")
LogVerbose "  Mobile Hotspot: " & IIf(hotspotActive, hotspot, "Not active")

' Build the gateways string
Dim gatewayArray()
Dim gatewayCount
gatewayCount = 0

If wifi <> "" Then
    ReDim Preserve gatewayArray(gatewayCount)
    gatewayArray(gatewayCount) = wifi
    gatewayCount = gatewayCount + 1
End If

If ethernet <> "" Then
    ReDim Preserve gatewayArray(gatewayCount)
    gatewayArray(gatewayCount) = ethernet
    gatewayCount = gatewayCount + 1
End If

If hotspot <> "" Then
    ReDim Preserve gatewayArray(gatewayCount)
    gatewayArray(gatewayCount) = hotspot
    gatewayCount = gatewayCount + 1
End If

' Join the gateways with space
If gatewayCount > 0 Then
    gateways = Join(gatewayArray, " ")
End If

LogVerbose ""
LogVerbose "Final output: " & gateways

' Output the result (only if not in verbose mode, or as final output)
If Not isVerbose Then
    WScript.Echo gateways
Else
    LogVerbose ""
    LogVerbose "===== FINAL RESULT ====="
    WScript.Echo gateways
End If

' Helper function for IIf
Function IIf(condition, trueValue, falseValue)
    If condition Then
        IIf = trueValue
    Else
        IIf = falseValue
    End If
End Function