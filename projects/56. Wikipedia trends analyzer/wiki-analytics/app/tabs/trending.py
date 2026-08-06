import streamlit as st
import pandas as pd
import plotly.express as px
from db import fetch_data


def render():
    st.header("Trending Today")

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Top Articles by Pageviews")
        top_views = fetch_data(
            "SELECT title, views FROM v_top_pageviews_today LIMIT 10"
        )
        if top_views:
            df_views = pd.DataFrame(top_views, columns=["Article Title", "Views"])
            fig = px.bar(
                df_views, x="Views", y="Article Title", orientation="h", text_auto=".2s"
            )
            fig.update_layout(
                yaxis={"categoryorder": "total ascending"},
                margin=dict(l=0, r=0, t=30, b=0),
            )
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.write("Pageviews data not yet ingested.")

    with col2:
        st.subheader("Trending Categories")
        top_cats = fetch_data(
            "SELECT category, views FROM v_trending_categories LIMIT 10"
        )
        if top_cats:
            df_cats = pd.DataFrame(top_cats, columns=["Category", "Views"])
            # Strip 'Category:' prefix for cleaner UI
            df_cats["Category"] = df_cats["Category"].str.replace("Category:", "")
            fig_cats = px.pie(df_cats, values="Views", names="Category", hole=0.4)
            fig_cats.update_layout(margin=dict(l=0, r=0, t=30, b=0))
            st.plotly_chart(fig_cats, use_container_width=True)
        else:
            st.write("Category trends not yet available.")

    st.markdown("---")

    st.subheader("Search Article History")
    search_term = st.text_input(
        "Enter exact article title (e.g., Python_(programming_language))"
    )
    if search_term:
        query = """
            SELECT view_date, views FROM raw_pageviews 
            WHERE title = %s ORDER BY view_date ASC
        """
        history = fetch_data(query, (search_term,))
        if history:
            df_history = pd.DataFrame(history, columns=["Date", "Views"])
            fig_hist = px.line(df_history, x="Date", y="Views", markers=True)
            st.plotly_chart(fig_hist, use_container_width=True)
        else:
            st.warning("No historical data found for this article.")
