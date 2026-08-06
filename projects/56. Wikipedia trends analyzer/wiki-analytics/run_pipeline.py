import time
import sys
from datetime import datetime, timezone

# Import ingestion functions
from ingestion.recentchanges_sync import main as sync_recent_changes
from ingestion.pageviews_sync import sync_pageviews

# Configuration (Intervals in seconds)
# 4 Hours = 14,400 seconds | 1 Hour = 3,600 seconds
EDIT_SYNC_INTERVAL = 4 * 3600  # Run edit catch-up batch every 4 hours
PAGEVIEW_SYNC_INTERVAL = 12 * 3600  # Check pageviews twice daily


def run_pipeline():
    print("=" * 60)
    print("🚀 Starting Wikipedia Analytics Batch Pipeline")
    print(
        f"Edit Sync Interval: {EDIT_SYNC_INTERVAL // 3600}h | Pageview Sync Interval: {PAGEVIEW_SYNC_INTERVAL // 3600}h"
    )
    print("=" * 60)

    last_pageview_sync = 0

    while True:
        current_time_str = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
        now = time.time()

        # 1. Run Live Edits Catch-Up
        print(f"\n[{current_time_str}] Triggering recent changes batch sync...")
        try:
            sync_recent_changes()
        except Exception as e:
            print(f"⚠️ Error during recent changes sync: {e}")

        # 2. Run Pageviews Sync if 12-hour interval elapsed
        if now - last_pageview_sync >= PAGEVIEW_SYNC_INTERVAL:
            print(f"\n[{current_time_str}] Checking for daily pageviews update...")
            try:
                sync_pageviews()
                last_pageview_sync = now
            except Exception as e:
                print(f"⚠️ Error during pageviews sync: {e}")

        # Wait for the next 4-hour cycle
        next_run_str = datetime.fromtimestamp(
            now + EDIT_SYNC_INTERVAL, tz=timezone.utc
        ).strftime("%H:%M:%S UTC")
        print(f"\nBatch complete. Next execution scheduled for ~{next_run_str}.")
        time.sleep(EDIT_SYNC_INTERVAL)


if __name__ == "__main__":
    try:
        run_pipeline()
    except KeyboardInterrupt:
        print("\nPipeline orchestrator stopped cleanly.")
        sys.exit(0)
