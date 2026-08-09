# E-Commerce Order Analytics System

## Week 8 – Data Engineering Internship Assignment

This project is an end-to-end **E-Commerce Order Analytics System** developed using **Python, Pandas, SQLite, and SQL**.

The objective is to generate realistic e-commerce data, introduce intentional data-quality issues, clean and validate the data, store it in a relational database, perform business analysis using SQL, and generate reports.

## 1. Project Objective

The project covers the complete data analytics workflow:

- Generate realistic e-commerce datasets.
- Introduce intentional data inconsistencies.
- Clean and validate data using Python and Pandas.
- Check referential integrity between related tables.
- Load cleaned data into SQLite.
- Perform basic, intermediate, and advanced SQL analysis.
- Use joins, aggregations, CTEs, window functions, ranking, and cohort analysis.
- Build a command-line reporting tool.
- Handle important edge cases.
- Save sample outputs and execution screenshots.
- Document the complete project for GitHub submission.

## 2. Technologies Used

| Technology | Purpose |
|---|---|
| Python | Data generation, cleaning, validation and reporting |
| Pandas | Data cleaning and transformation |
| Faker | Realistic sample data generation |
| SQLite | Local relational database |
| SQL | Business and analytical queries |
| VS Code / Jupyter | Development and execution |
| Git & GitHub | Version control and submission |

## 3. Project Workflow

```text
Data Generation
      ↓
Raw CSV Files
      ↓
Data Cleaning with Pandas
      ↓
Data Validation
      ↓
Cleaned CSV Files
      ↓
SQLite Database
      ↓
SQL Analysis
      ↓
Business Insights
      ↓
Reporting
      ↓
Screenshots & Documentation
```

## 4. Project Folder Structure

```text
WEEK 8_Ecommerce-analytics-system/
│
├── data/
│   ├── raw/
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── orders.csv
│   │   └── order_items.csv
│   │
│   └── cleaned/
│       ├── customers_clean.csv
│       ├── products_clean.csv
│       ├── orders_clean.csv
│       └── order_items_clean.csv
│
├── database/
│   └── ecommerce.db
│
├── pythonscripts/
│   ├── generate_data.py
│   ├── clean_data.py
│   └── report_cli.py
│
├── sql/
│   ├── schema.sql
│   ├── aggregations.sql
│   ├── window_functions.sql
│   └── cohort_analysis.sql
│
├── output/
│   └── sample_reports/
│
├── screenshots/
│   ├── data_generation.png
│   ├── data_cleaning.png
│   ├── database_loading.png
│   ├── sql_analysis.png
│   └── report_output.png
│
└── README.md
```

> The exact file names inside the folders may vary slightly depending on the final implementation.

## 5. Dataset Description

The system works with four related datasets.

### Customers

`customers.csv` contains:

- `customer_id`
- `customer_name`
- `email`
- `registration_date`
- `customer_type`

Customer types are **REGULAR, PREMIUM, and VIP**.

### Products

`products.csv` contains:

- `product_id`
- `product_name`
- `category`
- `subcategory`
- `cost_price`

Example categories include Electronics, Clothing, Home, and Books.

### Orders

`orders.csv` contains:

- `order_id`
- `customer_id`
- `order_date`
- `status`

Order statuses include:

- PLACED
- SHIPPED
- DELIVERED
- CANCELLED
- RETURNED

### Order Items

`order_items.csv` contains:

- `order_id`
- `product_id`
- `quantity`
- `unit_price`
- `discount_percent`

Negative quantities are intentionally used in some records to represent returns.

## 6. Intentional Data Quality Issues

The raw datasets intentionally contain realistic problems:

- Around 5% of orders have a missing `customer_id`.
- Around 3% of order items have negative quantities.
- Some order dates use the wrong `DD-MM-YYYY` format.
- Some product names contain extra spaces or mixed case.
- Around 2% of emails are invalid.
- Referential integrity problems may exist between related tables.
- Additional edge cases are tested during validation.

## 7. Phase 1 – Data Generation

Python and Faker are used to generate realistic sample data for:

```text
customers.csv
products.csv
orders.csv
order_items.csv
```

The generator also introduces intentional inconsistencies for testing.

A key relationship is maintained between `orders` and `order_items` through `order_id`. Referential integrity is checked during validation.

## 8. Phase 2 – Data Cleaning

The raw CSV files are loaded using Pandas.

### Orders

- Fix inconsistent date formats.
- Handle missing customer IDs.
- Check duplicates.
- Validate data types.

### Products

- Remove unnecessary spaces.
- Normalize product names.
- Convert product names to title case.
- Check missing values.

### Customers

- Validate email addresses.
- Identify customer IDs with invalid emails.

### Order Items

- Check negative quantities.
- Check invalid order references.
- Validate numeric fields.

Cleaned files are stored separately so the original raw data remains available.

## 9. Data Validation

Important validation checks include:

### Email Validation

Invalid email addresses are identified and reported.

### Referential Integrity

Every `order_id` in `order_items` is checked against the `orders` table.

### Date Validation

Order dates are checked for correct format, invalid values, and future dates.

### Numeric Validation

Quantity and discount percentage values are checked for invalid values.

## 10. Phase 3 – SQLite Database

After cleaning, the datasets are loaded into a SQLite database.

The main tables are:

```text
customers
products
orders
order_items
```

The database is stored in:

```text
database/ecommerce.db
```

## 11. Phase 4 – SQL Analysis

SQL is used to generate business insights.

### Basic Analysis

The project calculates:

1. Total revenue per category.
2. Top 10 customers by total order value.
3. Month-wise order count.

Revenue is calculated as:

```text
quantity × unit_price × (1 - discount_percent / 100)
```

### Intermediate Analysis

The project also identifies:

- Customers who placed orders but never had an item delivered.
- Products with more returns than purchases.
- Return rate per category.

## 12. Advanced SQL Analysis

The project demonstrates:

```sql
SUM() OVER()
RANK()
DENSE_RANK()
LAG()
LEAD()
NTILE()
```

These are used for running totals, ranking, previous-order analysis, segmentation, and comparisons.

### CTE Analysis

Common Table Expressions are used for multi-step analysis such as:

```text
Monthly Revenue
      ↓
Customer Classification
      ↓
Monthly Segment Counts
```

Customer categories include **High, Medium, and Low**.

### Customer Lifetime Value

Customers are divided into four quartiles using `NTILE(4)` and labelled:

```text
Platinum
Gold
Silver
Bronze
```

### Year-over-Year Analysis

Monthly revenue is compared with the same month of the previous year using current revenue, previous-year revenue, and YoY growth percentage.

### First and Most Recent Category

For each customer, the project identifies the first purchased category and most recent purchased category and flags whether the customer changed category.

### Cumulative Revenue

Customers are ranked by revenue and cumulative revenue is calculated to understand the contribution of high-value customers to total revenue.

## 13. Cohort and Retention Analysis

Customers are grouped according to their registration month.

For each cohort, the project calculates:

- Month 0 customers.
- Month 1 customers.
- Month 2 customers.
- Month 3 customers.
- Retention rate.

This helps understand repeat purchasing and customer retention.

## 14. Customer Segmentation

Customers can be analyzed using:

- Purchase frequency.
- Total spending.
- Recency.
- Customer type.
- Lifetime value.

Example segments include:

```text
One-time Customer
Occasional Customer
Loyal Customer
Low Spend
Medium Spend
High Spend
```

## 15. Command-Line Reporting

The project includes a Python reporting tool that connects to SQLite.

The reporting workflow accepts a report type and date range and can generate:

- Total orders.
- Total revenue.
- Unique customers.
- Top 3 products.
- Comparison with the previous period.

Example:

```text
Enter report type: monthly
Enter start date: 2026-01-01
Enter end date: 2026-01-31
```

## 16. Edge Case Handling

The project tests:

1. An `order_items` record referencing a non-existent order.
2. `discount_percent` greater than 100.
3. Quantity equal to zero.
4. Future order dates.
5. Empty result sets.
6. Invalid CLI inputs.
7. Database connection/query errors.

## 17. Output

The project produces:

- Raw CSV datasets.
- Cleaned CSV datasets.
- Validation results.
- SQLite database.
- SQL analysis results.
- Customer segmentation results.
- Cohort and retention analysis.
- CLI reports.
- Sample output files.
- Execution screenshots.

The output files are stored in:

```text
output/
```

## 18. Screenshots

The `screenshots/` folder contains evidence of successful execution of important project stages, including:

1. Data generation.
2. Data cleaning.
3. Data validation.
4. Database loading.
5. SQL queries.
6. Window-function analysis.
7. CTE analysis.
8. Cohort analysis.
9. Reporting output.

## 19. Setup and Execution

### Step 1 – Create a virtual environment

```powershell
python -m venv venv
```

Activate it in PowerShell:

```powershell
.\venv\Scripts\Activate.ps1
```

### Step 2 – Install dependencies

```powershell
pip install pandas faker
```

### Step 3 – Generate raw data

```powershell
python pythonscripts\generate_data.py
```

The raw files are generated in:

```text
data/raw/
```

### Step 4 – Clean and validate data

```powershell
python pythonscripts\clean_data.py
```

The cleaned files are generated in:

```text
data/cleaned/
```

### Step 5 – Create/load the SQLite database

Run the database schema and loading process so the cleaned data is available in:

```text
database/ecommerce.db
```

### Step 6 – Run SQL analysis

Execute the SQL files from:

```text
sql/
```

### Step 7 – Run the reporting tool

```powershell
python pythonscripts\report_cli.py
```

## 20. SQL Concepts Demonstrated

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- INNER JOIN
- LEFT JOIN
- Subqueries
- Aggregate functions
- CASE statements
- CTEs
- Window functions
- RANK
- DENSE_RANK
- LAG
- LEAD
- NTILE
- Running totals
- Year-over-Year analysis
- Cumulative distribution
- Cohort analysis

## 21. Key Learning Outcomes

This project provides practical experience in:

- Python data generation.
- Pandas data cleaning.
- Data-quality validation.
- Referential integrity checking.
- Relational database concepts.
- SQLite database handling.
- SQL joins and aggregations.
- Advanced SQL.
- Window functions.
- CTE-based analysis.
- Customer segmentation.
- Cohort and retention analysis.
- Command-line reporting.
- Edge-case handling.
- GitHub project organization and documentation.

## 22. Conclusion

The **E-Commerce Order Analytics System** demonstrates a complete data analytics workflow from raw and inconsistent data to cleaned datasets, a relational SQLite database, advanced SQL analysis, and business reports.

The complete pipeline is:

```text
Generate → Clean → Validate → Store → Analyze → Report
```

The project demonstrates how raw e-commerce data can be transformed into reliable and useful business insights using Python and SQL.

---

## Author

**Arati Thorat**  
**Data Engineering Intern – Celebal Technologies**  
**CEI ID: CT_CSI_DE_1180**
