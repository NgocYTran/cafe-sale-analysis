-- Project: Cafe Sales Analytics
-- Step 3: Data Standardization
-- Database: SQL Server

USE CafeSaleDB;

-- Remove leading and trailing spaces
UPDATE staging_cafe_sales
SET transaction_id = TRIM(transaction_id),
    item = TRIM(item),
    quantity = TRIM(quantity),
    price_per_unit = TRIM(price_per_unit),
    total_spent = TRIM(total_spent),
    payment_method = TRIM(payment_method),
    location = TRIM(location),
    transaction_date = TRIM(transaction_date);

-- Check product names
SELECT DISTINCT item
FROM staging_cafe_sales;

-- Check payment methods
SELECT DISTINCT payment_method
FROM staging_cafe_sales;

-- Check order types
SELECT DISTINCT location
FROM staging_cafe_sales;

/** Identify values that cannot be converted
to the appropriate numeric data types **/

SELECT *
FROM staging_cafe_sales
WHERE TRY_CAST(quantity AS INT) IS NULL
   OR TRY_CAST(price_per_unit AS DECIMAL(10,2)) IS NULL
   OR TRY_CAST(total_spent AS DECIMAL(10,2)) IS NULL;


-- Identify invalid or missing transaction dates
SELECT *
FROM staging_cafe_sales
WHERE TRY_CONVERT(DATE, NULLIF(transaction_date, ''), 23) IS NULL;