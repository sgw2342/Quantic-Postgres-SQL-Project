-- This file contains the SQL queries utilised to generate insights into business performance 

-- Setting Search Path to Production schema

set search_path=production;

-- Query 1
-- The following query finds the best selling products in terms of units sold

SELECT product_detail, SUM(transaction_qty) AS total_sold
FROM transaction_details
JOIN products ON transaction_details.product_id = products.product_id
GROUP BY product_detail
ORDER BY total_sold DESC;

-- Query 2
-- Query to retrieve the highest revenue generating products

SELECT product_detail, ROUND(SUM(transaction_qty * unit_price)::numeric,2) AS total_revenue
FROM transaction_details
JOIN products ON transaction_details.product_id = products.product_id
GROUP BY product_detail
ORDER BY total_revenue DESC;

-- Query 3
-- Store performance (by Revenue)

SELECT store_location, ROUND(SUM(transaction_qty * unit_price)::numeric,2) AS total_revenue
FROM transaction_details
JOIN transactions ON transaction_details.transaction_id = transactions.transaction_id
JOIN stores ON transactions.store_id = stores.store_id
GROUP BY store_location
ORDER BY total_revenue DESC;

-- Query 4
-- Performance by month

SELECT EXTRACT(MONTH FROM transaction_date) AS month, SUM(transaction_qty) AS total_sales
FROM transactions
JOIN transaction_details ON transactions.transaction_id = transaction_details.transaction_id
GROUP BY month
ORDER BY total_sales DESC;

-- Query 5
-- Performance (in transactions) by day of week

SELECT TO_CHAR(transaction_date, 'Day') AS day_of_week, COUNT(transaction_id) AS transaction_count
FROM transactions
GROUP BY day_of_week
ORDER BY transaction_count DESC;

-- Query 6
-- Performance (in revenue) by store by day of week

SELECT 
    stores.store_location,
    TO_CHAR(transactions.transaction_date, 'Day') AS day_of_week,
    ROUND(SUM(transaction_details.transaction_qty * transaction_details.unit_price)::numeric,2) AS total_revenue
FROM transactions
JOIN transaction_details ON transactions.transaction_id = transaction_details.transaction_id
JOIN stores ON transactions.store_id = stores.store_id
GROUP BY stores.store_location, day_of_week
ORDER BY stores.store_location, total_revenue DESC;

-- Query 7
-- Peak hour sales

SELECT EXTRACT(HOUR FROM transaction_time) AS hour, COUNT(transaction_id) AS transaction_count
FROM transactions
GROUP BY hour
ORDER BY transaction_count DESC;

-- Query 8
-- Peak hour revenue by store

SELECT 
    stores.store_location,
    EXTRACT(HOUR FROM transactions.transaction_time) AS hour_of_day,
    ROUND(SUM(transaction_details.transaction_qty * transaction_details.unit_price)::numeric,2) AS total_revenue
FROM transactions
JOIN transaction_details ON transactions.transaction_id = transaction_details.transaction_id
JOIN stores ON transactions.store_id = stores.store_id
GROUP BY stores.store_location, hour_of_day
ORDER BY total_revenue DESC;

-- Query 9
-- Average transaction value

SELECT ROUND(AVG(transaction_total)::numeric,2) AS avg_transaction_value
FROM (
    SELECT transaction_id, SUM(transaction_qty * unit_price) AS transaction_total
    FROM transaction_details
    GROUP BY transaction_id
) AS subquery;

-- Query 10
-- Average transaction value per store weekday versus weekend

SELECT 
    stores.store_location,
    CASE 
        WHEN EXTRACT(DOW FROM transactions.transaction_date) IN (1,2,3,4,5) THEN 'Weekday'
        ELSE 'Weekend'
    END AS day_type,
    ROUND(AVG(transaction_details.transaction_qty * transaction_details.unit_price)::numeric,2) AS avg_daily_revenue
FROM transactions
JOIN transaction_details ON transactions.transaction_id = transaction_details.transaction_id
JOIN stores ON transactions.store_id = stores.store_id
GROUP BY stores.store_location, day_type
ORDER BY stores.store_location, day_type;

-- Query 11
-- Worst performing products

SELECT product_detail, SUM(transaction_qty) AS total_sold
FROM transaction_details
JOIN products ON transaction_details.product_id = products.product_id
GROUP BY product_detail
ORDER BY total_sold ASC
LIMIT 10;

-- Query 12
-- Performance by product category

SELECT product_categories.product_category_type, ROUND(SUM(transaction_qty * unit_price)::numeric,2) AS total_revenue
FROM transaction_details
JOIN products ON transaction_details.product_id = products.product_id
JOIN product_categories ON products.product_category_id = product_categories.product_category_id
GROUP BY product_categories.product_category_type
ORDER BY total_revenue DESC;

-- Query 13
-- Performance by product by store (in units sold)

SELECT stores.store_location, products.product_detail, SUM(transaction_qty) AS total_sold
FROM transaction_details
JOIN transactions ON transaction_details.transaction_id = transactions.transaction_id
JOIN stores ON transactions.store_id = stores.store_id
JOIN products ON transaction_details.product_id = products.product_id
GROUP BY stores.store_location, products.product_detail
ORDER BY total_sold DESC;

-- Query 14
-- Best selling product in each category

WITH ranked_products AS (
    SELECT 
        p.product_category_id,
        pc.product_category_type,
        p.product_detail,
        SUM(td.transaction_qty) AS total_sold,
        RANK() OVER (PARTITION BY p.product_category_id ORDER BY SUM(td.transaction_qty) DESC) AS rank
    FROM transaction_details td
    JOIN products p ON td.product_id = p.product_id
    JOIN product_categories pc ON p.product_category_id = pc.product_category_id
    GROUP BY p.product_category_id, pc.product_category_type, p.product_detail
)
SELECT product_category_type, product_detail, total_sold
FROM ranked_products
WHERE rank = 1;

-- Query 15
-- Total revenues

SELECT ROUND(SUM(transaction_qty * unit_price)::numeric,2) AS total_revenue
FROM transaction_details;

-- Query 16
-- Revenue by product type

SELECT 
    pt.product_type, 
    ROUND(SUM(td.transaction_qty * td.unit_price)::numeric,2) AS total_revenue
FROM transaction_details td
JOIN products p ON td.product_id = p.product_id
JOIN product_types pt ON p.product_type_id = pt.product_type_id
GROUP BY pt.product_type
ORDER BY total_revenue DESC;

