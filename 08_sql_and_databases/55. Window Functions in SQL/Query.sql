CREATE TABLE marks (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);

INSERT INTO marks (name,branch,marks)VALUES
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);

SELECT AVG(marks)
FROM marks;

SELECT *,
       AVG(marks)
OVER ()
FROM marks;

SELECT *,
       AVG(marks)
OVER (PARTITION BY branch)
FROM marks;

SELECT *,
       MIN(marks) OVER(PARTITION BY branch) AS min_by_branch,
       MAX(marks) OVER(PARTITION BY branch) AS max_by_branch
FROM marks
ORDER BY student_id;

SELECT *
FROM (
    SELECT *,
       AVG(marks) OVER(PARTITION BY branch) AS branch_avg
    FROM marks
     )
WHERE marks > branch_avg;

SELECT *,
       RANK() OVER(PARTITION BY branch ORDER BY marks DESC),
       DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC)
FROM marks;

SELECT *,
       ROW_NUMBER() OVER(PARTITION BY branch)
FROM marks;

SELECT *,
       CONCAT(branch, '-', ROW_NUMBER() OVER (PARTITION BY branch ORDER BY student_id))
FROM marks;

SELECT *,
       EXTRACT(MONTH FROM date) AS month
FROM orders;

SELECT *,
       DATE_PART('month', date) AS month
FROM orders;

SELECT *,
       TO_CHAR(date, 'Month') AS month
FROM orders;

SELECT *
FROM (
    SELECT TO_CHAR(date, 'Month') AS month_name,
       user_id,
       SUM(amount) as total_amount,
       RANK() OVER (PARTITION BY TO_CHAR(date, 'Month')
           ORDER BY SUM(amount) DESC) AS month_rank
    FROM orders
    GROUP BY TO_CHAR(date, 'Month'), user_id
    ORDER BY TO_CHAR(date, 'Month')
     ) t
WHERE t.month_rank < 3
ORDER BY month_name DESC, month_rank ASC;

SELECT *,
       NTH_VALUE(marks, 1) OVER (PARTITION BY branch ORDER BY marks ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
       FIRST_VALUE(marks) OVER (PARTITION BY branch ORDER BY marks ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

SELECT *,
       NTH_VALUE(marks, 2) OVER (PARTITION BY branch ORDER BY marks DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks;

WITH top_studs AS (SELECT *,
                  NTH_VALUE(name, 1) OVER (PARTITION BY branch ORDER BY marks DESC)  AS topper_name,
                  NTH_VALUE(marks, 1) OVER (PARTITION BY branch ORDER BY marks DESC) AS topper_marks
           FROM marks)
SELECT name, branch, marks
FROM top_studs
WHERE top_studs.name = top_studs.topper_name
  AND top_studs.marks = top_studs.topper_marks;

WITH bottom_studs AS (
            SELECT *,
                   NTH_VALUE(name, 1) OVER w AS bottom_name,
                   NTH_VALUE(marks, 1) OVER w AS bottom_marks
           FROM marks
           WINDOW w AS (
               PARTITION BY branch
               ORDER BY marks ASC
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
               )
           )
SELECT name, branch, marks
FROM bottom_studs
WHERE bottom_studs.name = bottom_studs.bottom_name
  AND bottom_studs.marks = bottom_studs.bottom_marks;

SELECT *,
       LAG(marks) OVER(PARTITION BY branch ORDER BY student_id),
       LEAD(marks) OVER(PARTITION BY branch ORDER BY student_id)
FROM marks;

SELECT TO_CHAR(date, 'Month') as month,
       SUM(amount),
       LAG(SUM(amount)) OVER(ORDER BY TO_CHAR(date, 'Month') DESC) AS lag,
       SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY TO_CHAR(date, 'Month') DESC) AS revenue_diff
FROM orders
GROUP BY TO_CHAR(date, 'Month')
ORDER BY TO_CHAR(date, 'Month') DESC;

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', date) AS month_date,
        TO_CHAR(date, 'FMMonth') AS month,
        SUM(amount) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', date),
             TO_CHAR(date, 'FMMonth')
),
revenue_with_lag AS (
    SELECT
        month_date,
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month_date) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_revenue,
    revenue - previous_revenue AS revenue_diff,
    ((revenue - previous_revenue) / NULLIF(previous_revenue, 0)) * 100
        AS revenue_pct_change
FROM revenue_with_lag
ORDER BY month_date;