# parzialmente testato


Questo script bash automatizza la configurazione completa di un progetto Laravel chiamato "starter-kit". Ecco cosa fa in dettaglio:

## 🎯 **Scopo principale**
Imposta un ambiente di sviluppo/produzione completo per un progetto Laravel partendo da zero.

## 📋 **Operazioni eseguite**

### **1. Configurazione iniziale**
- Definisce variabili per nome progetto, directory di installazione, repository Git, credenziali database e dominio

### **2. Setup file system**
- Crea la directory `/var/www/html/starter-kit`
- Imposta i permessi corretti (proprietario: `teo`, gruppo: `www-data`)

### **3. Clone del repository**
- Clona il progetto da GitHub: `git@github.com:sarassoroberto/starter-kit.git`

### **4. Setup Laravel**
- Installa le dipendenze PHP con Composer
- Crea il file `.env` copiando `.env.example`
- Genera la chiave dell'applicazione Laravel

### **5. Setup Database MySQL**
- Crea il database `starter-kit`
- Crea l'utente MySQL `starter-kit` con password specifica
- Configura i permessi del database
- Aggiorna il file `.env` con le credenziali DB
- Esegue le migrazioni del database

### **6. Setup Apache**
- Crea un virtual host per il dominio `starter-kit.sarassoroberto.it`
- Abilita il sito e il modulo `mod_rewrite`
- Ricarica la configurazione Apache

### **7. Setup Frontend (Materialize)**
- Installa `pnpm` globalmente
- Installa le dipendenze Node.js
- Compila gli asset frontend

### **8. Pulizia finale**
- Pulisce le cache di Laravel (config, cache, view)

### **9. Funzione di Reset**
Se eseguito con il parametro `--reset`, lo script:
- Rimuove completamente la directory del progetto
- Elimina database e utente MySQL
- Disabilita e rimuove il virtual host Apache

## 🔧 **Utilizzo**
```bash
# Installazione normale
./set-up-starter-kit.sh

# Reset completo dell'ambiente
./set-up-starter-kit.sh --reset
```

Questo è uno script SERVE automatizzare il deployment di un progetto Laravel con tutti i componenti necessari (database, web server, dipendenze) in un singolo comando.


