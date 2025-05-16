CREATE DATABASE IF NOT EXISTS WalmartSalesData;

CREATE TABLE IF NOT EXISTS sales(
 invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
 branch VARCHAR(5) NOT NULL,
 city VARCHAR(30) NOT NULL,
 customer_type VARCHAR(30) NOT NULL,
 gender VARCHAR(10) NOT NULL,
 product_line VARCHAR(100) NOT NULL,
 unit_price DECIMAL(10,2) NOT NULL,
 quantity INT NOT NULL,
 VAT FLOAT (6,4) NOT NULL,
 total DECIMAL(12,4) NOT NULL,
 date DATETIME NOT NULL,
 time TIME NOT NULL,
 payment_method VARCHAR(15) NOT NULL,
 cogs DECIMAL(10,2) NOT NULL,
 gross_margin_pct FLOAT(11, 9),
 gross_income DECIMAL(12, 4) NOT NULL,
 rating FLOAT(2, 1)
 );
 
 
 
 
 
 
 
 -- -----------------------------------------------
 -- ------------ FEATURE ENGINEERING --------------
 -- time of day
 
 SELECT time, (
 CASE
 WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
 ELSE "Evening"
 END
 ) AS time_of_day
 FROM sales;
 
 ALTER TABLE sales
 DROP COLUMN time_of_day;
 
 ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
 
 UPDATE sales
 SET time_of_day = (
  CASE
 WHEN `time` BETWEEN "00:00:00" AND "11:59:59" THEN "Morning"
 WHEN `time` BETWEEN "12:00:00" AND "17:59:59" THEN "Afternoon"
 ELSE "Night"
 END
 );
 
 -- Day Name-------------------------------------------------
 SELECT date, DAYNAME(date) AS day_name
 FROM sales;
 
 ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
 
UPDATE sales
SET day_name = DAYNAME(date);

-- month name -----------------------------------------------

SELECT 
date, MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- -----------------------------------------------------------

-- -----------------------------------------------------------
-- ------------------------ GENERIC --------------------------

-- How many unique cities does the data have ? ---------------
SELECT 
DISTINCT city
FROM sales;

-- In which city is each branch ------------------------------

SELECT 
DISTINCT branch
FROM sales;

SELECT DISTINCT city, branch
FROM sales;

-- ----------------------------------------------------------
-- --------------------- PRODUCT ----------------------------

-- How many unique product lines does the data have ?

SELECT COUNT(DISTINCT product_line) 
FROM sales;

-- What is the most common payment method ? -----------------

SELECT payment_method, COUNT(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;

-- What is the most selling product line --------------------

SELECT product_line, COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- what is the total revenue by month -----------------------

SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- Which month has the largest COGS ? -----------------------

SELECT month_name, SUM(cog) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- Which product line has the largest revenue ---------------

SELECT product_line, SUM(total) AS large_revenue
FROM sales
GROUP BY product_line
ORDER BY large_revenue DESC;

-- What is the city with the largest revenue ? --------------

SELECT city, branch, SUM(total) AS large_revenue
FROM sales
GROUP BY city, branch
ORDER BY large_revenue DESC;

-- Which product line has the largest VAT ? -----------------
SELECT product_line, AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

/* Fetch each product line and add a column to those
product line showing "Good", "Bad". "Good" if its
greter than average sales */

-- Which branch sold more products than average products sold ? -----

SELECT branch, SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(quantity)
    FROM sales
);

-- What is the most common product line by gender -------------------

SELECT gender, product_line, COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line ------------------

SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ------------------------------------------------------------------
-- ---------------------- SALES -------------------------------------


-- Number of sales made in each time of the day per weekday ---------

SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales DESC;
-- Afternoon experiences most sales,
-- meaning stores are filled during afternoon hours. 

-- Which of the customer types bring more revenues ? ---------------

SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/VAT ? --------------------

ALTER TABLE sales ADD COLUMN tax_pct DECIMAL(5,2);

UPDATE sales
SET tax_pct = ROUND((VAT / total) * 100, 2);

SELECT city, AVG(VAT) AS avg_tax
FROM sales
GROUP BY city
ORDER BY avg_tax DESC;

-- Which type pays the most VAT ? ------------------------------

SELECT customer_type, AVG(VAT) AS avg_tax
FROM sales
GROUP BY customer_type
ORDER BY avg_tax DESC;



