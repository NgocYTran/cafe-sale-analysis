-- Project: Cafe Sales Analytics
-- Step 4: Handling Missing Values
-- Database: SQL Server

USE CafeSaleDB;

-- Standardize missing and invalid values as NULL
UPDATE staging_cafe_sales
SET item = CASE
        WHEN UPPER(item) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE item END,
    quantity = CASE
        WHEN UPPER(quantity) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE quantity END,
    price_per_unit = CASE
        WHEN UPPER(price_per_unit) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE price_per_unit END,
    total_spent = CASE
        WHEN UPPER(total_spent) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE total_spent END,
    payment_method = CASE
        WHEN UPPER(payment_method) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE payment_method END,
    location = CASE
        WHEN UPPER(location) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE location END,
    transaction_date = CASE
        WHEN UPPER(transaction_date) IN ('UNKNOWN', 'ERROR', '')
        THEN NULL ELSE transaction_date END;


-- Total counts of missing values before recovery
SELECT
    COUNT(*) - COUNT(item) AS missing_item,
    COUNT(*) - COUNT(quantity) AS missing_quantity,
    COUNT(*) - COUNT(price_per_unit) AS missing_price,
    COUNT(*) - COUNT(total_spent) AS missing_total,
    COUNT(*) - COUNT(payment_method) AS missing_payment,
    COUNT(*) - COUNT(location) AS missing_location,
    COUNT(*) - COUNT(transaction_date) AS missing_date
FROM staging_cafe_sales;


-- Recover missing unit prices using known product prices
UPDATE staging_cafe_sales
SET price_per_unit = CASE
    WHEN item = 'Cookie' THEN '1.00'
    WHEN item = 'Tea' THEN '1.50'
    WHEN item = 'Coffee' THEN '2.00'
    WHEN item IN ('Cake', 'Juice') THEN '3.00'
    WHEN item IN ('Sandwich', 'Smoothie') THEN '4.00'
    WHEN item = 'Salad' THEN '5.00'
END
WHERE price_per_unit IS NULL
  AND item IS NOT NULL;

-- Recover remaining missing unit prices using transaction values
UPDATE staging_cafe_sales
SET price_per_unit =
    TRY_CAST(total_spent AS DECIMAL(10,2))
    / NULLIF(TRY_CAST(quantity AS INT), 0)
WHERE price_per_unit IS NULL
  AND TRY_CAST(total_spent AS DECIMAL(10,2)) > 0
  AND TRY_CAST(quantity AS INT) > 0;

-- Recover missing product names only when
-- the unit price uniquely identifies a product
UPDATE staging_cafe_sales
SET item = CASE
    WHEN TRY_CAST(price_per_unit AS DECIMAL(10,2)) = 1.00
        THEN 'Cookie'
    WHEN TRY_CAST(price_per_unit AS DECIMAL(10,2)) = 1.50
        THEN 'Tea'
    WHEN TRY_CAST(price_per_unit AS DECIMAL(10,2)) = 2.00
        THEN 'Coffee'
    WHEN TRY_CAST(price_per_unit AS DECIMAL(10,2)) = 5.00
        THEN 'Salad'
END
WHERE item IS NULL
  AND TRY_CAST(price_per_unit AS DECIMAL(10,2))
      IN (1.00, 1.50, 2.00, 5.00);

/** Recover missing quantities when the calculated
quantity is a positive whole number **/
UPDATE staging_cafe_sales
SET quantity = TRY_CAST(
    TRY_CAST(total_spent AS DECIMAL(10,2))
    / NULLIF(TRY_CAST(price_per_unit AS DECIMAL(10,2)), 0)
    AS INT
)
WHERE quantity IS NULL
  AND TRY_CAST(total_spent AS DECIMAL(10,2)) > 0
  AND TRY_CAST(price_per_unit AS DECIMAL(10,2)) > 0
  AND TRY_CAST(total_spent AS DECIMAL(10,2))
      % NULLIF(TRY_CAST(price_per_unit AS DECIMAL(10,2)), 0) = 0;


-- Recover missing transaction totals
UPDATE staging_cafe_sales
SET total_spent =
    TRY_CAST(quantity AS INT)
    * TRY_CAST(price_per_unit AS DECIMAL(10,2))
WHERE total_spent IS NULL
  AND TRY_CAST(quantity AS INT) > 0
  AND TRY_CAST(price_per_unit AS DECIMAL(10,2)) > 0;

/** Unrecoverable missing values are retained as NULL
to avoid introducing unsupported assumptions
into the dataset.**/

-- Evaluate data completeness after recovery
SELECT
    COUNT(*) - COUNT(item) AS missing_item,
    COUNT(*) - COUNT(quantity) AS missing_quantity,
    COUNT(*) - COUNT(price_per_unit) AS missing_price,
    COUNT(*) - COUNT(total_spent) AS missing_total,
    COUNT(*) - COUNT(payment_method) AS missing_payment,
    COUNT(*) - COUNT(location) AS missing_location,
    COUNT(*) - COUNT(transaction_date) AS missing_date
FROM staging_cafe_sales;

-- Verify that no transaction records were lost
SELECT COUNT(*) AS total_records
FROM staging_cafe_sales;