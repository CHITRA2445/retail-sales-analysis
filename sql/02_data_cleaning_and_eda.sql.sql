USE p1_retail_db;

-- 1. Total number of records
SELECT COUNT(*) AS total_records FROM retail_sales;

-- 2. Preview the first 10 rows
SELECT * FROM retail_sales LIMIT 10;

-- 3. Date range of the data (sanity check that dates imported correctly)
SELECT MIN(sale_date) AS first_sale, MAX(sale_date) AS last_sale FROM retail_sales;

-- 4. Number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;

-- 5. All unique product categories
SELECT DISTINCT category FROM retail_sales;

-- 6. Find rows with missing values
SELECT * FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
      gender IS NULL OR age IS NULL OR category IS NULL OR
      quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR
      total_sale IS NULL;

-- 7. Count of rows with missing values
SELECT COUNT(*) AS rows_with_nulls FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
      gender IS NULL OR age IS NULL OR category IS NULL OR
      quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR
      total_sale IS NULL;

-- 8. Delete rows with missing values
SET SQL_SAFE_UPDATES = 0;

DELETE FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
      gender IS NULL OR age IS NULL OR category IS NULL OR
      quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR
      total_sale IS NULL;

-- 9. Record count after cleaning
SELECT COUNT(*) AS records_after_cleaning FROM retail_sales;