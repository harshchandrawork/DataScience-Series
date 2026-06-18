-- 7.
SELECT state,
       ROUND(AVG(value), 2) AS avg_value,
       COUNT(*) AS occurence_count
FROM nces330_20
WHERE year IN ('2013', '2017', '2021') AND type = 'Public In-State'
GROUP BY state
HAVING COUNT(*) BETWEEN 6 AND 10
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