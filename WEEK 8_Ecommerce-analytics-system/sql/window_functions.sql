-- ============================================================
-- window_functions.sql
-- Window Functions: running totals, ranking, LAG/LEAD
-- ============================================================

-- 1. Running total of revenue per region ordered by date
WITH daily_region_revenue AS (
    SELECT
        o.region_code,
        date(o.order_date) AS order_date,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS daily_revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.quantity > 0
    GROUP BY o.region_code, order_date
)
SELECT
    region_code,
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            PARTITION BY region_code
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS running_total
FROM daily_region_revenue
ORDER BY region_code, order_date;


-- 2. Rank products by total revenue within each category (DENSE_RANK)
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.quantity > 0
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT
    category,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rank_in_category
FROM product_revenue
ORDER BY category, rank_in_category;


-- 3. For each customer, days between consecutive orders (LAG)
WITH customer_orders AS (
    SELECT DISTINCT
        customer_id,
        date(order_date) AS order_date
    FROM orders
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
    julianday(order_date) - julianday(
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
    ) AS days_gap
FROM customer_orders
ORDER BY customer_id, order_date;


-- 4. Flag customers with average order gap > 30 days as "At Risk"
WITH customer_orders AS (
    SELECT DISTINCT
        customer_id,
        date(order_date) AS order_date
    FROM orders
    WHERE customer_id IS NOT NULL
),
gaps AS (
    SELECT
        customer_id,
        order_date,
        julianday(order_date) - julianday(
            LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
        ) AS days_gap
    FROM customer_orders
)
SELECT
    customer_id,
    ROUND(AVG(days_gap), 2) AS avg_order_gap_days,
    CASE
        WHEN AVG(days_gap) > 30 THEN 'At Risk'
        ELSE 'Active'
    END AS risk_status
FROM gaps
WHERE days_gap IS NOT NULL
GROUP BY customer_id
ORDER BY avg_order_gap_days DESC;


-- 5. LEAD() for forward-order analysis:
-- For each customer's order, show the NEXT order date and how many days
-- until that next order happens (useful for predicting next purchase window)
WITH customer_orders AS (
    SELECT DISTINCT
        customer_id,
        date(order_date) AS order_date
    FROM orders
    WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    order_date,
    LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date,
    julianday(
        LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
    ) - julianday(order_date) AS days_until_next_order
FROM customer_orders
ORDER BY customer_id, order_date;
