import streamlit as st
import pandas as pd
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
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{timestamp},{task.strip()},{review.strip()},{duration:.2f}\n")

# 📊 Carica dati
def load_data():
    if not os.path.exists(LOG_FILE):
        return pd.DataFrame(columns=["Timestamp", "Task", "Review", "Duration"])

    df = pd.read_csv(LOG_FILE, names=["Timestamp", "Task", "Review", "Duration"])
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])
    df["Duration"] = pd.to_numeric(df["Duration"])
    return df

# 📈 Grafico + riepilogo
def show_chart(df):
    st.subheader("📊 Durata delle Task")
    chart = df.groupby(["Task", "Review"])["Duration"].sum().reset_index()
    chart["Label"] = chart["Task"] + " (" + chart["Review"] + ")"
    st.bar_chart(chart.set_index("Label")["Duration"])

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
    
    
