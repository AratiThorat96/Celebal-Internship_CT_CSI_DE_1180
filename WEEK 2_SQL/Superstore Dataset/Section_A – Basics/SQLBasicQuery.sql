-- ============================================================
--  SECTION A : Basic Queries
--  Database  : Celebal_Week2
--  Table     : dbo.Superstore
--  Tool      : SQL Server Management Studio (SSMS)
--  Author    : ARATI THORAT  |  Celebal Internship – Week 2
-- ============================================================

USE Celebal_Week2;
GO

-- ────────────────────────────────────────────────────────────
-- A1. View ALL columns from the Superstore table
--     PURPOSE : Get a full picture of the raw dataset
-- ────────────────────────────────────────────────────────────
SELECT *
FROM   dbo.Superstore;

/*
   OBSERVATION:
   The table contains 9,994 rows and 21 columns covering
   order details, customer info, product info, and financials.
   All data is in a single flat/denormalised table.
*/


-- ────────────────────────────────────────────────────────────
-- A2. View only important columns (selective projection)
--     PURPOSE : Reduce noise, focus on key fields
-- ────────────────────────────────────────────────────────────
SELECT
    Row_ID,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_Name,
    Segment,
    Region,
    Category,
    Sub_Category,
    Product_Name,
    Sales,
    Quantity,
    Discount,
    Profit
FROM dbo.Superstore;

/*
   OBSERVATION:
   Projecting only the business-relevant columns makes the
   result easier to read and speeds up query execution.
*/


-- ────────────────────────────────────────────────────────────
-- A3. Total row count
--     PURPOSE : Confirm data load was complete
-- ────────────────────────────────────────────────────────────
SELECT COUNT(*) AS Total_Records
FROM   dbo.Superstore;

/*
   OBSERVATION:
   Expected result → 9,994 rows.
   If any number other than 9,994 appears, the CSV import
   may have been incomplete and needs to be re-imported.
*/


-- ────────────────────────────────────────────────────────────
-- A4. Inspect column names and data types from schema
--     PURPOSE : Understand the table structure before querying
-- ────────────────────────────────────────────────────────────
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME   = 'Superstore'
AND    TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;

/*
   OBSERVATION:
   Key columns and their expected types:
     Order_Date  → date / varchar  (check if parsed correctly)
     Sales       → float / decimal
     Profit      → float / decimal
     Quantity    → int
     Discount    → float
   If dates are stored as VARCHAR instead of DATE,
   conversion functions (CONVERT / TRY_CONVERT) must be used.
*/


-- ────────────────────────────────────────────────────────────
-- A5. DISTINCT values in categorical columns
--     PURPOSE : Understand the domain of key dimensions
-- ────────────────────────────────────────────────────────────

-- Unique customer segments
SELECT DISTINCT Segment  FROM dbo.Superstore;

-- Unique regions
SELECT DISTINCT Region   FROM dbo.Superstore;

-- Unique ship modes
SELECT DISTINCT Ship_Mode FROM dbo.Superstore;

-- Unique product categories
SELECT DISTINCT Category FROM dbo.Superstore;

-- Unique sub-categories
SELECT DISTINCT Sub_Category
FROM   dbo.Superstore
ORDER BY Sub_Category;

-- Unique countries
SELECT DISTINCT Country  FROM dbo.Superstore;

/*
   OBSERVATION:
   Segments   : Consumer, Corporate, Home Office
   Regions    : East, West, Central, South
   Ship Modes : Standard Class, Second Class, First Class, Same Day
   Categories : Furniture, Office Supplies, Technology
   Sub-Cats   : 17 unique sub-categories
   Country    : United States only (domestic dataset)
*/


-- ────────────────────────────────────────────────────────────
-- A6. First 10 rows (quick data preview)
--     PURPOSE : Sanity-check the data after import
-- ────────────────────────────────────────────────────────────
SELECT TOP 10 *
FROM   dbo.Superstore;

/*
   OBSERVATION:
   The first 10 rows give a quick look at data formatting.
   Check that dates, decimals, and text fields look correct.
*/


-- ────────────────────────────────────────────────────────────
-- A7. Date range of orders
--     PURPOSE : Understand the time span of the dataset
-- ────────────────────────────────────────────────────────────
SELECT
    MIN(Order_Date) AS Earliest_Order,
    MAX(Order_Date) AS Latest_Order
FROM dbo.Superstore;

/*
   OBSERVATION:
   Dataset spans from 2014 to 2017 (4 years of sales data).
   This enables multi-year trend analysis.
*/


-- ────────────────────────────────────────────────────────────
-- A8. Sales and Profit range
--     PURPOSE : Understand the financial spread of the data
-- ────────────────────────────────────────────────────────────
SELECT
    ROUND(MIN(Sales),   2) AS Min_Sale,
    ROUND(MAX(Sales),   2) AS Max_Sale,
    ROUND(AVG(Sales),   2) AS Avg_Sale,
    ROUND(MIN(Profit),  2) AS Min_Profit,
    ROUND(MAX(Profit),  2) AS Max_Profit,
    ROUND(AVG(Profit),  2) AS Avg_Profit
FROM dbo.Superstore;

/*
   OBSERVATION:
   - Min Sale ≈ $0.44   |  Max Sale ≈ $22,638
   - Some Profit values are NEGATIVE → loss-making transactions exist.
   - The wide range suggests outlier orders worth investigating.
*/


-- ────────────────────────────────────────────────────────────
-- A9. NULL / missing value check
--     PURPOSE : Identify data quality issues early
-- ────────────────────────────────────────────────────────────
SELECT
    SUM(CASE WHEN Row_ID        IS NULL THEN 1 ELSE 0 END) AS Null_RowID,
    SUM(CASE WHEN Order_ID      IS NULL THEN 1 ELSE 0 END) AS Null_OrderID,
    SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS Null_CustomerName,
    SUM(CASE WHEN Sales         IS NULL THEN 1 ELSE 0 END) AS Null_Sales,
    SUM(CASE WHEN Profit        IS NULL THEN 1 ELSE 0 END) AS Null_Profit,
    SUM(CASE WHEN Quantity      IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Discount      IS NULL THEN 1 ELSE 0 END) AS Null_Discount,
    SUM(CASE WHEN Region        IS NULL THEN 1 ELSE 0 END) AS Null_Region,
    SUM(CASE WHEN Category      IS NULL THEN 1 ELSE 0 END) AS Null_Category
FROM dbo.Superstore;

/*
   OBSERVATION:
   All critical columns should return 0 nulls.
   If any null count > 0, those records need cleaning
   before running aggregation queries.
*/


-- ────────────────────────────────────────────────────────────
-- A10. Duplicate Row_ID check
--      PURPOSE : Verify primary key uniqueness after import
-- ────────────────────────────────────────────────────────────
SELECT
    Row_ID,
    COUNT(*) AS Occurrence_Count
FROM   dbo.Superstore
GROUP BY Row_ID
HAVING COUNT(*) > 1;

/*
   OBSERVATION:
   An empty result = no duplicates = clean import.
   If duplicates exist, the CSV import included the header
   row twice or had repeated rows — needs cleaning.
*/


-- ────────────────────────────────────────────────────────────
-- A11. Count of unique customers, products, and orders
--      PURPOSE : Understand dataset cardinality
-- ────────────────────────────────────────────────────────────
SELECT
    COUNT(DISTINCT Customer_ID)  AS Unique_Customers,
    COUNT(DISTINCT Product_ID)   AS Unique_Products,
    COUNT(DISTINCT Order_ID)     AS Unique_Orders,
    COUNT(DISTINCT State)        AS Unique_States,
    COUNT(DISTINCT City)         AS Unique_Cities
FROM dbo.Superstore;

/*
   OBSERVATION:
   ~793 unique customers
   ~1,862 unique products
   ~5,009 unique orders
   49 states covered
   531 cities
*/