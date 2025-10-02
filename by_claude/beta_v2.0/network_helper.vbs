' network_helper.vbs - Enhanced network detection for FTP phone connector
Option Explicit

Dim objWMI, objPing, objNetwork, objShell
Dim strPhoneMAC, strComputer, colItems, objItem
Dim arrNetworks, strCurrentNetwork, strPhoneIP

' Configuration
strPhoneMAC = "64-dd-e9-5c-e3-f3"
strComputer = "."

Set objShell = CreateObject("WScript.Shell")
Set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set objNetwork = CreateObject("WScript.Network")

' Function to get default gateway (enhanced version)
Function GetDefaultGateway()
    Dim colAdapters, objAdapter, strGateway
    
    Set colAdapters = objWMI.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
    
    For Each objAdapter in colAdapters
        If Not IsNull(objAdapter.DefaultIPGateway) Then
            If IsArray(objAdapter.DefaultIPGateway) Then
                strGateway = objAdapter.DefaultIPGateway(0)
                ' Check if this is likely a phone hotspot
                If InStr(strGateway, "192.168.43.") > 0 Or _
                   InStr(strGateway, "192.168.49.") > 0 Or _
                   InStr(strGateway, "172.20.") > 0 Then
                    GetDefaultGateway = strGateway
                    Exit Function
                End If
            End If
        End If
    Next
    
    GetDefaultGateway = ""
End Function

' Function to scan for phone by MAC address
Function FindPhoneByMAC(strNetwork)
    Dim objExec, strCommand, strOutput, strLine
    Dim arrLines, i, strIP
    
    ' First, populate ARP cache
    For i = 1 To 254
        strCommand = "cmd /c ping -n 1 -w 50 " & strNetwork & "." & i & " >nul 2>&1"
        objShell.Run strCommand, 0, False
    Next
    
    ' Wait for pings to complete
    WScript.Sleep 3000
    
    ' Check ARP table
    strCommand = "cmd /c arp -a"
    Set objExec = objShell.Exec(strCommand)
    strOutput = objExec.StdOut.ReadAll
    
    ' Parse ARP output
    arrLines = Split(strOutput, vbCrLf)
    For i = 0 To UBound(arrLines)
        strLine = LCase(arrLines(i))
        ' Convert MAC format (64-dd-e9-5c-e3-f3 to 64-dd-e9-5c-e3-f3)
        If InStr(strLine, Replace(LCase(strPhoneMAC), ":", "-")) > 0 Then
            ' Extract IP from line
            strIP = Trim(Split(strLine, " ")(0))
            If InStr(strIP, strNetwork) > 0 Then
                FindPhoneByMAC = strIP
                Exit Function
            End If
        End If
    Next
    
    FindPhoneByMAC = ""
End Function

' Function to detect active network and find phone
Function DetectPhoneNetwork()
    Dim strGateway, strNetwork, strIP
    
    ' Method 1: Check gateway (phone hotspot)
    strGateway = GetDefaultGateway()
    If strGateway <> "" Then
        WScript.Echo strGateway
        Exit Function
    End If
    
    ' Method 2: Check PC hotspot (192.168.137.x)
    strIP = FindPhoneByMAC("192.168.137")
    If strIP <> "" Then
        WScript.Echo strIP
        Exit Function
    End If
    
    ' Method 3: Check router network (192.168.100.x)
    strIP = FindPhoneByMAC("192.168.100")
    If strIP <> "" Then
        WScript.Echo strIP
        Exit Function
    End If
    
    ' No phone found
    WScript.Echo "NOT_FOUND"
End Function

' Function to show device selection dialog
Function ShowDeviceSelector(arrDevices)
    Dim strPrompt, strTitle, strDefault, strChoice
    Dim i
    
    strPrompt = "Select your phone from the list:" & vbCrLf & vbCrLf
    
    For i = 0 To UBound(arrDevices)
        strPrompt = strPrompt & "[" & (i + 1) & "] " & arrDevices(i) & vbCrLf
    Next
    
    strPrompt = strPrompt & vbCrLf & "Enter device number:"
    strTitle = "FTP Phone Selector"
    strDefault = "1"
    
    strChoice = InputBox(strPrompt, strTitle, strDefault)
    
    If strChoice = "" Then
        ShowDeviceSelector = ""
    ElseIf IsNumeric(strChoice) Then
        i = CInt(strChoice) - 1
        If i >= 0 And i <= UBound(arrDevices) Then
            ShowDeviceSelector = arrDevices(i)
        Else
            ShowDeviceSelector = ""
        End If
    Else
        ShowDeviceSelector = ""
    End If
End Function

' Function to show manual IP input dialog
Function ShowIPInputDialog()
    Dim strNetwork, strHost, strTitle
    Dim arrNetworks, intChoice
    
    ' Network selection
    arrNetworks = Array("192.168.137", "192.168.100", "Other")
    
    strTitle = "Select Network Type"
    intChoice = InputBox("Select network:" & vbCrLf & _
                        "[1] PC Hotspot (192.168.137.x)" & vbCrLf & _
                        "[2] Router (192.168.100.x)" & vbCrLf & _
                        "[3] Other" & vbCrLf & vbCrLf & _
                        "Enter choice (1-3):", strTitle, "1")
    
    If intChoice = "" Then
        ShowIPInputDialog = ""
        Exit Function
    End If
    
    Select Case intChoice
        Case "1"
            strNetwork = "192.168.137"
        Case "2"
            strNetwork = "192.168.100"
        Case "3"
            strNetwork = InputBox("Enter network prefix (e.g., 192.168.1):", "Custom Network", "192.168.1")
            If strNetwork = "" Then
                ShowIPInputDialog = ""
                Exit Function
            End If
        Case Else
            ShowIPInputDialog = ""
            Exit Function
    End Select
    
    ' Host input
    strHost = InputBox("Enter last octet of phone IP (1-254):" & vbCrLf & vbCrLf & _
                      "Network: " & strNetwork & ".___", _
                      "Phone IP Address", "")
    
    If strHost = "" Then
        ShowIPInputDialog = ""
    ElseIf IsNumeric(strHost) Then
        If CInt(strHost) >= 1 And CInt(strHost) <= 254 Then
            ShowIPInputDialog = strNetwork & "." & strHost
        Else
            MsgBox "Invalid IP octet. Must be between 1 and 254.", vbExclamation, "Error"
            ShowIPInputDialog = ""
        End If
    Else
        ShowIPInputDialog = ""
    End If
End Function

' Main execution
If WScript.Arguments.Count > 0 Then
    Select Case WScript.Arguments(0)
        Case "detect"
            DetectPhoneNetwork()
        Case "select"
            ' This would be called with device list
            Dim devices, result
            devices = Split(WScript.Arguments(1), ";")
            result = ShowDeviceSelector(devices)
            WScript.Echo result
        Case "input"
            WScript.Echo ShowIPInputDialog()
        Case Else
            WScript.Echo GetDefaultGateway()
    End Select
Else
    ' Default behavior - get gateway
    WScript.Echo GetDefaultGateway()
End If