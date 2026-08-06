CREATE VIEW v_edits_per_hour AS
SELECT date_trunc('hour', event_ts) AS hour, wiki, count(*) AS edits
FROM raw_edits
WHERE event_ts > now() - interval '48 hours'
GROUP BY 1, 2 ORDER BY 1;

CREATE VIEW v_top_edited_today AS
SELECT wiki, title, count(*) AS edit_count
FROM raw_edits
WHERE event_ts::date = current_date
GROUP BY wiki, title
ORDER BY edit_count DESC LIMIT 50;

CREATE VIEW v_bot_human_ratio AS
SELECT wiki, is_bot, count(*) AS n
FROM raw_edits
WHERE event_ts > now() - interval '24 hours'
GROUP BY wiki, is_bot;

CREATE VIEW v_top_pageviews_today AS
SELECT wiki, title, views
FROM raw_pageviews
WHERE view_date = current_date - 1
ORDER BY views DESC LIMIT 50;

CREATE VIEW v_trending_categories AS
SELECT category, wiki, sum(total_views) AS views, sum(total_edits) AS edits,
       sum(article_count) AS articles
FROM category_trends
WHERE trend_date = current_date
GROUP BY category, wiki
ORDER BY views DESC LIMIT 30;