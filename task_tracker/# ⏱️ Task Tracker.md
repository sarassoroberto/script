# ⏱️ Task Tracker

> TODO:  Aggiungere un selettore di task che  raccoglie tutte le task gia usate , obbiettivo e poter riscxrivere la dicitura precisa
> 
> TODO: Mettere il concetto  di  Main Task e Subtask  | separsati dsa pipe





Un'applicazione per tracciare il tempo dedicato alle attività lavorative con review e analisi dei dati.

## 📋 Caratteristiche

- **Tracciamento temporale**: Registra automaticamente la durata delle task
- **Review**: Aggiungi note e valutazioni per ogni attività
- **Visualizzazioni**: Grafici a barre e statistiche giornaliere
- **Doppia interfaccia**: GUI (Streamlit) e terminale
- **Log giornalieri**: Un file CSV per ogni giorno

## 🚀 Installazione

### Prerequisiti

- Python 3.7+
- pip

### Dipendenze

```bash
pip install streamlit pandas
```

## 💻 Utilizzo

### Versione GUI (Streamlit)

1. **Avvio dell'applicazione:**
   
   ```bash
   streamlit run app.py
   ```

2. **Workflow:**
   
   - Inserisci il nome della task
   - L'app inizia automaticamente il cronometro
   - Quando finisci, inserisci una review
   - Clicca "Registra" per salvare

3. **Visualizzazione:**
   
   - Grafici automatici delle durate
   - Tabella con tutti i dati
   - Statistiche giornaliere

### Versione Terminale

1. **Tracciare una task:**
   
   ```bash
   python terminal_tracker.py
   ```
   
   - Inserisci il nome della task
   - Premi ENTER quando hai finito
   - Aggiungi una review

2. **Vedere il riepilogo:**
   
   ```bash
   python terminal_tracker.py summary
   ```

## 📁 Struttura File

```
task_tracker/
├── app.py              # Interfaccia Streamlit
├── terminal_tracker.py # Versione terminale
├── log_YYYY-MM-DD.csv  # File di log giornalieri
└── README.md          # Questo file
```

## 📊 Formato Dati

I file di log sono in formato CSV con le colonne:

- **Timestamp**: Data e ora di inizio task
- **Task**: Nome dell'attività
- **Review**: Note/valutazione
- **Duration**: Durata in minuti

Esempio:

```csv
2025-08-08 09:30:00,Sviluppo feature X,Completato con successo,45.50
2025-08-08 10:20:00,Meeting team,Discusso roadmap Q4,25.00
```

## 🎨 Personalizzazioni

### Layout GUI

Il CSS personalizzato nell'app Streamlit riduce:

- Dimensioni delle intestazioni
- Padding del container
- Layout fluido a tutta larghezza

### File di Log

- Automaticamente creati per ogni giorno
- Scrittura in append (non sovrascrive)
- Encoding UTF-8 per supportare caratteri speciali

## 🔧 Risoluzione Problemi

### Errore "Module not found"

```bash
pip install streamlit pandas
```

### Errore di permessi su Windows

Esegui il prompt come amministratore o cambia cartella di lavoro.

### File CSV corrotto

Elimina il file `log_YYYY-MM-DD.csv` problematico - ne verrà creato uno nuovo.

## 📈 Esempi d'uso

1. **Sviluppatore**: Traccia tempo su coding, review, meeting
2. **Freelancer**: Monitora ore per diversi clienti
3. **Studente**: Analizza tempo dedicato a materie diverse
4. **Project Manager**: Traccia attività amministrative

## 🚀 Avvio Rapido

```bash
# Clona o scarica i file
cd task_tracker

# Installa dipendenze
pip install streamlit pandas

# Avvia GUI
streamlit run app.py

# Oppure usa terminale
python terminal_tracker.py
```

## 📝 Note

- I file di log sono compatibili tra versione GUI e terminale
- L'app si auto-aggiorna quando cambiano i dati
- Le statistiche sono calcolate in tempo reale
- Supporta caratteri Unicode nelle task




