SELECT * FROM smartphones;

SELECT model, price, rating FROM smartphones;

SELECT os AS "Operating System", model, battery_capacity FROM smartphones;

SELECT model,
sqrt(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size AS ppi
FROM smartphones;

SELECT model, 'smartphone' as "type" from smartphones;

SELECT DISTINCT (smartphones.brand_name) AS brand_names
FROM smartphones;

SELECT DISTINCT smartphones.brand_name, smartphones.processor_brand
FROM smartphones;

SELECT * FROM smartphones
WHERE price > 50000;

SELECT * FROM smartphones
WHERE price > 10000 AND price < 20000;

SELECT * FROM smartphones
WHERE price BETWEEN 10000 AND 20000;

SELECT * FROM smartphones
WHERE price < 25000 AND rating > 80 AND processor_brand = 'snapdragon';

SELECT * FROM smartphones
WHERE brand_name = 'samsung' AND ram_capacity >= 8.0;

SELECT * FROM smartphones
WHERE brand_name = 'samsung' AND processor_brand = 'snapdragon';

SELECT DISTINCT (brand_name) FROM smartphones
WHERE price > 100000;

SELECT *
FROM smartphones
WHERE processor_brand = 'snapdragon' OR
      processor_brand = 'exynox' OR
      processor_brand = 'bionic';

SELECT *
FROM smartphones
WHERE processor_brand IN ('snapdragon', 'exynos', 'bionic');

SELECT *
FROM smartphones
WHERE processor_brand NOT IN ('snapdragon', 'exynos', 'bionic');

SELECT *
FROM smartphones
WHERE processor_brand = 'mediatek';

UPDATE smartphones
SET processor_brand = 'dimensity'
WHERE processor_brand = 'mediatek';

SELECT *
FROM smartphones
WHERE price > 200000;

DELETE
FROM smartphones
WHERE price > 200000;

SELECT MAX(price)
FROM smartphones;

SELECT MIN(price)
FROM smartphones;

SELECT AVG(price)
FROM smartphones
WHERE brand_name = 'apple';

SELECT SUM(price)
FROM smartphones;

SELECT COUNT(*)
FROM smartphones
WHERE brand_name = 'samsung';

SELECT COUNT(DISTINCT(brand_name))
FROM smartphones;

SELECT STDDEV(screen_size)
FROM smartphones;

SELECT VARIANCE(screen_size)
FROM smartphones;

SELECT ABS(price - 100000) AS "temp"
FROM smartphones;

SELECT model,
ROUND(sqrt(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size) AS ppi
FROM smartphones;

SELECT CEIL(screen_size)
FROM smartphones;

SELECT FLOOR(screen_size)
FROM smartphones;

