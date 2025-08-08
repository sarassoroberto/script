#!/bin/bash
# filepath: export_hosts.sh

# Percorso del file hosts di Windows
HOSTS_FILE="/c/Windows/System32/drivers/etc/hosts"
BACKUP_FILE="hosts_backup_$(date +%Y%m%d_%H%M%S).txt"

echo "🔍 Esportando il file hosts di Windows..."

# Verifica se il file hosts esiste
if [ ! -f "$HOSTS_FILE" ]; then
    echo "❌ Errore: File hosts non trovato in $HOSTS_FILE"
    echo "Assicurati di eseguire lo script come amministratore."
    exit 1
fi

# Copia il file hosts
cp "$HOSTS_FILE" "$BACKUP_FILE"

# Verifica se la copia è riuscita
if [ $? -eq 0 ]; then
    echo "✅ File hosts esportato con successo!"
    echo "📁 Backup salvato come: $(pwd)/$BACKUP_FILE"
    
    # Mostra le dimensioni del file
    FILE_SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE")
    echo "📊 Dimensione file: $FILE_SIZE bytes"
    
    # Conta le righe non vuote e non commentate
    ACTIVE_ENTRIES=$(grep -v "^#" "$BACKUP_FILE" | grep -v "^$" | wc -l)
    echo "🔢 Voci attive nel hosts: $ACTIVE_ENTRIES"
    
    echo ""
    echo "Anteprima delle prime 10 righe:"
    echo "================================"
    head -10 "$BACKUP_FILE"
else
    echo "❌ Errore durante la copia del file hosts"
    exit 1
fi