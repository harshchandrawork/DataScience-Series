import streamlit as st
import pandas as pd

file = st.file_uploader("Upload a CSV file to summarize")

if file:
    df = pd.read_csv(file)
    st.dataframe(df.describe())
