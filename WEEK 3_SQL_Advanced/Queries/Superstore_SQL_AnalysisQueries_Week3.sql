/* ============================================================
                CELEBAL TECHNOLOGIES
          DATA ENGINEERING INTERNSHIP

                WEEK 3 ASSIGNMENT

Dataset : Superstore
Tool    : SQL Server Management Studio (SSMS)

Topic   : Subqueries, CTEs & Window Functions
============================================================ */

/*-------------------------------------------------------------
STEP 1 : SETUP DATA
Task 1 : Create Database
-------------------------------------------------------------*/
CREATE DATABASE SuperstoreDB;
GO
USE SuperstoreDB;
GO

/*-------------------------------------------------------------
Task 2

Import the Superstore dataset into a table named
superstore_raw using the SSMS Import Flat File Wizard.
-------------------------------------------------------------*/

-- Verify the imported data
SELECT COUNT(*) AS total_rows FROM superstore_raw;
SELECT TOP 5 * FROM superstore_raw;


/*-------------------------------------------------------------
Task 3

Create normalized tables:
1. customers
2. orders
3. products
-------------------------------------------------------------*/

-- Create Customers Table
CREATE TABLE customers (
    customer_id   VARCHAR(20)  PRIMARY KEY,
    customer_name VARCHAR(100),
    segment       VARCHAR(30)0),
    country       VARCHAR(50)
);

INSERT INTO customers (customer_id, customer_name, segment, country)
SELECT DISTINCT Customer_ID, Customer_Name, Segment, Country
FROM superstore_raw;

-- Create Products Table
-- Some Product_ID values appear with multiple names in the dataset. ROW_NUMBER() is used to keep one record for each Product_ID.
CREATE TABLE products (
    product_id   VARCHAR(30) PRIMARY KEY,
    category     VARCHAR(30),
    sub_category VARCHAR(30),
    product_name VARCHAR(255)
);

INSERT INTO products (product_id, category, sub_category, product_name)
SELECT product_id, category, sub_category, product_name
FROM (
    SELECT
        Product_ID  AS product_id,
        Category   AS category,
        Sub_Category AS sub_category,
        Product_Name AS product_name,
        ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_Name) AS rn
    FROM superstore_raw
) t
WHERE rn = 1;

-- Create Orders Table (one row per order line, with shipping/location detail)
CREATE TABLE orders (
    row_id       INT PRIMARY KEY,
    order_id     VARCHAR(20),
    order_date   DATE,
    ship_date    DATE,
    ship_mode    VARCHAR(30),
    customer_id  VARCHAR(20),
    product_id   VARCHAR(30),
    city         VARCHAR(50),
    state        VARCHAR(50),
    postal_code  VARCHAR(10),
    region       VARCHAR(20),
    sales        DECIMAL(10,2),
    quantity     INT,
    discount     DECIMAL(4,2),
    profit       DECIMAL(10,2)
);

INSERT INTO orders
SELECT
    Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode,
    Customer_ID, Product_ID, City, State, Postal_Code, Region,
    Sales, Quantity, Discount, Profit
FROM superstore_raw;

-- Row-count check
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;


/* ------------------------------------------
   STEP 3: Subqueries
   ------------------------------------------ */

-- Query 1 : Find all orders where sales are greater than the average sales: Baseline - overall average sales value
SELECT ROUND(AVG(sales), 2) AS avg_sales
FROM orders;

-- Query 2 : Find the highest sales order for each customer: Orders with Sales above the overall average (simple subquery)
SELECT o.order_id, c.customer_name, p.product_name, o.sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE o.sales > (SELECT AVG(sales) FROM orders)
ORDER BY o.sales DESC;

--2. Highest sales order for each customer 
-- Query 3 : Calculate total sales for each customer: Highest single order value per customer (correlated subquery)
SELECT o.customer_id, c.customer_name, o.order_id, o.sales AS highest_order_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.sales = (
    SELECT MAX(o2.sales)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.sales DESC;


/* ------------------------------------------
   STEP 4: CTEs (Common Table Expressions)
   ------------------------------------------ */
-- 3. Total sales for each customer (CTE)
-- Query 4 : Find customers whose total sales are above average: Total sales per customer (CTE)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name,
           SUM(o.sales) AS total_sales,
           COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_sales
ORDER BY total_sales DESC;

--4. Customers whose total sales are above average (CTE + Subquery)


-- Query 5 : Rank all customers based on total sales: Customers whose TOTAL sales exceed the average customer total
-- (CTE combined with a subquery in the WHERE clause)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_sales, 2) AS total_sales
FROM customer_sales
WHERE total_sales > (SELECT AVG(total_sales) FROM customer_sales)
ORDER BY total_sales DESC;


/* ------------------------------------------
   STEP 5: Window Functions
   ------------------------------------------ */

-- Query 6 : Assign row numbers to each order within a customer: Customer ranking - JOIN + CTE + Window Functions
-- (ROW_NUMBER, RANK, DENSE_RANK side by side)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, c.segment,
           SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name, c.segment
)
SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(total_sales, 2) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num,
    RANK()       OVER (ORDER BY total_sales DESC) AS sales_rank,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_sales_rank
FROM customer_sales
ORDER BY total_sales DESC;

--6. Row numbers for each order within a customer (Window Function + PARTITION BY)
SELECT o.customer_id, c.customer_name, o.order_id, o.order_date, o.sales,
       ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_row_num
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.customer_id, order_row_num;

--7. Top 3 customers based on total sales (Window Function)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
ranked AS (
    SELECT customer_id, customer_name, ROUND(total_sales, 2) AS total_sales,
           RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
)
SELECT * FROM ranked WHERE sales_rank <= 3;

-- Final Combined Query (Customer Name, Total Sales, Rank)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    ROUND(total_sales, 2) AS total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS rank
FROM customer_sales
ORDER BY rank;

/* ------------------------------------------
   STEP 6: Mini Project: Customer Sales Insights
   ------------------------------------------ */

-- Query 7 : Display the Top 3 customers based on total sales: Top 5 customers by total sales
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
ranked AS (
    SELECT customer_id, customer_name, ROUND(total_sales, 2) AS total_sales,
           RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
)
SELECT * FROM ranked WHERE sales_rank <= 5;

-- Query 8: Bottom 5 customers by total sales (low-value customers)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
ranked AS (
    SELECT customer_id, customer_name, ROUND(total_sales, 2) AS total_sales,
           RANK() OVER (ORDER BY total_sales ASC) AS low_rank
    FROM customer_sales
)
SELECT * FROM ranked WHERE low_rank <= 5;

-- Query 9: Customers who placed only ONE order
WITH order_counts AS (
    SELECT c.customer_id, c.customer_name,
           COUNT(DISTINCT o.order_id) AS order_count,
           SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, order_count, ROUND(total_sales, 2) AS total_sales
FROM order_counts
WHERE order_count = 1
ORDER BY total_sales DESC;
--4. Customers with above-average sales
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(total_sales,2) AS total_sales
FROM customer_sales
WHERE total_sales > (SELECT AVG(total_sales) FROM customer_sales)
ORDER BY total_sales DESC;

--5 .Highest order value per customer
SELECT o.customer_id, c.customer_name, o.order_id, o.sales AS highest_order_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.sales = (SELECT MAX(o2.sales) FROM orders o2 WHERE o2.customer_id = o.customer_id)
ORDER BY o.sales DESC;
-- Query 1 : Find all orders where sales are greater than the average sales0: Top 3 customers per Region (PARTITION BY)
WITH customer_region_sales AS (
    SELECT c.customer_id, c.customer_name, o.region, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name, o.region
),
ranked AS (
    SELECT customer_id, customer_name, region, ROUND(total_sales, 2) AS total_sales,
           RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank_in_region
    FROM customer_region_sales
)
SELECT * FROM ranked WHERE rank_in_region <= 3
ORDER BY region, rank_in_region;

-- Query 1 : Find all orders where sales are greater than the average sales1: Customer segmentation into quartiles (NTILE)
WITH customer_sales AS (
    SELECT c.customer_id, c.customer_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
segmented AS (
    SELECT customer_id, customer_name, ROUND(total_sales, 2) AS total_sales,
           NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
    FROM customer_sales
)
SELECT quartile,
       COUNT(*) AS num_customers,
       ROUND(AVG(total_sales), 2) AS avg_sales_in_quartile,
       ROUND(MIN(total_sales), 2) AS min_sales,
       ROUND(MAX(total_sales), 2) AS max_sales
FROM segmented
GROUP BY quartile
ORDER BY quartile;

-- Query 1 : Find all orders where sales are greater than the average sales2: Best-selling product per category (window function)
WITH product_sales AS (
    SELECT p.category, p.product_name, SUM(o.sales) AS total_sales
    FROM orders o JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT category, product_name, ROUND(total_sales, 2) AS total_sales,
           RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rnk
    FROM product_sales
)
SELECT * FROM ranked WHERE rnk = 1;

/* ------------------------------------------
  


