#!/bin/bash
# filepath: restore_hosts.sh

# Percorso del file hosts di Windows
HOSTS_FILE="/c/Windows/System32/drivers/etc/hosts"

echo "🔍 Cerco file di backup hosts..."

# Trova il file di backup più recente
BACKUP_FILE=$(ls -1t hosts_backup_*.txt 2>/dev/null | head -1)

# Se non trova backup automatico, chiede all'utente
if [ -z "$BACKUP_FILE" ]; then
    echo "❓ Nessun backup automatico trovato."
    echo "Inserisci il nome del file di backup hosts:"
    read -r BACKUP_FILE
fi

# Verifica se il file di backup esiste
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Errore: File di backup $BACKUP_FILE non trovato!"
    echo "File disponibili:"
    ls -la hosts_backup_*.txt 2>/dev/null || echo "Nessun file di backup trovato"
    exit 1
fi

echo "📄 Utilizzando backup: $BACKUP_FILE"

# Crea un backup del file hosts attuale prima di sovrascriverlo
CURRENT_BACKUP="hosts_current_backup_$(date +%Y%m%d_%H%M%S).txt"
echo "💾 Creando backup del file hosts attuale..."
cp "$HOSTS_FILE" "$CURRENT_BACKUP" 2>/dev/null

echo ""
echo "⚠️  ATTENZIONE: Stai per sovrascrivere il file hosts del sistema!"
echo "📁 File di destinazione: $HOSTS_FILE"
echo "📁 File sorgente: $BACKUP_FILE"
echo "💾 Backup attuale salvato in: $CURRENT_BACKUP"
echo ""
echo "Vuoi continuare? (s/N):"
read -r CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    echo "❌ Operazione annullata dall'utente"
    exit 0
fi

# Verifica i privilegi di amministratore provando a toccare il file
if ! touch "$HOSTS_FILE" 2>/dev/null; then
    echo "❌ Errore: Privilegi insufficienti!"
    echo "Esegui il script come amministratore (Run as administrator)"
    exit 1
fi

echo "🚀 Ripristinando il file hosts..."

# Ripristina il file hosts
cp "$BACKUP_FILE" "$HOSTS_FILE"

# Verifica se il ripristino è riuscito
if [ $? -eq 0 ]; then
    echo "✅ File hosts ripristinato con successo!"
    
    # Mostra statistiche
    ACTIVE_ENTRIES=$(grep -v "^#" "$HOSTS_FILE" | grep -v "^$" | wc -l)
    echo "🔢 Voci attive ripristinate: $ACTIVE_ENTRIES"
    
    echo ""
    echo "🔄 Per applicare le modifiche, esegui:"
    echo "   ipconfig /flushdns"
    echo ""
    echo "Vuoi eseguire il flush DNS ora? (s/N):"
    read -r FLUSH_CONFIRM
    
    if [ "$FLUSH_CONFIRM" = "s" ] || [ "$FLUSH_CONFIRM" = "S" ]; then
        echo "🔄 Eseguendo flush DNS..."
        ipconfig //flushdns
        echo "✅ Cache DNS svuotata!"
    fi
else
    echo "❌ Errore durante il ripristino del file hosts"
    exit 1
fi