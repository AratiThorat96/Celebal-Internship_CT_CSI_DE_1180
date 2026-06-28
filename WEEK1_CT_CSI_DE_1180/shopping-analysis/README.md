# Week 1 Assignment – Celebal Technologies Data Engineering Internship

## Shopping Dataset Analysis and Data Cleaning

### Overview

This project was completed as part of the Celebal Technologies Data Engineering Internship Program. The objective of this assignment was to perform data exploration, data cleaning, feature engineering, and basic data analysis using Python and Pandas.

The analysis was conducted on a shopping dataset containing product information such as category, pricing, ratings, and customer reviews.

---

## Objectives

* Load and explore the dataset using Pandas
* Understand dataset structure and data types
* Identify and handle missing values
* Remove duplicate records
* Perform feature engineering
* Conduct exploratory data analysis (EDA)
* Generate visualizations for insights
* Save the cleaned dataset for further analysis

---

## Dataset

Dataset Used: **Combined_dataset.csv**

The dataset contains product-related information including:

* Product Title
* Category
* Initial Price
* Final Price
* Ratings
* Number of Ratings
* Product Details

---

## Tools and Libraries Used

* Python
* Pandas
* NumPy
* Matplotlib
* Seaborn
* Jupyter Notebook

---

## Data Cleaning Process

The following data cleaning steps were performed:

* Checked dataset structure and summary statistics
* Identified missing values
* Converted price-related columns to numeric format
* Handled missing values where necessary
* Removed duplicate records
* Verified data consistency

---

## Feature Engineering

Additional features were created to enhance analysis:

### Price Difference

Price Difference = Initial Price − Final Price

### Discount Percentage

Discount Percentage = (Price Difference / Initial Price) × 100

### Popularity Score

Popularity Score = Rating × Number of Ratings

---

## Exploratory Data Analysis

The following analyses were performed:

* Product rating distribution
* Category-level product distribution
* Relationship between ratings and review counts
* Relationship between discounts and ratings
* Popularity analysis
* Category performance comparison

---

## Visualizations

Several visualizations were created, including:

* Histograms
* Bar Charts
* Box Plots
* Correlation Analysis Charts

These visualizations helped identify trends, patterns, and business insights from the dataset.

---

## Key Insights

* More than half of the products have ratings above 4.0.
* A few major categories account for a large portion of the catalog.
* Higher ratings are only weakly related to review volume.
* Larger discounts do not necessarily result in higher customer satisfaction.
* Popularity score helps identify products that are both highly rated and widely reviewed.
* Smaller categories such as cutlery and personal care products show strong customer satisfaction.

---

## Project Structure

shopping-analysis/

│

├── data/

│   ├── Combined_dataset.csv

│   └── cleaned_dataset.csv

│

├── notebook/

│   └── analysis.ipynb

│

└── README.md

---

## Output Files

* analysis.ipynb
* cleaned_dataset.csv
* README.md

---

## Author

**Arati Sunil Thorat**

Data Engineering Intern

Celebal Technologies Internship Program 2026
