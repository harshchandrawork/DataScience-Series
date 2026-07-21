SELECT COUNT(*)
FROM athlete_events;

-- change type of age col
ALTER TABLE athlete_events
ALTER COLUMN age TYPE INTEGER
USING NULLIF(age, 'NA')::integer;

-- change type of height col
ALTER TABLE athlete_events
ALTER COLUMN height TYPE INTEGER
USING NULLIF(height, 'NA')::integer;

-- change type of weight col
ALTER TABLE athlete_events
ALTER COLUMN weight TYPE DECIMAL
USING NULLIF(weight, 'NA')::decimal;

-- Problems 1-6 from Olympic Dataset
-- problem 1
SELECT *
FROM athlete_events
WHERE medal = 'Gold'
  AND year = '2008'
  AND height > (SELECT AVG(height)
                FROM athlete_events
                WHERE year = '2008');

-- problem 2
SELECT *
FROM athlete_events
WHERE sport = 'Basketball'
  AND medal != 'NA'
  AND year = '2016'
  AND weight < (SELECT AVG(weight)
                FROM athlete_events
                WHERE year = '2016' AND medal != 'NA');

-- problem 3
SELECT *
FROM athlete_events
WHERE medal != 'NA'
  AND sport = 'Swimming'
  AND year IN ('2008', '2016');

-- problem 4
SELECT noc,
       year,
       COUNT(*) AS medal_count
FROM athlete_events
WHERE medal != 'NA'
GROUP BY noc, year
HAVING COUNT(*) > 50;

-- problem 5
SELECT name,
       sport,
       year,
       COUNT(*)
FROM athlete_events
WHERE medal != 'NA'
GROUP BY name, sport, year;

-- problem 6
SELECT AVG(A.weight - B.weight)
FROM (
    SELECT *
    FROM athlete_events
    WHERE medal IS NOT NULL AND sex = 'F'
     ) A
JOIN (
    SELECT *
    FROM athlete_events
    WHERE medal IS NOT NULL AND sex = 'M'
     ) B
ON A.event = B.event;

-- the most optimal query for the given problem
SELECT AVG(A.weight - B.weight)
FROM athlete_events A
JOIN athlete_events B ON A.event = B.event
WHERE A.medal IS NOT NULL AND A.sex = 'F'
  AND B.medal IS NOT NULL AND B.sex = 'M';


-- Problems 7-10 from Insurance Dataset
-- problem 7
SELECT COUNT(*)
FROM insurance_data
WHERE claim > (SELECT AVG(claim)
               FROM insurance_data
               WHERE smoker = 'Yes'
                 AND children >= 1
                 AND region = 'southeast');

-- problem 8
SELECT COUNT(*)
FROM insurance_data
WHERE claim > (SELECT AVG(claim)
               FROM insurance_data
               WHERE smoker = 'No'
                 AND bmi > (SELECT AVG(bmi)
                            FROM insurance_data
                            WHERE children >= 1));

-- problem 9
SELECT COUNT(*)
FROM insurance_data
WHERE claim > (SELECT AVG(claim)
               FROM insurance_data
               WHERE bmi > (SELECT AVG(bmi)
                            FROM insurance_data
                            WHERE diabetic = 'Yes'
                              AND children >= 1
                              AND region = 'southwest'));

-- problem 10
SELECT AVG(A.claim - B.claim)
FROM insurance_data A
JOIN insurance_data B
ON A.bmi = B.bmi AND
   A.smoker != B.smoker AND
   A.children = B.children;