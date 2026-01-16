import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt

# setting basic page configs
st.set_page_config(layout="wide", page_title="Startup Analysis")

# reading data
df = pd.read_csv("startup_cleaned.csv")
df["date"] = df["date"].str.replace("05/072018", "05/07/2018")
df["date"] = pd.to_datetime(df["date"], errors="coerce")
df["month"] = df["date"].dt.month
df["year"] = df["date"].dt.year


def load_investor_details():
    st.title(selected_investor)

    # load the 5 recent investments of the investor
    last5_df = df[df["investors"].str.contains(selected_investor)].head()[
        ["date", "startup", "vertical", "city", "round", "amount"]
    ]
    st.subheader("Most Recent Investments")
    st.dataframe(last5_df)

    # biggest investments

    big_series = (
        df[df["investors"].str.contains(selected_investor)]
        .groupby("startup")["amount"]
        .sum()
        .sort_values(ascending=False)
    )
    st.header("Biggest Investments")
    st.dataframe(big_series)

    col1, col2 = st.columns(2)
    with col1:
        # plotting the bar graph for 5 biggest investments
        st.header(f"5 Biggest Investments of {selected_investor}")
        fig, ax = plt.subplots()
        ax.bar(big_series.head().index, big_series.head().values)
        st.pyplot(fig)

    with col2:
        # plotting the pie chart for investment in distinct rounds by the investor
        vertical_series = (
            df[df["investors"].str.contains(selected_investor)]
            .groupby("vertical")["amount"]
            .sum()
        )
        st.header(f"Sectors Invested in")
        fig1, ax1 = plt.subplots()
        ax1.pie(vertical_series, labels=vertical_series.index, autopct="%0.01f%%")
        st.pyplot(fig1)

        # plotting the pie chart for investment in distinct rounds by the Investor
        round_series = (
            df[df["investors"].str.contains(selected_investor)]
            .groupby("round")["amount"]
            .sum()
            .sort_values(ascending=False)
        )
        st.header(f"Rounds Invested in")
        fig2, ax2 = plt.subplots()
        ax2.pie(round_series, labels=round_series.index, autopct="%0.01f%%")
        st.pyplot(fig2)

        # cities invested in, by the Investor
        cities_series = (
            df[df["investors"].str.contains(selected_investor)]
            .groupby("city")["amount"]
            .sum()
            .sort_values(ascending=False)
        )
        st.header(f"Cities Invested in")
        fig3, ax3 = plt.subplots()
        ax3.pie(cities_series, labels=cities_series.index, autopct="%0.01f%%")
        st.pyplot(fig3)

        # year by year line graph of investments by the Investors
        # df["year"] = df["date"].dt.year
        year_series = (
            df[df["investors"].str.contains(selected_investor)]
            .groupby("year")["amount"]
            .sum()
        )
        st.subheader("YoY Investment")
        fig4, ax4 = plt.subplots()
        ax4.plot(year_series.index, year_series.values)
        st.pyplot(fig4)


def load_overall_analysis():
    # st.title("Overall Analysis")

    # total invested amount
    total = round(df["amount"].sum())

    # max amount infused in a startup
    max_funding = (
        df.groupby("startup")["amount"].sum().sort_values(ascending=False).max()
    )
    # avg ticket size
    avg_funding = df.groupby("startup")["amount"].sum().mean()
    # total funded startups
    num_startups = df["startup"].nunique()

    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.metric("Total", str(total) + "Cr")
    with col2:
        st.metric("Max", str(max_funding) + "Cr")
    with col3:
        st.metric("Avg", str(round(avg_funding)) + "Cr")
    with col4:
        st.metric("Funded Startups", str(num_startups))

    st.header("MoM Graph")
    selected_option = st.selectbox("Select Type", ["Total", "Count"])
    if selected_option == "Total":
        temp_df = df.groupby(["year", "month"])["amount"].sum().reset_index()
    else:
        temp_df = df.groupby(["year", "month"])["amount"].count().reset_index()

    temp_df["x_axis"] = temp_df["month"].astype(str) + "-" + temp_df["year"].astype(str)

    fig3, ax3 = plt.subplots()
    ax3.plot(temp_df["x_axis"], temp_df["amount"])
    st.pyplot(fig3)


st.sidebar.title("Startup Funding Analysis")
st.sidebar.caption(
    "This is a web application for performing analysis on startup fundings."
)

# defining sidebar functionality
option = st.sidebar.selectbox(
    "Please Select one of the Options", ["Overall Analysis", "StartUp", "Investor"]
)

if option == "Overall Analysis":
    load_overall_analysis()
    # st.title("Overall Analysis")
    # btn0 = st.button("Show Overall Analysis")
    # if btn0:
    #     load_overall_analysis()
elif option == "StartUp":
    st.title("StartUp Analysis")
    st.selectbox("Select the Startup", sorted(df["startup"].unique().tolist()))
    btn1 = st.button("Find StartUp Details")
else:
    st.title("Investor Analysis")
    selected_investor = st.selectbox(
        "Select Investor", sorted(set(df["investors"].str.split(",").sum()))
    )
    btn2 = st.button("Find Investor Details")
    if btn2:
        load_investor_details()
