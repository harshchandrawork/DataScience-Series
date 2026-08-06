import streamlit as st
import pandas as pd
import plotly.express as px
from db import fetch_data


def render():
    st.header("Live Pulse")

    # 1. Freshness Indicator
    sync_data = fetch_data(
        "SELECT last_checkpoint FROM ingestion_state WHERE source LIKE 'recentchanges%';"
    )
    if sync_data:
        last_sync = sync_data[0][0].strftime("%Y-%m-%d %H:%M:%S UTC")
        st.info(f"📡 Data as of: **{last_sync}**")
    else:
        st.warning("📡 Awaiting first data ingestion cycle...")

    st.markdown("---")

    # 2. Top Level Metrics
    col1, col2, col3 = st.columns(3)

    bot_ratio_data = fetch_data("SELECT is_bot, n FROM v_bot_human_ratio")
    if bot_ratio_data:
        df_bots = pd.DataFrame(bot_ratio_data, columns=["is_bot", "count"])
        total_edits = df_bots["count"].sum()
        bot_edits = df_bots[df_bots["is_bot"] == True]["count"].sum()
        bot_pct = (bot_edits / total_edits * 100) if total_edits > 0 else 0

        col1.metric("Edits (Last 24h)", f"{total_edits:,}")
        col2.metric("Bot Traffic", f"{bot_pct:.1f}%")
    else:
        col1.metric("Edits (Last 24h)", "0")
        col2.metric("Bot Traffic", "0%")

    col3.metric("Busiest Wiki", "en.wikipedia.org")

    st.markdown("---")

    # 3. Rolling Bar Chart (48h)
    st.subheader("Edit Volume (Last 48 Hours)")
    hourly_data = fetch_data("SELECT hour, edits FROM v_edits_per_hour")

    if hourly_data:
        df_hourly = pd.DataFrame(hourly_data, columns=["hour", "edits"])
        fig = px.bar(
            df_hourly,
            x="hour",
            y="edits",
            labels={"hour": "Time (UTC)", "edits": "Number of Edits"},
            color_discrete_sequence=["#1f77b4"],
        )
        fig.update_layout(xaxis_title=None, margin=dict(l=0, r=0, t=30, b=0))
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.write("No recent edit data available.")
