-- ============================================================
-- aggregations.sql
-- Basic SQL Analysis: JOINs and aggregations
-- Revenue formula used throughout: quantity * unit_price * (1 - discount_percent/100)
-- ============================================================

-- 1. Total revenue per category
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.quantity > 0   -- exclude returns from revenue totals
GROUP BY p.category
ORDER BY total_revenue DESC;


-- 2. Top 10 customers by total order value
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE oi.quantity > 0
GROUP BY c.customer_id, c.customer_name
ORDER BY total_order_value DESC
LIMIT 10;


-- 3. Month-wise order count for the last 12 months
SELECT
    strftime('%Y-%m', order_date) AS order_month,
    COUNT(DISTINCT order_id) AS order_count
FROM orders
WHERE order_date >= date('now', '-12 months')
GROUP BY order_month
ORDER BY order_month;


-- 4. Total revenue per customer
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE oi.quantity > 0
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;


-- 5. Total revenue per month
SELECT
    strftime('%Y-%m', o.order_date) AS order_month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS monthly_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.quantity > 0
GROUP BY order_month
ORDER BY order_month;


-- 6. Top products by quantity sold
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 20;


-- 7. Top products by revenue
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.quantity > 0
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 20;


-- 8. Average Order Value (AOV) by customer type
WITH order_totals AS (
    SELECT
        o.order_id,
        c.customer_type,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS order_value
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY o.order_id, c.customer_type
)
SELECT
    customer_type,
    ROUND(AVG(order_value), 2) AS avg_order_value,
    COUNT(*) AS num_orders
FROM order_totals
GROUP BY customer_type
ORDER BY avg_order_value DESC;
