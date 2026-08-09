-- ============================================================
-- intermediate_queries.sql
-- Intermediate SQL Analysis
-- ============================================================

-- 1. Customers who placed orders but never had any item delivered
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id NOT IN (
    SELECT o2.customer_id
    FROM orders o2
    WHERE o2.status = 'DELIVERED' AND o2.customer_id IS NOT NULL
);


-- 2. Products that were ordered but had more returns than purchases
-- (returns = rows with negative quantity, purchases = rows with positive quantity)
SELECT
    p.product_id,
    p.product_name,
    SUM(CASE WHEN oi.quantity > 0 THEN oi.quantity ELSE 0 END) AS total_purchased,
    SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END) AS total_returned
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING total_returned > total_purchased
ORDER BY total_returned DESC;


-- 3. Return rate per category (returned_items / total_items)
SELECT
    p.category,
    SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END) AS returned_items,
    SUM(ABS(oi.quantity)) AS total_items,
    ROUND(
        1.0 * SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END)
        / NULLIF(SUM(ABS(oi.quantity)), 0),
        4
    ) AS return_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate DESC;


-- 4. Revenue by region
SELECT
    o.region_code,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.quantity > 0
GROUP BY o.region_code
ORDER BY total_revenue DESC;


-- 5. Daily revenue by region
SELECT
    o.region_code,
    date(o.order_date) AS order_day,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS daily_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.quantity > 0
GROUP BY o.region_code, order_day
ORDER BY order_day, o.region_code;


-- 6. Customer order frequency (number of distinct orders per customer)
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_frequency
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY order_frequency DESC;


-- 7. Monthly customer revenue
SELECT
    c.customer_id,
    c.customer_name,
    strftime('%Y-%m', o.order_date) AS order_month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS monthly_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE oi.quantity > 0
GROUP BY c.customer_id, c.customer_name, order_month
ORDER BY c.customer_id, order_month;
