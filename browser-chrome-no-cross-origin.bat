@echo off
set CHROME_PATH=chrome.exe
set PROFILE_DIR=%USERPROFILE%\chrome-dev-profile

if not exist "%PROFILE_DIR%" (
    mkdir "%PROFILE_DIR%"
)

start %CHROME_PATH% ^
  --user-data-dir=%PROFILE_DIR% ^
  --disable-web-security ^
  --disable-site-isolation-trials ^
  --disable-features=IsolateOrigins,site-per-process ^
  --ignore-certificate-errors ^
  --no-first-run ^
  --no-default-browser-check ^
  --disable-extensions ^
  --allow-file-access-from-files ^
  --disable-popup-blocking ^
  --disable-notifications ^
  --disable-background-networking ^
  --disable-client-side-phishing-detection ^
  --disable-component-update ^
  --disable-domain-reliability ^
  --disable-sync ^
  --metrics-recording-only ^
  --safebrowsing-disable-auto-update ^
  --remote-debugging-port=9222 ^
  http://localhost:8080
