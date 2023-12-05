-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

SHOW DATABASES;
USE wallmart_sales_analysis;

SELECT * FROM SALES;
SELECT COUNT(*) FROM SALES;


---------------------FEATURE ENGINEERING-------------------------------------------
------------------DAY_RANGE_COLUMN---------------------------------------------
SELECT TIME,
( CASE 
WHEN TIME BETWEEN  "00:00:00" AND "12:00:00" THEN "MORNING"
WHEN TIME BETWEEN  "12:00:01" AND "15:00:00" THEN "AFTERNOON"
WHEN TIME BETWEEN  "15:00:01" AND "18:00:00" THEN "AFTERNOON"
ELSE "NIGHT"
END 
)AS TIME_RANGE FROM SALES ;


ALTER TABLE SALES ADD COLUMN TIME_RANGE VARCHAR(20);

UPDATE SALES SET TIME_RANGE= 
	( CASE 
WHEN TIME BETWEEN  "00:00:00" AND "12:00:00" THEN "MORNING"
WHEN TIME BETWEEN  "12:00:01" AND "15:00:00" THEN "AFTERNOON"
WHEN TIME BETWEEN  "15:00:01" AND "18:00:00" THEN "AFTERNOON"
ELSE "NIGHT"
END 
);



------------------------------CREATE_DAY_NAME _COULUMN------------------------------------------------------------


SELECT * FROM SALES ;

ALTER TABLE SALES ADD COLUMN DAY_NAME VARCHAR(20);

UPDATE SALES SET DAY_NAME =DAYNAME(DATE);

SELECT * FROM SALES ;


---------------------------------------------CREATE_MONTH_COULUMN-------------------------------------------------------------------
ALTER TABLE SALES ADD COLUMN MONTH VARCHAR(15);

UPDATE SALES SET MONTH =MONTHNAME(DATE) ;
	
SELECT * FROM SALES;


---------------------------------------------------GENERIC------------------------------------------------------------------------

--HOW MANY UNIQUE CITIES DOES THE DATA HAVE?

SELECT DISTINCT CITY FROM SALES ;

--In which city is each branch?

SELECT DISTINCT CITY,BRANCH FROM SALES ;

------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------PRODUCT-----------------------------------------------------------------------------------

-----How many unique product lines does the data have?

SELECT DISTINCT product_line  FROM  SALES;

----What is the most common payment method?

SELECT payment_method, COUNT(payment_method) AS usage_count
FROM SALES 
GROUP BY payment_method
ORDER BY usage_count DESC;

---What is the most selling product line?

SELECT product_line, COUNT(product_line) AS MAX_SELLING_PRODUCT
FROM SALES 
GROUP BY product_line
ORDER BY MAX_SELLING_PRODUCT DESC;

SELECT * FROM SALES;
----What is the total revenue by month?

SELECT MONTH AS MONTH_NAME ,
				SUM(TOTAL) AS TOTAL_REVENUE 
		FROM SALES 
        GROUP BY MONTH_NAME
        ORDER BY TOTAL_REVENUE ;
        
--What month had the largest COGS?

SELECT MONTH AS MONTH_NAME ,
				SUM(COGS) AS COGS
		FROM SALES 
        GROUP BY MONTH_NAME
        ORDER BY  COGS DESC;
        
---What product line had the largest revenue?

SELECT product_line AS PRODUCT ,
				SUM(TOTAL) AS TOTAL_REVENUE
		FROM SALES 
        GROUP BY PRODUCT
        ORDER BY  TOTAL_REVENUE DESC; 
        
-----What is the city with the largest revenue?

SELECT CITY AS CITY_NAME ,
				SUM(TOTAL) AS TOTAL_REVENUE
		FROM SALES 
        GROUP BY CITY_NAME 
        ORDER BY  TOTAL_REVENUE DESC; 
        
---What product line had the largest VAT?

SELECT PRODUCT_LINE AS PRODUCT ,
				AVG(VAT) AS MAX_VAT
		FROM SALES 
        GROUP BY PRODUCT
        ORDER BY  MAX_VAT DESC; 

----Which branch sold more products than average product sold?

SELECT
branch,
SUM(quantity) AS qty
FROM
sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

----What is the most common product line by gender?

SELECT GENDER ,PRODUCT_LINE ,
				COUNT(PRODUCT_LINE) AS PRODUCT
		FROM SALES 
        GROUP BY GENDER ,PRODUCT_LINE
        ORDER BY  PRODUCT DESC;

----What is the average rating of each product line?

SELECT PRODUCT_LINE AS PRODUCT,
				AVG(RATING) AS RATING
		FROM SALES 
        GROUP BY PRODUCT_LINE
        ORDER BY  RATING DESC;
        

----------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------Sales------------------------------------------------------------------------------------------

----Number of sales made in each time of the day per weekday

SELECT
TIME_RANGE,
COUNT(*) AS total
FROM sales
WHERE day_name = "Monday"
GROUP BY TIME_RANGE
ORDER BY
total  DESC;

----Which of the customer types brings the most revenue?

SELECT customer_type AS CUSTOMER ,
       SUM(TOTAL) AS REVENUE 
       FROM SALES 
       GROUP BY CUSTOMER
       ORDER BY REVENUE;
        
-----Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT CITY AS CITY ,
       AVG(VAT) AS VAT
       FROM SALES 
       GROUP BY CITY
       ORDER BY VAT;
       
------Which customer type pays the most in VAT?

SELECT CUSTOMER_TYPE AS CUSTOMER ,
       SUM(VAT) AS VAT
       FROM SALES 
       GROUP BY CUSTOMER_TYPE
       ORDER BY VAT;
       
---------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------CUSTOMER---------------------------------------------------------------------------------------

-----How many unique customer types does the data have?

SELECT DISTINCT CUSTOMER_TYPE FROM SALES;

-----How many unique payment methods does the data have?

SELECT DISTINCT payment_method FROM SALES;

------What is the most common customer type?

SELECT MAX(CUSTOMER_TYPE) FROM SALES;

------Which customer type buys the most?

SELECT customer_type, SUM(TOTAL) as total_purchase
FROM sales
GROUP BY customer_type
ORDER BY total_purchase DESC
LIMIT 1;

-----What is the gender of most of the customers?

SELECT GENDER, SUM(TOTAL) as total_purchase
FROM sales
GROUP BY GENDER
ORDER BY total_purchase DESC;




-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_RANGE,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_RANGE,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_RANGE
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
