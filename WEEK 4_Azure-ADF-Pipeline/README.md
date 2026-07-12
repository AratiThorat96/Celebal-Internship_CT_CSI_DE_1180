# Week 4 Assignment – Celebal Technologies Data Engineering Internship

# Azure Cloud Fundamentals and Data Pipeline Implementation using Azure Data Factory
---

# 📌 Objective

The objective of this assignment was to understand Microsoft Azure cloud fundamentals and build a complete data pipeline using Azure Storage Account and Azure Data Factory (ADF).

The project demonstrates how data can be securely stored, validated, and copied using Azure cloud services without writing custom code.

---

# 🛠️ Technologies Used

- Microsoft Azure Portal
- Azure Resource Group
- Azure Storage Account
- Azure Blob Storage
- Azure Data Factory (ADF)
- Azure Integration Runtime
- Azure IAM (Role-Based Access Control)

---

# 📂 Dataset

**Dataset Name:** Superstore.csv

The dataset was uploaded to Azure Blob Storage and used as the source file for the Azure Data Factory pipeline.

---

# 📁 Project Workflow

```
Azure Blob Storage (raw-data)
          │
          ▼
    Get Metadata Activity
          │
          ▼
     Copy Data Activity
          │
          ▼
Azure Blob Storage (processed-data)
```

---

# 🚀 Steps Performed

### Task 1
- Explored Azure Portal
- Created Resource Group

### Task 2
- Created Storage Account
- Created Blob Containers
- Uploaded Superstore.csv

### Task 3
- Created Azure Data Factory
- Created Linked Service
- Created Source Dataset
- Created Destination Dataset
- Configured Get Metadata Activity

### Task 4
- Built Azure Data Factory Pipeline
- Connected Get Metadata and Copy Data Activities

### Task 5
- Executed Pipeline
- Verified Successful Execution
- Checked Output in Processed Container

### Task 6
- Explored Azure IAM
- Studied Reader, Contributor, and Storage Blob Data Contributor roles

---

# 📊 Pipeline Flow

```
Superstore.csv
      │
      ▼
Raw Data Container
      │
      ▼
Get Metadata
      │
      ▼
Copy Data
      │
      ▼
Processed Data Container
```

---

# ✅ Output

The pipeline executed successfully.

- Source file validated using Get Metadata.
- CSV file copied successfully.
- Destination container received the copied file.
- Pipeline execution status: **Succeeded**

---

# 📚 Key Learnings

- Azure Resource Group management
- Azure Storage Account
- Azure Blob Storage
- Azure Data Factory
- Linked Services
- Datasets
- Get Metadata Activity
- Copy Data Activity
- Azure IAM (RBAC)
- Pipeline Monitoring

---

# 📷 Project Screenshots

The **Output_Screenshots** folder contains screenshots for:

- Resource Group
- Storage Account
- Blob Containers
- Uploaded CSV File
- Azure Data Factory
- Linked Service
- Source Dataset
- Destination Dataset
- Get Metadata Activity
- Pipeline Design
- Pipeline Execution
- Processed Output
- IAM Roles

---

# 📄 Report

The complete internship report is available as:

**Azure_Week4_Report.pdf**

---

# 📖 References

- Microsoft Azure Documentation
- Microsoft Learn
- Azure Data Factory Documentation
- Azure Blob Storage Documentation

---

## ⭐ Internship Assignment

This repository contains the Week 4 assignment completed during the **Celebal Technologies Data Engineering Internship**, focusing on Azure Cloud Fundamentals and Azure Data Factory.
