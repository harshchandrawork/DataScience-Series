import streamlit as st
import numpy as np
import pandas as pd
import plotly.express as px

st.set_page_config(layout="wide")

df = pd.read_csv("../datasets/India Census 2011 Clean/india_census_2011_clean.csv")

states_list = list(df["State"].unique())
states_list.insert(0, "India Overall")

st.title("India Census 2011 Data Visualization")

st.markdown(
    """
    <div style="
        background-color: #f0f2f6;
        color: black;
        padding: 15px;
        border-radius: 10px;
        border-left: 6px solid #1f77b4;">
        <h4 style="margin-bottom:5px;">About This Dashboard</h4>
        <p style="margin-bottom:0px;">
        Explore demographic and socio-economic insights from the <b>India Census 2011</b>.
        Customize parameters from the sidebar to discover regional patterns across India.
        </p>
    </div><br>
    """,
    unsafe_allow_html=True,
)

col1, col2, col3 = st.columns(3)
col1.metric("Total States", df["State"].nunique())
col2.metric("Total Districts", df["District"].nunique())
col3.metric("Total Population", f"{df['Population'].sum():,}")

st.divider()


st.sidebar.title("Select Input Parameters")
selected_state = st.sidebar.selectbox("Select a State", states_list)
primary = st.sidebar.selectbox(
    "Select Primary Parameter", sorted(df.columns[6:]), index=2
)
st.sidebar.caption("Primary Parameter is represented by Size")
secondary = st.sidebar.selectbox(
    "Select Secondary Parameter", sorted(df.columns[6:]), index=2
)
st.sidebar.caption("Secondary Parameter is represented by Gradient")

plot = st.sidebar.button("Plot Graph")

if plot:
    if selected_state == "India Overall":
        fig = px.scatter_map(
            df,
            lat="Latitude",
            lon="Longitude",
            zoom=3,
            map_style="carto-positron",
            size=primary,
            color=secondary,
            width=1800,
            height=600,
        )
        st.plotly_chart(fig, use_container_width=True, theme=None)
    else:
        state_df = df[df["State"] == selected_state]
        fig = px.scatter_map(
            state_df,
            lat="Latitude",
            lon="Longitude",
            zoom=3,
            map_style="carto-positron",
            size=primary,
            color=secondary,
            width=1800,
            height=600,
        )
        st.plotly_chart(fig, use_container_width=True, theme=None)
