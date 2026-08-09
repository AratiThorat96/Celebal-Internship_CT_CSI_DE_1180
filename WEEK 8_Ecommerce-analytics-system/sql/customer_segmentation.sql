-- ============================================================
-- customer_segmentation.sql
-- Customer Segmentation: purchase frequency, spend tier, RFM
-- ============================================================

-- Segmentation logic explained:
--   Frequency segment (based on distinct order count):
--       One-Time   -> exactly 1 order
--       Occasional -> 2 to 4 orders
--       Loyal      -> 5 or more orders
--
--   Spend tier (based on total lifetime revenue):
--       Low    -> < 5,000
--       Medium -> 5,000 to 20,000
--       High   -> > 20,000
--
--   RFM metrics:
--       Recency   -> days since the customer's most recent order (lower = more recent = better)
--       Frequency -> total distinct number of orders placed
--       Monetary  -> total lifetime revenue generated

WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT o.order_id) AS frequency,
        MAX(date(o.order_date)) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
customer_revenue AS (
    SELECT
        c.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS monetary
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY c.customer_id
),
rfm_base AS (
    SELECT
        co.customer_id,
        co.customer_name,
        co.frequency,
        CAST(julianday('now') - julianday(co.last_order_date) AS INTEGER) AS recency_days,
        COALESCE(cr.monetary, 0) AS monetary
    FROM customer_orders co
    LEFT JOIN customer_revenue cr ON co.customer_id = cr.customer_id
)
SELECT
    customer_id,
    customer_name,
    recency_days AS recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    CASE
        WHEN frequency = 1 THEN 'One-Time'
        WHEN frequency BETWEEN 2 AND 4 THEN 'Occasional'
        ELSE 'Loyal'
    END AS frequency_segment,
    CASE
        WHEN monetary < 5000 THEN 'Low'
        WHEN monetary <= 20000 THEN 'Medium'
        ELSE 'High'
    END AS spend_tier
FROM rfm_base
ORDER BY monetary DESC;


-- ============================================================
-- Final combined customer segmentation query
-- Combines frequency segment, spend tier, and RFM into one view
-- ============================================================
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.customer_type,
        COUNT(DISTINCT o.order_id) AS frequency,
        MAX(date(o.order_date)) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.customer_type
),
customer_revenue AS (
    SELECT
        c.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS monetary
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY c.customer_id
)
SELECT
    co.customer_id,
    co.customer_name,
    co.customer_type,
    CAST(julianday('now') - julianday(co.last_order_date) AS INTEGER) AS recency_days,
    co.frequency,
    ROUND(COALESCE(cr.monetary, 0), 2) AS monetary,
    CASE
        WHEN co.frequency = 1 THEN 'One-Time'
        WHEN co.frequency BETWEEN 2 AND 4 THEN 'Occasional'
        ELSE 'Loyal'
    END AS frequency_segment,
    CASE
        WHEN COALESCE(cr.monetary, 0) < 5000 THEN 'Low'
        WHEN COALESCE(cr.monetary, 0) <= 20000 THEN 'Medium'
        ELSE 'High'
    END AS spend_tier
FROM customer_orders co
LEFT JOIN customer_revenue cr ON co.customer_id = cr.customer_id
ORDER BY monetary DESC;
