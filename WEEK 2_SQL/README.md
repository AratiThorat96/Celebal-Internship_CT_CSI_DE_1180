#SQL-Based Data Analysis

## Week 2 Assignment – Celebal Technologies Data Engineering Internship

**SQL-Based Data Analysis Using Filtering, Aggregation, Joins & Advanced Concepts**

---

## 📁 Repository Folder Structure

```
WEEK2_CT_CSI_DE_1180/
│
├── E-Commerce Database/
│   ├── SQLQuery_E-Commerce.sql          ← All 27 queries (Sections A–E)
│   ├── SQLQuery_E-Commerce.pdf          ← SQL file exported as PDF
│   └── Queries_Result.pdf               ← Screenshots of all query results from SSMS
│
└── Superstore Dataset/
    ├── Superstore.csv                   ← Raw dataset (sourced from Kaggle)
    │
    ├── Section_A – Basics/
    │   ├── SQLBasicQuery.sql
    │   ├── SQLBasicQuery.pdf
    │   └── SECTION_A_Basic_Queries_ResultScreenshots.pdf
    │
    ├── Section_B – Filtering/
    │   ├── SQLFilteringQuery.sql
    │   ├── SQLFilteringQuery.pdf
    │   └── SECTION_B_Filtering_QResultScreenshots.pdf
    │
    ├── Section_C – Aggregation/
    │   ├── SQLAggregationQuery.sql
    │   ├── SQLAggregationQuery.pdf
    │   └── SECTION_C_AggregationQ_ResultScreenS.pdf
    │
    ├── Section_D – Joins/
    │   ├── SQLJoinsQuery.sql
    │   ├── SQLJoinsQuery.pdf
    │   └── SECTION_D_JoinsQ_ResultScreenShot.pdf
    │
    └── Section_E – Advanced/
        ├── SQLAdvancedQuery.sql
        ├── SQLAdvancedQuery.pdf
        └── SECTION_D_JoinsQ_ResultScreenShot.pdf
```

---

## 🎯 Assignment Overview

This week's assignment is split into **two parts**:

### Part 1 — E-Commerce Sales Database (ShopEase)
A structured relational database was built from scratch in SSMS covering 4 tables: `customers`, `products`, `orders`, and `order_items`. All 27 questions across 5 sections (A–E) were answered using T-SQL.

### Part 2 — Superstore Dataset Analysis
The Kaggle Superstore CSV (9,994 rows, 21 columns) was imported into SQL Server and analysed section-by-section — from basic exploration to filtering, aggregation, joins, and advanced queries.

**Tool used throughout:** SQL Server Management Studio (SSMS)

---

## 🗂️ Part 1: E-Commerce Sales Database (ShopEase)

### Scenario
Working as a Junior Data Analyst at ShopEase, a mid-sized e-commerce company selling electronics, clothing, and home products across India. The goal was to write SQL queries to extract meaningful business insights from a relational database.

### Database Schema

**4 tables were created with proper constraints and indexes:**

```sql
-- customers: customer_id (PK), first_name, last_name, email (UNIQUE), city, state, join_date, is_premium
-- products:  product_id (PK), product_name, category, brand, unit_price (CHECK > 0), stock_qty
-- orders:    order_id (PK), customer_id (FK), order_date, status (CHECK IN allowed values), total_amount
-- order_items: item_id (PK), order_id (FK), product_id (FK), quantity, unit_price, discount_pct
```

**Entity Relationships:**
```
customers  ──(1:N)──▶  orders
orders     ──(1:N)──▶  order_items
products   ──(1:N)──▶  order_items
```

---

### Section A — SQL Basics (SELECT, Constraints, Primary Keys)

| Q# | Question | Key Concept |
|---|---|---|
| Q1 | Display all rows and columns from customers | SELECT * |
| Q2 | Retrieve first_name, last_name, city | Column projection |
| Q3 | List all unique product categories | DISTINCT |
| Q4 | Identify Primary Keys and explain UNIQUE + NOT NULL | PK theory |
| Q5 | Constraints on email column — duplicate insert test | UNIQUE constraint |
| Q6 | Insert product with unit_price = -50 and explain the error | CHECK constraint |

**Key Observations:**
- Q1 returned all 8 customer records; `SELECT *` is fine for exploration but column-specific queries are better for performance.
- Q3 returned 3 distinct categories: Electronics, Clothing, Home.
- Q5 demonstrated that SSMS throws a `Violation of UNIQUE KEY constraint` error when a duplicate email is inserted.
- Q6 confirmed the `CHECK (unit_price > 0)` constraint prevents negative prices at the database level — even if application code has a bug.

---

### Section B — Filtering & Optimization (WHERE, Indexes)

| Q# | Question | Key Concept |
|---|---|---|
| Q7 | All orders with status = 'Delivered' | WHERE filter |
| Q8 | Electronics products with unit_price > ₹2000 | AND condition |
| Q9 | Customers from Maharashtra who joined in 2024 | YEAR() + AND |
| Q10 | Orders between 08-10 and 08-25, not cancelled | BETWEEN + <> |
| Q11 | How does idx_orders_date improve performance? | Index theory |
| Q12 | Is YEAR(join_date) = 2024 index-friendly? Rewrite it | SARGability |

**Key Observations:**
- Q7: 6 out of 10 orders are Delivered. The `idx_orders_status` index enables an index seek rather than a full table scan.
- Q8: Smart Watch (₹2999) and Bluetooth Speaker (₹3499) qualify.
- Q10: Orders 1004, 1006, 1007, 1008, 1009 fall in range; cancelled order 1005 correctly excluded.
- Q12: `YEAR(join_date)` is **non-SARGable** — wrapping a column in a function prevents index usage. The SARGable rewrite uses `join_date >= '2024-01-01' AND join_date < '2025-01-01'`.

---

### Section C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX)

| Q# | Question | Key Concept |
|---|---|---|
| Q13 | Total number of orders | COUNT(*) |
| Q14 | Total revenue from Delivered orders | SUM + WHERE |
| Q15 | Average unit_price per category | AVG + GROUP BY |
| Q16 | Order count and revenue per status, sorted | GROUP BY + ORDER BY |
| Q17 | Most expensive and cheapest product per category | MAX + MIN |
| Q18 | Categories where avg price > ₹2000 | HAVING |

**Key Observations:**
- Q13: Total = 10 orders.
- Q14: Total delivered revenue = ₹17,191.
- Q15: Clothing avg ₹2699, Electronics avg ₹2224, Home avg ₹949.
- Q16: Delivered leads in both count (6) and revenue (₹17,191); cancelled order = ₹2,999 in lost revenue.
- Q18: Only Electronics and Clothing exceed the ₹2000 average threshold. `HAVING` is used (not `WHERE`) because it filters after aggregation.

---

### Section D — Joins & Relationships

| Q# | Question | Key Concept |
|---|---|---|
| Q19 | INNER JOIN: orders with customer names | INNER JOIN |
| Q20 | LEFT JOIN: all customers including those with no orders | LEFT JOIN |
| Q21 | Three-table JOIN: orders → order_items → products | Multi-table JOIN |
| Q22 | Difference between LEFT, RIGHT, FULL OUTER JOIN | JOIN theory |
| Q23 | Foreign Key relationships — insert with customer_id = 999 | FK + referential integrity |

**Key Observations:**
- Q19: All 10 orders matched. Aarav Sharma appears twice (orders 1001 and 1004) — one customer can place multiple orders.
- Q21: Most useful query for product-level analysis. Order 1009 included Cushion Covers with 15% discount.
- Q23: Inserting `customer_id = 999` triggers a FOREIGN KEY constraint violation — SQL Server refuses to create orphan records.

---

### Section E — Advanced Concepts (CASE, ACID, Transactions)

| Q# | Question | Key Concept |
|---|---|---|
| Q24 | Classify products into Budget / Mid-Range / Premium | CASE statement |
| Q25 | Count Delivered vs Not Delivered in one query | CASE inside SUM() |
| Q26 | Explain ACID properties with bank transfer example | Theory |
| Q27 | Full transaction: insert order + items + update stock | BEGIN TRY / CATCH / ROLLBACK |

**Key Observations:**
- Q24: Budget tier = Cushion Covers (₹599), Cotton T-Shirt (₹799), Laptop Stand (₹899). Premium = Running Shoes (₹4599), Bluetooth Speaker (₹3499).
- Q25: 6 Delivered, 4 Not Delivered — single table scan using the conditional SUM pivot pattern.
- Q27: After running the transaction, order 1011 inserted with today's date. Stock for Laptop Stand dropped 180→179, Cushion Covers 400→399. ROLLBACK confirmed working when a CHECK constraint is intentionally violated.

---

## 🗂️ Part 2: Superstore Dataset Analysis

### Dataset Details

| Property | Value |
|---|---|
| Source | [Kaggle — Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) |
| Rows | 9,994 |
| Columns | 21 |
| Date Range | 2014-01-03 to 2017-12-30 |
| Country | United States only |
| Database | Celebal_Week2 |
| Table | dbo.Superstore |

### Column Overview
The table is a flat/denormalized structure covering: `Row_ID`, `Order_ID`, `Order_Date`, `Ship_Date`, `Ship_Mode`, `Customer_ID`, `Customer_Name`, `Segment`, `Country`, `City`, `State`, `Postal_Code`, `Region`, `Product_ID`, `Category`, `Sub_Category`, `Product_Name`, `Sales`, `Quantity`, `Discount`, `Profit`

---

### Section A — Basic Queries (Exploration)

```sql
-- A1: Full table view
SELECT * FROM dbo.Superstore;

-- A2: Selective column projection
SELECT Row_ID, Order_ID, Order_Date, Customer_Name, Category, Sales, Profit FROM dbo.Superstore;

-- A3: Total row count
SELECT COUNT(*) AS Total_Records FROM dbo.Superstore;
-- Result: 9,994

-- A4: Schema inspection
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore' AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;

-- A5: Distinct values in key categorical columns
SELECT DISTINCT Segment FROM dbo.Superstore;   -- 3: Consumer, Corporate, Home Office
SELECT DISTINCT Region FROM dbo.Superstore;    -- 4: East, West, Central, South
SELECT DISTINCT Ship_Mode FROM dbo.Superstore; -- 4: Standard Class, Second Class, First Class, Same Day
SELECT DISTINCT Category FROM dbo.Superstore;  -- 3: Furniture, Office Supplies, Technology
SELECT DISTINCT Sub_Category FROM dbo.Superstore ORDER BY Sub_Category; -- 17 sub-categories

-- A6: Quick data preview
SELECT TOP 10 * FROM dbo.Superstore;

-- A7: Date range
SELECT MIN(Order_Date) AS Earliest_Order, MAX(Order_Date) AS Latest_Order FROM dbo.Superstore;
-- Result: 2014-01-03 to 2017-12-30

-- A8: Financial spread
SELECT ROUND(MIN(Sales),2) AS Min_Sale, ROUND(MAX(Sales),2) AS Max_Sale,
       ROUND(AVG(Sales),2) AS Avg_Sale, ROUND(MIN(Profit),2) AS Min_Profit,
       ROUND(MAX(Profit),2) AS Max_Profit, ROUND(AVG(Profit),2) AS Avg_Profit
FROM dbo.Superstore;
-- Min Sale: $0.44 | Max Sale: $22,638 | Some profits are NEGATIVE

-- A9: NULL check across key columns
-- Result: 1 NULL found in Profit column

-- A10: Duplicate Row_ID check
-- Result: Empty set — no duplicates, clean import

-- A11: Dataset cardinality
SELECT COUNT(DISTINCT Customer_ID) AS Unique_Customers,   -- 793
       COUNT(DISTINCT Product_ID)  AS Unique_Products,    -- 1,862
       COUNT(DISTINCT Order_ID)    AS Unique_Orders,      -- 5,009
       COUNT(DISTINCT State)       AS Unique_States,      -- 49
       COUNT(DISTINCT City)        AS Unique_Cities       -- 531
FROM dbo.Superstore;
```

**Key Observations:**
- Dataset is entirely from the United States, spanning 4 years (2014–2017).
- Profit column has 1 NULL value — needs attention before aggregation.
- Row_ID is unique across all 9,994 rows — no duplicate import issues.
- 793 unique customers placed 5,009 unique orders across 531 cities.

---

### Section B — Filtering Queries

Applied `WHERE` conditions to filter by region, category, date ranges, sales thresholds, discount levels, and segment. Queries covered:
- Orders from specific states/regions
- Products with sales above a threshold
- Orders placed in a specific year/month using date filters
- Customers with zero discount
- Loss-making transactions (`Profit < 0`)

---

### Section C — Aggregation Queries

Used `GROUP BY` with aggregate functions (`SUM`, `COUNT`, `AVG`, `MAX`, `MIN`) to answer:
- Total sales and profit by Category and Sub-Category
- Average discount by Segment
- Monthly and yearly revenue trends
- Top-performing states by total profit
- Order count by Ship Mode
- Revenue by Region

---

### Section D — Joins Queries

Although the Superstore dataset is a single flat table, JOIN-style queries were demonstrated using:
- Self-joins to compare orders from the same customer
- Subqueries and derived tables to simulate multi-table join patterns
- Cross-segment comparisons using aggregated subqueries

---

### Section E — Advanced Queries

Applied advanced SQL techniques:
- `CASE` statements to classify products by profit margin tier
- Window functions to rank customers by sales within each region
- Running totals using cumulative `SUM` with `OVER(ORDER BY)`
- Identifying top-N products per category
- Detecting orders where discount led to negative profit

---

## 🔑 Key Learnings from Week 2

1. **Constraints are the database's safety net** — `PRIMARY KEY`, `UNIQUE`, `CHECK`, and `FOREIGN KEY` all enforce data integrity at the storage level, independent of application code.

2. **Index design matters** — Indexes on `order_date`, `status`, and `category` dramatically reduce query scan time. Writing SARGable queries (avoiding functions on indexed columns in WHERE clauses) is essential to actually use those indexes.

3. **HAVING vs WHERE** — `WHERE` filters rows before aggregation; `HAVING` filters groups after. Using `WHERE AVG(...)` is a syntax error — a mistake worth learning early.

4. **The CASE inside SUM() pivot pattern** — Conditional aggregation in a single pass is far more efficient than running multiple queries with different filters.

5. **Transactions with TRY/CATCH/ROLLBACK** — Multi-step operations must be wrapped in transactions. Any failure mid-way should roll back all prior changes atomically. Verified this in Q27 by intentionally triggering a CHECK constraint violation inside the transaction block.

6. **Flat vs normalized data** — The Superstore CSV is fully denormalized (one giant table). The ShopEase database follows proper normalization with foreign key relationships. Both have tradeoffs: flat tables are easier to query ad hoc; normalized tables are more maintainable and space-efficient.

7. **Data quality checks before analysis** — Running NULL checks, duplicate Row_ID checks, and schema inspection (INFORMATION_SCHEMA.COLUMNS) before writing business queries saved time and prevented misleading results.

---

## 🛠️ How to Run the SQL Files

### Prerequisites
- SQL Server (any edition) installed
- SQL Server Management Studio (SSMS) installed
- For Superstore: the `Superstore.csv` file imported via SSMS Import Wizard

### Steps — E-Commerce Database

```sql
-- 1. Open SSMS and connect to your SQL Server instance
-- 2. Open SQLQuery_E-Commerce.sql
-- 3. Run the full file top to bottom (F5 or Execute)
--    The script creates the database, tables, indexes,
--    inserts all sample data, and runs all 27 queries.
```

### Steps — Superstore Dataset

```sql
-- 1. Create the database
CREATE DATABASE Celebal_Week2;
GO
USE Celebal_Week2;
GO

-- 2. Import Superstore.csv via SSMS:
--    Right-click database → Tasks → Import Flat File
--    Select Superstore.csv, set table name to 'Superstore'
--    Verify column types (Order_Date as DATE, Sales/Profit as FLOAT)

-- 3. Open section SQL files in order:
--    Section_A/SQLBasicQuery.sql
--    Section_B/SQLFilteringQuery.sql
--    Section_C/SQLAggregationQuery.sql
--    Section_D/SQLJoinsQuery.sql
--    Section_E/SQLAdvancedQuery.sql

-- 4. Run each file and compare results with the
--    corresponding ResultScreenshots PDF
```

---

## 📊 Result Screenshots

All query results are documented with SSMS screenshots:

| Section | Results File |
|---|---|
| E-Commerce (All Sections) | `E-Commerce Database/Queries_Result.pdf` |
| Section A – Basics | `Superstore Dataset/Section_A – Basics/SECTION_A_Basic_Queries_ResultScreenshots.pdf` |
| Section B – Filtering | `Superstore Dataset/Section_B – Filtering/SECTION_B_Filtering_QResultScreenshots.pdf` |
| Section C – Aggregation | `Superstore Dataset/Section_C – Aggregation/SECTION_C_AggregationQ_ResultScreenS.pdf` |
| Section D – Joins | `Superstore Dataset/Section_D – Joins/SECTION_D_JoinsQ_ResultScreenShot.pdf` |
| Section E – Advanced | `Superstore Dataset/Section_E – Advanced/` (included in advanced PDF) |

---

## 📚 Resources

- [Kaggle Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- [Celebal LMS — Week 2 Task Document](https://celebaltech.sharepoint.com/:w:/s/Celebal-LMS/IQDQ_Co-E08_RZo3eKklxGR-AQ09RkM5df72wSBZjaL9LYc?e=04TLA8)
- [Microsoft SQL Server Documentation](https://learn.microsoft.com/en-us/sql/sql-server/)
- [SSMS Download](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

---

*Submitted BY ARATI THORAT
| **Submission Date** | 28 June 2026 |
