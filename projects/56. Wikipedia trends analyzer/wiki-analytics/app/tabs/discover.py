import streamlit as st
import pandas as pd
import plotly.express as px
import requests
from db import fetch_data

USER_AGENT = "WikiTrendsAnalyzer/1.0 (github.com/harshchandrawork/DataScience-Series)"


def search_wikipedia_titles(query_text):
    """Query MediaWiki OpenSearch API for matching article titles."""
    if not query_text or len(query_text.strip()) < 2:
        return []

    url = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "opensearch",
        "search": query_text,
        "limit": 8,
        "namespace": 0,
        "format": "json",
    }
    headers = {"User-Agent": USER_AGENT}

    try:
        res = requests.get(url, headers=headers, params=params, timeout=5)
        if res.status_code == 200:
            data = res.json()
            # OpenSearch API returns [query, [titles], [descriptions], [urls]]
            return data[1] if len(data) > 1 else []
    except Exception:
        pass
    return []


def render():
    st.header("🔍 Discover & Article Deep Dive")
    st.caption(
        "Search any Wikipedia topic to analyze its edit activity, top contributors, and pageview records."
    )

    # Search Input Bar
    search_query = st.text_input(
        "Search Wikipedia Article:",
        placeholder="e.g., Artificial Intelligence, India, Python (programming language)...",
    )

    selected_title = None

    if search_query:
        suggestions = search_wikipedia_titles(search_query)
        if suggestions:
            selected_title = st.selectbox(
                "Select exact article from suggestions:", options=suggestions
            )
        else:
            selected_title = search_query.strip()

    if not selected_title:
        st.info("Enter an article name above to begin deep-dive analysis.")
        return

    st.subheader(f"Insights for: `{selected_title}`")

    # 1. Fetch Edit Metrics from Database
    summary_sql = """
        SELECT 
            COUNT(*) as total_edits,
            COUNT(*) FILTER (WHERE is_bot = true) as bot_edits,
            COALESCE(SUM(ABS(byte_diff)), 0) as total_bytes_changed,
            MIN(event_ts) as first_seen,
            MAX(event_ts) as last_seen
        FROM raw_edits
        WHERE LOWER(title) = LOWER(%s);
    """
    summary_rows = fetch_data(summary_sql, (selected_title,))

    total_edits = summary_rows[0][0] if summary_rows else 0
    bot_edits = summary_rows[0][1] if summary_rows else 0
    total_bytes = summary_rows[0][2] if summary_rows else 0
    first_seen = summary_rows[0][3] if summary_rows else None
    last_seen = summary_rows[0][4] if summary_rows else None

    # 2. Fetch Pageviews Metrics from Database
    pv_sql = """
        SELECT view_date, views
        FROM raw_pageviews
        WHERE LOWER(title) = LOWER(%s)
        ORDER BY view_date ASC;
    """
    pv_rows = fetch_data(pv_sql, (selected_title,))
    pv_df = (
        pd.DataFrame(pv_rows, columns=["view_date", "views"])
        if pv_rows
        else pd.DataFrame()
    )

    total_views = pv_df["views"].sum() if not pv_df.empty else 0

    # Display High-Level Metric Cards
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total Logged Edits", f"{total_edits:,}")
    col2.metric(
        "Bot Edits",
        f"{bot_edits:,}",
        delta=f"{(bot_edits/total_edits*100):.1f}% bot" if total_edits > 0 else "0%",
    )
    col3.metric("Volume Modified", f"{total_bytes:,} bytes")
    col4.metric(
        "Logged Pageviews", f"{total_views:,}" if total_views > 0 else "No data"
    )

    st.divider()

    if total_edits == 0 and pv_df.empty:
        st.warning(
            f"No local database records found for '{selected_title}' yet. "
            "This article has not received recent edits during your active ingestion sessions "
            "and was not in the top daily pageview rankings."
        )
        return

    # 3. Render Visualizations
    chart_col1, chart_col2 = st.columns(2)

    with chart_col1:
        st.markdown("##### 📈 Edit Activity Timeline")
        timeline_sql = """
            SELECT date_trunc('hour', event_ts) as edit_hour, COUNT(*) as edit_count
            FROM raw_edits
            WHERE LOWER(title) = LOWER(%s)
            GROUP BY edit_hour
            ORDER BY edit_hour ASC;
        """
        timeline_rows = fetch_data(timeline_sql, (selected_title,))
        if timeline_rows:
            t_df = pd.DataFrame(timeline_rows, columns=["edit_hour", "edit_count"])
            fig_timeline = px.line(
                t_df,
                x="edit_hour",
                y="edit_count",
                markers=True,
                labels={"edit_hour": "Hour", "edit_count": "Edits"},
            )
            fig_timeline.update_layout(height=350, margin=dict(l=10, r=10, t=20, b=10))
            st.plotly_chart(fig_timeline, use_container_width=True)
        else:
            st.caption("No hourly edit breakdown available.")

    with chart_col2:
        st.markdown("##### 👁️ Daily Pageviews Trend")
        if not pv_df.empty:
            fig_pv = px.bar(
                pv_df,
                x="view_date",
                y="views",
                labels={"view_date": "Date", "views": "Pageviews"},
            )
            fig_pv.update_layout(height=350, margin=dict(l=10, r=10, t=20, b=10))
            st.plotly_chart(fig_pv, use_container_width=True)
        else:
            st.caption("No pageview trend data available for this article.")

    st.divider()

    # 4. Top Contributors Table
    st.markdown("##### 🏆 Top Contributors to this Article")
    contributors_sql = """
        SELECT user_name, is_bot, COUNT(*) as edit_count, SUM(ABS(byte_diff)) as bytes_changed
        FROM raw_edits
        WHERE LOWER(title) = LOWER(%s)
        GROUP BY user_name, is_bot
        ORDER BY edit_count DESC
        LIMIT 10;
    """
    contrib_rows = fetch_data(contributors_sql, (selected_title,))
    if contrib_rows:
        contrib_df = pd.DataFrame(
            contrib_rows, columns=["User", "Is Bot", "Edits Made", "Bytes Changed"]
        )
        st.dataframe(contrib_df, use_container_width=True)
    else:
        st.caption("No contributor data logged yet.")
