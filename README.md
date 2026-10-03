# Retail Sales Analysis SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis
**Level:** Beginner
**Database:** `p1_retail_db`
**Tool:** MySQL 8.0, MySQL Workbench

This project uses SQL to explore, clean and analyze retail sales data. It covers setting up a database, exploratory data analysis (EDA), and answering business questions on sales, customers, profit and trends.

## Objectives

1. Set up a retail sales database and load the data.
2. Clean the data by identifying and removing records with missing values.
3. Perform exploratory data analysis to understand the dataset.
4. Use SQL to answer business questions and derive insights.

## Dataset

| Item | Value |
|---|---|
| Transactions | 1,987 |
| Unique customers | 155 |
| Categories | Beauty, Clothing, Electronics |
| Period | Jan 2022 - Dec 2023 |
| Total revenue | 908,230 |

**Columns:** `transactions_id`, `sale_date`, `sale_time`, `customer_id`, `gender`, `age`, `category`, `quantity`, `price_per_unit`, `cogs`, `total_sale`

## Project Structure

```
├── README.md
├── data/
│   └── SQL - Retail Sales Analysis_utf .csv
└── sql/
    ├── 01_database_setup.sql
    ├── 02_data_cleaning_and_eda.sql
    ├── 03_core_sales_analysis.sql
    └── 04_profit_customer_trend_analysis.sql
```

## 1. Database Setup

```sql
CREATE DATABASE p1_retail_db;
USE p1_retail_db;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

## 2. Data Exploration and Cleaning

```sql
-- Record count
SELECT COUNT(*) FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- Unique categories
SELECT DISTINCT category FROM retail_sales;

-- Date range
SELECT MIN(sale_date), MAX(sale_date) FROM retail_sales;

-- Null check
SELECT * FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
      gender IS NULL OR age IS NULL OR category IS NULL OR
      quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR
      total_sale IS NULL;

-- Delete rows with missing values
SET SQL_SAFE_UPDATES = 0;
DELETE FROM retail_sales
WHERE sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR
      gender IS NULL OR age IS NULL OR category IS NULL OR
      quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR
      total_sale IS NULL;
```

**Data notes**
- Final cleaned dataset: 1,987 records.
- `cogs` does not scale with `quantity`, and in 309 rows it is higher than the unit price, so it is treated as an order-level cost.
- 70 orders (3.5%) have `cogs` above `total_sale` (negative profit). They were kept and flagged.
- Margins are about 79% in every category, so they are used only for relative comparison.

## 3. Data Analysis

**Q1. Retrieve all sales made on 2022-11-05**
```sql
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';
```

**Q2. Clothing transactions in Nov 2022 with quantity of 4 or more**
```sql
SELECT * FROM retail_sales
WHERE category = 'Clothing'
  AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
  AND quantity >= 4;
```

**Q3. Total sales and orders for each category**
```sql
SELECT category, SUM(total_sale) AS net_sale, COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

**Q4. Average age of customers who bought Beauty products**
```sql
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

**Q5. Transactions where total_sale is greater than 1000**
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

**Q6. Number of transactions by gender in each category**
```sql
SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

**Q7. Average sale per month and the best month in each year**
```sql
SELECT sale_year, sale_month, avg_sale
FROM (
    SELECT YEAR(sale_date) AS sale_year,
           MONTH(sale_date) AS sale_month,
           AVG(total_sale) AS avg_sale,
           RANK() OVER (PARTITION BY YEAR(sale_date)
                        ORDER BY AVG(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) AS t1
WHERE rnk = 1;
```

**Q8. Top 5 customers by total sales**
```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

**Q9. Unique customers per category**
```sql
SELECT category, COUNT(DISTINCT customer_id) AS cnt_unique_customers
FROM retail_sales
GROUP BY category;
```

**Q10. Orders by shift (Morning < 12, Afternoon 12-17, Evening > 17)**
```sql
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
```

**Q11. Profit and margin by category**
```sql
SELECT category,
       ROUND(SUM(total_sale), 2) AS revenue,
       ROUND(SUM(total_sale - cogs), 2) AS profit,
       ROUND(SUM(total_sale - cogs) / SUM(total_sale) * 100, 2) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit DESC;
```

**Q12. Revenue and average order value by age group**
```sql
SELECT CASE WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 50 THEN '36-50'
            ELSE '50+' END AS age_group,
       COUNT(*) AS orders,
       ROUND(SUM(total_sale), 2) AS revenue,
       ROUND(AVG(total_sale), 2) AS avg_order_value
FROM retail_sales
GROUP BY age_group
ORDER BY revenue DESC;
```

**Q13. Total revenue by month**
```sql
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month,
       ROUND(SUM(total_sale), 2) AS revenue
FROM retail_sales
GROUP BY month
ORDER BY revenue DESC;
```

**Q14. Month-over-month growth**
```sql
WITH monthly AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS ym,
           SUM(total_sale) AS sales
    FROM retail_sales
    GROUP BY ym
)
SELECT ym, sales,
       ROUND((sales - LAG(sales) OVER (ORDER BY ym))
             / LAG(sales) OVER (ORDER BY ym) * 100, 2) AS mom_growth_pct
FROM monthly;
```

**Q15. Revenue share by shift**
```sql
SELECT CASE WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) < 18 THEN 'Afternoon'
            ELSE 'Evening' END AS shift,
       ROUND(SUM(total_sale), 2) AS revenue,
       ROUND(SUM(total_sale) / (SELECT SUM(total_sale) FROM retail_sales) * 100, 2) AS pct_of_revenue
FROM retail_sales
GROUP BY shift;
```

## Findings

- **Category sales:** Electronics leads with 311,445, followed by Clothing (309,995) and Beauty (286,790). Beauty has the highest average order value (469.38).
- **Customer demographics:** Beauty customers average 40.4 years old. Ages 36-50 bring the most revenue (279,245), while ages 18-25 have the highest average order (502.86).
- **Gender:** Beauty skews female (330 vs 281 orders). Clothing and Electronics are almost evenly split.
- **Seasonality:** Four of the top five revenue months fall in Oct-Dec. Dec 2022 is the peak at 71,880.
- **Monthly trend:** Early 2022 is volatile, with month-over-month swings from -28.8% to +45.6%.
- **Shifts:** Evening generates 52.4% of revenue and 1,062 of 1,987 orders.
- **Top customers:** The top 5 customers contribute 148,470, about 16.3% of total revenue.

## Recommendations

1. Run promotions and plan staffing around the evening peak.
2. Prepare stock and campaigns for Oct-Dec.
3. Offer bundles to 18-25 customers and upsell to the 50+ group, which has the lowest average order (426.51).
4. Consider a loyalty program for top-spending customers.
5. Review how `cogs` is recorded, since 70 orders show negative profit.

## How to Run

1. Clone or download this repository.
2. Open MySQL Workbench and connect to your server (MySQL 8.0+ is required).
3. Run `sql/01_database_setup.sql`, then import the CSV from the `data/` folder using the Table Data Import Wizard.
4. Run the remaining SQL files one query at a time.

## Conclusion

This project covers database setup, data cleaning, EDA and business-driven SQL analysis using aggregations, CASE logic, subqueries, CTEs and window functions (`RANK`, `LAG`). The findings highlight sales patterns, customer behavior and category performance.

## Acknowledgment

Dataset and base project idea from Zero Analyst's public Retail Sales Analysis project.

## Author

**Your Name** | [LinkedIn](#) | [GitHub](#)
