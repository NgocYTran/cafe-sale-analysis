/*
Project: Cafe Sales Analytics
Step 6: Sales Analysis
Database: SQL Server

Description:
Analyze sales performance, monthly revenue trends,
product performance, and customer purchasing behavior.
*/

USE CafeSaleDB;

-- Total recorded revenue
SELECT SUM(total_spent) AS total_revenue
FROM cafe_sales_clean;

-- Total transactions recorded
SELECT COUNT(*) AS total_transactions
FROM cafe_sales_clean;

-- Total items sold
SELECT SUM(quantity) AS total_items_sold
FROM cafe_sales_clean;

-- AVG transaction value
SELECT ROUND(AVG(total_spent), 2) AS avg_transaction_value
FROM cafe_sales_clean;

-- What percentage of transactions have a recorded sales amount
SELECT COUNT(*) AS total_transactions,
       COUNT(total_spent) AS transactions_with_revenue,
       COUNT(*) - COUNT(total_spent) AS missing_revenue,
       ROUND(
           COUNT(total_spent) * 100.0 / COUNT(*),
           2
       ) AS pct_with_sales_amount
FROM cafe_sales_clean;

-- Monthly revenue trend
SELECT YEAR(transaction_date) AS sales_year,
       MONTH(transaction_date) AS sales_month,
       SUM(total_spent) AS monthly_revenue,
       COUNT(*) AS total_transactions
FROM cafe_sales_clean
WHERE transaction_date IS NOT NULL
GROUP BY YEAR(transaction_date),
         MONTH(transaction_date)
ORDER BY sales_year, sales_month;

-- Month-over-month revenue growth
WITH monthly_sales AS (
    SELECT YEAR(transaction_date) AS sales_year,
           MONTH(transaction_date) AS sales_month,
           SUM(total_spent) AS monthly_revenue
    FROM cafe_sales_clean
    WHERE transaction_date IS NOT NULL
    GROUP BY YEAR(transaction_date),
             MONTH(transaction_date)
),
previous_month_rev AS (
    SELECT *,
           LAG(monthly_revenue) OVER (
               ORDER BY sales_year, sales_month
           ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT *,
       ROUND(
           (monthly_revenue - previous_month_revenue)
           * 100.0 / NULLIF(previous_month_revenue, 0),
           2
       ) AS monthly_growth_pct
FROM previous_month_rev
ORDER BY sales_year, sales_month;

-- Total revenue cannot be assigned to a month
SELECT COUNT(*) AS transactions_without_date,
       SUM(total_spent) AS revenue_without_date
FROM cafe_sales_clean
WHERE transaction_date IS NULL;

-- Which products generate the most revenue
SELECT item,
       SUM(total_spent) AS total_revenue
FROM cafe_sales_clean
WHERE item IS NOT NULL
GROUP BY item
ORDER BY total_revenue DESC;

-- Which products sell the most units
SELECT item,
       SUM(quantity) AS total_quantity_sold
FROM cafe_sales_clean
WHERE item IS NOT NULL
GROUP BY item
ORDER BY total_quantity_sold DESC;

-- Which order type is more popular
SELECT order_type,
       COUNT(*) AS total_transactions,
       SUM(total_spent) AS total_revenue,
       ROUND(AVG(total_spent), 2) AS avg_transaction_value
FROM cafe_sales_clean
WHERE order_type IS NOT NULL
GROUP BY order_type
ORDER BY total_transactions DESC;

-- Which payment method is used most frequently
SELECT payment_method,
       COUNT(*) AS total_transactions,
       ROUND(
           COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
           2
       ) AS transaction_pct
FROM cafe_sales_clean
WHERE payment_method IS NOT NULL
GROUP BY payment_method
ORDER BY total_transactions DESC;
