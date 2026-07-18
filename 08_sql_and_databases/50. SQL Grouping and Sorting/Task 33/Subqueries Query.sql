SELECT MAX(score)
FROM movies;

SELECT *
FROM movies
WHERE score = 9.3;

SELECT *
FROM movies
WHERE score = (
    SELECT MAX(score)
    FROM movies
    );

-- chore: modify the column 'gross' and 'budget' for the next ques.
-- they have empty string values
ALTER TABLE movies
  ALTER COLUMN gross TYPE decimal USING NULLIF(trim(gross::text), '')::decimal,
  ALTER COLUMN budget TYPE decimal USING NULLIF(trim(budget::text), '')::decimal;

-- Independent Subquery - Scalar Subqueries
-- 1. Find the movie with the highest 'gross' (profit) (vs ORDER BY)
SELECT *
FROM movies
WHERE (gross - budget) = (
    SELECT MAX(gross - budget)
    FROM movies
    );

-- vs ORDER BY
SELECT *
FROM movies
WHERE gross IS NOT NULL AND gross <> 0
ORDER BY (gross - budget) DESC
LIMIT 1;

-- 2. Find how many movies have a score > the avg of all the movie score
-- (find the count of above average movies)
SELECT COUNT(*)
FROM movies
WHERE score > (
    SELECT AVG(score)
    FROM movies
    );

-- 3. Find the highest scored movie for the year 2000
SELECT *
FROM movies
WHERE year = '2000' AND
      score = (
          SELECT MAX(score)
          FROM movies
          WHERE year = '2000'
          );

-- 4. Find the highest scored movie among all movies whose
-- number of votes > the dataset avg votes
SELECT *
FROM movies
WHERE score = (
    SELECT MAX(score)
    FROM movies
    WHERE votes > (
        SELECT AVG(votes)
        FROM movies
        )
    );

-- Independent Subquery - Row Subquery (One Col Multi Rows)
-- 1. Find all users who never ordered
SELECT *
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT(user_id)
    FROM orders
    );

-- 2. Find all the movies made by top 3 directors (in terms of total gross income)
SELECT *
FROM movies
WHERE director IN (
    SELECT director
    FROM movies
    GROUP BY director
    ORDER BY SUM(gross) DESC NULLS LAST
    LIMIT 3
    )
ORDER BY gross DESC NULLS LAST;

-- 3. Find all movies of all those actors whose filmography's avg score > 8.5.
-- Also take 25000 votes as lower cutoff
SELECT *
FROM movies
WHERE star IN (
    SELECT star
    FROM movies
    WHERE votes > 25000
    GROUP BY star
    HAVING AVG(score) > 8.5
    );

-- Independent Subquery - Table Subquery (Multi Col Multi Row)
-- 1. Find the most profitable movie of each year
SELECT *
FROM movies -- checking the (year, gross - budget) combinations in the below line
WHERE (year, gross - budget) IN (
    SELECT year,
           MAX(gross - budget)
    FROM movies
    GROUP BY year
    );

-- 2. Find the highest scored movie of each genre votes cutoff of 25000
SELECT *
FROM movies
WHERE (genre, score) IN (
    SELECT genre,
       MAX(score)
    FROM movies
    WHERE votes > 25000
    GROUP BY genre
    );

-- 3. Find the highest grossing movies of top 5 actor/director combo
-- in terms of total gross income
-- method 1:
WITH top_duos AS (
    SELECT star,
       director,
       MAX(gross) AS max_gross
    FROM movies
    GROUP BY star, director
    ORDER BY MAX(gross) DESC NULLS LAST
    LIMIT 5
)
SELECT *
FROM movies
WHERE (star, director, gross) IN(
    SELECT *
    FROM top_duos
    );

-- method 2:
WITH top_5_pairs AS (
    -- Find the 5 pairs with the highest individual grossing movies
    SELECT star, director
    FROM movies
    WHERE star IS NOT NULL AND director IS NOT NULL
    GROUP BY star, director
    ORDER BY MAX(gross) DESC NULLS LAST
    LIMIT 5
)
SELECT m.*
FROM movies m
INNER JOIN top_5_pairs t
   ON m.star = t.star
  AND m.director = t.director
ORDER BY m.gross DESC NULLS LAST;

-- Correlated Subquery
-- 1. Find all the movies with a score higher than the average
-- score of movies in the same genre
SELECT *
FROM movies m1
WHERE score > (
    SELECT AVG(score)
    FROM movies m2
    WHERE m2.genre = m1.genre
    );

-- 2. Find the favourite food of each customer. Favourite must be based
-- on how many times a customer order a certain food.
WITH fav_food AS (
    SELECT name,
       f_name,
       COUNT(*) AS "frequency"
    FROM users t1
    JOIN orders t2
    ON t1.user_id = t2.user_id
    JOIN order_details t3
    ON t2.order_id = t3.order_id
    JOIN food t4
    ON t3.f_id = t4.f_id
    GROUP BY t1.name, t4.f_name
)
SELECT *
FROM fav_food f1
WHERE frequency =  (
    SELECT MAX(frequency)
    FROM fav_food f2
    WHERE f2.name = f1.name
    );

-- using subqueries with SELECT
-- 1. Get the percentage of votes for each movie compared to
-- the total number of votes.
SELECT name,
--        ((votes/SUM(votes)) * 100)
        (votes/(SELECT SUM(votes) FROM movies)) * 100
FROM movies;

-- Display all movie names, genre, score, and avg(score) of genre
SELECT name,
       genre,
       score,
       (SELECT AVG(score)
        FROM movies m2
        WHERE m2.genre = m1.genre) AS avg_score_genre
FROM movies m1;

-- using subqueries with FROM
-- 1. Display average rating of all the restaurants
SELECT r_name,
       avg_rating
FROM (
    SELECT r_id,
       AVG(restaurant_rating) AS "avg_rating"
    FROM orders
    GROUP BY r_id
     ) t1 JOIN restaurants t2
    ON t1.r_id = t2.r_id;

-- using subqueries with HAVING
-- 1. Find genres having avg score > avg score of all the movies
SELECT genre,
       (SELECT AVG(score)
        FROM movies m2
        WHERE m2.genre = m1.genre)
FROM movies m1;

SELECT genre,
       AVG(score) AS avg_score_genre,
       (SELECT AVG(score) FROM movies) AS avg_score
FROM movies
GROUP BY genre
HAVING AVG(score) > (SELECT AVG(score) FROM movies);

-- Subquery in INSERT
-- Populate an already create loyal_customers table with records
-- of only those customers who have ordered good more than 3 times.

CREATE TABLE loyal_users (
    user_id INT PRIMARY KEY,
    name VARCHAR (50),
    expenditure INT
);

INSERT INTO loyal_users (user_id, name)
SELECT t1.user_id,
       t2.name
FROM orders t1
JOIN users t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id, t2.name
HAVING COUNT(*) > 3;

-- Subquery in UPDATE
-- Populate the "expenditure" column of loyal_users table using the
-- orders table. Provide a 10% app money to all customers based on their
-- order value.
UPDATE loyal_users
SET money = (
    SELECT SUM(orders.amount) * 0.1
    FROM orders
    WHERE orders.user_id = loyal_users.user_id
    );

-- Subquery in DELETE
-- Delete all the customers records who have never ordered.
DELETE FROM users
WHERE user_id IN (
    SELECT user_id
    FROM users
    WHERE user_id NOT IN (
        SELECT DISTINCT(user_id)
        FROM orders
        )
    )

SELECT DISTINCT (user_id)
FROM users;