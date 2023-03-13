/* CEO vs Worker Pay in Russell 3000 and S&P 500 Companies
Deep dive into how different workers and top executives are paid in top companies */
/* Data Source: https://www.kaggle.com/datasets/salimwid/latest-top-3000-companies-ceo-salary-202223 */

/* Data Cleaning - 
Check if the ceo_data_pay_merged_r3000 data is inclusive of all sp500 companies based on ticker
Result: ceo_data_pay_merged_r3000 is inclusive of ceo_data_pay_merged_sp500 */

SELECT sp.ticker, sp.company_name, 
(CASE WHEN sp.ticker IN 
(SELECT r.ticker FROM ceo_data_pay_merged_r3000 AS r) 
THEN 'yes' ELSE 'no' END) AS in_r3000
FROM ceo_data_pay_merged_sp500 AS sp
WHERE in_r3000 = 'no';

/* To create view with a new column sp500 in ceo_data_pay_merged_r3000 to indicate whether the company is also a SP500. */
DROP VIEW vdata_r3000;
CREATE VIEW vdata_r3000 AS
SELECT *,(CASE WHEN r.ticker IN (SELECT sp.ticker
FROM ceo_data_pay_merged_sp500 AS sp) THEN 'yes' ELSE 'no' END) AS is_sp500
FROM ceo_data_pay_merged_r3000 AS r;

/* Cross check if data in ceo_data_pay_merged_r3000 for sp500 matches ceo_data_pay_merged_sp500 */

SELECT CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM vdata_r3000
WHERE is_sp500='yes')  THEN 'true' ELSE 'false' END AS same_length
from ceo_data_pay_merged_sp500;
--result returned true - table's lengths matched
--To check for any mismatched field
WITH ordered_sp AS (SELECT ticker,company_name,median_worker_pay, pay_ratio, ceo_name, salary, industry FROM ceo_data_pay_merged_sp500
ORDER by ticker),
v AS (SELECT ticker,company_name,median_worker_pay, pay_ratio, ceo_name, salary, industry FROM vdata_r3000
WHERE is_sp500='yes'
ORDER by ticker)
SELECT *
FROM (SELECT * FROM v UNION ALL SELECT * FROM ordered_sp)
GROUP BY ticker,company_name,median_worker_pay, pay_ratio, ceo_name, salary, industry
HAVING COUNT(ticker)<2;
--0 resulted returned for mismatched row

--Replace special characters 20% with space in the industry column
UPDATE ceo_data_pay_merged_r3000
SET industry=REPLACE(industry,'%20', ' ') ;


--Check for null or zero values
SELECT *
FROM ceo_data_pay_merged_r3000
WHERE ticker IS NULL OR
company_name IS NULL OR
median_worker_pay IS NULL OR
median_worker_pay = '$0' OR
pay_ratio IS NULL OR
ceo_name IS NULL OR
salary IS NULL OR
salary = '$0' OR
industry IS NULL;
--3 row with zero values in found. Looked up at Zippia and salary.com and updated the values.
--Avg worker pay is used to update if median value is not found. Also pay ratio is checked and updated accordingly.
--Data row for Safehold is removed since median worker pay could not be found.
--Drop field1 as the row number is no longer correct, will assign new row number in setting up table view.
UPDATE ceo_data_pay_merged_r3000
SET median_worker_pay='$155,950'
WHERE ticker='CEVA';
UPDATE ceo_data_pay_merged_r3000
SET median_worker_pay='$55,695', pay_ratio='73:1'
WHERE ticker='CMCO';
DELETE FROM ceo_data_pay_merged_r3000
WHERE ticker='SAFE';
--ALTER TABLE ceo_data_pay_merged_r3000
--DROP COLUMN field1;

--Check data types 
--PRAGMA table_info(ceo_data_pay_merged_r3000);

--median_worker_pay and salary are in text format and need to convert numerical type. 
--pay_ratio will be calculated from ceo_salary and worker_median_pay to a better accuracy AND
--:1 will be omitted for plotting purpose.
--Create new row number column since table rows has changed.
/* To create view with the above changes and a new column sp500 to ceo_data_pay_merged_r3000 
to indicate whether the company is also a SP500. */

DROP VIEW vdata_r3000;
CREATE VIEW vdata_r3000 AS
SELECT (ROW_NUMBER() OVER(ORDER BY ticker)) AS row_n, 
ticker,company_name, ceo_name, CAST((REPLACE((SUBSTR(salary, 2, length(salary)-1)),',','')) AS INTEGER) AS ceo_salary, 
ROUND(CAST((REPLACE((SUBSTR(salary, 2, length(salary)-1)),',','')) AS FLOAT)/CAST((REPLACE((SUBSTR(median_worker_pay, 2, length(median_worker_pay)-1)),',','')) AS FLOAT),2) as ceo_pay_ratio , 
CAST((REPLACE((SUBSTR(median_worker_pay, 2, length(median_worker_pay)-1)),',','')) AS INTEGER) AS worker_median_pay , industry,
(CASE WHEN r.ticker IN (SELECT sp.ticker FROM ceo_data_pay_merged_sp500 AS sp) THEN 'yes' ELSE 'no' END) AS is_sp500
FROM ceo_data_pay_merged_r3000 AS r;

--Check highest and lowest values in ceo_salary and verify
SELECT *
FROM vdata_r3000
ORDER BY ceo_salary;
--Crossed checked a few lowest few ceo_salary values
SELECT *
FROM vdata_r3000
ORDER BY ceo_salary DESC;
--Crossed checked a few highest few ceo_salary values

--Check lowest values of worker_median_pay
/*worker_median_pay data is likely to be biased since the source of data is from America's Union that advocates for higher wages
Lot of median_worker_pay values are lower than the federal minimum yearly salary ~15,000USD meaning they may not be full time wages.
However it is important to have all worker's salaries in yearly amount so the comparison to annual ceo_salary will be fair. */

SELECT *
FROM vdata_r3000
ORDER BY worker_median_pay;
--Update value of outlier in worker_median_pay. Workers group in concern here are mainly production workers and sales associates.
UPDATE ceo_data_pay_merged_r3000
SET median_worker_pay = '$35,436' --corrected from $224 based on pay data from Indeed
WHERE ticker = 'NUS';

--Check highest values of worker_median_pay
SELECT *
FROM vdata_r3000
ORDER BY worker_median_pay DESC;

UPDATE ceo_data_pay_merged_r3000
SET median_worker_pay = '$67,533' --corrected from $1656424 based on pay data from Zippia
WHERE ticker = 'KOD';

--check industry categories
SELECT industry
from ceo_data_pay_merged_r3000
GROUP BY industry;

--Compute and rank average CEO salary by sector
SELECT industry, ROUND(AVG(ceo_salary), 2)
from vdata_r3000
GROUP BY industry
ORDER BY AVG(ceo_salary) DESC;


--Compute and rank average worker_median_pay by sector
SELECT industry, ROUND(AVG(worker_median_pay), 2)
from vdata_r3000
GROUP BY industry
ORDER BY AVG(worker_median_pay);

--return top 10 company per industry with the highest average ceo pay per industry
WITH topindustry AS (
SELECT industry, avg(ceo_salary)
FROM vdata_r3000
GROUP BY industry
ORDER BY avg(ceo_salary) DESC)
SELECT rk.industry, rk.company_name
FROM (SELECT industry, company_name, ceo_salary, 
RANK() OVER( PARTITION BY industry ORDER BY ceo_salary desc) AS topceopay
FROM vdata_r3000) as rk
INNER JOIN topindustry
ON rk.industry = topindustry.industry
WHERE rk.topceopay <= 10;

--return data table with path order for creating range plot between ceo salart and worker pay in Tableau
SELECT company_name, (SELECT work_median_pay, ceo_salary FROM vdata_r3000)as pay_type, 
(CASE WHEN pay_type = work_median_pay THEN 1 ELSE 2 END) as path_order
FROM vdata_r3000;

--rearrange data table for creating range plot between ceo salart and worker pay in Tableau
WITH temp1 AS 
(SELECT company_name, worker_median_pay as salary, 'worker_median_pay' as pay_type, 
(ceo_salary-worker_median_pay)as difference ,is_sp500 FROM vdata_r3000),
temp2 AS 
(SELECT company_name, ceo_salary as salary, 'ceo_salary' as pay_type, 
(ceo_salary-worker_median_pay)as difference, is_sp500 FROM vdata_r3000) 

SELECT * FROM temp1
UNION ALL
SELECT * FROM temp2
ORDER BY company_name;

--return the list of 10 companies with lowest CEO pay and compare to worker pay.
SELECT company_name, ceo_salary, worker_median_pay
FROM vdata_r3000
ORDER BY ceo_salary
LIMIT 10;

--compute average ceo salary and average worker pay.
SELECT ROUND(avg(ceo_salary),2), ROUND(avg(worker_median_pay),2)
FROM vdata_r3000;

--compute percentage of CEO salary that match with 150% worker median pay range within company
WITH compare AS (SELECT ceo_salary, CASE WHEN ceo_salary<= 1.5*worker_median_pay 
THEN 1 ELSE 0 END AS in_range
FROM vdata_r3000)

SELECT ROUND(CAST(sum(in_range) as float)/count(*),4) as inrange_percent, ROUND((1-CAST(sum(in_range) as float)/count(*)),4)as outrange_percent
FROM compare;

--Compute average pay ratio by industry
SELECT industry,avg(ceo_pay_ratio)
FROM vdata_r3000
GROUP BY industry;

--return top 10 company per industry with the highest average ceo pay per industry
WITH list AS(SELECT industry, company_name, worker_median_pay, 
(RANK() OVER( PARTITION BY industry ORDER BY worker_median_pay)) AS lowestpayrk
FROM vdata_r3000)
SELECT industry, company_name, worker_median_pay, lowestpayrk
FROM list
WHERE lowestpayrk <= 10;

--create visualization table for worker unit chart of pay ratio in tableau

SELECT industry, CAST(AVG(ceo_pay_ratio)/10 AS integer) as ratioper10
FROM vdata_r3000
GROUP BY industry;

--compute statistics summary for dashboard
SELECT MAX(ceo_salary), MAX(worker_median_pay), AVG(ceo_salary), AVG(worker_median_pay), 
COUNT(company_name)
FROM vdata_r3000;

SELECT COUNT(company_name)
FROM vdata_r3000
WHERE is_sp500='yes';
--find out the percentage of ceo above avg pay
SELECT CAST((SELECT COUNT(ceo_salary)
From vdata_r3000
WHERE ceo_salary>(SELECT avg(ceo_salary) FROM vdata_r3000)) as float)/count(ceo_salary) as percent_above_avg_ceopay
FROM vdata_r3000;
--find out the percentage of worker above avg pay
SELECT CAST((SELECT COUNT(worker_median_pay)
From vdata_r3000
WHERE worker_median_pay>(SELECT avg(worker_median_pay) FROM vdata_r3000)) as float)/count(worker_median_pay) as percent_above_avg_workerpay
FROM vdata_r3000;

--verify avg ceo pay ratio for sp500 company_name
SELECT industry,avg(ceo_pay_ratio)
FROM vdata_r3000
WHERE is_sp500 = 'yes'
GROUP BY industry
ORDER by avg(ceo_pay_ratio) DESC;