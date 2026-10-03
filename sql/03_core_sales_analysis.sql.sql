USE p1_retail_db;

-- Q1. All sales made on 2022-11-05
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2. Clothing transactions in Nov-2022 with quantity of 4 or more
SELECT * FROM retail_sales
WHERE category = 'Clothing'
  AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
  AND quantity >= 4;

-- Q3. Total sales and number of orders per category
SELECT category,
       SUM(total_sale) AS net_sale,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Q4. Average age of customers who bought Beauty products
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5. Transactions where total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q6. Number of transactions by each gender in each category
SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q7. Average sale per month, and the best month in each year
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

-- Q8. Top 5 customers by total sales
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9. Unique customers per category
SELECT category, COUNT(DISTINCT customer_id) AS cnt_unique_customers
FROM retail_sales
GROUP BY category;

-- Q10. Orders by shift (Morning < 12, Afternoon 12-17, Evening > 17)
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