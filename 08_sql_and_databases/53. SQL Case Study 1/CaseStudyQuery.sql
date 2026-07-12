-- 1. select a particular database
SELECT * FROM users;

-- 2. count number of rows
SELECT COUNT(*)
FROM users;

-- 3. return n random records (as sample in python)
SELECT *
FROM users
ORDER BY random()
LIMIT 5;

-- 4. find null values
-- to find the null values
SELECT *
FROM orders
WHERE restaurant_rating IS NULL;

-- to find the not null values
SELECT *
FROM orders
WHERE restaurant_rating IS NOT NULL;

-- to replace null values with 0
UPDATE orders
SET restaurant_rating = 0
WHERE restaurant_rating IS NULL;

-- 5. find the number of orders placed by each customer
SELECT t1.user_id,
       COUNT(*)
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id;

SELECT * FROM orders;

-- 6. find restaurant with the most number of menu items
SELECT t1.r_id,
       t2.r_name,
       COUNT(*)
FROM menu t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t2.r_name
ORDER BY COUNT(*) DESC;

SELECT * FROM restaurants;

-- 7. find the number of votes and avg rating for all the restaurants
SELECT t1.r_id,
       t2.r_name,
       COUNT(*) AS "num_votes",
       ROUND(AVG(restaurant_rating), 2) AS "avg_rating"
FROM orders t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
WHERE restaurant_rating IS NOT NULL
GROUP BY t1.r_id, t2.r_name;

-- 8. find the food that us being sold at most number of restaurants
SELECT t1.f_id,
       t2.f_name,
       COUNT(*)
FROM menu t1
JOIN food t2
ON t1.f_id = t2.f_id
GROUP BY t1.f_id, t2.f_name
ORDER BY COUNT(*) DESC;

-- 9. find restaurant with max revenue in a given month
SELECT TO_CHAR(t1.date::date, 'FMMonth') AS month_name,
       t1.date,
       t1.r_id,
       t2.r_name,
       SUM(t1.amount) AS revenue
FROM orders t1
JOIN restaurants t2 ON t1.r_id = t2.r_id
WHERE TO_CHAR(t1.date::date, 'FMMonth') = 'May'
GROUP BY t1.date, t1.r_id, t2.r_name
ORDER BY revenue DESC;

-- 10. find restaurant with sales > 3000
SELECT t1.r_id,
       t2.r_name,
       SUM(t1.amount)
FROM orders t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t2.r_name
HAVING SUM(t1.amount) > 3000
ORDER BY SUM(t1.amount) DESC;

-- 11. find customers who have never ordered
SELECT *
FROM users t1
LEFT JOIN orders t2
ON t1.user_id = t2.user_id
WHERE t2.user_id IS NULL;

SELECT user_id
FROM users
EXCEPT
SELECT t1.user_id
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id;

SELECT user_id
FROM users
EXCEPT
SELECT t1.user_id
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id;

-- 12. show order details of a particular customer in a given data range
SELECT *
FROM orders t1
JOIN order_details t2
ON t1.order_id = t2.order_id
WHERE user_id = '1' AND date BETWEEN '2022-05-10' AND '2022-06-15';

-- 13. favourite food of each customer (food most ordered by each customer)
SELECT t1.user_id,
       t1.name,
       t3.f_id,
       COUNT(*) AS occurence_count
FROM users t1
JOIN orders t2
ON t1.user_id = t2.user_id
JOIN order_details t3
ON t2.order_id = t3.order_id
GROUP BY t1.user_id, t1.name, t3.f_id;

WITH RankedFood AS (
    SELECT
        t1.user_id,
        t1.name,
        t3.f_id,
        COUNT(*) as occurrence_count,
        ROW_NUMBER() OVER (
            PARTITION BY t1.user_id, t1.name
            ORDER BY COUNT(*) DESC
        ) as rn
    FROM users t1
    JOIN orders t2 ON t1.user_id = t2.user_id
    JOIN order_details t3 ON t3.order_id = t2.order_id
    GROUP BY t1.user_id, t1.name, t3.f_id
)
SELECT
    user_id,
    name,
    t4.f_id,
    t5.f_name,
    t5.type
FROM RankedFood t4
JOIN food t5
ON t4.f_id = t5.f_id
WHERE rn = 1;

-- 14. find the costliest restaurants (avg price / dish)
SELECT t1.r_id,
       t2.r_name,
       COUNT(*),
       SUM(price),
       SUM(price) / COUNT(*) AS avg_price_per_dish
FROM menu t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t2.r_name
ORDER BY avg_price_per_dish DESC;

-- 15. find delivery partner compensation using the formula (#deliveries * 100 + 1000 * avg_rating)
SELECT t1.partner_id,
       t1.partner_name,
       COUNT(*) AS delivery_count,
       SUM(amount),
       (COUNT(*) * 100) + (1000 * SUM(t2.delivery_rating)) AS partner_compensation
FROM delivery_partner t1
JOIN orders t2
ON t1.partner_id = t2.partner_id
GROUP BY t1.partner_id, t1.partner_name;

-- 16. find the correlation between delivery_time and total_rating
SELECT CORR(delivery_time, delivery_rating + restaurant_rating)
FROM orders;

-- 17. find correlation between #orders and avg_price for all restaurants
WITH grouped_orders AS (
    SELECT r_id,
       COUNT(*) AS order_count,
       SUM(amount) / COUNT(*) AS avg_price
    FROM orders
    GROUP BY r_id
)
SELECT COUNT(order_count),
       AVG(avg_price),
       CORR(order_count, avg_price) AS correlation
FROM grouped_orders;

-- 18. find all the veg restaurants
SELECT t1.r_id,
       t3.r_name
FROM menu t1
JOIN food t2
ON t1.f_id = t2.f_id
JOIN restaurants t3
ON t1.r_id = t3.r_id
GROUP BY t1.r_id, t3.r_name
HAVING MIN(type) = 'Veg' AND MAX(type) = 'Veg';

-- 19. find min and max order value for all the customers
SELECT t1.user_id,
       t2.name,
       MIN(amount),
       MAX(amount),
       SUM(amount)
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id, t2.name