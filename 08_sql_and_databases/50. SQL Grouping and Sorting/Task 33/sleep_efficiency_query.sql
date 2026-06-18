-- verifying if there is any id with count > 1
SELECT COUNT(*)
FROM sleep_efficiency
GROUP BY id
ORDER BY COUNT(*) DESC;

-- 1.
SELECT AVG("Sleep duration")
FROM (
    SELECT "Sleep duration"
    FROM sleep_efficiency
    WHERE "Sleep duration" >= 7.5 AND gender = 'Male'
    ORDER BY "Sleep duration" DESC
    LIMIT 15
) AS t;

-- 2.
SELECT gender,
       ROUND((AVG("Sleep duration")*AVG("Deep sleep percentage")) / 100, 2) AS avg_deep_sleep
FROM sleep_efficiency
GROUP BY gender;

-- 3.
(SELECT age,
       "Light sleep percentage",
       "Deep sleep percentage"
FROM sleep_efficiency
WHERE "Deep sleep percentage" BETWEEN 25 AND 45
ORDER BY "Light sleep percentage"
OFFSET 29 LIMIT 1)
UNION ALL
(SELECT age,
       "Light sleep percentage",
       "Deep sleep percentage"
FROM sleep_efficiency
WHERE "Deep sleep percentage" > 25 AND "Deep sleep percentage" < 45
ORDER BY "Light sleep percentage"
OFFSET 9 LIMIT 1);

-- 4.
SELECT "Smoking status",
       "Exercise frequency",
       ROUND((AVG("Sleep duration")*AVG("Deep sleep percentage")) / 100, 2) AS avg_deep_sleep,
       ROUND((AVG("Sleep duration")*AVG("Light sleep percentage")) / 100, 2) AS avg_light_sleep,
       ROUND((AVG("Sleep duration")*AVG("REM sleep percentage")) / 100, 2) AS avg_rem_sleep
FROM sleep_efficiency
GROUP BY "Exercise frequency",
         "Smoking status"
ORDER BY avg_deep_sleep DESC;
-- order by avg_deep_sleep was misc. I sorted it by avg_deep_sleep in desc to find out
-- the average of people having the highest deep sleep time.
-- Apparently, Non-Smoking people have a better deep sleep time.

-- 5.
SELECT awakenings,
       COUNT(*),
       ROUND(AVG("Caffeine consumption"), 2) AS avg_caffeine_consumption,
       ROUND((AVG("Sleep duration")*AVG("Deep sleep percentage")) / 100, 2) AS avg_deep_sleep,
       ROUND(AVG("Alcohol consumption"), 2) AS avg_alcohol_consumption
FROM sleep_efficiency
GROUP BY awakenings;

