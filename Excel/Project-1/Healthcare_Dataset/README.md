📊 Healthcare Data Analysis & Interactive Excel Dashboard

First End-to-End Excel Project | Data Cleaning, Analysis, KPIs & Dashboard

# 📊 Healthcare Data Analysis Dashboard

![Dashboard Preview](images/dashboard_overview.png)


This project is part of my data analytics career transition, where I am building real-world portfolio projects using Excel, SQL, and Power BI.
Here, I analyzed a synthetic healthcare dataset containing patient demographics, billing, admissions, medical conditions, medications, and doctor details.

The final outcome is a fully interactive Excel dashboard with slicers, KPIs, and data-driven insights.

🏥 Project Overview

This project demonstrates a complete end-to-end healthcare data analysis workflow using Microsoft Excel:

✔ Data Cleaning

✔ Data Transformation

✔ Derived Columns

✔ Advanced Excel Functions

✔ KPI Calculations

✔ Pivot Tables

✔ Interactive Slicers

✔ Dynamic KPI Cards

✔ Fully Functional Dashboard

📂 Dataset Description

The dataset includes:

| Column Name            | Description                   |
| ---------------------- | ----------------------------- |
| **Name**               | Patient full name             |
| **Age**                | Age of patient                |
| **Gender**             | Male/Female                   |
| **Blood Type**         | A/B/O/AB                      |
| **Medical Condition**  | Diagnosed condition           |
| **Date of Admission**  | Admission date                |
| **Doctor**             | Assigned doctor               |
| **Hospital**           | Hospital name                 |
| **Insurance Provider** | Insurance company             |
| **Billing Amount**     | Total billed amount           |
| **Room Number**        | Assigned room                 |
| **Admission Type**     | Elective / Emergency / Urgent |
| **Discharge Date**     | Patient discharge date        |
| **Medication**         | Prescribed medicines          |
| **Test Results**       | Diagnostic test results       |

🧹 1. Data Cleaning & Preparation

Cleaning performed using Excel:

✔ Removed Duplicates
✔ Corrected Data Types (Dates, Numbers, Text)
✔ Fixed inconsistent values
✔ Standardized text using:

=TRIM()
=PROPER()
=CLEAN()
✔ Converted into Excel Table → Data_Clean
✔ Added Derived Columns

1. Length of Stay
=[@[Discharge Date]] - [@[Date of Admission]]
2. Age Group
=IF([@Age]<18,"Child",IF([@Age]<30,"Young Adult",IF([@Age]<50,"Adult","Senior")))

3. Stay Category
=IF([@[Length of Stay]]<=3,"Short",IF([@[Length of Stay]]<=7,"Medium",IF([@[Length of Stay]]<=14,"Long","Very Long")))

4. Doctor–Patient Lookup Key
=[@Doctor] & "-" & [@Name]
🔍 2. Analysis Using Excel Functions

Key formulas used:

🔹 XLOOKUP

Find medical condition by patient name:

=XLOOKUP(G2, Data_Clean[Name], Data_Clean[Medical Condition])


Find billing amount by room number:

=XLOOKUP(G3, Data_Clean[Room Number], Data_Clean[Billing Amount])


Two-way lookup using helper key:

=XLOOKUP(H2 & "-" & I2, Data_Clean[Doctor_Name_Key], Data_Clean[Discharge Date])

🔹 SUMIFS / AVERAGEIFS / COUNTIFS

Used to build KPIs and summary tables.

Examples:

=SUMIFS(Data_Clean[Billing Amount], Data_Clean[Medical Condition], A2)
=AVERAGEIFS(Data_Clean[Billing Amount], Data_Clean[Gender], "Female")
=COUNTIFS(Data_Clean[Doctor], "Dr. Smith")

📈 3. Pivot Tables Created

Pivot tables were used to summarize:

Patient Count by Medical Condition

Billing Amount by Condition

Billing by Age Group

Admissions by Month

Gender Distribution

Average Length of Stay (LOS) by Condition

Doctor-wise Patient Load

📊 4. Interactive Excel Dashboard

The dashboard includes:

🔹 Slicers for:

Age Group

Gender

Medical Condition

Doctor

Admission Type

Stay Category

🔹 Timeline for:

Date of Admission

🔹 KPI Cards

Each KPI is dynamically linked to pivot table results:

Total Patients

Total Revenue

Average Billing

Average Length of Stay

KPI cards built using Excel Shapes linked with:

=Pivot_KPIs!C5

🔹 Visualizations

Charts included:

Pie Chart → Gender Distribution

Column Chart → Patients by Medical Condition

Line Chart → Monthly Admissions

Line Chart → Billing Trend

Area/Bar Chart → Average Length of Stay

Line Chart → Billing by Age Group

All visuals update automatically when slicers are changed.

🧠 Key Insights

Some of the insights discovered:

Adult and senior patients generated the highest revenue.

Admissions peak mid-year (June–August).

Cancer and diabetes had the longest length of stay.

Billing trends showed strong seasonal patterns.

Some doctors handled significantly more patients than others.

🎯 Skills Demonstrated

This project helped me build and practice:

Data Cleaning in Excel

Data Transformation

Advanced Excel Functions

Pivot Tables & Charts

Slicers & Timeline

Dashboard Design

KPI Creation

Healthcare domain understanding

Storytelling with Data

📁 Project Files
File	Description
Healthcare_Dashboard.xlsx	Final dashboard with slicers & KPIs
Healthcare_Dataset_Cleaned.xlsx	Cleaned table with derived columns
README.md	Project documentation
🙋‍♂️ About Me

Hi! I’m Dilip Thakali, transitioning from civil engineering & healthcare into data analytics.
My focus areas include Excel, SQL, Python, Power BI, and real-world analytics projects.

I aim to build strong portfolio projects and secure a data analyst role, especially in healthcare or sales analytics.

🔗 Connect With Me

LinkedIn: [https://www.linkedin.com/in/dilip-thakali07/]

GitHub: [https://github.com/DilipThakali07]

YouTube: [https://www.youtube.com/@DilipThakali07]


