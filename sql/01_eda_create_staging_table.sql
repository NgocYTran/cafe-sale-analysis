-- 1. EDA + Create staging table
USE CafeSaleDB;

-- Preview the original dataset
SELECT TOP 100 *
FROM dirty_cafe_sales;

-- Count the total number of transactions
SELECT COUNT(*) AS total_records
FROM dirty_cafe_sales;

-- Inspect column names and data types
SELECT COLUMN_NAME,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH,
       IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dirty_cafe_sales'
  AND TABLE_SCHEMA = 'dbo';

-- Create a staging table to preserve the original dataset
SELECT
    Transaction_ID AS transaction_id,
    Item AS item,
    Quantity AS quantity,
    Price_Per_Unit AS price_per_unit,
    Total_Spent AS total_spent,
    Payment_Method AS payment_method,
    Location AS location,
    Transaction_Date AS transaction_date
INTO staging_cafe_sales
FROM dirty_cafe_sales;

-- Verify that all records were copied successfully
SELECT
    (SELECT COUNT(*) FROM dirty_cafe_sales) AS original_records,
    (SELECT COUNT(*) FROM staging_cafe_sales) AS staging_records;