import streamlit as st
import pandas as pd
import time

# Text utility
st.title("Startup Dashboard")
st.header("This is header")
st.subheader("Yo this is subheading")
st.write("This is a normal text")

st.markdown(
    """
    ### An example of markdown
    - Bullet 1
    - Bullet 2
    - Bullet 3
    > This is sample note.
    """
)

st.code(
    """
    def samp_code(input):
        return input ** 2

    x = samp_code(2)
    """
)

st.latex("x^2 + y^2 = 0")

# Display elements
df = pd.DataFrame(
    {"name": ["Yola", "Gola", "Bhola"], "marks": [50, 60, 70], "package": [10, 12, 14]}
)

st.dataframe(df)

st.metric("Revenue", "Rs 3L", "3%")

st.json(
    {"name": ["Yola", "Gola", "Bhola"], "marks": [50, 60, 70], "package": [10, 12, 14]}
)

# Displaying Media
st.image("/home/harshchandra/Data1/Xdp.jpg")
# similarly we also have video and audio as methods os streamlit

# Creating Layouts
st.sidebar.title("Haha sidebar")

# to align contents side by side, here is an example
col1, col2 = st.columns(2)

with col1:
    st.image("/home/harshchandra/Data1/Xdp.jpg")

with col2:
    st.image("/home/harshchandra/Data1/Xdp.jpg")

# Showing Status
st.error("Login Failed")

st.success("Login Success")

st.info("This info")

st.warning("This warning")

# for creating a progress bar
bar = st.progress(0)
for i in range(101):
    # time.sleep(0.1)
    bar.progress(i)

# Taking user input
name = st.text_input("Enter a name")

number = st.number_input("Enter age")

date = st.date_input("Enter a date")

# also used the file uploader
# we have also used streamlit buttons
