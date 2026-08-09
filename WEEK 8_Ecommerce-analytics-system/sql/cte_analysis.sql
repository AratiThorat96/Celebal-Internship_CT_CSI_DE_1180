-- ============================================================
-- cte_analysis.sql
-- Advanced CTE Analysis
-- ============================================================

-- 1. Monthly revenue per customer -> categorize (High/Medium/Low) -> count per month
WITH monthly_customer_revenue AS (
    SELECT
        c.customer_id,
        strftime('%Y-%m', o.order_date) AS order_month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY c.customer_id, order_month
),
categorized AS (
    SELECT
        order_month,
        customer_id,
        revenue,
        CASE
            WHEN revenue > 10000 THEN 'High'
            WHEN revenue >= 5000 THEN 'Medium'
            ELSE 'Low'
        END AS customer_category
    FROM monthly_customer_revenue
)
SELECT
    order_month AS month,
    customer_category,
    COUNT(*) AS customer_count
FROM categorized
GROUP BY order_month, customer_category
ORDER BY order_month, customer_category;


-- 2. Customer lifetime value quartiles (NTILE)
WITH customer_ltv AS (
    SELECT
        c.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS total_value
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY c.customer_id
)
SELECT
    customer_id,
    ROUND(total_value, 2) AS total_value,
    NTILE(4) OVER (ORDER BY total_value DESC) AS quartile,
    CASE NTILE(4) OVER (ORDER BY total_value DESC)
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS quartile_label
FROM customer_ltv
ORDER BY total_value DESC;


-- 3. Year-over-Year revenue comparison (LAG across years for same month)
WITH monthly_revenue AS (
    SELECT
        CAST(strftime('%Y', o.order_date) AS INTEGER) AS year,
        CAST(strftime('%m', o.order_date) AS INTEGER) AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.quantity > 0
    GROUP BY year, month
)
SELECT
    cur.year,
    cur.month,
    ROUND(cur.revenue, 2) AS revenue,
    ROUND(prev.revenue, 2) AS prev_year_revenue,
    CASE
        WHEN prev.revenue IS NULL OR prev.revenue = 0 THEN NULL
        ELSE ROUND(((cur.revenue - prev.revenue) / prev.revenue) * 100, 2)
    END AS yoy_growth_percent
FROM monthly_revenue cur
LEFT JOIN monthly_revenue prev
    ON cur.month = prev.month AND cur.year = prev.year + 1
ORDER BY cur.year, cur.month;


-- 4. First purchased category vs most recent purchased category, per customer
WITH customer_category_orders AS (
    SELECT
        c.customer_id,
        p.category,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date ASC) AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY o.order_date DESC) AS rn_last
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.quantity > 0
),
first_category AS (
    SELECT customer_id, category AS first_category
    FROM customer_category_orders
    WHERE rn_first = 1
),
latest_category AS (
    SELECT customer_id, category AS latest_category
    FROM customer_category_orders
    WHERE rn_last = 1
)
SELECT
    f.customer_id,
    f.first_category,
    l.latest_category,
    CASE
        WHEN f.first_category = l.latest_category THEN 'No'
        ELSE 'Yes'
    END AS category_shift
FROM first_category f
JOIN latest_category l ON f.customer_id = l.customer_id
ORDER BY f.customer_id;


-- ============================================================
-- 5. Cumulative distribution: what % of total revenue comes from
--    the top N% of customers (uses SUM() OVER and PERCENT_RANK)
-- ============================================================
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE oi.quantity > 0
    GROUP BY c.customer_id
),
ranked AS (
    SELECT
        customer_id,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
        SUM(revenue) OVER () AS grand_total_revenue,
        PERCENT_RANK() OVER (ORDER BY revenue DESC) AS percent_rank_of_customer
    FROM customer_revenue
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(cumulative_revenue, 2) AS cumulative_revenue,
    ROUND(100.0 * cumulative_revenue / grand_total_revenue, 2) AS cumulative_percent,
    ROUND(percent_rank_of_customer * 100, 2) AS percentile_rank
FROM ranked
ORDER BY revenue DESC;
