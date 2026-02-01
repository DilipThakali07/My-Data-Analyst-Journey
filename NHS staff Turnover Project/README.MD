# 🏥 NHS Staff Turnover & Financial Impact Analysis (FY 2024/25)

## 📌 Project Overview
This project analyses the **impact of staff turnover on the financial health of NHS Trusts** for the financial year **2024/25**.  
The goal is to understand how workforce instability influences **agency staffing costs, overtime spending, and financial risk**, and to surface actionable insights for workforce planning and financial sustainability.

This is an **end-to-end data analytics project** covering:
- SQL data engineering & analysis (SQL Server)
- Business-focused exploratory data analysis
- Power BI dashboarding & storytelling

---

## 🎯 Business Problem
NHS organisations face increasing pressure from:
- High staff turnover
- Rising agency and overtime costs
- Budget constraints and financial overspend risks

This project answers:
- Does higher staff turnover lead to higher temporary staffing costs?
- Which trusts and staff groups drive financial pressure?
- Which organisations are financial and workforce risk outliers?

---

## 📊 Datasets Used
Two cleaned and modelled datasets were used:

### 1️⃣ Staff Turnover Dataset
Key fields:
- `trust_code`
- `organisation_name`
- `staff_group`
- `leaver_rate`


### 2️⃣ Financial Dataset
Key fields:
- `trust_code`
- `agency_staff_cost`
- `overtime_cost`
- `total_pay_cost`
- `financial_year`

---

## 🛠️ Tools & Technologies
- **SQL Server** – Data cleaning, modelling, views, analysis
- **Power BI** – Data modelling, DAX, interactive dashboards
- **GitHub** – Project documentation & version control

---

## 🧱 Data Modelling Approach
- Created clean schemas and views in SQL Server
- Aggregated turnover data at **trust level**
- Calculated financial ratios:
  - Agency % of total pay
  - Overtime % of total pay
  - Temporary staff cost %
## 🔍 Key Business Questions Answered

### Q1. What is the average staff turnover across NHS Trusts?
- Calculated the average leaver rate per trust
- Classified trusts into **Low**, **Medium**, and **High** turnover bands

### Q2. Do high-turnover trusts rely more on agency staff or overtime?
- Compared agency and overtime cost percentages by turnover band
- Found that **agency staff costs dominate across all bands**, not just in high-turnover trusts

### Q3. Which trusts are financial outliers?
- Identified trusts with:
  - High turnover
  - High temporary staffing cost percentages
- Classified organisations as:
  - **Within Expected Range**
  - **Moderate Outlier**
  - **Severe Outlier**

### Q4. Which staff groups drive financial pressure?
- Combined turnover and finance data by staff group via trust-level joins
- Highlighted the workforce segments contributing most to agency and overtime reliance

### Q5. Does turnover impact overall financial sustainability?
- Built a **Sustainability Risk Framework** using:
  - Turnover rate
  - Agency % of pay
  - Overtime % of pay
- Identified trusts at higher operational and financial risk

## 📈 Power BI Dashboard
The Power BI report presents insights through:

**KPI Cards:**
- Average Turnover Rate
- Average Agency Cost %
- Average Overtime Cost %

**Key Visuals:**
- Top 10 organisations by turnover
- Agency vs. overtime contribution by turnover band
- Turnover risk classification (donut chart)
- Outlier scatter plot: Turnover vs. Temporary Staff Cost

📸 *Dashboard preview included in repository*

## 🧠 Key Insights
- High turnover does **not** always correlate with the highest agency spend
- Some low-turnover trusts still rely heavily on agency staffing
- Financial risk is driven by **cost structure**, not turnover alone
- A small number of trusts represent disproportionate financial risk

### Example View:
```sql
CREATE VIEW vw_TrustTurnoverSummary AS
WITH turnover_summary AS (
    SELECT
        trust_code,
        MAX(organisation_name) AS organisation_name,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code
)
SELECT
    trust_code,
    organisation_name,
    ROUND(avg_leaver_rate, 3) AS avg_leaver_rate,
    CASE
        WHEN avg_leaver_rate < 0.08 THEN 'Low Turnover'
        WHEN avg_leaver_rate < 0.15 THEN 'Medium Turnover'
        ELSE 'High Turnover'
    END AS turnover_band
FROM turnover_summary;```



