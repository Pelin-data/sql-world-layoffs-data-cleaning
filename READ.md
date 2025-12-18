# World Layoffs – SQL Data Cleaning Project

This project demonstrates a complete SQL data cleaning workflow using MySQL.

## 🔧 Skills Used
- SQL (MySQL)
- Data Cleaning
- Staging Tables
- Window Functions (ROW_NUMBER)
- Duplicate Removal
- NULL & Blank Handling
- Text Standardization (TRIM)
- Date Conversion (STR_TO_DATE)

## 📊 Dataset
Global layoffs dataset (2,300+ rows)

## 🛠 Workflow
Raw Data → Staging → Staging2 → Cleaned Dataset

## 📁 Files
- `02_data_cleaning.sql` – full data cleaning script

## 🚀 Outcome
The dataset was cleaned and prepared for exploratory data analysis (EDA).

Note: Due to MySQL limitations, duplicate records were removed using a second staging table instead of deleting directly from a CTE.

