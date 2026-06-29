-- Joins
-- CROSS JOIN
SELECT *
FROM users1 t1
CROSS JOIN groups t2;

-- INNER JOIN
SELECT *
FROM users1 t1
INNER JOIN membership t2
ON t1.user_id = t2.user_id;

-- to verify INNER JOIN (or any join)
SELECT DISTINCT(t1.user_id)
FROM users1 t1
INNER JOIN membership t2
ON t1.user_id = t2.user_id;

-- LEFT JOIN
SELECT *
FROM users1 t1
LEFT JOIN membership t2
ON t1.user_id = t2.user_id;

-- RIGHT JOIN
SELECT *
FROM users1 t1
RIGHT JOIN membership t2
ON t1.user_id = t2.user_id;

-- OUTER JOIN
SELECT *
FROM users1 t1
FULL OUTER JOIN membership t2
ON t1.user_id = t2.user_id;

-- SELF JOIN
SELECT *
FROM users1 t1
JOIN users1 t2
ON t1.emergency_contact = t2.user_id;

-- Set Operations
-- UNION
SELECT *
FROM person1
UNION
SELECT *
FROM person2;

-- UNION ALL
SELECT *
FROM person1
UNION ALL
SELECT *
FROM person2;

-- INTERSECT
SELECT *
FROM person1
INTERSECT
SELECT *
FROM person2;

-- EXCEPT
SELECT *
FROM person1
EXCEPT
SELECT *
FROM person2;

-- Joining on multiple columns
SELECT *
FROM students t1
JOIN class t2
ON t1.class_id = t2.class_id
AND t1.enrollment_year = t2.class_year;

-- Joining more than 2 tables

-- suppose the tables in need of joining do not hve common columns
-- though, there is an intermediary table which has both the PK
-- column of table 1 and table 2. Then we can perform the join
-- using 3 tables as such
SELECT *
FROM order_details_2 t1
JOIN orders t2
ON t1.order_id = t2.order_id
JOIN users t3
ON t2.user_id = t3.user_id;

-- Filtering columns
SELECT t1.order_id,
       t1.amount,
       t1.profit,
       t3.name
FROM order_details_2 t1
JOIN orders t2
ON t1.order_id = t2.order_id
JOIN users t3
ON t2.user_id = t3.user_id;

-- another example
SELECT t1.order_id,
       t2.name,
       t2.city
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id;

-- Filtering Rows
-- find all the orders placed in Pune
SELECT *
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id
WHERE t2.city = 'Pune';

-- find all orders under Chair category
SELECT *
FROM order_details_2 t1
JOIN category t2
ON t1.category_id = t2.category_id
WHERE t2.vertical = 'Chairs';

-- some other queries
-- find all profitable orders
SELECT t1.order_id,
       SUM(profit)
FROM orders t1
JOIN order_details_2 t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id
HAVING SUM(profit) > 0;

-- find the customer who has placed the most orders
SELECT t2.user_id,
       COUNT(*),
       t2.name,
       t2.city,
       t2.state
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id
GROUP BY t2.user_id, name, state, city
ORDER BY COUNT(*) DESC
LIMIT 1;

-- find the most profitable category
SELECT vertical,
       SUM(profit)
FROM order_details_2 t1
JOIN category t2
ON t1.category_id = t2.category_id
GROUP BY t2.vertical
ORDER BY SUM(profit) DESC
LIMIT 1;

-- find the most profitable state
SELECT state,
       SUM(profit)
FROM orders t1
JOIN order_details_2 t2
ON t1.order_id = t2.order_id
JOIN users t3
ON t1.user_id = t3.user_id
GROUP BY state
ORDER BY SUM(profit) DESC
LIMIT 1;

-- find all the categories with profit higher than 5000
SELECT t1.category_id,
       category,
       SUM(profit)
FROM category t1
JOIN order_details_2 t2
ON t1.category_id = t2.category_id
GROUP BY t1.category_id, category
HAVING SUM(profit) > 5000;