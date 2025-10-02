Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * From Win32_NetworkAdapterConfiguration Where IPEnabled = True")
For Each objItem in colItems
    If Not IsNull(objItem.DefaultIPGateway) Then
        For Each strGateway in objItem.DefaultIPGateway
            WScript.Echo strGateway
        Next
    End If
Next