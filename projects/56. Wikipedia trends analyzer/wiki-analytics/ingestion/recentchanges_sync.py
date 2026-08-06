import os
import time
import requests
import psycopg
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

# 1. Load environment variables from .env
load_dotenv()

DB_URL = os.environ.get("DATABASE_URL")
WIKI = "en.wikipedia.org"
SOURCE_KEY = f"recentchanges:{WIKI}"
USER_AGENT = "WikiTrendsAnalyzer/1.0 (github.com/harshchandrawork/DataScience-Series)"


def get_last_checkpoint(conn):
    """Retrieve the last successful ingestion timestamp from the database."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT last_checkpoint FROM ingestion_state WHERE source = %s;",
            (SOURCE_KEY,),
        )
        row = cur.fetchone()
        if row:
            return row[0]
        # Default to 2 hours ago if this is the very first run
        return datetime.now(timezone.utc) - timedelta(hours=2)


def update_checkpoint(conn, new_ts):
    """Save the latest processed timestamp into the ingestion_state table."""
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO ingestion_state (source, last_checkpoint, updated_at)
            VALUES (%s, %s, now())
            ON CONFLICT (source) DO UPDATE 
            SET last_checkpoint = EXCLUDED.last_checkpoint, updated_at = now();
        """,
            (SOURCE_KEY, new_ts),
        )
    conn.commit()


def fetch_and_sync(conn):
    """Poll MediaWiki API and batch insert new edit records into PostgreSQL."""
    last_checkpoint = get_last_checkpoint(conn)
    print(f"Starting sync for {WIKI} from checkpoint: {last_checkpoint}")

    api_url = f"https://{WIKI}/w/api.php"
    headers = {"User-Agent": USER_AGENT}

    params = {
        "action": "query",
        "list": "recentchanges",
        "rcstart": last_checkpoint.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "rcdir": "newer",
        "rcprop": "title|timestamp|user|comment|sizes|flags",
        "rclimit": "500",
        "format": "json",
    }

    total_inserted = 0

    while True:
        # Pause 0.5s between requests to respect MediaWiki API rate limits
        time.sleep(0.5)

        try:
            res = requests.get(api_url, headers=headers, params=params, timeout=10)

            if res.status_code == 429:
                print("Rate limit encountered. Waiting 5 seconds...")
                time.sleep(5)
                continue

            res.raise_for_status()
            data = res.json()
        except Exception as e:
            print(f"Network error: {e}. Retrying in 5 seconds...")
            time.sleep(5)
            continue

        changes = data.get("query", {}).get("recentchanges", [])
        if not changes:
            print("No further edits found.")
            break

        records = []
        batch_latest_ts = last_checkpoint

        for item in changes:
            event_ts = datetime.strptime(
                item["timestamp"], "%Y-%m-%dT%H:%M:%SZ"
            ).replace(tzinfo=timezone.utc)
            if event_ts > batch_latest_ts:
                batch_latest_ts = event_ts

            is_bot = "bot" in item or item.get("user", "").lower().endswith("bot")
            byte_diff = item.get("newlen", 0) - item.get("oldlen", 0)

            records.append(
                (
                    event_ts,
                    WIKI,
                    item.get("title", ""),
                    item.get("user", "Anonymous"),
                    is_bot,
                    item.get("type", "edit"),
                    byte_diff,
                    item.get("comment", ""),
                )
            )

        if records:
            with conn.cursor() as cur:
                cur.executemany(
                    """
                    INSERT INTO raw_edits (event_ts, wiki, title, user_name, is_bot, edit_type, byte_diff, comment)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                    records,
                )

            # Commit data and update checkpoint immediately per batch
            update_checkpoint(conn, batch_latest_ts)
            total_inserted += len(records)
            print(
                f"Inserted batch of {len(records)} records. Checkpoint: {batch_latest_ts}"
            )

        # Check for pagination token
        if "continue" in data and "rccontinue" in data["continue"]:
            params["rccontinue"] = data["continue"]["rccontinue"]
        else:
            break

    print(f"Sync finished. Total edits ingested: {total_inserted}")


def main():
    if not DB_URL:
        raise ValueError("DATABASE_URL is not configured in your .env file!")

    print("Connecting to PostgreSQL database...")
    with psycopg.connect(DB_URL) as conn:
        fetch_and_sync(conn)


if __name__ == "__main__":
    main()
