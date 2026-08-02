# Week 7 - Delta Lake Assignment

## Overview

This assignment demonstrates how to perform incremental data processing using **Delta Lake** in **Databricks** with **PySpark**. The workflow covers loading datasets, cleaning data, creating a Delta table, performing MERGE operations for incremental updates, and validating the final results.

---

## Objectives

- Load a CSV dataset into a Delta table.
- Clean the dataset by handling null values and removing duplicate records.
- Create an incremental dataset to simulate newly arrived data.
- Perform MERGE (UPSERT) operations using Delta Lake.
- Validate the updated dataset.
- Save the processed data and document the workflow.

---

## Technologies Used

- Databricks Community Edition
- Apache Spark (PySpark)
- Delta Lake
- Python
- Jupyter Notebook

---

## Project Structure

```
week7-delta-lake-assignment/
│
├── data/
│   ├── customer_master.csv
│   ├── customer_incremental.csv
│   └── cleaned_customer.csv
│
├── notebook/
│   └── Week7_DeltaLake_Assignment.ipynb
│
├── report/
│   └── Week7_Report.pdf
│
├── screenshots/
│   ├── data_loading.png
│   ├── data_cleaning.png
│   ├── customer_summary.png
│   ├── delta_table.png
│   ├── merge_operation.png
│   ├── validation.png
│   └── final_output.png
│
└── README.md
```

---

## Dataset

### Customer Master

Contains the existing customer records used to create the initial Delta table.

### Customer Incremental

Contains new and updated customer records used to simulate incremental data loading.

---

## Assignment Workflow

### Step 1 – Load Dataset

- Read the CSV files using PySpark.
- Enable header and schema inference.
- Display the dataset.

---

### Step 2 – Data Cleaning

- Check for missing values.
- Handle null values.
- Remove duplicate records.
- Verify the cleaned dataset.

---

### Step 3 – Customer Summary

Create a customer-level summary by calculating:

- Total Orders
- Total Quantity
- Total Sales
- Total Profit
- Home Region

---

### Step 4 – Create Delta Table

Store the processed customer data as a Delta table.

---

### Step 5 – Load Incremental Dataset

Read the incremental customer dataset that contains new and modified records.

---

### Step 6 – MERGE Operation

Perform an UPSERT using the Delta Lake `MERGE` command.

- Update existing customer records.
- Insert new customer records.

---

### Step 7 – Validation

Validate the final Delta table by checking:

- Total record count
- Duplicate records
- Updated customer information
- Newly inserted records

---

## Key Delta Lake Features Used

- ACID Transactions
- MERGE (Upsert)
- Schema Enforcement
- Data Validation
- Incremental Data Processing

---

## Output

The assignment produces:

- Cleaned customer dataset
- Customer summary table
- Delta table
- MERGE operation results
- Validation output
- Notebook
- Screenshots
- Report

---

## Learning Outcomes

After completing this assignment, I learned:

- Working with PySpark DataFrames.
- Reading and processing CSV datasets.
- Performing data cleaning operations.
- Creating Delta tables in Databricks.
- Using MERGE for incremental data loading.
- Validating processed data.
- Understanding the advantages of Delta Lake over traditional file formats.

---

## How to Run

1. Open Databricks.
2. Upload the datasets to a Unity Catalog Volume.
3. Open the notebook.
4. Execute the notebook cells sequentially.
5. Verify the outputs after each step.
6. Capture screenshots for documentation.

---

## Author

**Arati Thorat**

Data Engineering Internship – Week 7 Assignment
