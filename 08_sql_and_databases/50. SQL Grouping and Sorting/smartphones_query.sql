-- SORTING DATA
-- 1. find top 5 samsung phones with the biggest screen size
SELECT model, screen_size
FROM smartphones
WHERE brand_name = 'samsung'
ORDER BY screen_size DESC
LIMIT 5;

-- 2. sort the phones in descending order of number of total cameras
SELECT model, smartphones.num_rear_cameras, smartphones.num_front_cameras
FROM smartphones
ORDER BY num_rear_cameras + num_front_cameras DESC;

SELECT model, smartphones.num_rear_cameras + smartphones.num_front_cameras AS total_cameras
FROM smartphones
ORDER BY total_cameras DESC;

-- 3. sort data on the basis of ppi in decreasing order
SELECT model,
       ROUND(SQRT(smartphones.resolution_width * smartphones.resolution_width +
                  smartphones.resolution_height * smartphones.resolution_height) / smartphones.screen_size) AS ppi
FROM smartphones
ORDER BY ppi DESC;

-- 4. find the phone with 2nd largest battery
SELECT model, smartphones.battery_capacity
FROM smartphones
ORDER BY battery_capacity DESC NULLS LAST
LIMIT 1 OFFSET 1;

-- explanation:
-- LIMIT 1: Specifies the total number of rows you want to return (1 row).OFFSET 1: Specifies the number of rows to skip before starting to return data (skips the first row).MySQL vs. PostgreSQL: In MySQL, LIMIT 1, 1 means LIMIT offset, row_count. PostgreSQL requires the explicit LIMIT row_count OFFSET offset syntax.
-- while sorting using ORDER BY in DESC order, i was getting the NULL values first. This is the basic nature in Postgresql. Explanation: In PostgreSQL, NULL values appear first when you sort using DESC because PostgreSQL treats NULL as the highest possible value. Solution: use `NULLS LAST`.

-- similarly, for the phone with 5th and 6th largest battery:
SELECT model, smartphones.battery_capacity
FROM smartphones
ORDER BY battery_capacity DESC NULLS LAST
LIMIT 2 OFFSET 4;

-- 5. find the name and rating of thw worst rated apple phone
SELECT model, smartphones.rating
FROM smartphones
WHERE brand_name = 'apple'
ORDER BY rating
LIMIT 1;

--6. sort phones alphabetically and then on the basis of price in order
SELECT model, price
FROM smartphones
ORDER BY model, price;

-- Grouping Data
-- 1. Group smartphones by brand and get the count, average price, max rating,
-- avg screen size, avg battery capacity and sort by average price
SELECT brand_name,
       COUNT(model) AS total_models_count,
       AVG(price) AS average_price,
       MAX(smartphones.rating) AS max_rating,
       AVG(smartphones.screen_size) AS average_screen_size,
       AVG(smartphones.battery_capacity) AS average_battery_capacity
FROM smartphones
GROUP BY brand_name
ORDER BY average_price DESC;

--2. Group smartphones by whether they have an NFC and get the average price and rating
SELECT smartphones.has_nfc,
       AVG(price) AS average_price,
       AVG(rating) AS average_rating
FROM smartphones
GROUP BY has_nfc;

-- Suppose that we want the above information for each model and brand names as wel, then we do:
SELECT brand_name,
       model,
       has_nfc,
       AVG(price) AS average_price,
       AVG(rating) AS average_rating
FROM smartphones
GROUP BY has_nfc, brand_name, model;

-- SORTING DATA
-- 1. find top 5 samsung phones with the biggest screen size
SELECT model, screen_size
FROM smartphones
WHERE brand_name = 'samsung'
ORDER BY screen_size DESC
LIMIT 5;

-- 2. sort the phones in descending order of number of total cameras
SELECT model, smartphones.num_rear_cameras, smartphones.num_front_cameras
FROM smartphones
ORDER BY num_rear_cameras + num_front_cameras DESC;

SELECT model, smartphones.num_rear_cameras + smartphones.num_front_cameras AS total_cameras
FROM smartphones
ORDER BY total_cameras DESC;

-- 3. sort data on the basis of ppi in decreasing order
SELECT model,
       ROUND(SQRT(smartphones.resolution_width * smartphones.resolution_width +
                  smartphones.resolution_height * smartphones.resolution_height) / smartphones.screen_size) AS ppi
FROM smartphones
ORDER BY ppi DESC;

-- 4. find the phone with 2nd largest battery
SELECT model, smartphones.battery_capacity
FROM smartphones
ORDER BY battery_capacity DESC NULLS LAST
LIMIT 1 OFFSET 1;

-- explanation:
-- LIMIT 1: Specifies the total number of rows you want to return (1 row).OFFSET 1: Specifies the number of rows to skip before starting to return data (skips the first row).MySQL vs. PostgreSQL: In MySQL, LIMIT 1, 1 means LIMIT offset, row_count. PostgreSQL requires the explicit LIMIT row_count OFFSET offset syntax.
-- while sorting using ORDER BY in DESC order, i was getting the NULL values first. This is the basic nature in Postgresql. Explanation: In PostgreSQL, NULL values appear first when you sort using DESC because PostgreSQL treats NULL as the highest possible value. Solution: use `NULLS LAST`.

-- similarly, for the phone with 5th and 6th largest battery:
SELECT model, smartphones.battery_capacity
FROM smartphones
ORDER BY battery_capacity DESC NULLS LAST
LIMIT 2 OFFSET 4;

-- 5. find the name and rating of thw worst rated apple phone
SELECT model, smartphones.rating
FROM smartphones
WHERE brand_name = 'apple'
ORDER BY rating
LIMIT 1;

--6. sort phones alphabetically and then on the basis of price in order
SELECT model, price
FROM smartphones
ORDER BY model, price;

-- Grouping Data
-- 1. Group smartphones by brand and get the count, average price, max rating,
-- avg screen size, avg battery capacity and sort by average price
SELECT brand_name,
       COUNT(model) AS total_models_count,
       AVG(price) AS average_price,
       MAX(smartphones.rating) AS max_rating,
       AVG(smartphones.screen_size) AS average_screen_size,
       AVG(smartphones.battery_capacity) AS average_battery_capacity
FROM smartphones
GROUP BY brand_name
ORDER BY average_price DESC;

--2. Group smartphones by whether they have an NFC and get the average price and rating
SELECT smartphones.has_nfc,
       AVG(price) AS average_price,
       AVG(rating) AS average_rating
FROM smartphones
GROUP BY has_nfc;

-- 3. Group smartphones by the extended memory available and get the average price
SELECT extended_memory_available,
       AVG(price) AS average_price
FROM smartphones
GROUP BY extended_memory_available;

-- 4. Group smartphones by the brand and processor brand and get the count of models
-- and the average primary camera resolution (rear)
SELECT brand_name,
       processor_brand,
       COUNT(model) AS model_count,
       AVG(primary_camera_rear) AS average_rearCamResolution
FROM smartphones
GROUP BY brand_name, processor_brand
ORDER BY brand_name;

-- one important thing to mention is that upon using Group by on multiple attributes
-- or columns, the obtained number of rows will be the result of the cartesian product
-- of the attributes that are used. For example:
SELECT has_nfc,
       has_5g,
       AVG(price)
FROM smartphones
GROUP BY has_nfc, has_5g;
-- since both the attributes or columns had 2 categorical type values, i.e.
-- "True" and "False" in each of has_nfc and has_5g, therefore
-- the number of rows obtained in the resultant table is of size 2 * 2 = 4

-- 5. Find top 5 most costly phone brands
SELECT brand_name,
       ROUND(AVG(price)) AS average_price
FROM smartphones
GROUP BY brand_name
ORDER BY average_price DESC
LIMIT 5;

-- 6. which brand makes the smallest screen smartphones
SELECT brand_name,
       AVG(smartphones.screen_size) AS average_screenSize
FROM smartphones
GROUP BY brand_name
ORDER BY average_screenSize
LIMIT 1;

-- 7. average price of 5g phones vs avg price of non 5g phones
SELECT has_5g,
       AVG(price)
FROM smartphones
GROUP BY has_5g;

-- 8. Group smartphones by the brand and find the brand with the highest number of
-- models that have both NFC and an IR blaster
SELECT brand_name,
       COUNT(model) AS model_count
FROM smartphones
WHERE has_nfc = 'True' AND has_ir_blaster = 'True'
GROUP BY brand_name
ORDER BY model_count DESC
LIMIT 1;

-- 9. find all the samsung 5g enabled smartphones and find out the avg price
-- for NFC and Non-NFC phones
SELECT has_nfc,
       AVG(price) AS average_price
FROM smartphones
WHERE brand_name = 'samsung' AND has_5g = 'True'
GROUP BY has_nfc;

-- HAVING Clause
-- HAVING clause does the same thing for GROUP BY that WHERE clause does or SELECT

-- for example, suppose that we want to find out the costliest phone making brand
-- so we take the group by on brand_name and take the average of the price.
-- But, there are come companies such as royole and leitz which have only 2 and 1
-- models respectively. Then the average price used to find the company making the
-- costliest phones doesn't make much sense. This is where the HAVING clause comes
-- into role, and we use this to select only those companies who have made at least
-- 20 phone models. Then the avg price comparison to find the companies that make
-- the costliest phones, makes better sense. Here is how we do it:
SELECT brand_name,
       COUNT(*) AS model_count,
       AVG(price) AS avg_price
FROM smartphones
GROUP BY brand_name
HAVING COUNT(*) > 20
ORDER BY avg_price DESC;
-- one technical detail to note is that we haven't used the model_count alias in
-- the HAVING clause. This is because in PostgreSQL, the execution hierarchy is
-- as such: FROM > WHERE > GROUP BY > HAVING > SELECT > ORDER (FWGHSO), and so
-- HAVING clause is executed before SELECT clause wherein the aliasing is actually
-- taking place. Therefore, we cannot use alias in HAVING clause.

-- Another important thing to note about the HAVING clause is that HAVING clause
-- will be used only upon the aggregate operated column, such as AVG(attribute),
-- COUNT(*), MAX(attribute), etc while using a GROUP BY clause.
-- Whereas, the WHILE clause will be used upon normal columns upon which aggregate
-- operations haven't been performed. This is because WHERE filters each row
-- individually, while HAVING does just the opposite, so it makes much sense.

-- 1. find the avg rating of smartphone brands which have more than 20 phones.
SELECT brand_name,
       COUNT(*) AS model_count,
       AVG(rating) AS avg_rating
FROM smartphones
GROUP BY brand_name
HAVING COUNT(*) > 20
ORDER BY avg_rating DESC;

-- 2. find the top 3 brands with the highest avg ram that have a refresh rate of at
-- least 90 Hz and fast charging available, and don't consider brands which have less
-- than 10 phones

SELECT brand_name,
       COUNT(*),
       AVG(rating) AS avg_rating
FROM smartphones
WHERE refresh_rate > 90 AND fast_charging_available = '1'
GROUP BY brand_name
HAVING COUNT(*) > 10
ORDER BY avg_rating DESC
LIMIT 3;

-- 3. find the avg price of all the phone brands with avg_rating > 70 and num_phones
-- more than 10 among all 5g enabled phones
SELECT brand_name,
       COUNT(*) AS model_count,
       AVG(price) AS avg_price,
       AVG(rating) AS avg_rating
FROM smartphones
WHERE has_5g = 'True'
GROUP BY brand_name
HAVING AVG(rating) > 70 AND COUNT(*) > 10;