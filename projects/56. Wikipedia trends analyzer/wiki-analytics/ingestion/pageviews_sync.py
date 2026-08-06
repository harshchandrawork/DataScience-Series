import os
import time
from datetime import datetime, timedelta, timezone
import requests
import psycopg
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.environ.get("DATABASE_URL")
WIKI = "en.wikipedia"
USER_AGENT = "WikiTrendsAnalyzer/1.0 (github.com/harshchandrawork/DataScience-Series)"


def get_last_pageviews_checkpoint(conn):
    """Retrieve the last ingested date for pageviews state."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT last_checkpoint FROM ingestion_state WHERE source = %s;",
            (f"pageviews:{WIKI}",),
        )
        row = cur.fetchone()
        if row:
            return row[0].date()
        # Default to 2 days ago if first run (Wikimedia pageviews API has a 1-day processing lag)
        return (datetime.now(timezone.utc) - timedelta(days=2)).date()


def update_pageviews_checkpoint(conn, target_date):
    """Update checkpoint to mark a date as successfully ingested."""
    ts = datetime.combine(target_date, datetime.min.time(), tzinfo=timezone.utc)
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO ingestion_state (source, last_checkpoint, updated_at)
            VALUES (%s, %s, now())
            ON CONFLICT (source) DO UPDATE 
            SET last_checkpoint = EXCLUDED.last_checkpoint, updated_at = now();
        """,
            (f"pageviews:{WIKI}", ts),
        )
    conn.commit()


def fetch_top_pageviews(target_date):
    """Fetch top viewed articles from Wikimedia Pageviews API for a specific date."""
    year = target_date.strftime("%Y")
    month = target_date.strftime("%m")
    day = target_date.strftime("%d")

    url = f"https://wikimedia.org/api/rest_v1/metrics/pageviews/top/{WIKI}/all-access/{year}/{month}/{day}"
    headers = {"User-Agent": USER_AGENT}

    res = requests.get(url, headers=headers, timeout=10)
    if res.status_code == 404:
        print(f"Pageviews data for {target_date} is not available yet.")
        return []

    res.raise_for_status()
    items = res.json().get("items", [])
    if not items:
        return []

    articles = items[0].get("articles", [])
    records = []

    for item in articles:
        # Exclude administrative Wikipedia pages
        title = item.get("article", "")
        if title.startswith("Main_Page") or title.startswith("Special:"):
            continue

        records.append(
            (
                target_date,
                "en.wikipedia.org",
                title.replace("_", " "),
                item.get("views", 0),
            )
        )

    return records


def sync_pageviews():
    if not DB_URL:
        raise ValueError("DATABASE_URL is not set in .env file!")

    with psycopg.connect(DB_URL) as conn:
        last_date = get_last_pageviews_checkpoint(conn)
        target_date = last_date + timedelta(days=1)
        yesterday = (datetime.now(timezone.utc) - timedelta(days=1)).date()

        if target_date > yesterday:
            print(f"Pageviews are already up to date (Latest: {last_date}).")
            return

        print(f"Fetching top pageviews for date: {target_date}...")
        records = fetch_top_pageviews(target_date)

        if records:
            with conn.cursor() as cur:
                cur.executemany(
                    """
                    INSERT INTO raw_pageviews (view_date, wiki, title, views)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT DO NOTHING;
                """,
                    records,
                )

            update_pageviews_checkpoint(conn, target_date)
            print(
                f"Successfully inserted {len(records)} pageview records for {target_date}."
            )


if __name__ == "__main__":
    sync_pageviews()
