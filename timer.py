import time
import csv
import threading
from datetime import datetime, timedelta
import pyttsx3

# === TTS SETUP ===
def init_tts():
    engine = pyttsx3.init()
    for voice in engine.getProperty('voices'):
        if "italian" in voice.name.lower() or "elsa" in voice.name.lower():
            engine.setProperty('voice', voice.id)
            break
    engine.setProperty('rate', 150)
    return engine

engine = init_tts()

def speak(text):
    engine.say(text)
    engine.runAndWait()

# === UTILS ===
def format_duration(seconds):
    return str(timedelta(seconds=int(seconds)))

def current_timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# === ANNUNCI MILIONARI ===
def announce_milestones(get_elapsed_time, stop_flag):
    milestone_sec = 600  # ogni 10 minuti
    milestone = 1
    while not stop_flag.is_set():
        time.sleep(5)
        elapsed = get_elapsed_time()
        if elapsed >= milestone * milestone_sec:
            speak(f"{milestone * 10} minuti")
            milestone += 1

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
        cmd = input("> ").strip()

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

            # Avvia il thread degli annunci vocali
            milestone_stop_flag.clear()
            milestone_thread = threading.Thread(
                target=announce_milestones,
                args=(get_elapsed, milestone_stop_flag),
                daemon=True
            )
            milestone_thread.start()

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
            milestone_stop_flag.set()

        elif cmd.lower() == "exit":
            if start_time:
                print("Segmento attivo, fermalo prima con 'stop'.")
                continue
            milestone_stop_flag.set()
            if segments:
                write_csv(segments)
            print("Uscita.")
            break

        else:
            print("Comando non riconosciuto.")

# === CSV EXPORT ===
def write_csv(data):
    filename = f"timer_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    with open(filename, "w", newline="", encoding="utf-8") as csvfile:
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
