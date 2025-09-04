#!/bin/bash

# === CONFIGURAZIONE ===
PROJECT_NAME="starter-kit"
INSTALL_DIR="/var/www/html/$PROJECT_NAME"
REPO_URL="git@github.com:sarassoroberto/starter-kit.git"
DB_NAME="starter-kit"
DB_USER="starter-kit"
DB_PASS="JoelMiller1998!"  # Cambia questa password!
DOMAIN="starter-kit.sarassoroberto.it"
# http://starter-kit.sarassoroberto.it
APACHE_CONF="/etc/apache2/sites-available/$PROJECT_NAME.conf"

# === CREAZIONE CARTELLA PROGETTO ===
echo "📁 Creazione directory di installazione..."
sudo mkdir -p "$INSTALL_DIR"
sudo chown teo:www-data "$INSTALL_DIR"

# === CLONE DEL REPOSITORY ===
echo "📦 Clonazione dello starter kit..."
sudo -u teo git clone "$REPO_URL" "$INSTALL_DIR"

# === SETUP LARAVEL ===
cd "$INSTALL_DIR" || exit
echo "📦 Installazione dipendenze Composer..."
sudo -u teo composer install --no-interaction --prefer-dist

echo "🔐 Setup file .env..."
sudo -u teo cp .env.example .env
sudo -u teo php artisan key:generate

# -------------------------------------------
# Comandi database per creare user e database
# CREATE DATABASE IF NOT EXISTS `starter-kit`;
# CREATE USER IF NOT EXISTS 'starter-kit'@'localhost' IDENTIFIED BY 'JoelMiller1998!';
# GRANT ALL PRIVILEGES ON `starter-kit`.* TO 'starter-kit'@'localhost';
# FLUSH PRIVILEGES;
# -------------------------------------------
read -p "⏸️ Premi INVIO per continuare dopo aver verificato che i servizi siano pronti..."

echo "🗄️ Creazione utente e database MySQL..."
mysql -u root -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF


echo "📝 Aggiornamento file .env con parametri DB..."
sudo -u teo sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sudo -u teo sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sudo -u teo sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

echo "🧹 Pulizia cache Laravel..."
sudo -u teo php artisan config:clear
sudo -u teo php artisan cache:clear

echo "🔍 Verifica configurazione DB nel file .env..."

ENV_FILE="$INSTALL_DIR/.env"
DB_DRIVER=$(grep "^DB_CONNECTION=" "$ENV_FILE" | cut -d '=' -f2)

if [ "$DB_DRIVER" != "mysql" ]; then
    echo "⚠️ DB_CONNECTION è impostato su '$DB_DRIVER'. Correggo in 'mysql'..."
    sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' "$ENV_FILE"
else
    echo "✅ DB_CONNECTION è già impostato correttamente su 'mysql'."
fi

echo "🔄 Pulizia cache Laravel..."
sudo -u teo php artisan config:clear
sudo -u teo php artisan cache:clear



echo "🗄️ Esecuzione migrazioni..."
sudo -u teo php artisan migrate --force

# === PERMESSI ===
echo "🔐 Impostazione permessi cartelle..."
sudo chown -R teo:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# === VIRTUAL HOST APACHE ===
echo "🌐 Creazione virtual host Apache..."
sudo bash -c "cat > $APACHE_CONF" <<EOL
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $INSTALL_DIR/public

    <Directory $INSTALL_DIR/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$PROJECT_NAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$PROJECT_NAME-access.log combined
</VirtualHost>
EOL

echo "🔄 Abilitazione sito e mod_rewrite..."
sudo a2ensite "$PROJECT_NAME.conf"
sudo a2enmod rewrite
sudo systemctl reload apache2

echo "✅ Installazione completata! Visita: http://$DOMAIN"


# particolare per materialize
npm install -g pnpm
pnpm install
pnpm npm run build



php artisan config:clear
php artisan cache:clear
php artisan view:clear





# RESET
if [[ "$1" == "--reset" ]]; then
    echo "🔄 Resetting environment..."

    # 1. Remove project folder
    sudo rm -rf "$WEB_ROOT"
    echo "✅ Cartella rimossa: $WEB_ROOT"

    # 2. Drop DB and user
    mysql -u root -p <<EOF
DROP DATABASE IF EXISTS `$DB_NAME`;
DROP USER IF EXISTS '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
    echo "✅ Database e utente MySQL rimossi"

    # 3. Remove Apache virtual host
    sudo a2dissite "$PROJECT_NAME.conf"
    sudo rm -f "$VHOST_CONF"
    sudo systemctl reload apache2
    echo "✅ Virtual host Apache rimosso"

    echo "✅ Reset completato. Puoi ora rieseguire lo script normalmente."
    exit 0
fi

# ...segue il resto dello script per installare Laravel, creare DB, configurare Apache, ecc.
