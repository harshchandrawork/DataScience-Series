-- 7.
SELECT state,
       ROUND(AVG(value), 2) AS avg_value,
       COUNT(*) AS occurence_count
FROM nces330_20
WHERE year = '2013' OR year = '2017' OR year = '2021' AND type = 'Public In-State'
GROUP BY state
HAVING COUNT(*) > 6 AND COUNT(*) < 10
ORDER BY AVG(value)
LIMIT 10;

-- 8.
SELECT state,
       ROUND(AVG(value), 2)
FROM nces330_20
WHERE expense = 'Fees/Tuition' AND type = 'Public In-State'
GROUP BY state
ORDER BY AVG(value)
LIMIT 1;

-- 9.
SELECT state,
       ROUND(AVG(value), 2)
FROM nces330_20
WHERE type = 'Private'
GROUP BY state
ORDER BY AVG(value) DESC
OFFSET 1
LIMIT 1;