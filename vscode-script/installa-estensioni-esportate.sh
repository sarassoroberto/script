#!/bin/bash
# filepath: install_vscode_extensions.sh

# Nome del file con le estensioni
EXTENSIONS_FILE="vscode_extensions.txt"

# Verifica se il file esiste
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "❌ Errore: File $EXTENSIONS_FILE non trovato!"
    echo "Assicurati che il file sia nella directory corrente."
    exit 1
fi

# Conta il numero totale di estensioni
TOTAL_EXTENSIONS=$(wc -l < "$EXTENSIONS_FILE")
echo "🚀 Installazione di $TOTAL_EXTENSIONS estensioni VS Code..."
echo ""

# Contatore per il progresso
COUNTER=0

# Legge il file riga per riga e installa ogni estensione
while IFS= read -r extension; do
    # Salta righe vuote
    if [ -z "$extension" ]; then
        continue
    fi
    
    COUNTER=$((COUNTER + 1))
    echo "[$COUNTER/$TOTAL_EXTENSIONS] Installando: $extension"
    
    # Installa l'estensione
    code --install-extension "$extension"
    
    # Verifica se l'installazione è riuscita
    if [ $? -eq 0 ]; then
        echo "✅ $extension installata con successo"
    else
        echo "❌ Errore nell'installazione di $extension"
    fi
    echo ""
done < "$EXTENSIONS_FILE"

echo "🎉 Processo di installazione completato!"
echo "Riavvia VS Code per assicurarti che tutte le estensioni siano attive."