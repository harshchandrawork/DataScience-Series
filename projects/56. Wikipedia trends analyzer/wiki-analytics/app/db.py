import os
import streamlit as st
from psycopg_pool import ConnectionPool
from dotenv import load_dotenv

# Load local environment variables from .env if present
load_dotenv()


def get_db_connection_string():
    """Safely reads DATABASE_URL from Streamlit secrets or local .env file."""
    try:
        if "DATABASE_URL" in st.secrets:
            return st.secrets["DATABASE_URL"]
    except Exception:
        pass

    return os.environ.get("DATABASE_URL")


@st.cache_resource
def get_connection_pool():
    """Initializes a cached Psycopg3 connection pool."""
    conn_str = get_db_connection_string()
    if not conn_str:
        raise ValueError("DATABASE_URL is not set in .env or Streamlit secrets.")
    return ConnectionPool(conninfo=conn_str)


def fetch_data(query, params=None):
    """Executes a SQL query using the Psycopg3 pool and returns fetched rows."""
    pool = get_connection_pool()
    with pool.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(query, params)
            return cur.fetchall()
