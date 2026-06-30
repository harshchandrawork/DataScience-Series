-- Q-1
SELECT t1.country,
       SUM(a),
       SUM(d)
FROM country_ab t1
JOIN country_cd t2
ON t1.country = t2.country
GROUP BY t1.country
ORDER BY SUM(a) DESC, SUM(d) DESC
LIMIT 10;

-- Q-2
SELECT t2.region,
       t2.edition,
       SUM(cl)
FROM country_cl t1
JOIN country_ab t2
ON t1.country = t2.country
WHERE t2.edition = '2020'
GROUP BY t2.edition, t2.region
ORDER BY SUM(cl) DESC;

-- Q-3
SELECT t2.name,
       SUM(quantity)
FROM "Sales1" t1
JOIN "Products" t2
ON t1.productid = t2.productid
GROUP BY t2.name
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- Q-4
SELECT t1.employeeid,
       t1.firstname,
       t1.lastname,
       SUM(t2.quantity)
FROM "Employees" t1
JOIN "Sales1" t2
ON t1.employeeid = t2.salesid
GROUP BY t1.employeeid, t1.firstname, t1.lastname
ORDER BY SUM(quantity) DESC
LIMIT 1;

-- Q-5
SELECT employeeid,
       firstname,
       lastname,
       COUNT(customerid)
FROM "Employees" t1
JOIN "Sales1" t2
ON t1.employeeid = t2.salespersonid
GROUP BY employeeid, firstname, lastname
ORDER BY COUNT(customerid) DESC
LIMIT 1;

-- Q-6
SELECT t1.employeeid,
       t1.firstname,
       t1.lastname,
       SUM(t3.price)
FROM "Employees" t1
JOIN "Sales1" t2
ON t1.employeeid = t2.salesid
JOIN "Products" t3
ON t2.productid = t3.productid
GROUP BY t1.employeeid, t1.firstname, t1.lastname
ORDER BY SUM(t3.price) DESC
LIMIT 5;

-- Q-7
SELECT t1.customerid,
       t1.firstname,
       t1.lastname,
       COUNT(*)
FROM "Customers" t1
JOIN "Sales1" t2
ON t1.customerid = t2.customerid
GROUP BY t1.customerid, t1.firstname, t1.lastname
HAVING COUNT(*) > 10;

-- Q-8
SELECT employeeid,
       firstname,
       lastname,
       COUNT(customerid) AS "customer_count"
FROM "Employees" t1
JOIN "Sales1" t2
ON t1.employeeid = t2.salespersonid
GROUP BY employeeid, firstname, lastname
HAVING COUNT(customerid) > 5;

-- Q-9

SELECT CONCAT(B.firstname, ' ', B.lastname) AS fc_name,
       CONCAT(C.firstname, ' ', C.lastname) AS sc_name
FROM (
    SELECT DISTINCT t1.customerid AS first_customer,
                    t2.customerid AS second_customer,
                    t1.salespersonid
    FROM "Sales1" t1
    JOIN "Sales1" t2
    ON t1.salespersonid = t2.salespersonid
    AND t1.customerid != t2.customerid
     ) A
JOIN "Customers" B
ON A.first_customer = B.customerid
LEFT JOIN "Customers" C
ON A.second_customer = C.customerid
LEFT JOIN "Employees" D
ON A.salespersonid = D.employeeid;