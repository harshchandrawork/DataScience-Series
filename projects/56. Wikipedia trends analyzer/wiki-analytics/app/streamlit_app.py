import streamlit as st
from db import fetch_data
from tabs import live_pulse, trending, discover, explorer

st.set_page_config(
    page_title="Wikipedia Trends Analyzer",
    page_icon="📈",
    layout="wide",
    initial_sidebar_state="expanded",
)


def render_sidebar():
    st.sidebar.title("🌐 Wiki Trends")
    st.sidebar.caption("Real-Time Wikimedia Analytics Pipeline")
    st.sidebar.divider()

    # System Health & Live Record Counters
    st.sidebar.subheader("🔌 System Health & Metrics")

    try:
        # Query total ingested records
        edits_count = fetch_data("SELECT COUNT(*) FROM raw_edits;")[0][0]
        pv_count = fetch_data("SELECT COUNT(*) FROM raw_pageviews;")[0][0]

        # Query latest ingestion state checkpoints
        checkpoints = fetch_data("""
            SELECT source, last_checkpoint 
            FROM ingestion_state 
            ORDER BY updated_at DESC;
        """)

        st.sidebar.success("Database Status: Connected")

        st.sidebar.metric("Total Ingested Edits", f"{edits_count:,}")
        st.sidebar.metric("Pageview Records", f"{pv_count:,}")

        if checkpoints:
            st.sidebar.markdown("**Latest Checkpoints:**")
            for row in checkpoints:
                source_label = (
                    row[0]
                    .replace("recentchanges:", "Edits: ")
                    .replace("pageviews:", "Views: ")
                )
                formatted_ts = (
                    row[1].strftime("%Y-%m-%d %H:%M UTC") if row[1] else "N/A"
                )
                st.sidebar.caption(f"• **{source_label}**: `{formatted_ts}`")

    except Exception as e:
        st.sidebar.error("Database Status: Disconnected")
        st.sidebar.caption(f"Error reading metrics: {e}")

    st.sidebar.divider()
    st.sidebar.markdown("### 🛠️ Architecture Stack")
    st.sidebar.caption(
        "• **Pipeline:** Python 3.12 & Requests\n"
        "• **Database:** PostgreSQL (Psycopg3)\n"
        "• **Frontend:** Streamlit & Plotly\n"
        "• **API:** MediaWiki Action & REST APIs"
    )
    st.sidebar.divider()
    st.sidebar.markdown(
        "[⭐ Source Code on GitHub](https://github.com/harshchandrawork/DataScience-Series)"
    )


def main():
    render_sidebar()

    st.title("Wikipedia Trends Analyzer")

    tab1, tab2, tab3, tab4 = st.tabs(
        [
            "📊 Live Pulse",
            "🔥 Trending Topics",
            "🔍 Discover & Deep Dive",
            "📁 Data Explorer",
        ]
    )

    with tab1:
        live_pulse.render()
    with tab2:
        trending.render()
    with tab3:
        discover.render()
    with tab4:
        explorer.render()


if __name__ == "__main__":
    main()
