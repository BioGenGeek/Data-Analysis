-- Database: Project1

-- DROP DATABASE IF EXISTS "Project1";

CREATE DATABASE "Project1"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- CREATE TABLE 

DROP TABLE IF EXISTS retail
;
CREATE TABLE retail
(
     transactions_id INT PRIMARY KEY,
     sale_date DATE ,
     sale_time TIME,
     customer_id INT,
     gender VARCHAR(15),
     age INT,
     category VARCHAR(15),
     quantiy INT,
     price_per_unit FLOAT,
     cogs FLOAT,
     total_sale FLOAT
)
;


-- IMPORT DATA

SELECT * 
FROM retail
;

-- TOTAL ROWS
SELECT 
	COUNT(*)
FROM retail
;

-- RETRIEVE COLUMN NAMES
SELECT
	COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'retail'
;

-- CHECK FOR NULL VALUES

SELECT * 
FROM retail
WHERE transactions_id IS NULL
	OR 
	sale_date IS NULL
	OR
	"sale_time" IS NULL
	OR
	"customer_id" IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	OR
	age IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
;

-- CREATE CLEANING TABLE TO KEEP RAW DATA INTACT

CREATE TABLE retail_2
    (LIKE retail INCLUDING CONSTRAINTS)
;

SELECT *
FROM retail_2
;

INSERT INTO retail_2
SELECT *
FROM retail
;

SELECT 
	COUNT(*)
FROM retail_2
;

-- DELETE NULL VALUES

DELETE FROM retail_2
WHERE transactions_id IS NULL
	OR 
	sale_date IS NULL
	OR
	"sale_time" IS NULL
	OR
	"customer_id" IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	OR
	age IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
;



SELECT * 
FROM retail_2
WHERE transactions_id IS NULL
	OR 
	sale_date IS NULL
	OR
	"sale_time" IS NULL
	OR
	"customer_id" IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	OR
	age IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
;


-- CHECK FOR DUPS


WITH dup_cte AS
(
SELECT  * , ROW_NUMBER() OVER(PARTITION BY "total_sale","sale_date", "sale_time",
"customer_id","cogs","transactions_id","age","quantiy","price_per_unit",
"gender" , "category" ) AS row_num
FROM retail_2
)
SELECT *
FROM dup_cte
WHERE row_num >1
;


WITH dup_cte AS
(
SELECT  * , ROW_NUMBER() OVER(PARTITION BY "customer_id") AS row_num
FROM retail_2
)
SELECT *
FROM dup_cte
WHERE row_num >1
;

SELECT *
FROM retail_2
WHERE customer_id = 1

-- HOW MANY SALES WE HAVE

SELECT 
	COUNT(*) AS all_sale
FROM retail_2
;

-- NUMBER OF TOTAL CUSTOMERS

SELECT 
	COUNT(customer_id)
FROM retail_2
;
-- NUMBER OF UNIQUE CUSTOMERS
SELECT 
	COUNT(DISTINCT customer_id)
FROM retail_2
;

-- NUMBER OF UNIQUE ITEMS 

SELECT 
	DISTINCT category
FROM retail_2
;


-- Q1 RETRIEVE ALL COLUMNS FOR SALES MADE ON 2022-11-05

SELECT  *
FROM retail_2
WHERE sale_date = '2022-11-05'
ORDER BY gender
;

SELECT  COUNT(*), gender
FROM retail_2
WHERE sale_date = '2022-11-05'
GROUP BY gender
;

-- Q2 RETRIEVE ALL TRANSACTIONS : CATEGORY IS CLOTHING & QUANTITY >=4 & IN MONTH NOV-2022

SELECT *
FROM retail_2
WHERE category = 'Clothing'
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30'
	AND quantiy >= 4
;

SELECT *
FROM retail_2
WHERE category = 'Clothing'
	AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
	AND quantiy >= 4
;

-- Q3 TOTAL SALES FOR EACH CATEGORY

SELECT 
	category , SUM(total_sale) AS total_sale_per_cat , COUNT(*) AS total_orders
FROM retail_2
GROUP BY category
ORDER BY total_sale_per_cat DESC
;

-- Q4 AVG OF AGE FOR THOSE WHO PURCHASED 'Beauty'

SELECT ROUND(AVG(age),2) avg_age
FROM retail_2
WHERE category = 'Beauty'
;

-- Q5 ALL TRANSACTIONS WHERE TOTAL SALE IS >1000

SELECT * 
FROM retail_2
WHERE total_sale > 1000
;

-- Q6 ALL TRANSACTIONS BY EACH GENDER IN EACH CATEGORY FOR EACH YEAR

SELECT gender, category, COUNT(transactions_id) AS total_purchase,EXTRACT(Year FROM sale_date) AS years
FROM retail_2
GROUP BY gender, category,years
ORDER BY gender,years
;

-- Q7
WITH temp AS (
SELECT ROUND(CAST(AVG(total_sale) AS NUMERIC), 2) avg_purchase, EXTRACT(Month FROM sale_date) AS months,
EXTRACT(Year FROM sale_date) AS years
FROM retail_2
GROUP BY years,months
ORDER BY years,months
)
SELECT MAX(avg_purchase) AS max_avg_purchase,months,years
FROM temp
GROUP BY months,years
ORDER BY max_avg_purchase DESC
;

SELECT *
FROM (
SELECT  EXTRACT(YEAR FROM sale_date) AS years,
EXTRACT(MONTH FROM sale_date) AS months, ROUND(CAST(AVG(total_sale) AS NUMERIC), 2) avg_purchase ,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(CAST(AVG(total_sale) AS NUMERIC), 2) DESC ) AS ranks
FROM retail_2
GROUP BY 1,2
-- ORDER BY 2,1 DESC
) AS t1
WHERE ranks =1
;

-- Q8 TOP % CUSTOMERS BASED ON TOTAL SALES
SELECT  customer_id, SUM(total_sale) AS top_5 , RANK() OVER(PARTITION BY customer_id ORDER BY SUM(total_sale) )
FROM retail_2
GROUP BY customer_id
LIMIT 5

-- Q9 NUMBER OF UNIQUE CUSTOMERS FOR EACH CATEGORY

SELECT  category, COUNT(DISTINCT customer_id )
FROM retail_2
GROUP BY  category
;

-- Q10
SELECT 
	COUNT(*) ,CASE 
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time)  BETWEEN 12 AND 17 THEN 'After Noon'
			ELSE 'Evening'
		END AS shift
FROM retail_2
GROUP BY shift
;

WITH hourly_shift AS (
	SELECT * ,CASE 
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time)  BETWEEN 12 AND 17 THEN 'After Noon'
			ELSE 'Evening'
		END AS shift
FROM retail_2
)
SELECT 
	   shift,COUNT(*)
FROM hourly_shift
GROUP BY shift