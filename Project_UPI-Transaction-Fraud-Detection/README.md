# Real-Time UPI Transaction & Fraud Detection Pipeline

## 📌 Project Overview

**Project Title:** Real-Time UPI Transaction & Fraud Detection Pipeline

This project is an end-to-end UPI transaction processing and fraud monitoring pipeline developed using **Databricks, PySpark, SQL, and Delta Lake**.

The main purpose of the project is to take UPI transaction data through different data engineering stages, clean and transform the data, create analytical Gold-layer data, apply fraud detection logic, and finally present the results through an interactive **Databricks SQL Dashboard**.

The project follows a **Medallion Architecture**:

**Data Generation → Landing/Ingestion → Bronze → Silver → Gold → Fraud Detection → Dashboard**

The project uses simulated UPI transaction data. The fraud detection stage assigns transactions to three risk levels:

- **LOW**
- **MEDIUM**
- **HIGH**

The final dashboard provides an easy way to monitor transaction volume, fraud rate, critical fraud alerts, transaction amount, fraud trends, and high-risk transactions.

---

## 🎯 Project Objectives

The major objectives of this project are:

1. Generate or work with simulated UPI transaction data.
2. Ingest the transaction data into Databricks.
3. Store and process raw data using the Bronze layer.
4. Clean and transform the data in the Silver layer.
5. Create aggregated business-level data in the Gold layer.
6. Apply fraud detection and fraud scoring logic.
7. Categorize transactions into LOW, MEDIUM, and HIGH risk levels.
8. Validate the fraud detection results using SQL.
9. Create an interactive Databricks dashboard.
10. Provide filters for date range, fraud level, and bank.
11. Publish the dashboard for easy access.
12. Maintain screenshots and notebooks as evidence of successful execution.

---

## 🏗️ Project Architecture

```text
                    UPI Transaction Data
                            │
                            ▼
                  ┌─────────────────────┐
                  │ 01_Data_Generator   │
                  │ Simulated UPI Data  │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ 02_Landing_Ingestion│
                  │ Data Ingestion       │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ 03_Bronze_Processing│
                  │ Raw / Initial Data  │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ 04_Silver_          │
                  │ Transformation      │
                  │ Cleaned Data        │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ 05_Gold_Aggregation │
                  │ Analytical Data     │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ 06_Fraud_Detection  │
                  │ Fraud Score & Level │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Databricks Dashboard│
                  │ Fraud Monitoring    │
                  └─────────────────────┘
```

---

## 🥇 Medallion Architecture

### Bronze Layer

The Bronze layer contains the initially ingested transaction data.

The purpose of this layer is to preserve the incoming data before applying extensive transformations.

### Silver Layer

The Silver layer contains cleaned and transformed transaction data.

Typical processing includes:

- Data cleaning
- Data type handling
- Removing or handling invalid records
- Standardizing transaction fields
- Preparing data for analytics

### Gold Layer

The Gold layer contains processed and analytical data that can be directly used for reporting and business analysis.

The fraud detection output is built on top of the processed Gold data.

---

# 📂 Repository Structure

The final project repository is organized as follows:

```text
Project_UPI-Transaction-Fraud-Detection/
│
├── notebooks/
│   ├── 01_Data_Generator.ipynb
│   ├── 02_Landing_Ingestion.ipynb
│   ├── 03_Bronze_Processing.ipynb
│   ├── 04_Silver_Transformation.ipynb
│   ├── 05_Gold_Aggregation.ipynb
│   └── 06_Fraud_Detection.ipynb
│
├── dashboard/
│   └── dashboard_link.txt
│
├── screenshots/
│   ├── 01_Data_Generator.png
│   ├── 02_Landing_Ingestion.png
│   ├── 03_Bronze_Processing.png
│   ├── 04_Silver_Transformation.png
│   ├── 05_Gold_Aggregation_01.png
│   ├── 05_Gold_Aggregation_02.png
│   ├── 06_Fraud_Detection.png
│   ├── 06_Validation.png
│   ├── 07_Dashboard.png
│   ├── 07_Dashboard_01.png
│   ├── 07_Dashboard_02.png
│   └── 07_Dashboard_03.png
│
├── report/
│   └── UPI_Transaction_Fraud_Monitoring_Report.pdf
│
└── README.md
```

---

# 🔄 Pipeline Steps

## Step 1 – Data Generation

**Notebook:** `01_Data_Generator.ipynb`

The first step of the project creates simulated UPI transaction data.

The generated dataset represents UPI transactions and contains transaction-related information required for downstream processing and fraud analysis.

The generated data is used as the starting point for the complete pipeline.

### Purpose

- Create a realistic transaction dataset for project implementation.
- Provide sufficient transaction records for processing and analysis.
- Simulate a UPI transaction environment without using sensitive real financial data.

### Output

The generated transaction data becomes the input for the ingestion stage.

---

## Step 2 – Landing and Ingestion

**Notebook:** `02_Landing_Ingestion.ipynb`

In this step, the generated transaction data is brought into the Databricks environment.

The purpose of the landing/ingestion stage is to move the incoming transaction data into the data engineering pipeline so that it can be processed by the Bronze layer.

### Purpose

- Ingest transaction data into Databricks.
- Prepare the data for structured processing.
- Establish the initial data flow.

### Output

The successfully ingested data is passed to the Bronze processing stage.

---

## Step 3 – Bronze Processing

**Notebook:** `03_Bronze_Processing.ipynb`

The Bronze layer is the first structured processing layer.

At this stage, the ingested data is stored and processed while keeping the original transaction information available for downstream processing.

### Purpose

- Process the ingested transaction data.
- Maintain the raw/initial representation of the data.
- Prepare the data for Silver transformation.

### Output

A Bronze-level transaction dataset is created and used as the input for the Silver layer.

---

## Step 4 – Silver Transformation

**Notebook:** `04_Silver_Transformation.ipynb`

The Silver layer prepares the transaction data for analysis.

Data transformation and cleaning are performed so that the transaction records can be reliably used for Gold-level aggregation and fraud analysis.

### Purpose

- Clean transaction data.
- Standardize data for analysis.
- Transform required fields.
- Prepare high-quality data for the Gold layer.

### Output

A cleaned and transformed Silver transaction dataset.

---

## Step 5 – Gold Aggregation

**Notebook:** `05_Gold_Aggregation.ipynb`

The Gold layer contains analytical data prepared for reporting and business analysis.

The Gold data is used as the foundation for the fraud detection and monitoring stage.

### Purpose

- Create analytical transaction data.
- Aggregate and organize information required for reporting.
- Prepare the final analytical dataset for fraud monitoring.

### Output

A Gold-level transaction table that can be queried by the fraud detection notebook and dashboard.

---

# 🚨 Step 6 – Fraud Detection

**Notebook:** `06_Fraud_Detection.ipynb`

This is the main fraud monitoring stage of the project.

The Gold transaction data is analyzed using fraud detection logic. A **fraud score** is calculated for transactions and the transactions are classified into different fraud levels.

The project uses three fraud categories:

| Fraud Level | Meaning |
|---|---|
| LOW | Low-risk transaction |
| MEDIUM | Transaction requiring additional attention |
| HIGH | High-risk / critical transaction |

The resulting fraud data is stored in a fraud-focused Gold table and is used by the Databricks dashboard.

### Main Output

The validation result showed:

| Fraud Level | Transactions | Average Fraud Score |
|---|---:|---:|
| HIGH | 458 | 69.3 |
| MEDIUM | 311 | 30 |
| LOW | 13,811 | 0 |

This result demonstrates that the HIGH-risk group has a significantly higher average fraud score than the LOW-risk group.

---

# ✅ Step 7 – Validation

After fraud detection, SQL validation was performed to verify whether the fraud scoring and classification were working correctly.

The validation grouped transactions by `fraud_level` and calculated:

- Number of transactions
- Average fraud score

The validation output was:

```text
HIGH    → 458 transactions  → Average score: 69.3
MEDIUM  → 311 transactions  → Average score: 30
LOW     → 13,811 transactions → Average score: 0
```

This validation provides evidence that the fraud classification is behaving as expected.

The project repository contains a screenshot of the successful validation output.

---

# 📊 Step 8 – Dashboard Creation

A Databricks dashboard named:

**UPI Transaction Fraud Monitoring**

was created using the processed fraud data.

The dashboard converts the SQL results into visual KPIs, charts, and tables so that users can understand the transaction and fraud situation without manually running SQL queries.

## Dashboard KPIs

The final dashboard displayed the following key metrics:

### Total Transactions

**14.58K**

This represents the total number of transactions included in the dashboard result.

### Fraud Rate

**5.27%**

The fraud rate represents the proportion of MEDIUM and HIGH fraud-level transactions compared with total transactions.

### Critical Fraud Alerts

**458**

This represents the number of HIGH-risk transactions.

### Total Transaction Amount

**₹502.53M**

This represents the total transaction amount displayed by the dashboard.

---

# 📈 Dashboard Visualizations

The dashboard includes visual components for monitoring fraud activity.

## Fraud Transactions Over Time

This visualization shows how fraud transactions change over time.

It helps identify periods where fraud activity increases or decreases.

## Average Fraud Score Trend

This visualization shows the change in average fraud score over time.

It helps users understand the overall risk level of transactions during different periods.

## Fraud Level Distribution

The dashboard displays the distribution of:

- LOW
- MEDIUM
- HIGH

fraud transactions.

The observed distribution is:

```text
LOW      : 13,811
MEDIUM   : 311
HIGH     : 458
```

## High-Risk Transactions

A dedicated table is provided for HIGH-risk transactions.

The table focuses on critical transactions and is sorted using the fraud score so that high-risk records can be reviewed more easily.

---

# 🎛️ Dashboard Filters

The dashboard provides interactive filters for analysis.

## 1. Date Range Filter

The user can select a date range using the **From → To** date selector.

This allows the dashboard to be analyzed for a specific time period.

## 2. Fraud Level Filter

The user can filter transactions based on fraud level:

- LOW
- MEDIUM
- HIGH

The filter can also be left as **All** to view the complete dataset.

## 3. Bank Filter

The dashboard also provides a bank filter.

Users can select a particular bank or keep the filter as **All**.

These filters make the dashboard interactive and allow users to focus on a specific part of the transaction data.

---

# 🌐 Published Dashboard

The final dashboard was published through Databricks.

The published dashboard is available through the following link:

**UPI Transaction Fraud Monitoring**

https://dbc-b18957d0-752a.cloud.databricks.com/dashboardsv3/01f1935c5a7c10feaf67e38e46368ef9/published?o=7474660330074134

The dashboard was configured so that the published link can be used to access the dashboard according to the sharing configuration used in Databricks.

> **Note:** Access to the dashboard may still depend on the Databricks workspace/sharing configuration.

The same link is also stored in:

```text
dashboard/dashboard_link.txt
```

---

# 📸 Project Screenshots

The `screenshots/` folder contains execution evidence collected during the project.

The screenshots cover the major stages of the pipeline:

| Screenshot | Stage |
|---|---|
| `01_Data_Generator.png` | Data generation |
| `02_Landing_Ingestion.png` | Landing and ingestion |
| `03_Bronze_Processing.png` | Bronze processing |
| `04_Silver_Transformation.png` | Silver transformation |
| `05_Gold_Aggregation_01.png` | Gold aggregation |
| `05_Gold_Aggregation_02.png` | Gold output/validation |
| `06_Fraud_Detection.png` | Fraud detection |
| `06_Validation.png` | Fraud validation |
| `07_Dashboard.png` | Dashboard |
| `07_Dashboard_01.png` | Dashboard visualization |
| `07_Dashboard_02.png` | Dashboard visualization |
| `07_Dashboard_03.png` | Dashboard visualization |

These screenshots provide visual proof that the individual stages were successfully executed in Databricks.

---

# 📓 Databricks Notebooks

The `notebooks/` directory contains the downloaded `.ipynb` files from Databricks.

| Notebook | Purpose |
|---|---|
| `01_Data_Generator.ipynb` | Generates simulated UPI transaction data |
| `02_Landing_Ingestion.ipynb` | Ingests the transaction data |
| `03_Bronze_Processing.ipynb` | Processes data in the Bronze layer |
| `04_Silver_Transformation.ipynb` | Cleans and transforms data |
| `05_Gold_Aggregation.ipynb` | Creates analytical Gold-level data |
| `06_Fraud_Detection.ipynb` | Calculates fraud scores and fraud levels |

The notebooks are included so that the complete implementation can be reviewed.

---

# 🧰 Technologies Used

| Technology | Usage |
|---|---|
| **Databricks** | Main data engineering and analytics platform |
| **PySpark** | Data processing and transformation |
| **Python** | Data generation and processing logic |
| **SQL** | Data validation, analysis, and dashboard queries |
| **Delta Lake** | Structured data storage and processing |
| **Databricks SQL Dashboard** | Visualization and fraud monitoring |
| **Jupyter Notebook (.ipynb)** | Exported project notebooks |

---

# 🏦 Business Problem

Digital payment systems process a large number of transactions every day. Detecting suspicious transactions manually is difficult because of the high volume of data.

This project demonstrates how a data engineering pipeline can process transaction data and provide fraud-related insights through automated scoring and classification.

The project focuses on:

- Transaction processing
- Data cleaning
- Data transformation
- Analytical aggregation
- Fraud scoring
- Fraud classification
- Fraud monitoring
- Interactive visualization

---

# 💡 Key Insights

Based on the final validation and dashboard output:

1. The pipeline processed approximately **14.58K transactions**.
2. There were **458 HIGH-risk transactions**.
3. There were **311 MEDIUM-risk transactions**.
4. There were **13,811 LOW-risk transactions**.
5. The calculated fraud rate was approximately **5.27%**.
6. HIGH-risk transactions had an average fraud score of **69.3**.
7. MEDIUM-risk transactions had an average fraud score of **30**.
8. LOW-risk transactions had an average fraud score of **0**.
9. The dashboard provides interactive analysis through date, fraud-level, and bank filters.
10. High-risk transactions can be reviewed separately using the dedicated high-risk transaction table.

---

# 🔍 Validation Summary

The fraud detection logic was not only implemented but also validated using SQL.

The validation confirmed that the risk levels were separated according to the calculated fraud scores.

The difference between the average scores is particularly useful:

```text
HIGH    → 69.3
MEDIUM  → 30
LOW     → 0
```

This gives a clear indication that the fraud scoring and classification stages are producing meaningful risk categories for monitoring.

---

# 📋 Project Deliverables

The final repository contains:

- ✅ Complete Databricks notebooks
- ✅ Data generation notebook
- ✅ Landing/ingestion notebook
- ✅ Bronze processing notebook
- ✅ Silver transformation notebook
- ✅ Gold aggregation notebook
- ✅ Fraud detection notebook
- ✅ Validation evidence
- ✅ Dashboard link
- ✅ Dashboard screenshots
- ✅ Pipeline execution screenshots
- ✅ Final project report
- ✅ README documentation

---

# 🚀 How to Review the Project

A reviewer can understand the project in the following order:

### 1. Read this README

Start with the project architecture and objectives.

### 2. Open the notebooks

Review the notebooks in numerical order:

```text
01 → 02 → 03 → 04 → 05 → 06
```

This follows the actual data flow.

### 3. Review the screenshots

Open the `screenshots/` directory to see successful execution at each stage.

### 4. Review the validation

Check `06_Validation.png` to verify the fraud-level counts and average fraud scores.

### 5. Open the dashboard

Use the link stored in:

```text
dashboard/dashboard_link.txt
```

to view the published fraud monitoring dashboard.

### 6. Review the final report

The detailed project report is available inside:

```text
report/
```

---

# ⚠️ Important Note

This project uses **simulated UPI transaction data** for educational and internship purposes. It does not represent real customer financial data.

The fraud detection logic is intended as a project demonstration of data engineering, risk scoring, and dashboard-based monitoring. It should not be treated as a production banking fraud detection system.

---

# 🔮 Future Enhancements

The project can be extended in the future with:

- Real-time transaction ingestion using streaming technologies.
- Kafka-based transaction streaming.
- Real-time fraud scoring.
- Machine learning-based fraud prediction.
- Advanced anomaly detection.
- Automated fraud alerts.
- Email/SMS notifications for critical transactions.
- Model monitoring and retraining.
- More advanced fraud rules.
- Role-based dashboard access.
- Integration with production payment systems.
- Cloud-based deployment and monitoring.

---

# 📌 Final Project Summary

The **Real-Time UPI Transaction & Fraud Detection Pipeline** demonstrates a complete data engineering workflow using Databricks.

The project starts with simulated UPI transaction data and processes it through ingestion, Bronze, Silver, and Gold layers. Fraud detection logic is then applied to generate fraud scores and classify transactions into LOW, MEDIUM, and HIGH risk levels.

The processed results are validated using SQL and presented through an interactive Databricks dashboard.

The final solution combines:

**Data Engineering + Delta/Medallion Architecture + PySpark + SQL + Fraud Detection + Data Visualization**

This provides an end-to-end demonstration of how transaction data can be transformed into useful fraud monitoring insights.

---

## 👤 Project Information

**Project Title:** Real-Time UPI Transaction & Fraud Detection Pipeline

**Project Type:** Internship Final Project

**Platform:** Databricks

**Domain:** Data Engineering / Financial Transaction Analytics / Fraud Monitoring

**Data:** Simulated UPI Transaction Data

---

## 📁 Final Repository Structure

```text
Project_UPI-Transaction-Fraud-Detection/
│
├── dashboard/
│   └── dashboard_link.txt
│
├── notebooks/
│   ├── 01_Data_Generator.ipynb
│   ├── 02_Landing_Ingestion.ipynb
│   ├── 03_Bronze_Processing.ipynb
│   ├── 04_Silver_Transformation.ipynb
│   ├── 05_Gold_Aggregation.ipynb
│   └── 06_Fraud_Detection.ipynb
│
├── report/
│   └── UPI_Transaction_Fraud_Monitoring_Report.pdf
│
├── screenshots/
│   ├── 01_Data_Generator.png
│   ├── 02_Landing_Ingestion.png
│   ├── 03_Bronze_Processing.png
│   ├── 04_Silver_Transformation.png
│   ├── 05_Gold_Aggregation_01.png
│   ├── 05_Gold_Aggregation_02.png
│   ├── 06_Fraud_Detection.png
│   ├── 06_Validation.png
│   ├── 07_Dashboard.png
│   ├── 07_Dashboard_01.png
│   ├── 07_Dashboard_02.png
│   └── 07_Dashboard_03.png
│
└── README.md
```

---

## ⭐ Conclusion

This project successfully demonstrates an end-to-end transaction data pipeline and fraud monitoring solution using Databricks.

It covers the complete journey from raw/simulated transaction generation to processed analytical data, fraud classification, validation, and dashboard-based monitoring.

The repository contains the implementation notebooks, execution screenshots, final report, and published dashboard reference so that the complete project can be reviewed from start to finish.

---

## 👩‍💻 Author

**Arati Thorat**  
Data Engineering Intern  
Celebal Technologies  
StudentId: CT_CSI_DE_1180
