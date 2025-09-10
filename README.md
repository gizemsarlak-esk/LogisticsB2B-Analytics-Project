# LogisticsB2B-Analytics-Project
End-to-end logistics analytics project using SQL and Power BI. Includes data preparation, KPI analysis, and interactive dashboard. Supplier data anonymized for confidentiality.
🔹 Project Overview

This project simulates a B2B logistics analytics case study, designed to showcase an end-to-end data pipeline from SQL data preparation to Power BI visualization.

Note: Supplier names and IDs have been anonymized for confidentiality.

🔹 Workflow

1. Data Preparation (SQL)

Created database schema (suppliers, orders, invoices).

Loaded and validated data with BULK INSERT.

Built enriched view v_orders_enriched (joins + KPIs: LeadTimeDays, OnTimeFlag, NetAmount).

Scripts available:

01_create_tables.sql

02_bulk_insert.sql

03_data_checks.sql

2. Analysis (SQL KPIs)

On-Time Delivery Rate.

Supplier performance (lead time vs. contract, reliability).

Customer spend (total & average).

Monthly and quarterly trends.

3. Visualization (Power BI)

Supplier Performance Overview (on-time %, orders, revenue).

Monthly Orders & On-Time Rate (trend analysis).

Top Customers (Top N by net spend).

Supplier KPI Matrix (orders, on-time %, lead time, total net).

Location Insights (distribution by city).

KPI cards for quick overview (Orders, On-Time %, Total Net).

🔹 Results & Insights

Average on-time delivery performance and supplier variability were highlighted.

Top customers identified, showing concentration of revenue.

Seasonal patterns observed (2023 + Q1 2024).

Dashboard provides management with actionable insights into supplier reliability, customer value, and geographic distribution.

🔹 Files in Repository

SQL/ → Scripts for table creation, data loading, and validation.

PowerBI/ → LogisticsB2B.pbix file.

README.md → Project documentation.

Screenshots/ → Key visuals from dashboard.
