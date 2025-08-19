import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime
import os


st.markdown("""
<style>
.main .block-container {
    padding-left: 1rem;
    padding-right: 1rem;
    max-width: none;
}
h1 {
    font-size: 1.5rem !important;
}
h2 {
    font-size: 1.3rem !important;
}
h3 {
    font-size: 1.1rem !important;
}
</style>
""", unsafe_allow_html=True)

st.set_page_config(layout="wide")



LOG_FILE = f"log_{datetime.now().strftime('%Y-%m-%d')}.csv"
# 📝 Salva task + review + durata
def save_entry(task, review, start_time):
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds() / 60
    timestamp = start_time.strftime("%Y-%m-%d %H:%M:%S")
    
    # Uso il formato CSV con virgolette per gestire virgole nei campi
    import csv
    import io
    
    # Creo una riga CSV protetta con virgolette
    output = io.StringIO()
    writer = csv.writer(output, quoting=csv.QUOTE_MINIMAL)
    writer.writerow([timestamp, task.strip(), review.strip(), f"{duration:.2f}"])
    csv_line = output.getvalue().strip()
    
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(csv_line + "\n")

# 📊 Carica dati
def load_data():
    if not os.path.exists(LOG_FILE):
        return pd.DataFrame(columns=["Timestamp", "Task", "Review", "Duration"])

    try:
        # Uso pd.read_csv con gestione corretta delle virgolette
        df = pd.read_csv(LOG_FILE, names=["Timestamp", "Task", "Review", "Duration"], 
                        quoting=1, escapechar=None, skipinitialspace=True)
        df["Timestamp"] = pd.to_datetime(df["Timestamp"])
        df["Duration"] = pd.to_numeric(df["Duration"])
        return df
    except Exception as e:
        st.error(f"Errore nel leggere il file CSV: {e}")
        st.info("Prova a controllare il file CSV per righe malformate")
        return pd.DataFrame(columns=["Timestamp", "Task", "Review", "Duration"])

# 📈 Grafico + riepilogo
def show_chart(df):
    st.subheader("📊 Timeline delle Task della Giornata")
    
    # Creo una copia del dataframe e preparo i dati per il grafico
    chart_df = df.copy()
    chart_df["Task_Label"] = chart_df["Task"].str[:30] + ("..." if chart_df["Task"].str.len().max() > 30 else "")
    
    # Uso il timestamp effettivo per avere posizioni proporzionali al tempo reale
    fig = px.bar(
        chart_df, 
        x="Timestamp", 
        y="Duration",
        color="Task_Label",
        title="Timeline delle Task - Posizioni Proporzionali al Tempo Reale",
        labels={
            "Timestamp": "Orario della Giornata",
            "Duration": "Durata (minuti)",
            "Task_Label": "Task"
        },
        hover_data={
            "Task": True,
            "Review": True,
            "Duration": ":.1f"
        }
    )
    
    # Configurazione per timeline proporzionale
    fig.update_layout(
        xaxis_title="Orario della Giornata",
        yaxis_title="Durata (minuti)",
        legend_title="Task",
        height=500,
        xaxis=dict(
            type='date',
            tickformat='%H:%M',
            dtick=3600000,  # Tick ogni ora (in millisecondi)
            tickangle=45
        )
    )
    
    # Larghezza delle barre fissa (non proporzionale alla durata temporale)
    fig.update_traces(
        width=1800000  # Larghezza fissa in millisecondi (30 minuti)
    )
    
    st.plotly_chart(fig, use_container_width=True)

    total_time = df["Duration"].sum()
    task_count = df["Task"].nunique()

    st.markdown("### 📋 Riepilogo")
    st.markdown(f"- ⏳ Tempo totale attivo: **{total_time:.1f} minuti**")
    st.markdown(f"- 📌 Numero di task svolte: **{task_count}**")

# 🌐 Interfaccia
st.title("⏱️ Task Tracker - Segmenti Task → Review")

if "current_task" not in st.session_state:
    st.session_state.current_task = ""
    st.session_state.start_time = None

# Inserimento task
if not st.session_state.current_task:
    st.markdown("### ✏️ Inserisci la task")
    task_input = st.text_input("Task:", key="task_input")
    if task_input.strip():
        st.session_state.current_task = task_input.strip()
        st.session_state.start_time = datetime.now()
        st.rerun()
else:
    st.markdown(f"🕒 Task in corso: **{st.session_state.current_task}**")
    st.markdown("### 🗣️ Inserisci la review")
    review_input = st.text_input("Review:", key="review_input")
    if st.button("Registra"):
        save_entry(st.session_state.current_task, review_input, st.session_state.start_time)
        st.success("✅ Task registrata!")
        st.session_state.current_task = ""
        st.session_state.start_time = None
        # st.session_state.review_input = ""
        st.rerun()

# Visualizzazione
df = load_data()
if not df.empty:
    show_chart(df)
    st.dataframe(df)
else:
    st.info("Nessuna attività registrata oggi.")
    
    
