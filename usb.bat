@echo off
setlocal
if "%~1"=="" (set USB_ID=MANUAL) else (set USB_ID=%~1)

:: ---- Awareness page opens immediately ----
start "" "https://www.khipuawareness.co.uk/awareness/c8803bb920f32a6582260029c7404d983055d89355d291102c9fd2bea82e93e9/11/index.html"

:: ---- Data collection (pure CMD - no PowerShell) ----
for /f "tokens=2 delims=\" %%a in ('whoami') do set U=%%a
for /f %%a in ('hostname') do set H=%%a
set NB=%COMPUTERNAME%
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do if not defined IP set IP=%%a
for /f "tokens=*" %%a in ("%IP%") do set IP=%%a

:: ---- Write JSON to temp file (avoids batch quote escaping hell) ----
>"%TEMP%\d.json" echo [{"timestamp":"%date% %time%","username":"%U%","hostname":"%H%","netbios":"%NB%","ip":"%IP%","usb_id":"%USB_ID%"}]

:: ---- Send via curl with built-in retry (no PowerShell needed) ----
:: Retries every 30s until internet is available - up to ~8 hours
set "URI=https://default186f8545468f49e59c70379e23e2af.14.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/07/workflows/077b9dbc48f54a7a93fecc9619390597/triggers/manual/paths/invoke?api-version=1&sp=%%2Ftriggers%%2Fmanual%%2Frun&sv=1.0&sig=DeE829DsviqXQivynKdiFqZOo2Hs05j5rYkZtUztfXA"
start /min "" curl.exe -s --retry 999 --retry-delay 30 --retry-all-errors -X POST -H "Content-Type: application/json" -d @"%TEMP%\d.json" "%URI%"

exit /b
