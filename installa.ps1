Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -Value 0


Stop-Process -Name explorer
Start-Process explorer


# Assicurati di eseguire questo script come Amministratore

wsl --install
wsl --list --verbose
wsl --install -d Ubuntu
wsl --update


# Installa Ubuntu (versione LTS tramite Microsoft Store)
choco install ubuntu -y

# Installa Visual Studio Code
choco install vscode -y

# Installa Python
choco install python -y

# Installa Docker Desktop
choco install docker-desktop -y

# Installa OpenOffice
choco install openoffice -y

# Installa Firefox
choco install firefox -y

choco install docker-desktop -y
choco upgrade docker-desktop


choco install greenshot -y
    

# Write-Host "✅ Installazione completata!"

# 🧠 IntelliSense avanzato per PHP
code --install-extension bmewburn.vscode-intelephense-client  # Intelephense

# 🤖 Autocompletamento di metodi e facades Laravel
code --install-extension amiralizadeh9480.laravel-extra-intellisense  # Laravel Extra IntelliSense

# 🧬 Evidenziazione e snippet per Blade templating
code --install-extension onecentlin.laravel-blade  # Laravel Blade Snippets

# 🔧 Pack completo di estensioni Laravel
# code --install-extension onecentlin.laravel-extension-pack  # Laravel Extension Pack

# ✨ Formattazione automatica per file Blade (.blade.php)
# code --install-extension juniorbandes.blade-formatter  # Blade Formatter

# 🛠️ Formattazione del codice PHP secondo le best practice
# code --install-extension junstyle.php-cs-fixer  # PHP CS Fixer

# 🎨 IntelliSense per Tailwind CSS (se usato nel frontend Laravel)
# code --install-extension bradlc.vscode-tailwindcss  # Tailwind CSS IntelliSense

# 🚀 Esecuzione comandi Artisan direttamente da VS Code
# code --install-extension ryannaddy.laravel-artisan  # Laravel Artisan

# 🌐 Connessione remota via SSH a server (modifica e debug)
code --install-extension ms-vscode-remote.remote-ssh  # Remote - SSH

# 📝 Modifica file remoti direttamente dentro VS Code
code --install-extension ms-vscode-remote.remote-ssh-edit  # Remote - SSH: Editing Configuration Files

# 🗂️ Esplorazione e gestione delle connessioni remote
code --install-extension ms-vscode.remote-explorer  # Remote Explorer

# 📂 Monta filesystem remoto via SSH (come se fosse una cartella locale)
code --install-extension Kelvin.vscode-sshfs  # SSH FS

# 🤖🤖 ANDROID STUDIO
choco install androidstudio -y
choco install openjdk11 -y


choco install filezilla -y


# guida libera nominativa ognuno di loro 83 Tariffa + 7 Diritti + 10 competenze


choco install copyq -y

# NOTA FARESCRIPT PER VSCODE OPPURE SINCRONIZZARE