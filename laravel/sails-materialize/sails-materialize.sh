#!/bin/bash
set -e

PROJECT_NAME="myapp"
THEME_ZIP="$HOME/Downloads/materialize-vuetify3-template.zip"

# Funzione per controllare ed installare pacchetti
install_if_missing() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[INFO] $1 non trovato. Installo..."
        sudo apt install -y $2
    else
        echo "[OK] $1 già installato."
    fi
}

echo "=== Aggiornamento pacchetti ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Controllo dipendenze base ==="
install_if_missing php php-cli php-cli
install_if_missing composer composer
install_if_missing node nodejs
install_if_missing npm npm
install_if_missing git git
install_if_missing curl curl
install_if_missing unzip unzip

# Creazione progetto Laravel
if [ ! -d "$PROJECT_NAME" ]; then
    echo "=== Creazione progetto Laravel: $PROJECT_NAME ==="
    composer create-project laravel/laravel "$PROJECT_NAME"
else
    echo "[OK] Cartella $PROJECT_NAME già esistente. Skipping."
fi

cd "$PROJECT_NAME"

# Installazione Sail
if [ ! -f "vendor/bin/sail" ]; then
    echo "=== Installazione Laravel Sail ==="
    composer require laravel/sail --dev
    php artisan sail:install
else
    echo "[OK] Sail già installato."
fi

# Avvio Sail
./vendor/bin/sail up -d

# Installazione Vue 3 + Vuetify 3
echo "=== Installazione Vue 3 + Vuetify 3 ==="
./vendor/bin/sail npm install vue@3
./vendor/bin/sail npm install vuetify@3 sass sass-loader@^10

# Configurazione vite.config.js
if ! grep -q "@vitejs/plugin-vue" vite.config.js 2>/dev/null; then
    echo "=== Configurazione vite.config.js ==="
    ./vendor/bin/sail npm install @vitejs/plugin-vue
    cat > vite.config.js <<'EOL'
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/js/app.js', 'resources/css/app.css'],
            refresh: true,
        }),
        vue(),
    ],
});
EOL
fi

# Vuetify setup
mkdir -p resources/js
if [ ! -f "resources/js/vuetify.js" ]; then
    echo "=== Creazione file Vuetify ==="
    cat > resources/js/vuetify.js <<'EOL'
import 'vuetify/styles';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';

export default createVuetify({
  components,
  directives,
});
EOL
fi

if [ ! -f "resources/js/app.js" ]; then
    echo "=== Creazione app.js Vue ==="
    cat > resources/js/app.js <<'EOL'
import './bootstrap';
import { createApp } from 'vue';
import App from './App.vue';
import vuetify from './vuetify';

createApp(App)
  .use(vuetify)
  .mount('#app');
EOL
fi

if [ ! -f "resources/js/App.vue" ]; then
    echo "=== Creazione App.vue base ==="
    cat > resources/js/App.vue <<'EOL'
<template>
  <v-app>
    <v-main>
      <v-container>
        <h1>Hello Vuetify 3 + Laravel Sail!</h1>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
</script>
EOL
fi

# Estrazione tema Pixinvent
if [ -f "$THEME_ZIP" ]; then
    echo "=== Estraggo tema Pixinvent da $THEME_ZIP ==="
    TMP_DIR=$(mktemp -d)
    unzip -q "$THEME_ZIP" -d "$TMP_DIR"
    cp -r "$TMP_DIR"/* resources/js/
    rm -rf "$TMP_DIR"
    ./vendor/bin/sail npm install
else
    echo "[INFO] Tema ZIP non trovato in $THEME_ZIP. Skipping."
fi

# Avvio sviluppo
echo "=== Avvio ambiente ==="
./vendor/bin/sail npm run dev

echo "✅ Installazione completata!"
