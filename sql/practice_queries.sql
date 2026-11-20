-- Total Revenue = 89096
-- Underestimate rev because NULLs by 4173.50
SELECT SUM(Total_Spent) as revenue
FROM cafe_sales_clean;

-- Total Quantity sold = 9977
SELECT SUM(Quantity) as total_quantity
FROM cafe_sales_clean
WHERE Quantity IS NOT NULL;

-- Best-selling product: Coffee = 3878, Salad = 3815
-- Tea = 3622
SELECT 
Item,
SUM(Quantity) as total_quantity_sold
FROM cafe_sales_clean
WHERE Item IS NOT NULL
GROUP BY Item
ORDER BY SUM(Quantity) DESC;

-- Revenue by product
SELECT DISTINCT Item,
SUM(Total_Spent) as revenue
FROM cafe_sales_clean
GROUP BY Item
ORDER BY SUM(Total_Spent) DESC;

-- Average transaction value????
SELECT AVG(Total_Spent) as avg_trans_value
FROM cafe_sales_clean;

-- Daily sales trend
-- Because error, unknown, and nulls combined so total sales and rev are a lot
SELECT Transaction_Date,
COUNT(Transaction_ID) as total_sales,
SUM(Total_Spent) as revenue,
SUM(Quantity) as total_quantity_sold
FROM cafe_sales_clean
GROUP BY Transaction_Date
ORDER BY SUM(Total_Spent)DESC;

-- Monthly Sales Trend
SELECT
	YEAR(Transaction_Date) as year,
	MONTH(Transaction_Date) as month,
	COUNT(Transaction_ID) as total_sales,
	SUM(Total_Spent) as revenue,
	SUM(Quantity) as total_quantity_sold
FROM cafe_sales_clean
WHERE Transaction_Date IS NOT NULL
GROUP BY YEAR(Transaction_Date),MONTH(Transaction_Date)
ORDER BY MONTH(Transaction_Date) ASC;

-- Month over month growth
with previous_month_rev as (
	SELECT 
	YEAR(Transaction_Date) as year,
	MONTH(Transaction_Date) as month,
	SUM(Total_Spent) as rev,
	LAG(SUM(Total_Spent)) OVER (
		ORDER BY YEAR(Transaction_Date),MONTH(Transaction_Date)
		) AS previous_rev
	FROM cafe_sales_clean
	GROUP BY YEAR(Transaction_Date),MONTH(Transaction_Date)
)
SELECT
	year,
	month,
	ROUND(
	(rev - previous_rev)*100 /NULLIF(previous_rev,0),2) as monthly_growth
FROM previous_month_rev
ORDER BY month ASC;

SELECT *
FROM cafe_sales_clean;