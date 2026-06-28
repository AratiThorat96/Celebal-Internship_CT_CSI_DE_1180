-- ============================================================
--  SECTION D : Joins Queries
--  Database  : Celebal_Week2
--  Table     : dbo.Superstore (single flat table — self-join
--              and derived-table joins used to simulate
--              multi-table relational analysis)
--  Tool      : SQL Server Management Studio (SSMS)
--  Author    : ARATI THORAT  |  Celebal Internship – Week 2
-- ============================================================

USE Celebal_Week2;
GO

-- NOTE ─────────────────────────────────────────────────────────
-- Since the Superstore CSV was imported as a single flat table,
-- we use SELF-JOINS and SUBQUERY-based derived tables to
-- demonstrate INNER JOIN and LEFT JOIN logic meaningfully.
-- This mirrors real-world scenarios where one large table
-- is compared against itself or against aggregated views.
-- ──────────────────────────────────────────────────────────────


-- ────────────────────────────────────────────────────────────
-- D1. INNER JOIN Simulation
--     PURPOSE : Join customer orders with their regional average
--               to compare individual orders vs regional baseline
-- ────────────────────────────────────────────────────────────
SELECT
    s.Order_ID,
    s.Customer_Name,
    s.Region,
    s.Category,
    s.Product_Name,
    ROUND(s.Sales,       2)  AS Order_Sales,
    ROUND(s.Profit,      2)  AS Order_Profit,
    ROUND(ra.Region_Avg, 2)  AS Regional_Avg_Sales,
    CASE
        WHEN s.Sales > ra.Region_Avg
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS Sales_vs_Region
FROM dbo.Superstore AS s
INNER JOIN (
    -- Derived table: average sales per region
    SELECT Region, AVG(Sales) AS Region_Avg
    FROM   dbo.Superstore
    GROUP BY Region
) AS ra ON s.Region = ra.Region
ORDER BY s.Region, s.Sales DESC;

/*
   OBSERVATION:
   West region has the highest regional average sale.
   Most high-value Technology orders are 'Above Average' within
   their region — confirming Tech is the growth driver everywhere.
*/


-- ────────────────────────────────────────────────────────────
-- D2. INNER JOIN – Order Detail with Category Average
--     PURPOSE : Find orders that exceed the category average sale
-- ────────────────────────────────────────────────────────────
SELECT
    s.Order_ID,
    s.Order_Date,
    s.Customer_Name,
    s.Category,
    s.Product_Name,
    ROUND(s.Sales,        2)  AS Order_Sales,
    ROUND(ca.Cat_Avg,     2)  AS Category_Avg_Sales,
    ROUND(s.Profit,       2)  AS Profit
FROM dbo.Superstore AS s
INNER JOIN (
    SELECT Category, AVG(Sales) AS Cat_Avg
    FROM   dbo.Superstore
    GROUP BY Category
) AS ca ON s.Category = ca.Category
WHERE s.Sales > ca.Cat_Avg
ORDER BY s.Category, s.Sales DESC;

/*
   OBSERVATION:
   Technology orders that exceed the category average are mostly
   Copiers and Phones — the two highest-ticket sub-categories.
   Furniture orders exceeding the category average are Bookcases
   and Tables, but many still have negative profit.
*/


-- ────────────────────────────────────────────────────────────
-- D3. INNER JOIN – Customer's Orders vs Their Own Average
--     PURPOSE : Find customers with unusually large orders
-- ────────────────────────────────────────────────────────────
SELECT
    s.Order_ID,
    s.Order_Date,
    s.Customer_Name,
    s.Segment,
    s.Region,
    ROUND(s.Sales,          2)  AS Order_Sales,
    ROUND(cust.Cust_Avg,    2)  AS Customer_Avg_Sales
FROM dbo.Superstore AS s
INNER JOIN (
    SELECT Customer_ID, AVG(Sales) AS Cust_Avg
    FROM   dbo.Superstore
    GROUP BY Customer_ID
) AS cust ON s.Customer_ID = cust.Customer_ID
WHERE s.Sales > cust.Cust_Avg * 2   -- orders 2× the customer's own average
ORDER BY s.Sales DESC;

/*
   OBSERVATION:
   These are "spike" orders — unusual one-time large purchases.
   Useful for detecting bulk B2B orders or anomalous transactions.
*/


-- ────────────────────────────────────────────────────────────
-- D4. INNER JOIN – Region × Sub-Category Performance Matrix
--     PURPOSE : Cross-dimensional analysis of region and product
-- ────────────────────────────────────────────────────────────
SELECT
    s.Region,
    s.Sub_Category,
    rs.Total_Region_Sales,
    ROUND(SUM(s.Sales),  2)              AS SubCat_Sales_In_Region,
    ROUND(SUM(s.Profit), 2)              AS SubCat_Profit_In_Region,
    ROUND(SUM(s.Sales) * 100.0
          / NULLIF(rs.Total_Region_Sales, 0), 2) AS Pct_Of_Region_Sales
FROM dbo.Superstore AS s
INNER JOIN (
    SELECT Region, SUM(Sales) AS Total_Region_Sales
    FROM   dbo.Superstore
    GROUP BY Region
) AS rs ON s.Region = rs.Region
GROUP BY s.Region, s.Sub_Category, rs.Total_Region_Sales
ORDER BY s.Region, SubCat_Sales_In_Region DESC;

/*
   OBSERVATION:
   Phones and Chairs are top sub-categories in every region.
   Tables consistently underperform profit-wise across ALL regions.
   The Central region has the lowest % contribution from
   high-margin Technology sub-categories.
*/


-- ────────────────────────────────────────────────────────────
-- D5. LEFT JOIN Simulation – Customers with Below-Average Profit
--     PURPOSE : Find customers contributing less than average
-- ────────────────────────────────────────────────────────────

-- Step 1: Identify all customers and their total profit
-- Step 2: LEFT JOIN to overall average to flag underperformers

SELECT
    cust.Customer_ID,
    cust.Customer_Name,
    cust.Segment,
    cust.Region,
    ROUND(cust.Total_Sales,  2)  AS Total_Sales,
    ROUND(cust.Total_Profit, 2)  AS Total_Profit,
    ROUND(avg_profit.Avg_Profit, 2) AS Company_Avg_Profit,
    CASE
        WHEN cust.Total_Profit < 0
        THEN 'Loss-Generating Customer'
        WHEN cust.Total_Profit < avg_profit.Avg_Profit
        THEN 'Below Average Profit'
        ELSE 'Above Average Profit'
    END AS Customer_Profit_Status
FROM (
    SELECT Customer_ID, Customer_Name, Segment, Region,
           SUM(Sales)  AS Total_Sales,
           SUM(Profit) AS Total_Profit
    FROM   dbo.Superstore
    GROUP BY Customer_ID, Customer_Name, Segment, Region
) AS cust
LEFT JOIN (
    SELECT AVG(cust_inner.Total_Profit) AS Avg_Profit
    FROM (
        SELECT Customer_ID, SUM(Profit) AS Total_Profit
        FROM   dbo.Superstore
        GROUP BY Customer_ID
    ) AS cust_inner
) AS avg_profit ON 1 = 1
ORDER BY cust.Total_Profit ASC;

/*
   OBSERVATION:
   Some customers have placed many orders yet generate NET LOSSES.
   These are often customers who consistently request high discounts.
   LEFT JOIN ensures ALL customers appear even if they don't match
   a filter — important for complete auditing.
*/


-- ────────────────────────────────────────────────────────────
-- D6. INNER JOIN – Year-over-Year Order Comparison (Self-Join)
--     PURPOSE : Compare a customer's orders across two years
-- ────────────────────────────────────────────────────────────
SELECT
    y1.Customer_Name,
    y1.Segment,
    ROUND(y1.Sales_2016, 2)   AS Sales_2016,
    ROUND(y2.Sales_2017, 2)   AS Sales_2017,
    ROUND(y2.Sales_2017 - y1.Sales_2016, 2) AS YoY_Growth
FROM (
    SELECT Customer_ID, Customer_Name, Segment, SUM(Sales) AS Sales_2016
    FROM   dbo.Superstore
    WHERE  YEAR(Order_Date) = 2016
    GROUP BY Customer_ID, Customer_Name, Segment
) AS y1
INNER JOIN (
    SELECT Customer_ID, SUM(Sales) AS Sales_2017
    FROM   dbo.Superstore
    WHERE  YEAR(Order_Date) = 2017
    GROUP BY Customer_ID
) AS y2 ON y1.Customer_ID = y2.Customer_ID
ORDER BY YoY_Growth DESC;

/*
   OBSERVATION:
   INNER JOIN here returns only customers who placed orders in
   BOTH 2016 AND 2017 — i.e., returning customers.
   Customers showing positive YoY growth are loyal, growing accounts.
   Customers with negative growth might be churning.
*/


-- ────────────────────────────────────────────────────────────
-- D7. LEFT JOIN – Customers who ordered in 2016 but NOT 2017
--     PURPOSE : Identify churned customers
-- ────────────────────────────────────────────────────────────
SELECT
    prev.Customer_ID,
    prev.Customer_Name,
    prev.Segment,
    ROUND(prev.Sales_2016, 2) AS Sales_2016,
    curr.Sales_2017
FROM (
    SELECT Customer_ID, Customer_Name, Segment, SUM(Sales) AS Sales_2016
    FROM   dbo.Superstore
    WHERE  YEAR(Order_Date) = 2016
    GROUP BY Customer_ID, Customer_Name, Segment
) AS prev
LEFT JOIN (
    SELECT Customer_ID, SUM(Sales) AS Sales_2017
    FROM   dbo.Superstore
    WHERE  YEAR(Order_Date) = 2017
    GROUP BY Customer_ID
) AS curr ON prev.Customer_ID = curr.Customer_ID
WHERE curr.Customer_ID IS NULL   -- ordered in 2016 but NOT in 2017
ORDER BY prev.Sales_2016 DESC;

/*
   OBSERVATION:
   LEFT JOIN is key here — it keeps ALL 2016 customers and
   identifies those with NO matching 2017 orders (NULL values).
   These are potentially churned customers and prime targets
   for re-engagement campaigns.
   Some high-value 2016 customers are not seen in 2017 —
   a significant revenue risk.
*/


-- ────────────────────────────────────────────────────────────
-- D8. INNER JOIN – Segment × Region cross analysis
--     PURPOSE : Full cross-dimensional business intelligence view
-- ────────────────────────────────────────────────────────────
SELECT
    s.Segment,
    s.Region,
    ROUND(SUM(s.Sales),  2)                  AS Total_Sales,
    ROUND(SUM(s.Profit), 2)                  AS Total_Profit,
    COUNT(DISTINCT s.Order_ID)               AS Total_Orders,
    ROUND(SUM(s.Sales) / COUNT(DISTINCT s.Order_ID), 2) AS Avg_Order_Value,
    ROUND(SUM(s.Profit) * 100.0
          / NULLIF(SUM(s.Sales), 0), 2)      AS Profit_Margin_Pct
FROM dbo.Superstore AS s
INNER JOIN (
    SELECT DISTINCT Segment, Region
    FROM   dbo.Superstore
) AS seg_reg ON s.Segment = seg_reg.Segment
           AND  s.Region  = seg_reg.Region
GROUP BY s.Segment, s.Region
ORDER BY s.Segment, Total_Sales DESC;

/*
   OBSERVATION:
   Best combination  : Corporate + West → highest profit margin
   Worst combination : Consumer + Central → negative margins possible
   Home Office + East shows surprisingly strong average order values.
*/