-- ============================================================
--  SECTION B : Filtering Queries
--  Database  : Celebal_Week2
--  Table     : dbo.Superstore
--  Tool      : SQL Server Management Studio (SSMS)
--  Author    : ARATI THORAT |  Celebal Internship – Week 2
-- ============================================================

USE Celebal_Week2;
GO

-- ────────────────────────────────────────────────────────────
-- B1. Filter by Region
--     PURPOSE : Isolate sales from a specific geography
-- ────────────────────────────────────────────────────────────

-- All orders from the West region
SELECT
    Order_ID, Customer_Name, City, State,
    Sales, Profit
FROM   dbo.Superstore
WHERE  Region = 'West'
ORDER BY Sales DESC;

-- Orders from East OR Central
SELECT
    Order_ID, Customer_Name, Region,
    Sales, Profit
FROM   dbo.Superstore
WHERE  Region IN ('East', 'Central')
ORDER BY Region, Sales DESC;

/*
   OBSERVATION:
   West region has the highest number of orders among all regions.
   California dominates the West with the most transactions.
*/


-- ────────────────────────────────────────────────────────────
-- B2. Filter by Product Category
--     PURPOSE : Drill into category-specific performance
-- ────────────────────────────────────────────────────────────

-- Technology products only
SELECT
    Product_ID, Product_Name, Sub_Category,
    Sales, Profit, Quantity
FROM   dbo.Superstore
WHERE  Category = 'Technology'
ORDER BY Sales DESC;

-- Office Supplies in a specific sub-category
SELECT
    Product_Name, Sub_Category,
    Sales, Profit, Discount
FROM   dbo.Superstore
WHERE  Category     = 'Office Supplies'
AND    Sub_Category = 'Binders'
ORDER BY Sales DESC;

/*
   OBSERVATION:
   Technology has the highest individual sales values (Phones, Copiers).
   Binders are the most ordered sub-category by volume.
*/


-- ────────────────────────────────────────────────────────────
-- B3. Filter by Date Range
--     PURPOSE : Analyse sales within specific time windows
-- ────────────────────────────────────────────────────────────

-- Orders placed in the year 2017
SELECT
    Order_ID, Order_Date, Ship_Date,
    Customer_Name, Sales, Profit
FROM   dbo.Superstore
WHERE  Order_Date BETWEEN '2017-01-01' AND '2017-12-31'
ORDER BY Order_Date;

-- Q1 2017 orders (January to March)
SELECT
    Order_ID, Order_Date,
    Customer_Name, Region, Sales
FROM   dbo.Superstore
WHERE  Order_Date BETWEEN '2017-01-01' AND '2017-03-31'
ORDER BY Order_Date;

-- Orders shipped using Standard Class in 2016
SELECT
    Order_ID, Order_Date, Ship_Date,
    Ship_Mode, Customer_Name, Sales
FROM   dbo.Superstore
WHERE  Ship_Mode   = 'Standard Class'
AND    Order_Date BETWEEN '2016-01-01' AND '2016-12-31'
ORDER BY Order_Date;

/*
   OBSERVATION:
   The dataset spans 2014–2017. Year-over-year queries show
   steady sales growth. Q4 (Oct–Dec) consistently shows
   the highest sales volume across all years.
*/


-- ────────────────────────────────────────────────────────────
-- B4. Filter by Sales Amount
--     PURPOSE : Identify high-value and low-value transactions
-- ────────────────────────────────────────────────────────────

-- High-value orders (Sales > $1,000)
SELECT
    Order_ID, Customer_Name, Product_Name,
    Category, Sales, Profit
FROM   dbo.Superstore
WHERE  Sales > 1000
ORDER BY Sales DESC;

-- Orders with Sales between $500 and $1,000
SELECT
    Order_ID, Customer_Name, Sales, Profit
FROM   dbo.Superstore
WHERE  Sales BETWEEN 500 AND 1000
ORDER BY Sales DESC;

-- Very small orders (Sales < $10)
SELECT TOP 20
    Order_ID, Customer_Name, Product_Name,
    Sales, Quantity, Discount
FROM   dbo.Superstore
WHERE  Sales < 10
ORDER BY Sales ASC;

/*
   OBSERVATION:
   Orders above $1,000 are dominated by Technology (Copiers, Phones).
   Very small orders (< $10) often have high discounts applied,
   which erodes profit significantly.
*/


-- ────────────────────────────────────────────────────────────
-- B5. Filter by Discount applied
--     PURPOSE : Understand impact of discounting strategy
-- ────────────────────────────────────────────────────────────

-- Items with NO discount
SELECT
    Order_ID, Product_Name, Category,
    Sales, Discount, Profit
FROM   dbo.Superstore
WHERE  Discount = 0
ORDER BY Sales DESC;

-- Heavily discounted items (Discount > 30%)
SELECT
    Order_ID, Product_Name, Category,
    Sales, Discount, Profit
FROM   dbo.Superstore
WHERE  Discount > 0.30
ORDER BY Discount DESC;

/*
   OBSERVATION:
   Items with 0% discount are generally more profitable.
   Items with discount > 30% often show NEGATIVE profit —
   indicating over-discounting is hurting the business.
*/


-- ────────────────────────────────────────────────────────────
-- B6. Filter Loss-Making Orders (Profit < 0)
--     PURPOSE : Identify orders that lost money
-- ────────────────────────────────────────────────────────────
SELECT
    Order_ID, Customer_Name, Product_Name,
    Category, Sub_Category,
    Sales, Discount, Profit
FROM   dbo.Superstore
WHERE  Profit < 0
ORDER BY Profit ASC;

/*
   OBSERVATION:
   There are ~1,871 loss-making line items (about 18.7% of all rows).
   Most losses are in Furniture (Tables) and Office Supplies
   categories where discounts exceed 40%.
*/


-- ────────────────────────────────────────────────────────────
-- B7. Filter using LIKE (pattern matching)
--     PURPOSE : Search for products/customers by partial name
-- ────────────────────────────────────────────────────────────

-- Products containing the word 'Table'
SELECT
    Product_ID, Product_Name, Category, Sub_Category,
    Sales, Profit
FROM   dbo.Superstore
WHERE  Product_Name LIKE '%Table%';

-- Customers whose name starts with 'A'
SELECT DISTINCT
    Customer_ID, Customer_Name, Segment, Region
FROM   dbo.Superstore
WHERE  Customer_Name LIKE 'A%'
ORDER BY Customer_Name;

-- Orders starting with CA- (California convention)
SELECT TOP 10
    Order_ID, Order_Date, Customer_Name, State
FROM   dbo.Superstore
WHERE  Order_ID LIKE 'CA-%'
ORDER BY Order_Date DESC;

/*
   OBSERVATION:
   LIKE is powerful for exploring semi-structured data.
   'Table' products (Furniture) consistently show negative profit —
   a critical business finding.
*/


-- ────────────────────────────────────────────────────────────
-- B8. Filter by Segment
--     PURPOSE : Compare performance across customer types
-- ────────────────────────────────────────────────────────────

-- Corporate segment customers only
SELECT DISTINCT
    Customer_ID, Customer_Name, City, State, Region
FROM   dbo.Superstore
WHERE  Segment = 'Corporate'
ORDER BY Customer_Name;

-- Home Office customers in the South region
SELECT DISTINCT
    Customer_ID, Customer_Name, City, State
FROM   dbo.Superstore
WHERE  Segment = 'Home Office'
AND    Region  = 'South'
ORDER BY State;

/*
   OBSERVATION:
   Corporate segment places fewer but larger individual orders.
   Home Office customers are concentrated in the South and West.
*/


-- ────────────────────────────────────────────────────────────
-- B9. Filter using NOT and NOT IN
--     PURPOSE : Exclude specific groups from analysis
-- ────────────────────────────────────────────────────────────

-- Orders NOT shipped via Standard Class
SELECT
    Order_ID, Order_Date, Ship_Mode,
    Customer_Name, Sales
FROM   dbo.Superstore
WHERE  Ship_Mode <> 'Standard Class'
ORDER BY Ship_Mode, Sales DESC;

-- Products NOT in Furniture category
SELECT
    Product_ID, Product_Name, Category
FROM   dbo.Superstore
WHERE  Category NOT IN ('Furniture')
ORDER BY Category, Product_Name;

/*
   OBSERVATION:
   Non-Standard Class shipping (First Class, Same Day) represents
   premium shipping and is used more often by Corporate customers.
*/


-- ────────────────────────────────────────────────────────────
-- B10. Combined AND / OR filter
--      PURPOSE : Apply multiple business conditions simultaneously
-- ────────────────────────────────────────────────────────────

-- High-sales OR high-discount transactions
SELECT
    Order_ID, Customer_Name, Category,
    Sales, Discount, Profit
FROM   dbo.Superstore
WHERE  Sales > 500
OR     Discount > 0.30
ORDER BY Sales DESC;

-- High-value AND profitable orders
SELECT
    Order_ID, Customer_Name,
    Product_Name, Sales, Profit
FROM   dbo.Superstore
WHERE  Sales  > 500
AND    Profit > 100
ORDER BY Profit DESC;

-- Corporate segment AND Technology category
SELECT
    Order_ID, Customer_Name,
    Product_Name, Sales, Profit
FROM   dbo.Superstore
WHERE  Segment  = 'Corporate'
AND    Category = 'Technology'
ORDER BY Sales DESC;

/*
   OBSERVATION:
   Corporate + Technology is the most profitable combination —
   high sales, low discount, strong profit margin.
   High discount + high sales → often still ends in loss.
*/


-- ────────────────────────────────────────────────────────────
-- B11. TOP N results (Limit output)
--      PURPOSE : Get best/worst performers quickly
-- ────────────────────────────────────────────────────────────

-- Top 10 highest sales transactions
SELECT TOP 10
    Order_ID, Customer_Name, Product_Name,
    Category, Sales, Profit
FROM   dbo.Superstore
ORDER BY Sales DESC;

-- Top 10 worst profit (biggest losses)
SELECT TOP 10
    Order_ID, Customer_Name, Product_Name,
    Category, Sales, Discount, Profit
FROM   dbo.Superstore
ORDER BY Profit ASC;

-- Top 10 most discounted items
SELECT TOP 10
    Order_ID, Product_Name, Category,
    Sales, Discount, Profit
FROM   dbo.Superstore
ORDER BY Discount DESC;

/*
   OBSERVATION:
   Top 10 highest sales are all Technology (Copiers, Phones, Machines).
   Top 10 worst losses include Tables and Bookcases with 40–80% discounts.
   Heavy discounting is the #1 driver of losses in this dataset.
*/