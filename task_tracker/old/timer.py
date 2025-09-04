import time
import csv
import threading
from datetime import datetime, timedelta
import pyttsx3

# === TTS SETUP ===

def init_tts():
    try:
        engine = pyttsx3.init()
        for voice in engine.getProperty('voices'):
            if "italian" in voice.name.lower() or "elsa" in voice.name.lower():
                engine.setProperty('voice', voice.id)
                break
        engine.setProperty('rate', 150)
        return engine
    except Exception as e:
        print(f"[WARNING] TTS non disponibile: {e}")
        return None

engine = init_tts()
tts_lock = threading.Lock()

def speak(text):
    if engine is None:
        print(f"[VOICE] {text}")
        return
    
    # Esegui TTS in un thread separato per evitare blocchi
    def _speak_thread():
        print(f"[DEBUG] Tentativo TTS: {text}")
        try:
            with tts_lock:
                engine.say(text)
                engine.runAndWait()
            print(f"[DEBUG] TTS completato: {text}")
        except Exception as e:
            print(f"[TTS Error] {text} - Errore: {e}")
    
    thread = threading.Thread(target=_speak_thread, daemon=True)
    thread.start()
# === UTILS ===
def format_duration(seconds):
    return str(timedelta(seconds=int(seconds)))

def current_timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# === ANNUNCI MILIONARI ===
def announce_milestones(get_elapsed_time, stop_flag):
    milestone_sec = 600  # ogni 10 minuti
    milestone = 1
    print("[DEBUG] Thread milestone avviato")
    
    while not stop_flag.is_set():
        try:
            # Controlla stop_flag più frequentemente
            for _ in range(10):  # 5 secondi divisi in 0.5 secondi
                if stop_flag.is_set():
                    print("[DEBUG] Thread milestone fermato")
                    return
                time.sleep(0.5)
            
            elapsed = get_elapsed_time()
            
            if elapsed >= milestone * milestone_sec:
                print(f"[DEBUG] Annuncio milestone: {milestone * 10} minuti")
                speak(f"{milestone * 10} minuti")
                milestone += 1
                
        except Exception as e:
            print(f"[DEBUG] Errore nel thread milestone: {e}")
            break
    
    print("[DEBUG] Thread milestone terminato")

# === MAIN ===
def main():
    print('Comandi: start "commento" | pause | resume | stop | exit')

    segments = []
    segment_number = 0
    start_time = None
    pause_start = None
    total_paused = 0
    paused_times = []
    segment_start = None
    current_task = ""

    milestone_stop_flag = threading.Event()
    milestone_thread = None

    def get_elapsed():
        if start_time:
            return time.time() - start_time - total_paused
        return 0

    while True:
        try:
            cmd = input("> ").strip()
        except KeyboardInterrupt:
            print("\n[DEBUG] Ctrl+C rilevato")
            milestone_stop_flag.set()
            break

        # START con commento opzionale
        if cmd.lower().startswith("start"):
            if start_time:
                print("Segmento già in corso.")
                continue

            # Estrai commento tra virgolette se presente
            comment = ""
            if '"' in cmd:
                parts = cmd.split('"')
                if len(parts) >= 2:
                    comment = parts[1].strip()

            current_task = comment
            start_time = time.time()
            segment_start = current_timestamp()
            total_paused = 0
            paused_times = []

            # Ferma il thread precedente se esiste
            if milestone_thread and milestone_thread.is_alive():
                milestone_stop_flag.set()
                milestone_thread.join(timeout=1)

            # Avvia il thread degli annunci vocali
            milestone_stop_flag.clear()
            milestone_thread = threading.Thread(
                target=announce_milestones,
                args=(get_elapsed, milestone_stop_flag),
                daemon=True
            )
            milestone_thread.start()
            print("[DEBUG] Thread milestone riavviato")

            print(f"Cronometro avviato. Task: \"{comment}\"" if comment else "Cronometro avviato.")

        elif cmd.lower() == "pause":
            if not start_time:
                print("Nessun segmento attivo.")
                continue
            if pause_start:
                print("Già in pausa.")
                continue
            pause_start = time.time()
            pause_start_ts = current_timestamp()
            print("Pausa attivata.")

        elif cmd.lower() == "resume":
            if not pause_start:
                print("Non sei in pausa.")
                continue
            resumed_at = time.time()
            pause_duration = resumed_at - pause_start
            total_paused += pause_duration
            paused_times.append({
                "pause_start": pause_start_ts,
                "pause_end": current_timestamp()
            })
            pause_start = None
            print("Pausa terminata.")

        elif cmd.lower() == "stop":
            if not start_time:
                print("Nessun segmento attivo.")
                continue
            if pause_start:
                print("Termina prima la pausa con 'resume'.")
                continue

            # Ferma il thread milestone
            milestone_stop_flag.set()
            if milestone_thread and milestone_thread.is_alive():
                milestone_thread.join(timeout=1)

            end_time = time.time()
            segment_end = current_timestamp()
            duration = end_time - start_time - total_paused

            segment_number += 1
            segment = {
                "segment_id": segment_number,
                "start": segment_start,
                "end": segment_end,
                "duration_seconds": round(duration, 2),
                "duration_formatted": format_duration(duration),
                "paused_periods": paused_times.copy(),
                "task": current_task
            }
            segments.append(segment)

            # Controllo record
            max_duration = max(s["duration_seconds"] for s in segments)
            print(f"Segmento {segment_number} salvato (durata: {segment['duration_formatted']})")
            print(f"Segmento max finora: {format_duration(max_duration)}")
            if segment["duration_seconds"] >= max_duration:
                speak("hai superato il record")

            # Reset stato
            start_time = None
            paused_times = []

        elif cmd.lower() == "exit":
            if start_time:
                print("Segmento attivo, fermalo prima con 'stop'.")
                continue
            milestone_stop_flag.set()
            if milestone_thread and milestone_thread.is_alive():
                milestone_thread.join(timeout=1)
            if segments:
                write_csv(segments)
            print("Uscita.")
            break

        else:
            print("Comando non riconosciuto.")

# === CSV EXPORT ===
def write_csv(data):
    filename = f"timer_report_{datetime.now().strftime('%Y%m%d')}.csv"
    with open(filename, "a", newline="", encoding="utf-8") as csvfile:
        write_header = csvfile.tell() == 0
        fieldnames = [
            "segment_id", "start", "end", "duration_seconds", "duration_formatted",
            "task", "pause_start", "pause_end"
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for segment in data:
            if segment["paused_periods"]:
                for pause in segment["paused_periods"]:
                    writer.writerow({
                        "segment_id": segment["segment_id"],
                        "start": segment["start"],
                        "end": segment["end"],
                        "duration_seconds": segment["duration_seconds"],
                        "duration_formatted": segment["duration_formatted"],
                        "task": segment.get("task", ""),
                        "pause_start": pause["pause_start"],
                        "pause_end": pause["pause_end"]
                    })
            else:
                writer.writerow({
                    "segment_id": segment["segment_id"],
                    "start": segment["start"],
                    "end": segment["end"],
                    "duration_seconds": segment["duration_seconds"],
                    "duration_formatted": segment["duration_formatted"],
                    "task": segment.get("task", ""),
                    "pause_start": "",
                    "pause_end": ""
                })
    print(f"Report salvato in: {filename}")

# === ENTRY POINT ===
if __name__ == "__main__":
    main()