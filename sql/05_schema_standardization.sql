-- Project: Cafe Sales Analytics
-- Step 5: Schema Standardization
-- Database: SQL Server

USE CafeSaleDB;

-- Check for remaining data type conversion issues
SELECT *
FROM staging_cafe_sales
WHERE (quantity IS NOT NULL
       AND TRY_CAST(quantity AS INT) IS NULL)
   OR (price_per_unit IS NOT NULL
       AND TRY_CAST(price_per_unit AS DECIMAL(10,2)) IS NULL)
   OR (total_spent IS NOT NULL
       AND TRY_CAST(total_spent AS DECIMAL(10,2)) IS NULL)
   OR (transaction_date IS NOT NULL
       AND TRY_CONVERT(DATE, transaction_date, 23) IS NULL);

-- Convert quantity to integer
ALTER TABLE staging_cafe_sales
ALTER COLUMN quantity INT;

-- Convert unit price to decimal
ALTER TABLE staging_cafe_sales
ALTER COLUMN price_per_unit DECIMAL(10,2);

-- Convert transaction total to decimal
ALTER TABLE staging_cafe_sales
ALTER COLUMN total_spent DECIMAL(10,2);

-- Convert transaction date to date
ALTER TABLE staging_cafe_sales
ALTER COLUMN transaction_date DATE;

-- Rename location to better reflect its meaning
EXEC sp_rename
    'dbo.staging_cafe_sales.location',
    'order_type',
    'COLUMN';

-- Check for inconsistent transaction totals
SELECT *
FROM staging_cafe_sales
WHERE total_spent <> quantity * price_per_unit;

-- Verify record count and transaction ID uniqueness
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT transaction_id) AS unique_transactions
FROM staging_cafe_sales;

-- Create the final cleaned dataset
SELECT *
INTO cafe_sales_clean
FROM staging_cafe_sales;

-- Verify final column names and data types
SELECT COLUMN_NAME,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH,
       NUMERIC_PRECISION,
       NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'cafe_sales_clean'
  AND TABLE_SCHEMA = 'dbo';

-- Preview the cleaned dataset
SELECT TOP 100 *
FROM cafe_sales_clean;