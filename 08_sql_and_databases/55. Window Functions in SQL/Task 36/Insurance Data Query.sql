-- Quick Tip: Use `DISTINCT ON (column_name) *` whenever there is a need to print
-- only the unique values belonging to a column in case of Window Functions.
-- An example is given in query 2.

-- 1.
SELECT index,
       patientid,
       claim,
       RANK() OVER(ORDER BY claim DESC)
FROM insurance_data;

-- 2.
SELECT DISTINCT ON (children) *
FROM (
    SELECT *,
       AVG(claim) OVER(PARTITION BY children) AS avg_claim
    FROM insurance_data
     ) AS sub_table;


-- 3.
SELECT *
FROM (
    SELECT *,
       DENSE_RANK() OVER(ORDER BY claim DESC) AS region_rank
    FROM insurance_data
     ) AS sub_table
WHERE region_rank = 1;

SELECT *
FROM (
    SELECT *,
       DENSE_RANK() OVER(ORDER BY claim) AS region_rank
    FROM insurance_data
     ) AS sub_table
WHERE region_rank = 1;

-- verify
SELECT *
FROM insurance_data
WHERE claim = (
    SELECT MIN(claim)
    FROM insurance_data
    );

-- 4.
SELECT age,
       (smoker_count * 100 / SUM(smoker_count) OVER()) AS smoker_percentage
FROM (
    SELECT age,
       COUNT(*) AS smoker_count
    FROM insurance_data
    WHERE smoker = 'Yes'
    GROUP BY age
     ) AS sub_table;
-- SUM(smoker_count) in line 2 of query 4 would normally raise an error due to
-- lack of group by.
-- So we simply avoid collapsing the rows in line 2 and include the sum of smoker_count
-- column with each row in the window using OVER().

-- 5.
WITH patients_claims AS (
    SELECT patientid,
       FIRST_VALUE(claim) over (PARTITION BY patientid) AS first_claim,
       SUM(claim) OVER(PARTITION BY patientid) AS total_claim
    FROM insurance_data
)
SELECT patientid,
       first_claim,
       total_claim,
       (total_claim - first_claim) AS claim_diff
FROM patients_claims;

-- 6.
WITH sub_table AS (
    SELECT patientid,
       children,
       claim,
       AVG(claim) OVER(PARTITION BY children) AS avg_claim
    FROM insurance_data
)
SELECT patientid,
       children,
       claim,
       avg_claim,
       (avg_claim - claim) AS claim_diff
FROM sub_table;

-- 7.
SELECT *,
       RANK() OVER(PARTITION BY region ORDER BY bmi DESC)
FROM insurance_data;

--8
WITH sub_table AS (
    SELECT patientid,
           region,
           claim,
           FIRST_VALUE(claim) over (PARTITION BY region ORDER BY bmi) AS highest_claim
    FROM insurance_data
    ORDER BY patientid
)
SELECT *,
       (highest_claim - claim) AS claim_diff
FROM sub_table;

-- 9.
WITH max_claims AS (
    SELECT
        patientid,
        claim,
        bmi,
        smoker,
        region,
        MAX(claim) OVER (PARTITION BY bmi, smoker, region) AS highest_claim_amount
    FROM insurance_data
)
SELECT
    patientid,
    claim,
    bmi,
    smoker,
    region,
    highest_claim_amount - claim AS claim_difference
FROM max_claims
ORDER BY claim_difference DESC;

-- 10.
SELECT *,
       MAX(bmi) OVER(
           ORDER BY age ASC NULLS LAST
           ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING
       ) AS max_bmi_next_three
FROM insurance_data;

-- 11.
SELECT
    patientid,
    index,
    claim,
    AVG(claim) OVER (
        PARTITION BY patientid
        ORDER BY index
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_last_2
FROM insurance_data
ORDER BY patientid, index;

-- 12.
WITH filtered_patients AS (
    SELECT
        region,
        gender,
        age,
        bmi,
        diabetic,
        claim,
        ROW_NUMBER() OVER (
            PARTITION BY region, gender
            ORDER BY age ASC, index ASC
        ) AS rn
    FROM insurance_data
    WHERE diabetic = 'No'
      AND bmi BETWEEN 25 AND 30
)
SELECT
    region,
    gender,
    age,
    bmi,
    claim AS first_claim_amount
FROM filtered_patients
WHERE rn = 1
ORDER BY region, gender, age ASC;