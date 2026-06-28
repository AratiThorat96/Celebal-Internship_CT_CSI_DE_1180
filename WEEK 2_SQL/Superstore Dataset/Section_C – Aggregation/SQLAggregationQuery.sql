-- ============================================================
--  SECTION C : Aggregation Queries
--  Database  : Celebal_Week2
--  Table     : dbo.Superstore
--  Tool      : SQL Server Management Studio (SSMS)
--  Author    : ARATI THORAT |  Celebal Internship – Week 2
-- ============================================================

USE Celebal_Week2;
GO

-- ────────────────────────────────────────────────────────────
-- C1. Overall Business Summary
--     PURPOSE : Get a single-row KPI snapshot of the entire store
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(*)                      AS Total_Transactions,
    COUNT(DISTINCT Order_ID)      AS Total_Orders,
    COUNT(DISTINCT Customer_ID)   AS Total_Customers,
    COUNT(DISTINCT Product_ID)    AS Total_Products,
    ROUND(SUM(Sales),    2)       AS Total_Revenue,
    ROUND(SUM(Profit),   2)       AS Total_Profit,
    SUM(Quantity)                 AS Total_Units_Sold,
    ROUND(AVG(Sales),    2)       AS Avg_Sale_Per_Transaction,
    ROUND(AVG(Profit),   2)       AS Avg_Profit_Per_Transaction,
    ROUND(MIN(Sales),    2)       AS Min_Sale,
    ROUND(MAX(Sales),    2)       AS Max_Sale
FROM dbo.Superstore;

/*
   OBSERVATION:
   Total Revenue  ≈ $2.30 Million
   Total Profit   ≈ $286,000
   Overall profit margin ≈ 12.5%
   9,994 transactions across 5,009 unique orders
   Average sale per transaction ≈ $230
*/


-- ────────────────────────────────────────────────────────────
-- C2. Sales and Profit by Category
--     PURPOSE : Compare revenue and profitability by product line
-- ────────────────────────────────────────────────────────────
SELECT
    Category,
    COUNT(*)                     AS Total_Transactions,
    SUM(Quantity)                AS Units_Sold,
    ROUND(SUM(Sales),    2)      AS Total_Sales,
    ROUND(SUM(Profit),   2)      AS Total_Profit,
    ROUND(AVG(Sales),    2)      AS Avg_Sale,
    ROUND(AVG(Profit),   2)      AS Avg_Profit,
    ROUND(MAX(Sales),    2)      AS Max_Sale,
    ROUND(MIN(Sales),    2)      AS Min_Sale
FROM   dbo.Superstore
GROUP BY Category
ORDER BY Total_Sales DESC;

/*
   OBSERVATION:
   1. Technology   → Highest revenue AND highest profit
   2. Furniture    → High revenue but LOW profit (losses on Tables)
   3. Office Supp. → Most transactions, moderate profit
   KEY INSIGHT: Furniture's high revenue doesn't translate to profit
   due to excessive discounting on Tables and Bookcases.
*/


-- ────────────────────────────────────────────────────────────
-- C3. Sales and Profit by Sub-Category
--     PURPOSE : Identify best and worst performing sub-categories
-- ────────────────────────────────────────────────────────────
SELECT
    Category,
    Sub_Category,
    COUNT(*)                     AS Transactions,
    ROUND(SUM(Sales),    2)      AS Total_Sales,
    ROUND(SUM(Profit),   2)      AS Total_Profit,
    ROUND(AVG(Discount), 4)      AS Avg_Discount,
    ROUND(SUM(Profit) * 100.0
          / NULLIF(SUM(Sales),0), 2) AS Profit_Margin_Pct
FROM   dbo.Superstore
GROUP BY Category, Sub_Category
ORDER BY Total_Profit DESC;

/*
   OBSERVATION:
   TOP PROFIT: Copiers, Phones, Accessories, Paper
   LOSS-MAKING: Tables (-$17,725), Bookcases (-$3,473), Supplies (-$1,189)
   Tables have an average discount > 40% → direct cause of losses.
   Copiers have the highest profit margin at ~37%.
*/


-- ────────────────────────────────────────────────────────────
-- C4. Sales and Profit by Region
--     PURPOSE : Identify strongest and weakest geographic markets
-- ────────────────────────────────────────────────────────────
SELECT
    Region,
    COUNT(DISTINCT Order_ID)     AS Total_Orders,
    COUNT(DISTINCT Customer_ID)  AS Total_Customers,
    ROUND(SUM(Sales),  2)        AS Total_Sales,
    ROUND(SUM(Profit), 2)        AS Total_Profit,
    ROUND(AVG(Sales),  2)        AS Avg_Order_Sale,
    ROUND(SUM(Profit) * 100.0
          / NULLIF(SUM(Sales),0), 2) AS Profit_Margin_Pct
FROM   dbo.Superstore
GROUP BY Region
ORDER BY Total_Sales DESC;

/*
   OBSERVATION:
   1. West    → Highest sales ($725K) and profit ($108K)
   2. East    → Second in sales and profit
   3. Central → Lowest profit despite moderate sales (margin only ~7%)
   4. South   → Lowest sales volume
   Central region underperforms on profit — likely over-discounting.
*/


-- ────────────────────────────────────────────────────────────
-- C5. Sales and Profit by Customer Segment
--     PURPOSE : Understand which segment drives the business
-- ────────────────────────────────────────────────────────────
SELECT
    Segment,
    COUNT(DISTINCT Customer_ID)  AS Total_Customers,
    COUNT(DISTINCT Order_ID)     AS Total_Orders,
    ROUND(SUM(Sales),    2)      AS Total_Sales,
    ROUND(SUM(Profit),   2)      AS Total_Profit,
    ROUND(AVG(Sales),    2)      AS Avg_Sale_Per_Transaction,
    ROUND(SUM(Profit) * 100.0
          / NULLIF(SUM(Sales),0), 2) AS Profit_Margin_Pct
FROM   dbo.Superstore
GROUP BY Segment
ORDER BY Total_Sales DESC;

/*
   OBSERVATION:
   Consumer  → 52% of total revenue (largest segment)
   Corporate → Higher average order value, better margins
   Home Office → Fewest customers but decent profit margin
   RECOMMENDATION: Focus retention efforts on Corporate segment
   as they generate the best profit per order.
*/


-- ────────────────────────────────────────────────────────────
-- C6. Monthly Sales Trend (use case: monthly trends)
--     PURPOSE : Identify seasonal patterns in sales
-- ────────────────────────────────────────────────────────────
SELECT
    YEAR(Order_Date)                  AS Order_Year,
    MONTH(Order_Date)                 AS Order_Month,
    DATENAME(MONTH, Order_Date)       AS Month_Name,
    COUNT(DISTINCT Order_ID)          AS Total_Orders,
    ROUND(SUM(Sales),  2)             AS Monthly_Sales,
    ROUND(SUM(Profit), 2)             AS Monthly_Profit,
    ROUND(AVG(Sales),  2)             AS Avg_Sale
FROM   dbo.Superstore
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)
ORDER BY Order_Year, Order_Month;

/*
   OBSERVATION:
   Clear seasonality pattern:
   → Q4 (Oct, Nov, Dec) is consistently the highest-sales period
   → Q1 (Jan, Feb) is the slowest period each year
   → November and December spike due to holiday purchasing
   This is valuable for inventory and staffing planning.
*/


-- ────────────────────────────────────────────────────────────
-- C7. Yearly Sales Summary
--     PURPOSE : Track year-over-year business growth
-- ────────────────────────────────────────────────────────────
SELECT
    YEAR(Order_Date)              AS Order_Year,
    COUNT(DISTINCT Order_ID)      AS Total_Orders,
    COUNT(DISTINCT Customer_ID)   AS Total_Customers,
    ROUND(SUM(Sales),  2)         AS Annual_Sales,
    ROUND(SUM(Profit), 2)         AS Annual_Profit,
    ROUND(AVG(Sales),  2)         AS Avg_Sale
FROM   dbo.Superstore
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year;

/*
   OBSERVATION:
   Sales grew consistently from 2014 to 2017.
   2017 shows the highest revenue (~$733K in available months).
   Customer base also grew year-over-year, confirming business expansion.
*/


-- ────────────────────────────────────────────────────────────
-- C8. Top 10 Best-Selling Products (by Revenue)
--     PURPOSE : Identify hero products that drive revenue
-- ────────────────────────────────────────────────────────────
SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    COUNT(*)                  AS Times_Ordered,
    SUM(Quantity)             AS Total_Units_Sold,
    ROUND(SUM(Sales),  2)     AS Total_Revenue,
    ROUND(SUM(Profit), 2)     AS Total_Profit
FROM   dbo.Superstore
GROUP BY Product_ID, Product_Name, Category, Sub_Category
ORDER BY Total_Revenue DESC;

/*
   OBSERVATION:
   Top revenue products are Copiers and Phones (Technology).
   Canon imageCLASS Copier alone generates significant revenue.
   These high-ticket items drive disproportionate profit.
*/


-- ────────────────────────────────────────────────────────────
-- C9. Top 10 Customers by Total Purchase Value
--     PURPOSE : Identify VIP customers for retention strategy
-- ────────────────────────────────────────────────────────────
SELECT TOP 10
    Customer_ID,
    Customer_Name,
    Segment,
    Region,
    COUNT(DISTINCT Order_ID)  AS Total_Orders,
    SUM(Quantity)             AS Total_Units_Bought,
    ROUND(SUM(Sales),  2)     AS Total_Spent,
    ROUND(SUM(Profit), 2)     AS Total_Profit_Generated
FROM   dbo.Superstore
GROUP BY Customer_ID, Customer_Name, Segment, Region
ORDER BY Total_Spent DESC;

/*
   OBSERVATION:
   Top customers are mostly in Consumer and Corporate segments.
   Some top-spending customers actually generate negative profit
   due to excessive discounts — needs review.
*/


-- ────────────────────────────────────────────────────────────
-- C10. Ship Mode Analysis
--      PURPOSE : Understand shipping preferences and their timing
-- ────────────────────────────────────────────────────────────
SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID)                          AS Total_Orders,
    ROUND(SUM(Sales),  2)                             AS Total_Sales,
    ROUND(AVG(Sales),  2)                             AS Avg_Sale,
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date))         AS Avg_Ship_Days,
    MIN(DATEDIFF(DAY, Order_Date, Ship_Date))         AS Min_Ship_Days,
    MAX(DATEDIFF(DAY, Order_Date, Ship_Date))         AS Max_Ship_Days
FROM   dbo.Superstore
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;

/*
   OBSERVATION:
   Standard Class → 60%+ of all orders, ships in 4–5 days average
   Second Class   → ~20% of orders, ships in 3–4 days
   First Class    → ~15% of orders, ships in 2 days
   Same Day       → <5% of orders, ships in 0 days
   Premium shipping modes are used less often but carry higher-value orders.
*/


-- ────────────────────────────────────────────────────────────
-- C11. State-Level Performance (Top 15 States)
--      PURPOSE : Geographic performance deep-dive
-- ────────────────────────────────────────────────────────────
SELECT TOP 15
    State,
    Region,
    COUNT(DISTINCT Order_ID)  AS Total_Orders,
    ROUND(SUM(Sales),  2)     AS Total_Sales,
    ROUND(SUM(Profit), 2)     AS Total_Profit,
    ROUND(SUM(Profit) * 100.0
          / NULLIF(SUM(Sales),0), 2) AS Profit_Margin_Pct
FROM   dbo.Superstore
GROUP BY State, Region
ORDER BY Total_Sales DESC;

/*
   OBSERVATION:
   California → Highest sales state (~$457K)
   New York   → Second highest
   Texas      → High sales but NEGATIVE total profit (-$25K)
   Ohio       → Also shows loss despite decent sales volume
   Texas and Ohio are key states to investigate for margin improvement.
*/


-- ────────────────────────────────────────────────────────────
-- C12. Average Discount by Sub-Category
--      PURPOSE : Identify where the company over-discounts
-- ────────────────────────────────────────────────────────────
SELECT
    Sub_Category,
    ROUND(AVG(Discount),   4)  AS Avg_Discount,
    ROUND(SUM(Sales),      2)  AS Total_Sales,
    ROUND(SUM(Profit),     2)  AS Total_Profit,
    COUNT(*)                   AS Transactions
FROM   dbo.Superstore
GROUP BY Sub_Category
ORDER BY Avg_Discount DESC;

/*
   OBSERVATION:
   Binders, Tables, and Bookcases have the highest average discounts.
   All three are associated with losses or thin profit margins.
   INSIGHT: There is a direct correlation between high discount rates
   and negative profitability in this dataset.
*/