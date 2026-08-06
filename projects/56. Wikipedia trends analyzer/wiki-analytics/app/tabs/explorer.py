import streamlit as st
import pandas as pd
from db import fetch_data


def render():
    st.header("Raw Edits Explorer")
    st.markdown("View a sample of the most recently ingested raw edit events.")

    col1, col2 = st.columns(2)
    with col1:
        limit = st.selectbox("Rows to fetch", [100, 500, 1000])
    with col2:
        hide_bots = st.checkbox("Hide Bot Edits", value=False)

    bot_filter = "WHERE is_bot = FALSE" if hide_bots else ""

    query = f"""
        SELECT event_ts, wiki, title, user_name, edit_type, byte_diff, comment 
        FROM raw_edits 
        {bot_filter}
        ORDER BY event_ts DESC 
        LIMIT %s
    """

    with st.spinner("Fetching raw edits..."):
        raw_data = fetch_data(query, (limit,))

        if raw_data:
            df = pd.DataFrame(
                raw_data,
                columns=[
                    "Timestamp",
                    "Wiki",
                    "Title",
                    "User",
                    "Type",
                    "Byte Diff",
                    "Comment",
                ],
            )
            st.dataframe(df, hide_index=True, use_container_width=True)
        else:
            st.info("No edit data found in the database.")
