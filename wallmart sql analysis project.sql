About
This project aims to explore the Walmart Sales data to understand top performing branches and products, sales trend of of different products, customer behaviour. The aims is to study how sales strategies can be improved and optimized. The dataset was obtained from the Kaggle Walmart Sales Forecasting Competition.

"In this recruiting competition, job-seekers are provided with historical sales data for 45 Walmart stores located in different regions. Each store contains many departments, and participants must project the sales for each department in each store. To add to the challenge, selected holiday markdown events are included in the dataset. These markdowns are known to affect sales, but it is challenging to predict which departments are affected and the extent of the impact." source

Purposes Of The Project
The major aim of thie project is to gain insight into the sales data of Walmart to understand the different factors that affect sales of the different branches.

About Data
The dataset was obtained from the Kaggle Walmart Sales Forecasting Competition. This dataset contains sales transactions from a three different branches of Walmart, respectively located in Mandalay, Yangon and Naypyitaw. The data contains 17 columns and 1000 rows:

Column	Description	Data Type
invoice_id	Invoice of the sales made	VARCHAR(30)
branch	Branch at which sales were made	VARCHAR(5)
city	The location of the branch	VARCHAR(30)
customer_type	The type of the customer	VARCHAR(30)
gender	Gender of the customer making purchase	VARCHAR(10)
product_line	Product line of the product solf	VARCHAR(100)
unit_price	The price of each product	DECIMAL(10, 2)
quantity	The amount of the product sold	INT
VAT	The amount of tax on the purchase	FLOAT(6, 4)
total	The total cost of the purchase	DECIMAL(10, 2)
date	The date on which the purchase was made	DATE
time	The time at which the purchase was made	TIMESTAMP
payment_method	The total amount paid	DECIMAL(10, 2)
cogs	Cost Of Goods sold	DECIMAL(10, 2)
gross_margin_percentage	Gross margin percentage	FLOAT(11, 9)
gross_income	Gross Income	DECIMAL(10, 2)
rating	Rating	FLOAT(2, 1)
Analysis List
Product Analysis
Conduct analysis on the data to understand the different product lines, the products lines performing best and the product lines that need to be improved.

Sales Analysis
This analysis aims to answer the question of the sales trends of product. The result of this can help use measure the effectiveness of each sales strategy the business applies and what modificatoins are needed to gain more sales.

Customer Analysis
This analysis aims to uncover the different customers segments, purchase trends and the profitability of each customer segment.

Approach Used
Data Wrangling: This is the first step where inspection of data is done to make sure NULL values and missing values are detected and data replacement methods are used to replace, missing or NULL values.
Build a database
Create table and insert the data.
Select columns with null values in them. There are no null values in our database as in creating the tables, we set NOT NULL for each field, hence null values are filtered out.
Feature Engineering: This will help use generate some new columns from existing ones.
Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project.

Conclusion:

Business Questions To Answer
Generic Question
How many unique cities does the data have?
In which city is each branch?
Product
How many unique product lines does the data have?
What is the most common payment method?
What is the most selling product line?
What is the total revenue by month?
What month had the largest COGS?
What product line had the largest revenue?
What is the city with the largest revenue?
What product line had the largest VAT?
Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
Which branch sold more products than average product sold?
What is the most common product line by gender?
What is the average rating of each product line?
Sales
Number of sales made in each time of the day per weekday
Which of the customer types brings the most revenue?
Which city has the largest tax percent/ VAT (Value Added Tax)?
Which customer type pays the most in VAT?
Customer
How many unique customer types does the data have?
How many unique payment methods does the data have?
What is the most common customer type?
Which customer type buys the most?
What is the gender of most of the customers?
What is the gender distribution per branch?
Which time of the day do customers give most ratings?
Which time of the day do customers give most ratings per branch?
Which day fo the week has the best avg ratings?
Which day of the week has the best average ratings per branch?
Revenue And Profit Calculations
$ COGS = unitsPrice * quantity $

$ VAT = 5% * COGS $

 is added to the 
 and this is what is billed to the customer.

$ total(gross_sales) = VAT + COGS $

$ grossProfit(grossIncome) = total(gross_sales) - COGS $

Gross Margin is gross profit expressed in percentage of the total(gross profit/revenue)

$ \text{Gross Margin} = \frac{\text{gross income}}{\text{total revenue}} $

Example with the first row in our DB:

Data given:

$ \text{Unite Price} = 45.79 $
$ \text{Quantity} = 7 $
$ COGS = 45.79 * 7 = 320.53 $

$ \text{VAT} = 5% * COGS\= 5% 320.53 = 16.0265 $

$ total = VAT + COGS\= 16.0265 + 320.53 = 

$ \text{Gross Margin Percentage} = \frac{\text{gross income}}{\text{total revenue}}\=\frac{16.0265}{336.5565} = 0.047619\\approx 4.7619% $

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
