#!/bin/bash

KEY_PATH="$HOME/.ssh/id_rsa.pub"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# Lista dei server
declare -A SERVERS=(
    ["TeoUserAurumServer_Produzione_2025"]="teo@185.205.244.102"
    ["ROOT_TeoUserAurumServer_Produzione_2025"]="root@185.205.244.102"
    ["TeoUserAurumServerStaging"]="teo@161.97.76.57"
    ["Python_Studio"]="teo@161.97.76.57"
    ["TeoUserProduzione"]="teo@161.97.135.136 -p 2099"
    ["CanellaStaging"]="teo@161.97.135.136 -p 2099"
    ["CanellaProduction"]="teo@161.97.135.136 -p 2099"
    ["TEOROOT"]="root@161.97.135.136 -p 2099"
)


if [[ ! -f "$KEY_PATH" ]]; then
    echo "[ERRORE] Chiave pubblica non trovata: $KEY_PATH"
    exit 1
fi

FAILED_SERVERS=()

for NAME in "${!SERVERS[@]}"; do
    echo ""
    echo "============================"
    echo "🔍 Diagnosi server: $NAME"
    echo "============================"

    SERVER="${SERVERS[$NAME]}"
    COPY_LOG="$LOG_DIR/ssh_copy_log_${NAME}.log"
    CONNECT_LOG="$LOG_DIR/ssh_connect_log_${NAME}.log"
    DIAG_LOG="$LOG_DIR/ssh_diag_log_${NAME}.log"

    echo "[INFO] Copia chiave su $SERVER..."
    ssh-copy-id -i "$KEY_PATH" "$SERVER" 2>&1 | tee "$COPY_LOG"

    echo "[INFO] Test SSH + diagnosi..."
    ssh -v -o ConnectTimeout=5 -o BatchMode=no $SERVER 'bash -s' <<'EOF' 2>&1 | tee "$DIAG_LOG"
echo "📁 Verifica file ~/.ssh/authorized_keys"
ls -la ~/.ssh/authorized_keys

echo "📄 Contenuto authorized_keys"
head -n 5 ~/.ssh/authorized_keys

echo "🔑 Permessi e proprietà"
stat ~/.ssh
stat ~/.ssh/authorized_keys
id
whoami

echo "🏠 Verifica home e shell utente"
getent passwd $(whoami)

echo "⚙️ Parametri SSH server (grep)"
grep -E "PasswordAuthentication|PubkeyAuthentication" /etc/ssh/sshd_config
EOF

    if [ $? -ne 0 ]; then
        echo "❌ Connessione o diagnostica fallita su $NAME"
        FAILED_SERVERS+=("$NAME")
    else
        echo "✅ Diagnostica completata su $NAME (vedi log: $DIAG_LOG)"
    fi
done

echo ""
echo "📋 Report finale:"
if [ ${#FAILED_SERVERS[@]} -eq 0 ]; then
    echo "🎉 Tutte le connessioni e diagnosi completate con successo!"
else
    echo "⚠️ Fallite:"
    for NAME in "${FAILED_SERVERS[@]}"; do
        echo "❌ $NAME (vedi logs/ssh_diag_log_${NAME}.log)"
    done
fi


# dr182