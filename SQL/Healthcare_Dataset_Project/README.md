# 🏥 Hospital Billing SQL Project – End-to-End Analysis (Q1–Q12)

## 📌 Project Overview

This project simulates a **real-world healthcare data analysis** scenario using SQL. The goal is to transform raw hospital billing data into **business-ready insights and KPIs** that can be directly used in **Power BI dashboards**.

I approached this as a **career-transition data analyst project**, focusing not only on SQL syntax but also on **why each step matters from a business and reporting perspective**.

---

## 🗂️ Dataset Description

The dataset represents hospital patient records with the following key fields:

* Patient Name
* Age, Gender, Blood Type
* Medical Condition
* Admission & Discharge Dates
* Hospital & Doctor
* Insurance Provider
* Billing Amount
* Admission Type
* Medication & Test Results

---

## 🎯 Business Objectives

* Understand hospital billing patterns
* Identify high-cost patients and hospitals
* Measure operational efficiency (Length of Stay)
* Create **Power BI–ready KPIs** for healthcare reporting

---

# 🔹 STEP-BY-STEP SQL ANALYSIS

> Below, each question includes **clean SQL snippets**, **business logic**, and **Power BI mapping** so this project is fully end-to-end.

---

## Q1️⃣ Data Cleaning – Proper Patient Name Formatting

**Problem:** Patient names were inconsistent.

```sql
SELECT 
  CONCAT(
    UPPER(LEFT(name,1)), 
    LOWER(SUBSTRING(name,2,LEN(name)))
  ) AS clean_name
FROM hospital_data;
```

**Business Value:** Clean dimensions improve dashboard trust.

📊 **Power BI:** Use `clean_name` as Patient dimension.

---

## Q2️⃣ Identify Total Number of Patients

```sql
SELECT COUNT(DISTINCT name) AS total_patients
FROM hospital_data;
```

📊 **KPI Card:** Total Patients

---

## Q3️⃣ Total Revenue Generated

```sql
SELECT SUM(billing_amount) AS total_revenue
FROM hospital_data;
```

📊 **KPI Card:** Total Revenue (£)

---

## Q4️⃣ Revenue by Hospital

```sql
SELECT hospital, SUM(billing_amount) AS revenue
FROM hospital_data
GROUP BY hospital;
```

📊 **Power BI:** Bar Chart – Revenue by Hospital

---

## Q5️⃣ Average Billing Amount per Patient

```sql
SELECT AVG(billing_amount) AS avg_billing
FROM hospital_data;
```

📊 **KPI Card:** Avg Billing

---

## Q6️⃣ Patient Distribution by Admission Type

```sql
SELECT admission_type, COUNT(*) AS patients
FROM hospital_data
GROUP BY admission_type;
```

📊 **Power BI:** Donut Chart – Admission Types

---

## Q7️⃣ Length of Stay (LOS) Calculation

```sql
SELECT 
  DATEDIFF(day, date_of_admission, discharge_date) AS length_of_stay
FROM hospital_data;
```

📊 **KPIs:** Avg LOS, LOS by Hospital

---

## Q8️⃣ High-Cost Patients Identification

```sql
SELECT name, billing_amount
FROM hospital_data
WHERE billing_amount > (
  SELECT AVG(billing_amount) FROM hospital_data
);
```

📊 **Power BI:** Table – High-Cost Patients

---

## Q9️⃣ Insurance Provider Analysis

```sql
SELECT insurance_provider, SUM(billing_amount) AS revenue
FROM hospital_data
GROUP BY insurance_provider;
```

📊 **Power BI:** Bar Chart – Revenue by Insurance

---

## Q1️⃣0️⃣ Top 3 Highest-Cost Patients per Hospital

```sql
WITH ranked_patients AS (
  SELECT hospital, name, billing_amount,
         RANK() OVER (PARTITION BY hospital ORDER BY billing_amount DESC) AS rnk
  FROM hospital_data
)
SELECT *
FROM ranked_patients
WHERE rnk <= 3;
```

📊 **Power BI:** Matrix – Hospital → Patient → Billing

---

## Q1️⃣1️⃣ Doctor Performance – Revenue Contribution

```sql
SELECT doctor, SUM(billing_amount) AS revenue
FROM hospital_data
GROUP BY doctor;
```

📊 **Power BI:** Bar Chart – Revenue by Doctor

---

## Q1️⃣2️⃣ Hospital Efficiency Score (Revenue vs LOS)

```sql
SELECT hospital,
       AVG(billing_amount) AS avg_revenue,
       AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS avg_los,
       AVG(billing_amount) / NULLIF(AVG(DATEDIFF(day, date_of_admission, discharge_date)),0) AS revenue_per_day
FROM hospital_data
GROUP BY hospital;
```

📊 **Power BI:** Scatter Plot – Revenue vs LOS

---

# 📊 FINAL KPI LIST (POWER BI READY)

✔ Total Patients
✔ Total Revenue
✔ Avg Billing Amount
✔ Revenue by Hospital
✔ Revenue by Insurance Provider
✔ Avg Length of Stay
✔ LOS by Hospital
✔ Emergency Admission %
✔ Top 3 Patients per Hospital
✔ Revenue by Doctor
✔ Revenue per Day of Stay
✔ Hospital Efficiency Index

---

# 🧠 Skills Demonstrated

* SQL Data Cleaning
* Aggregations & Grouping
* Window Functions (`RANK()`)
* Healthcare Business Understanding
* KPI Design for Power BI
* Analytical Thinking

---

# 📊 POWER BI DASHBOARD WIREFRAME

### Page 1: Executive Overview

* KPI Cards: Total Revenue, Total Patients, Avg LOS
* Bar: Revenue by Hospital
* Donut: Admission Types

### Page 2: Financial Analysis

* Revenue by Insurance
* Top 3 Patients per Hospital
* Revenue by Doctor

### Page 3: Operational Efficiency

* Avg LOS by Hospital
* Scatter: Revenue vs LOS

---

# 🧩 Portfolio Roadmap

This project is **Project 1** in my Healthcare Analytics Portfolio:

1. Hospital Billing Analysis (SQL + Power BI)
2. Readmission Analysis
3. Patient Flow Optimization
4. Cost Reduction Dashboard

---

# 📣 LinkedIn Project Announcement (Ready to Post)

**Title:** From Healthcare Worker to Data Analyst – SQL Healthcare Project

"I analyzed real-world hospital billing data using SQL, calculated KPIs like Length of Stay, Revenue per Hospital, and built Power BI–ready insights. This project reflects my journey transitioning from healthcare into data analytics."

#SQL #DataAnalytics #HealthcareAnalytics #PowerBI #CareerTransition

---

⭐ Star the repo if this helped you. Connect with me on LinkedIn.

**Author:** Dilip Thakali

