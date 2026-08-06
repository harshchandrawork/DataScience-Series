-- One row per polled recent-change event
CREATE TABLE raw_edits (
    id BIGSERIAL PRIMARY KEY,
    event_ts TIMESTAMPTZ NOT NULL,
    wiki TEXT NOT NULL,
    title TEXT NOT NULL,
    user_name TEXT,
    is_bot BOOLEAN NOT NULL DEFAULT FALSE,
    edit_type TEXT,
    byte_diff INTEGER,
    comment TEXT,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_raw_edits_ts ON raw_edits (event_ts);
CREATE INDEX idx_raw_edits_wiki_title ON raw_edits (wiki, title);

-- One row per article/day
CREATE TABLE raw_pageviews (
    id BIGSERIAL PRIMARY KEY,
    view_date DATE NOT NULL,
    wiki TEXT NOT NULL,
    title TEXT NOT NULL,
    views INTEGER NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (view_date, wiki, title)
);

-- Rolled-up summary table
CREATE TABLE articles (
    wiki TEXT NOT NULL,
    title TEXT NOT NULL,
    last_edited_at TIMESTAMPTZ,
    edits_last_24h INTEGER DEFAULT 0,
    views_today INTEGER DEFAULT 0,
    views_7d INTEGER DEFAULT 0,
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (wiki, title)
);

-- Checkpoint for scheduled polling
CREATE TABLE ingestion_state (
    source TEXT NOT NULL,
    last_checkpoint TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (source)
);

-- Hourly rollups for long-range trend charts
CREATE TABLE edits_hourly_rollup (
    wiki TEXT NOT NULL,
    hour_bucket TIMESTAMPTZ NOT NULL,
    edit_count INTEGER NOT NULL,
    bot_count INTEGER NOT NULL,
    human_count INTEGER NOT NULL,
    PRIMARY KEY (wiki, hour_bucket)
);

-- Category-level trend analytics
CREATE TABLE category_trends (
    category TEXT NOT NULL,
    wiki TEXT NOT NULL,
    trend_date DATE NOT NULL,
    article_count INTEGER NOT NULL,
    total_views INTEGER DEFAULT 0,
    total_edits INTEGER DEFAULT 0,
    PRIMARY KEY (category, wiki, trend_date)
);