CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

CREATE TABLE orders (
    Row_ID        INT,
    Order_ID      VARCHAR(20),
    Order_Date    VARCHAR(15),
    Ship_Date     VARCHAR(15),
    Ship_Mode     VARCHAR(30),
    Customer_ID   VARCHAR(20),
    Customer_Name VARCHAR(50),
    Segment       VARCHAR(20),
    Country       VARCHAR(30),
    City          VARCHAR(50),
    State         VARCHAR(30),
    Postal_Code   VARCHAR(10),
    Region        VARCHAR(30),
    Product_ID    VARCHAR(20),
    Category      VARCHAR(30),
    Sub_Category  VARCHAR(30),
    Product_Name  VARCHAR(255),
    Sales         DECIMAL(10,2),
    Quantity      INT,
    Discount      DECIMAL(4,2),
    Profit        DECIMAL(10,2)
);

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/e_commerce_data.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from orders;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM orders WHERE Order_Date IS NULL;

DESCRIBE orders;

UPDATE orders
SET 
Order_Date = CASE
    WHEN Order_Date LIKE '%/%' THEN STR_TO_DATE(Order_Date,'%m/%d/%Y')
    WHEN Order_Date LIKE '%-%' THEN STR_TO_DATE(Order_Date,'%m-%d-%Y')
END,
Ship_Date = CASE
    WHEN Ship_Date LIKE '%/%' THEN STR_TO_DATE(Ship_Date,'%m/%d/%Y')
    WHEN Ship_Date LIKE '%-%' THEN STR_TO_DATE(Ship_Date,'%m-%d-%Y')
END;

-- What are all the product categories?
SELECT DISTINCT Category FROM orders;

-- What are all the regions?
SELECT DISTINCT Region FROM orders;

-- What are the customer segments?
SELECT DISTINCT Segment FROM orders;

-- What time period does the data cover?
SELECT 
    MIN(Order_Date) AS earliest_order,
    MAX(Order_Date) AS latest_order
FROM orders;


-- Quick summary of key numbers
SELECT
    COUNT(*)                        AS total_orders,
    COUNT(DISTINCT Customer_ID)     AS unique_customers,
    COUNT(DISTINCT Product_ID)      AS unique_products,
    ROUND(SUM(Sales), 2)            AS total_revenue,
    ROUND(SUM(Profit), 2)           AS total_profit,
    ROUND(AVG(Sales), 2)            AS avg_order_value,
    ROUND(AVG(Discount) * 100, 1)   AS avg_discount_pct
FROM orders;


-- Check for NULL values in important columns
SELECT
    SUM(CASE WHEN Sales    IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN Profit   IS NULL THEN 1 ELSE 0 END) AS null_profit,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN Region   IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category
FROM orders;
 
-- Check for negative or zero sales
SELECT COUNT(*) AS bad_sales_rows
FROM orders
WHERE Sales <= 0;
 
 
-- Check for duplicate Order IDs
SELECT 
    Order_ID, 
    Row_ID,
    COUNT(*) AS count
FROM orders
GROUP BY Order_ID, Row_ID
HAVING COUNT(*) > 1;
 
 
-- Check discount range
SELECT 
    MIN(Discount) AS min_discount,
    MAX(Discount) AS max_discount
FROM orders;
 
 
-- Check profit range to spot extremes
SELECT 
    MIN(Profit) AS worst_loss,
    MAX(Profit) AS best_profit,
    ROUND(AVG(Profit), 2) AS avg_profit
FROM orders;


-- BUSINESS ANALYSIS QUERIES

-- Q1. Which product categories and sub-categories are profitable and which are running at a loss?
 
-- 1.1  Profit and revenue by Category
SELECT
    Category,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Category
ORDER BY total_profit DESC;
 
 
-- 1.2 Profit by Sub-Category
SELECT
    Category,
    Sub_Category,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Category, Sub_Category
ORDER BY total_profit DESC;
 
 
-- 4.3  Which sub-categories are LOSING money?
SELECT
    Sub_Category,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Sales), 2)  AS total_revenue
FROM orders
GROUP BY Sub_Category
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC;
 
 
-- Q2. Which regions contribute most to revenue
 
-- 2.1  Sales and profit by Region
SELECT
    Region,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Region
ORDER BY total_profit DESC;
 
 
-- 2.2  Which States have the highest losses?
SELECT
    State,
    Region,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY State, Region
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC
LIMIT 10;
 
 
-- Q3 How does the discount rate impact profit margin?
 
-- 3.1 Group orders by discount level and see profit impact
SELECT
    CASE
        WHEN Discount = 0 THEN '0% — No Discount'
        WHEN Discount <= 0.10 THEN '1-10% — Low'
        WHEN Discount <= 0.20 THEN '11-20% — Moderate'
        WHEN Discount <= 0.40 THEN '21-40% — High'
        ELSE 'Above 40% — Very High'
    END AS discount_band,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Profit), 2) AS avg_profit_per_order
FROM orders
GROUP BY discount_band
ORDER BY avg_profit_per_order DESC;
 
 
-- 3.2  Which category is most affected by high discounts?
SELECT
    Category,
    ROUND(AVG(Discount)*100, 1) AS avg_discount_pct,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Category
ORDER BY avg_discount_pct DESC;
 
 
-- Q4. Which customer segment generates the highest profit per order?
 
-- 4.1 Performance by Customer Segment
SELECT
    Segment,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Profit), 2) AS avg_profit_per_order,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Segment
ORDER BY avg_profit_per_order DESC;
 
 
-- 4.2  Segment performance by Category
SELECT
    Segment,
    Category,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct
FROM orders
GROUP BY Segment, Category
ORDER BY Segment, total_profit DESC;
 

-- Q5. Are there seasonal or quarterly patterns in sales?
 
-- 5.1  Monthly sales trend across all years
SELECT
    YEAR(Order_Date) AS year,
    MONTH(Order_Date) AS month_number,
    MONTHNAME(Order_Date) AS month_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY year, month_number, month_name
ORDER BY year, month_number;
 
 
-- 5.2 Quarterly performance — which quarter is strongest?
SELECT
    YEAR(Order_Date) AS year,
    QUARTER(Order_Date) AS quarter,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY year, quarter
ORDER BY year, quarter;
 

-- ADVANCED QUERIES

-- Q6. Rank sub-categories by profit within each category
SELECT
    Category,
    Sub_Category,
    ROUND(SUM(Profit), 2) AS total_profit,
    RANK() OVER (
        PARTITION BY Category
        ORDER BY SUM(Profit) DESC
    ) AS rank_in_category
FROM orders
GROUP BY Category, Sub_Category;
 
 
-- Q7. Top 10 most profitable products
SELECT
    Product_Name,
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY Product_Name, Category, Sub_Category
ORDER BY total_profit DESC
LIMIT 10;
 
 
-- Q8.  Top 10 worst performing products (biggest losses)
SELECT
    Product_Name,
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY Product_Name, Category, Sub_Category
ORDER BY total_profit ASC
LIMIT 10;
 
 
-- Q9. Year over year revenue growth
SELECT
    YEAR(Order_Date) AS year,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND((SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date)))
        / LAG(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date)) * 100, 1) 
        AS revenue_growth_pct
FROM orders
GROUP BY year
ORDER BY year;

