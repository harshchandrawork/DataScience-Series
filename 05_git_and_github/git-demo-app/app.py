import streamlit as st

st.title("CampusX")

col1, col2 = st.columns(2)

with col1:
    st.image("Monke_2.jpg")
with col2:
    st.write(
        """
    Are you a monke?
    """
    )

st.header("Courses Offered")
st.subheader("Data Science and Machine Learning")
st.subheader("Data Analysis")
st.subheader("Python")
st.subheader("SQL")
st.subheader("DSA")

st.sidebar.title("Menu")
st.sidebar.markdown(
    """
- Home
- About
- Contact
- Career
- Login
"""
)

option = st.sidebar.selectbox("Select One", ["teacher", "student"])
btn = st.sidebar.button("Select")

if btn:
    st.title("")
