-- ============================================================
-- cohort_analysis.sql
-- Cohort Analysis: group customers by registration month,
-- track retention across month 0-3, and classify customers as
-- repeat / one-time / churned.
-- ============================================================

-- Cohort retention table: for each registration-month cohort, how many
-- of those customers placed an order in month 0 (their reg month),
-- month 1, month 2, and month 3 relative to registration.
WITH cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', registration_date) AS cohort_month
    FROM customers
),
customer_order_months AS (
    SELECT DISTINCT
        c.customer_id,
        strftime('%Y-%m', o.order_date) AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
),
cohort_activity AS (
    SELECT
        co.customer_id,
        co.cohort_month,
        com.order_month,
        -- month_number = number of calendar months between cohort month and order month
        (CAST(strftime('%Y', com.order_month || '-01') AS INTEGER) - CAST(strftime('%Y', co.cohort_month || '-01') AS INTEGER)) * 12
        + (CAST(strftime('%m', com.order_month || '-01') AS INTEGER) - CAST(strftime('%m', co.cohort_month || '-01') AS INTEGER)) AS month_number
    FROM cohorts co
    JOIN customer_order_months com ON co.customer_id = com.customer_id
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.month_number,
    COUNT(DISTINCT ca.customer_id) AS customers,
    cs.cohort_size,
    ROUND(100.0 * COUNT(DISTINCT ca.customer_id) / cs.cohort_size, 2) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
WHERE ca.month_number BETWEEN 0 AND 3
GROUP BY ca.cohort_month, ca.month_number, cs.cohort_size
ORDER BY ca.cohort_month, ca.month_number;


-- Repeat vs one-time vs churned customers
-- Repeat customer   -> placed 2 or more orders
-- One-time customer -> placed exactly 1 order
-- Churned customer  -> registered but has NOT ordered in the last 6 months
--                      (regardless of how many orders they placed historically)
WITH customer_order_counts AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS num_orders,
        MAX(date(o.order_date)) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT
    CASE
        WHEN num_orders = 0 THEN 'Never Ordered'
        WHEN num_orders = 1 THEN 'One-Time'
        WHEN num_orders >= 2 AND last_order_date < date('now', '-6 months') THEN 'Churned Repeat Customer'
        ELSE 'Repeat'
    END AS customer_status,
    COUNT(*) AS customer_count
FROM customer_order_counts
GROUP BY customer_status
ORDER BY customer_count DESC;
