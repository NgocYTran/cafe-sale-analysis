-- Project: Cafe Sales Analytics
-- Step 2: Duplicate Detection
-- Database: SQL Server

USE CafeSaleDB;

-- Check for duplicate transaction IDs
SELECT transaction_id,
       COUNT(*) AS duplicate_count
FROM staging_cafe_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Check for missing transaction IDs
SELECT *
FROM staging_cafe_sales
WHERE transaction_id IS NULL
    OR TRIM(transaction_id) = '';


-- Verify transaction ID uniqueness
SELECT COUNT(*) AS total_records,
        COUNT(DISTINCT transaction_id) AS unique_ids
FROM staging_cafe_sales;

-- Result:
-- All 10,000 records have unique, non-missing transaction IDs.
-- No duplicate records were identified based on transaction ID.
-- No records were removed.