USE p1_retail_db;

-- A1. Check how cogs relates to total_sale (run this first)
SELECT transactions_id, quantity, price_per_unit, cogs, total_sale
FROM retail_sales
LIMIT 10;

SELECT COUNT(*) AS rows_cogs_above_price
FROM retail_sales
WHERE cogs > price_per_unit;


SELECT COUNT(*) AS loss_making_orders
FROM retail_sales
WHERE cogs > total_sale;


-- A2. Profit and margin by category
SELECT category,
       ROUND(SUM(total_sale), 2) AS revenue,
       ROUND(SUM(total_sale - cogs), 2) AS profit,
       ROUND(SUM(total_sale - cogs) / SUM(total_sale) * 100, 2) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY profit DESC;

-- A3. Average order value by category
SELECT category,
       ROUND(AVG(total_sale), 2) AS avg_order_value
FROM retail_sales
GROUP BY category
ORDER BY avg_order_value DESC;

-- A4. Spending by age group
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

-- A5. Total revenue by month (best month by actual revenue)
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month,
       ROUND(SUM(total_sale), 2) AS revenue
FROM retail_sales
GROUP BY month
ORDER BY revenue DESC LIMIT 5;

-- A6. Month-over-month growth
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

-- A7. Repeat vs one-time customers
SELECT CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
       COUNT(*) AS customers
FROM (SELECT customer_id, COUNT(*) AS orders
      FROM retail_sales
      GROUP BY customer_id) t
GROUP BY customer_type;

-- A8. Revenue share by shift
SELECT CASE WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) < 18 THEN 'Afternoon'
            ELSE 'Evening' END AS shift,
       ROUND(SUM(total_sale), 2) AS revenue,
       ROUND(SUM(total_sale) / (SELECT SUM(total_sale) FROM retail_sales) * 100, 2) AS pct_of_revenue
FROM retail_sales
GROUP BY shift;