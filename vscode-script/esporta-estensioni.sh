#!/bin/bash
# filepath: export_vscode_extensions.sh

# Nome del file di output
OUTPUT_FILE="vscode_extensions.txt"

echo "Esportando le estensioni di VS Code attive..."

# Esporta la lista delle estensioni installate
code --list-extensions > "$OUTPUT_FILE"

# Conta il numero di estensioni
EXTENSION_COUNT=$(wc -l < "$OUTPUT_FILE")

echo "✅ Esportate $EXTENSION_COUNT estensioni in $OUTPUT_FILE"
echo "📁 File salvato in: $(pwd)/$OUTPUT_FILE"

# Mostra le prime 5 estensioni come anteprima
echo ""
echo "Anteprima delle estensioni esportate:"
head -5 "$OUTPUT_FILE"

if [ $EXTENSION_COUNT -gt 5 ]; then
    echo "... e altre $((EXTENSION_COUNT - 5)) estensioni"
fi