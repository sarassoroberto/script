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



@REM GitHub Copilot: Sì, questo script **disabilita il CORS (Cross-Origin Resource Sharing)** e altre misure di sicurezza del browser Chrome. Ti spiego le voci più importanti:

@REM ## Disabilitazione CORS e Sicurezza Web:
@REM - `--disable-web-security` - **Disabilita completamente la sicurezza web**, incluso CORS
@REM - `--allow-file-access-from-files` - Permette ai file locali di accedere ad altri file locali
@REM - `--ignore-certificate-errors` - Ignora gli errori dei certificati SSL/TLS

@REM ## Isolamento dei Siti:
@REM - `--disable-site-isolation-trials` - Disabilita l'isolamento dei siti web
@REM - `--disable-features=IsolateOrigins,site-per-process` - Disabilita ulteriori feature di isolamento

@REM ## Funzionalità del Browser:
@REM - `--disable-extensions` - Disabilita tutte le estensioni
@REM - `--disable-popup-blocking` - Disabilita il blocco dei popup
@REM - `--disable-notifications` - Disabilita le notifiche
@REM - `--no-first-run` - Salta la configurazione iniziale
@REM - `--no-default-browser-check` - Non chiede se impostare Chrome come browser predefinito

@REM ## Funzionalità di Rete e Telemetria:
@REM - `--disable-background-networking` - Disabilita connessioni in background
@REM - `--disable-sync` - Disabilita la sincronizzazione
@REM - `--disable-component-update` - Disabilita aggiornamenti automatici
@REM - `--metrics-recording-only` - Limita la raccolta di metriche

@REM ## Configurazione di Sviluppo:
@REM - `--user-data-dir=%PROFILE_DIR%` - Usa un profilo separato per lo sviluppo
@REM - `--remote-debugging-port=9222` - Abilita il debugging remoto

@REM **⚠️ ATTENZIONE:** Questo script rende Chrome molto meno sicuro e dovrebbe essere usato **SOLO per sviluppo/test**, mai per navigazione normale!