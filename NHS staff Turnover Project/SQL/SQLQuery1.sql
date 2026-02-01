
create database NHS_Staff_Turnover_Analysis;
use NHS_Staff_Turnover_Analysis;

-- create schemas
create schema raw;
create schema clean;
create schema dim;
create schema fact;

drop schema if exists fact;

select * from [NHS_Staff_Turnover_Analysis].[raw].[staff_turnover_raw];

select * from [NHS_Staff_Turnover_Analysis].[raw].[Finance_Dataset_raw];

-- Data Profiling (Read-only)
-- Row Count

select count(*) as total_rows
from [raw].[staff_turnover_raw];

-- Null and Blank Check
SELECT
    SUM(CASE WHEN joiners IS NULL OR LTRIM(RTRIM(joiners)) = '' THEN 1 ELSE 0 END) AS joiners_missing,
    SUM(CASE WHEN leavers IS NULL OR LTRIM(RTRIM(leavers)) = '' THEN 1 ELSE 0 END) AS leavers_missing,
    SUM(CASE WHEN trust_code  IS NULL OR LTRIM(RTRIM(trust_code))  = '' THEN 1 ELSE 0 END) AS trust_code_missing
FROM raw.staff_turnover_raw;

-- Percentage stored as Text

SELECT leaver_rate, joiner_rate, stability_index
FROM raw.staff_turnover_raw
WHERE leaver_rate LIKE '%[%]%' or joiner_rate like '%[%]%';

-- Duplicate Check
select organisation_name,staff_group,trust_code
from [raw].[staff_turnover_raw]
group by organisation_name,
    staff_group,
    trust_code
having count(*) >1;

-- Data Cleaning
-- clean staff turnover table
select 
    trim(organisation_name) as Organisation_Name,
    upper(Trust_code) as Trust_Code,
    upper(nhse_region_code) as Region_code,
    trim(nhse_region_name) as Region_Name,
    upper(ics_name) as ICS_Name,
    trim(cluster_group) as Cluster_Group,
    trim(staff_group) as Staff_Group,
    try_cast(joiners as int) as Joiners,
    try_cast(replace(trim(joiner_rate), '%', '') as decimal(5,2)) /100 as Joiner_Rate,
    try_cast(leavers as int) as Leavers,
    try_cast(replace(trim(leaver_rate), '%', '') as decimal(5,2)) / 100 as Leaver_Rate,
    try_cast(replace(trim(Stability_index), '%', '') as decimal(5,2)) as Stability_Index
into clean.staff_turnover_clean
from raw.staff_turnover_raw;

-- handle NULLs and Blank identifiers

delete from clean.staff_turnover_clean
where Trust_Code is null or Staff_Group is null
    or Trust_Code = '' or Staff_Group = '';

ALTER TABLE clean.staff_turnover_clean
ADD staff_group_std VARCHAR(100) NULL;

UPDATE clean.staff_turnover_clean
-- 1. Apply classification
UPDATE clean.staff_turnover_clean
SET staff_group_std = 
    CASE staff_group
        WHEN 'HCHS doctors (exc. Resident doctors and equivalents)' THEN 'Medical & Dental'
        WHEN 'SCIENTIFIC, THERAPEUTIC & TECHNICAL STAFF' THEN 'Allied Health Professionals'
        WHEN 'Nurses & health visitors' THEN 'Nursing & Midwifery'
        WHEN 'Midwives' THEN 'Nursing & Midwifery'
        WHEN 'Managers' THEN 'Management'
        WHEN 'Senior managers' THEN 'Management'
        WHEN 'All staff groups' THEN 'Organisation Total'
        WHEN 'Central functions' THEN 'Support Staff'
        WHEN 'Hotel, property & estates' THEN 'Support Staff'
        WHEN 'Support to doctors, nurses & midwives' THEN 'Clinical Support'
        WHEN 'Support to ST&T staff' THEN 'Clinical Support'
        WHEN 'Ambulance staff' THEN 'Ambulance Staff'
        WHEN 'Support to ambulance staff' THEN 'Ambulance Staff'
        WHEN 'Unknown classification' THEN 'Unclassified'
        WHEN 'Staff group' THEN 'Unclassified'
        ELSE staff_group_std
    END;

-- 2. View results
SELECT 
    staff_group_std,
    COUNT(*) as record_count
FROM [NHS_Staff_Turnover_Analysis].clean.staff_turnover_clean
GROUP BY staff_group_std
ORDER BY record_count DESC;



select count(*) from clean.staff_turnover_clean

-- Duplicate Resolution
-- Detect grain violations
select 
   trust_code,
staff_group,
    count(*) as count
from clean.staff_turnover_clean
group by  trust_code,
staff_group
     
having count(*) >1;

-- Remove duplicate

with cte_duplicate as (
    select *,
    row_number() over(partition by
    trust_code,
    staff_group,
    organisation_name,
    region_code,
    region_name
    order by organisation_name
) as Row_Num
from clean.staff_turnover_clean
)
delete
from cte_duplicate
where Row_Num > 1;

--cleaning finance Table
select * from [raw].[Finance_Dataset_raw]


select 
    upper(trust_code) as Trust_Code,
    trim(financial_year) as Financial_Year,
    try_cast(agency_staff_cost as int) as Agency_Staff_Cost,
    try_cast(overtime_cost as int) as Overtime_Cost,
    try_cast(total_pay_cost as int) as Total_Pay_Cost
into clean.finance_dataset_clean
from raw.Finance_Dataset_raw

select * from [NHS_Staff_Turnover_Analysis]. clean.finance_dataset_clean

with dup_cte as (
select *,
ROW_NUMBER() over(partition by trust_code, financial_year, Agency_Staff_Cost,Overtime_Cost, Total_Pay_Cost
order by financial_year) as Row_Num
from clean.finance_dataset_clean
)
delete from dup_cte
where row_num >1



-- Data Exploration
-- confirm clean data

SELECT COUNT(DISTINCT trust_code) AS total_trusts
FROM clean.staff_turnover_clean;

SELECT COUNT(DISTINCT trust_code) AS total_trusts
FROM clean.finance_dataset_clean;

/* “Distinct trust validation confirmed 254 common NHS trusts across workforce and finance datasets for FY 2024/25, 
ensuring consistency for joined analysis.*/

-- Explore staff Turnover
-- Distribution of turnover rate

select 
    min(leaver_rate) as Min_turnover,
    max(leaver_rate) as Max_Turnover,
    AVG(leaver_rate) as Avg_Turnover,
    STDEV(leaver_rate) as Std_Turnover
from clean.staff_turnover_clean
where leaver_rate between 0 and 0.3;

-- Report outliers separately
select 
    count(*) as outlier_records
from clean.staff_turnover_clean
where Leaver_Rate > 0.3;

/* “Descriptive statistics were calculated using turnover rates between 0% and 30% to
reflect realistic NHS workforce patterns. 
Extreme values were excluded and reported separately as data quality outliers.”
select * from raw.staff_turnover_raw */


SELECT
    count(*)
FROM clean.staff_turnover_clean
  where (leaver_rate > 1)

SELECT TOP 20
    trust_code,
    organisation_name,
    leavers,
    leaver_rate
FROM clean.staff_turnover_clean
WHERE leaver_rate > 1
ORDER BY leaver_rate DESC;

CREATE VIEW staff_turnover_cleaned AS
SELECT *
FROM clean.staff_turnover_clean
WHERE leaver_rate BETWEEN 0 AND 0.5

delete from [NHS_Staff_Turnover_Analysis].[clean].[finance_dataset_clean]
where trust_code is null;

select * from staff_turnover_cleaned

/* EDA identified 95 records with leaver rate above 100%, which is not realistic at NHS trust level. These records
were excluded from analysis using a clean analytical view capped between 0% and 30% turnover. */

-- Turnover Distribution Analysis

WITH TurnoverData AS (
    SELECT 
        CASE
            WHEN leaver_rate < 0.1 THEN 'Low (0-10%)'
            WHEN leaver_rate < 0.2 THEN 'Medium (10-20%)'
            WHEN leaver_rate <= 0.3 THEN 'High (20-30%)'
        END AS Turnover_Band
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
)
SELECT 
    Turnover_Band,
    COUNT(*) AS Trust_Count
FROM TurnoverData
GROUP BY Turnover_Band
ORDER BY Turnover_Band;

/* 📌 Insight to look for

If many trusts sit in 20–30%, that’s a retention risk signal

Majority in 10–20% = system pressure but not collapse */

-- Trust-Level Risk Identification
-- Flag High_Risk Trusts
select
    trust_code,
    Organisation_name,
    leaver_rate
from clean.staff_turnover_clean
where Leaver_Rate between 0.2 and 0.3
order by Leaver_Rate desc

/* 📌 These trusts are:

Priority for HR intervention

Likely linked to higher agency spend */

-- Stability index Check
select 
    min(stability_index) as min_stability,
    max(stability_index) as max_stability,
    AVG(stability_index) as avg_stability
from clean.staff_turnover_clean

-- Part B Financial Data EDA
-- Overall Cost Distribution
select 
min((agency_staff_cost/total_pay_cost) * 100) as min_agency_pct,
max((agency_staff_cost/total_pay_cost) *100) as max_agency_pct,
AVG((agency_staff_cost/ total_pay_cost) * 100) as avg_agency_pct
from clean.finance_dataset_clean
where Agency_Staff_Cost is not null
      and Total_Pay_Cost is not null
      and Total_Pay_Cost > 0;

select * from [NHS_Staff_Turnover_Analysis].clean.finance_dataset_clean;
SELECT 
    COUNT(*) as record_count,
    MIN((try_CAST(agency_staff_cost AS DECIMAL(10,2)) / total_pay_cost * 100)) as min_agency_pct,
    MAX((try_CAST(agency_staff_cost AS DECIMAL(10,2)) / total_pay_cost * 100)) as max_agency_pct,
    AVG((try_CAST(agency_staff_cost AS DECIMAL(10,2)) / total_pay_cost * 100)) as avg_agency_pct
FROM clean.finance_dataset_clean
WHERE agency_staff_cost IS NOT NULL 
    AND total_pay_cost IS NOT NULL 
    ;

SELECT 
    CASE 
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 100 THEN '0-100%'
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 200 THEN '101-200%'
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 500 THEN '201-500%'
        ELSE '500%+'
    END as pct_range,
    COUNT(*) as record_count,
    AVG(agency_staff_cost * 100.0 / total_pay_cost) as avg_pct,
    MIN(agency_staff_cost * 100.0 / total_pay_cost) as min_pct,
    MAX(agency_staff_cost * 100.0 / total_pay_cost) as max_pct
FROM clean.finance_dataset_clean
WHERE agency_staff_cost IS NOT NULL 
    AND total_pay_cost IS NOT NULL 
    AND total_pay_cost > 0
GROUP BY 
    CASE 
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 100 THEN '0-100%'
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 200 THEN '101-200%'
        WHEN (agency_staff_cost * 100.0 / total_pay_cost) <= 500 THEN '201-500%'
        ELSE '500%+'
    END
ORDER BY MIN(agency_staff_cost * 100.0 / total_pay_cost);

SELECT TOP 10
    agency_staff_cost,
    total_pay_cost,
    (agency_staff_cost * 100.0 / total_pay_cost) as pct_calculated,
    agency_staff_cost - total_pay_cost as excess_amount,
    (agency_staff_cost - total_pay_cost) * 100.0 / total_pay_cost as excess_pct
FROM clean.finance_dataset_clean
WHERE agency_staff_cost IS NOT NULL 
    AND total_pay_cost IS NOT NULL 
    AND total_pay_cost > 0
    AND agency_staff_cost > total_pay_cost  -- Only show > 100%
ORDER BY pct_calculated DESC;


SELECT TOP 10
    trust_code,
    agency_staff_cost,
    total_pay_cost,
    ROUND((agency_staff_cost * 100.0 / total_pay_cost), 2) AS agency_pct
FROM clean.finance_dataset_clean
WHERE financial_year = '2024/25'
    AND total_pay_cost > 0
ORDER BY agency_staff_cost DESC;

-- Combined EDA 
-- JOIN staffturnover + finance (EDA view)

SELECT
    s.trust_code,
    s.organisation_name,
    s.leaver_rate,
    s.stability_index,
    f.agency_staff_cost,
    f.overtime_cost,
    f.total_pay_cost
FROM clean.staff_turnover_clean s
JOIN clean.finance_dataset_clean f
    ON s.trust_code = f.trust_code

-- Turnover Bands
SELECT
    CASE
        WHEN leaver_rate < 0.1 THEN 'Low Turnover'
        WHEN leaver_rate BETWEEN 0.1 AND 0.15 THEN 'Medium Turnover'
        ELSE 'High Turnover'
    END AS turnover_band,
    COUNT(*) AS trust_count
FROM clean.staff_turnover_clean
GROUP BY
    CASE
        WHEN leaver_rate < 0.1 THEN 'Low Turnover'
        WHEN leaver_rate BETWEEN 0.1 AND 0.15 THEN 'Medium Turnover'
        ELSE 'High Turnover'
    END;

-- Financial Pattern by Turnover Band
SELECT
    turnover_band,
    ROUND(AVG(CAST(agency_staff_cost AS DECIMAL(18,2))), 2) AS avg_agency_cost,
    ROUND(AVG(CAST(overtime_cost AS DECIMAL(18,2))), 2) AS avg_overtime_cost
FROM (
    SELECT
        s.trust_code,
        CASE
            WHEN s.leaver_rate < 0.1 THEN 'Low Turnover (0–10%)'
            WHEN s.leaver_rate BETWEEN 0.1 AND 0.20 THEN 'Medium Turnover (10–20%)'
            WHEN s.leaver_rate BETWEEN 0.20 AND 0.30 THEN 'High Turnover (20–30%)'
        END AS turnover_band,
        ISNULL(f.agency_staff_cost, 0) AS agency_staff_cost,
        ISNULL(f.overtime_cost, 0) AS overtime_cost
    FROM clean.staff_turnover_clean s
    JOIN clean.finance_dataset_clean f
        ON s.trust_code = f.trust_code
    WHEre
      s.leaver_rate BETWEEN 0 AND 0.3
) x
GROUP BY turnover_band
ORDER BY turnover_band;




SELECT
    turnover_band,
    ROUND(AVG(agency_ratio) * 100, 2) AS avg_agency_percent_of_pay
FROM (
    SELECT
        s.trust_code,
        CASE
            WHEN s.leaver_rate < 0.1 THEN 'Low Turnover (0–10%)'
            WHEN s.leaver_rate BETWEEN 0.10 AND 0.20 THEN 'Medium Turnover (10–20%)'
            WHEN s.leaver_rate BETWEEN 0.20 AND 0.30 THEN 'High Turnover (20–30%)'
        END AS turnover_band,
        CAST(f.agency_staff_cost AS DECIMAL(18,2)) /
        NULLIF(CAST(f.total_pay_cost AS DECIMAL(18,2)), 0) AS agency_ratio
    FROM clean.staff_turnover_clean s
    JOIN clean.finance_dataset_clean f
        ON s.trust_code = f.trust_code
    where s.leaver_rate BETWEEN 0 AND 0.3
) x
GROUP BY turnover_band
ORDER BY turnover_band;

-- Segment by staff group

SELECT
    s.staff_group,
    CASE
        WHEN s.leaver_rate < 0.10 THEN 'Low'
        WHEN s.leaver_rate BETWEEN 0.10 AND 0.20 THEN 'Medium'
        ELSE 'High'
    END AS turnover_band,
    ROUND(AVG(
        CAST(f.agency_staff_cost AS DECIMAL(18,2)) /
        NULLIF(CAST(f.total_pay_cost AS DECIMAL(18,2)),0)
    ) * 100, 2) AS avg_agency_percent
FROM clean.staff_turnover_clean s
JOIN clean.finance_dataset_clean f
  ON s.trust_code = f.trust_code
WHERE
  s.leaver_rate BETWEEN 0 AND 0.30
GROUP BY
    s.staff_group,
    CASE
        WHEN s.leaver_rate < 0.10 THEN 'Low'
        WHEN s.leaver_rate BETWEEN 0.10 AND 0.20 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY s.staff_group, turnover_band;

-- Analysis
select * from clean.staff_turnover_clean;

-- which trust have hightest staff turnover in 2024/25?
-- Q1: Highest staff turnover in 2024/25
-- Rank trusts by leaver rate (0-50% range)
SELECT TOP 20
    trust_code,
    Organisation_Name,
    ROUND(leaver_rate * 100, 2) AS leaver_rate_percent,
    RANK() OVER (ORDER BY leaver_rate DESC) AS turnover_rank
FROM [NHS_Staff_Turnover_Analysis]. clean.staff_turnover_clean
WHERE leaver_rate BETWEEN 0 AND 0.5  -- 0-50% range
    AND leaver_rate IS NOT NULL
ORDER BY leaver_rate DESC;

-- Categorise trusts into turnover risk band

select 
    trust_code,
    organisation_name,
    ROUND(avg(leaver_rate),2) as avg_leaver_rate,
   case 
    when AVG(leaver_rate ) < 0.15 then 'Low Turnover'
    when AVG(leaver_rate) between 0.15 and 0.30 then 'Medium_Turnover'
    else 'High Turnover'
   end as turnover_risk
from [NHS_Staff_Turnover_Analysis].clean.staff_turnover_clean
where Leaver_Rate between 0 and 0.5
group by 
    Trust_Code,
    Organisation_Name
order by avg_leaver_rate desc;

/* “When turnover was averaged at trust level, no organisations exceeded the high-turnover threshold. 
This indicates that workforce instability is concentrated within specific staff groups rather than affecting
entire organisations.” */


-- Question 2 How is staff turnover distributed across nhs trusts in 2024/25

with trust_turnover as (
    select 
        trust_code,
        organisation_name,
        avg(leaver_rate) as avg_leaver_rate
    from [NHS_Staff_Turnover_Analysis].clean.staff_turnover_clean
    where leaver_rate between 0 and 0.5
    group by 
        trust_code,
        organisation_name
)
select 
    case
        when avg_leaver_rate < 0.1 then 'Low Turnover (< 10%)'
        when avg_leaver_rate between 0.1 and 0.2 then 'Moderate Turnover (10-20%)'
        else 'Eleveted Turnover (> 20%)'
    end as turnover_band,
    count(*) as trust_count,
    round(
        count(*) * 100 / sum(count(*)) over (),1
    ) as percent_of_trusts
from trust_turnover
group by 
    case
        when avg_leaver_rate < 0.1 then 'Low Turnover (< 10%)'
        when avg_leaver_rate between 0.1 and 0.2 then 'Moderate Turnover (10-20%)'
        else 'Eleveted Turnover (> 20%)'
    end
order by trust_count desc;

/* “Most NHS trusts fall within a moderate staff turnover range, indicating system-wide workforce pressure 
rather than isolated organisational failure. Only a smaller proportion of trusts experience elevated turnover, 
suggesting targeted intervention would be more effective than blanket policies.” */

-- Do trusts with higher staff turnover rely more on agency staffs or overtime?

/* some trusts have NULL Agency_staff_cost, So we assume trust did not use agency staff or data not reprted separately. */
select * from [NHS_Staff_Turnover_Analysis].[clean].[finance_dataset_clean]

-- convert null --> 0

SELECT
    trust_code,
    COALESCE(agency_staff_cost, 0) AS agency_staff_cost,
    COALESCE(overtime_cost, 0) AS overtime_cost,
    total_pay_cost,
    ROUND(
        CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(18,2))
        / NULLIF(total_pay_cost, 0) * 100,
        2
    ) AS agency_percent_of_pay,
    ROUND(
        CAST(COALESCE(overtime_cost, 0) AS DECIMAL(18,2))
        / NULLIF(total_pay_cost, 0) * 100,
        2
    ) AS overtime_percent_of_pay
FROM [NHS_Staff_Turnover_Analysis].clean.finance_dataset_clean


WITH trust_turnover AS (
    SELECT
        Organisation_Name,
        trust_code,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
      where leaver_rate BETWEEN 0 AND 30
    GROUP BY trust_code, Organisation_Name
),
trust_finance AS (
    SELECT
        trust_code,
        ROUND(
            CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS agency_percent_of_pay,
        ROUND(
            CAST(COALESCE(overtime_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS overtime_percent_of_pay
    FROM clean.finance_dataset_clean
    
)
SELECT
    t.organisation_name,
    t.trust_code,
    ROUND(t.avg_leaver_rate, 3) AS avg_leaver_rate,
    f.agency_percent_of_pay,
    f.overtime_percent_of_pay
FROM trust_turnover t
LEFT JOIN trust_finance f
    ON t.trust_code = f.trust_code
ORDER BY avg_leaver_rate DESC;

-- **************************
WITH trust_turnover AS (
    SELECT
        trust_code,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE 
      leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code
),
trust_finance AS (
    SELECT
        trust_code,
        ROUND(
            CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS agency_percent_of_pay,
        ROUND(
            CAST(COALESCE(overtime_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS overtime_percent_of_pay
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
),
combined AS (
    SELECT
        t.trust_code,
        t.avg_leaver_rate,
        CASE
            WHEN t.avg_leaver_rate < 0.08 THEN 'Low Turnover'
            WHEN t.avg_leaver_rate BETWEEN 0.08 AND 0.15 THEN 'Medium Turnover'
            ELSE 'High Turnover'
        END AS turnover_band,
        f.agency_percent_of_pay,
        f.overtime_percent_of_pay
    FROM trust_turnover t
    LEFT JOIN trust_finance f
        ON t.trust_code = f.trust_code
)
SELECT
    turnover_band,
    ROUND(AVG(agency_percent_of_pay), 2) AS avg_agency_percent,
    ROUND(AVG(overtime_percent_of_pay), 2) AS avg_overtime_percent,
    COUNT(*) AS trust_count
FROM combined
GROUP BY turnover_band
ORDER BY
    CASE turnover_band
        WHEN 'Low Turnover' THEN 1
        WHEN 'Medium Turnover' THEN 2
        ELSE 3
    END;

-- Are high-turnover trusts more likely to overspend?

WITH trust_turnover AS (
    SELECT
        trust_code,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    where leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code
),
trust_finance AS (
    SELECT
        trust_code,
        CAST(total_pay_cost AS DECIMAL(18,2)) AS total_pay_cost
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
),
combined AS (
    SELECT
        t.trust_code,
        t.avg_leaver_rate,
        f.total_pay_cost,
        CASE
            WHEN t.avg_leaver_rate < 0.08 THEN 'Low Turnover'
            WHEN t.avg_leaver_rate BETWEEN 0.08 AND 0.15 THEN 'Medium Turnover'
            ELSE 'High Turnover'
        END AS turnover_band
    FROM trust_turnover t
    JOIN trust_finance f
        ON t.trust_code = f.trust_code
)
SELECT
    turnover_band,
    COUNT(*) AS trust_count,
    ROUND(AVG(total_pay_cost) / 1000000, 2) AS avg_pay_cost_million
FROM combined
GROUP BY turnover_band
ORDER BY
    CASE turnover_band
        WHEN 'Low Turnover' THEN 1
        WHEN 'Medium Turnover' THEN 2
        ELSE 3
    END;


-- Qn 6, Do high turnover trusts show signs of long-term workforce sustainability risk?


WITH trust_turnover AS (
    SELECT 
        trust_code,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code
),
trust_finance AS (
    SELECT
        trust_code,
        ROUND(
            TRY_CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS agency_percent_of_pay,
        ROUND(
            TRY_CAST(COALESCE(overtime_cost, 0) AS DECIMAL(18,2))
            / NULLIF(total_pay_cost, 0) * 100, 2
        ) AS overtime_percent_of_pay
    FROM clean.finance_dataset_clean
),
combined AS (
    SELECT 
        t.trust_code,
        t.avg_leaver_rate,
        f.agency_percent_of_pay,
        f.overtime_percent_of_pay,
        CASE  
            WHEN t.avg_leaver_rate > 0.15
                 AND f.agency_percent_of_pay > 15
                 AND f.overtime_percent_of_pay > 3
                THEN 'High Sustainability Risk'
            WHEN t.avg_leaver_rate > 0.10
                 AND (f.agency_percent_of_pay > 15
                      OR f.overtime_percent_of_pay > 3)
                THEN 'Moderate Sustainability Risk'
            ELSE 'Lower Sustainability Risk'
        END AS sustainability_risk
    FROM trust_turnover t
    JOIN trust_finance f
        ON t.trust_code = f.trust_code
)
SELECT 
    sustainability_risk,
    COUNT(*) AS trust_count,
    ROUND(AVG(avg_leaver_rate), 3) AS avg_leaver_rate,
    ROUND(AVG(agency_percent_of_pay), 2) AS avg_agency_percent,
    ROUND(AVG(overtime_percent_of_pay), 2) AS avg_overtime_percent
FROM combined
GROUP BY sustainability_risk
ORDER BY trust_count DESC;

-- Q7. What actions should NHS Trusts take to improve sustainability based on turnover and financial patterns?


-- Which staff groups drive financial pressure?


WITH staff_group_turnover AS (
    SELECT
        trust_code,
        staff_group,
        AVG(leaver_rate) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code, staff_group
),
trust_finance AS (
    SELECT
        trust_code,
        ROUND(
            AVG(
                CAST(COALESCE(agency_staff_cost, 0) + COALESCE(overtime_cost, 0) AS DECIMAL(18,4))
                / NULLIF(CAST(total_pay_cost AS DECIMAL(18,4)), 0) * 100
            ), 2
        ) AS temporary_staff_cost_percent
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
    GROUP BY trust_code
),
combined AS (
    SELECT
        s.staff_group,
        s.trust_code,
        ROUND(s.avg_leaver_rate, 3) AS avg_leaver_rate,
        f.temporary_staff_cost_percent
    FROM staff_group_turnover s
    JOIN trust_finance f
        ON s.trust_code = f.trust_code
)
SELECT
    staff_group,
    ROUND(AVG(avg_leaver_rate), 3) AS avg_leaver_rate,
    ROUND(AVG(CAST(temporary_staff_cost_percent AS DECIMAL(18,4))), 2)
        AS avg_temp_staff_cost_percent,
    COUNT(DISTINCT trust_code) AS number_of_trusts
FROM combined
GROUP BY staff_group
ORDER BY avg_temp_staff_cost_percent DESC;


-- How does staff turnover affect cost structure?

WITH trust_turnover AS (
    SELECT
        trust_code,
        ROUND(AVG(leaver_rate), 3) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
    GROUP BY trust_code
),
trust_cost_structure AS (
    SELECT
        trust_code,
        -- Use larger precision for NHS financial data
        SUM(CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(28,2))) AS agency_cost,
        SUM(CAST(COALESCE(overtime_cost, 0) AS DECIMAL(28,2))) AS overtime_cost,
        SUM(CAST(total_pay_cost AS DECIMAL(28,2))) AS total_pay_cost,
        ROUND(
            SUM(CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(28,2))) 
            / NULLIF(SUM(CAST(total_pay_cost AS DECIMAL(28,2))), 0) * 100, 
            2
        ) AS agency_percent,
        ROUND(
            SUM(CAST(COALESCE(overtime_cost, 0) AS DECIMAL(28,2))) 
            / NULLIF(SUM(CAST(total_pay_cost AS DECIMAL(28,2))), 0) * 100, 
            2
        ) AS overtime_percent
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
    GROUP BY trust_code
)
SELECT
    CASE
        WHEN t.avg_leaver_rate < 0.10 THEN 'Low Turnover'
        WHEN t.avg_leaver_rate BETWEEN 0.10 AND 0.15 THEN 'Medium Turnover'
        ELSE 'High Turnover'
    END AS turnover_band,
    COUNT(*) AS trust_count,
    ROUND(AVG(t.avg_leaver_rate), 3) AS avg_leaver_rate,
    ROUND(AVG(CAST(c.agency_percent AS DECIMAL(18,4))), 2) AS avg_agency_percent,
    ROUND(AVG(CAST(c.overtime_percent AS DECIMAL(18,4))), 2) AS avg_overtime_percent
FROM trust_turnover t
JOIN trust_cost_structure c
    ON t.trust_code = c.trust_code
GROUP BY
    CASE
        WHEN t.avg_leaver_rate < 0.10 THEN 'Low Turnover'
        WHEN t.avg_leaver_rate BETWEEN 0.10 AND 0.15 THEN 'Medium Turnover'
        ELSE 'High Turnover'
    END
ORDER BY avg_agency_percent DESC;

-- Which trusts are outliers?


WITH turnover_summary AS (
    SELECT
        Organisation_Name,
        trust_code,
        ROUND(AVG(leaver_rate), 3) AS avg_leaver_rate
    FROM clean.staff_turnover_clean
    WHERE leaver_rate BETWEEN 0 AND 0.3
    GROUP BY Organisation_Name, trust_code
),
finance_summary AS (
    SELECT
        trust_code,
        SUM(CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(28,4))) AS agency_cost,
        SUM(CAST(COALESCE(overtime_cost, 0) AS DECIMAL(28,4))) AS overtime_cost,
        SUM(CAST(total_pay_cost AS DECIMAL(28,4))) AS total_pay_cost
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
    GROUP BY trust_code
),
combined AS (
    SELECT
        t.Organisation_Name,
        t.trust_code,
        t.avg_leaver_rate,
        f.agency_cost,
        f.overtime_cost,
        f.total_pay_cost,
        CASE 
            WHEN f.total_pay_cost > 0 
            THEN ROUND(
                CAST((f.agency_cost + f.overtime_cost) AS DECIMAL(28,4)) 
                / f.total_pay_cost * 100, 
                2
            )
            ELSE 0 
        END AS temp_staff_cost_percent
    FROM turnover_summary t
    JOIN finance_summary f ON t.trust_code = f.trust_code
)
SELECT
    organisation_name,
    trust_code,
    avg_leaver_rate,
    temp_staff_cost_percent,
    CASE
        WHEN avg_leaver_rate > 0.15
         AND temp_staff_cost_percent > 20
         THEN 'Severe Outlier'
        WHEN avg_leaver_rate > 0.12
         AND temp_staff_cost_percent > 15
         THEN 'Moderate Outlier'
        ELSE 'Within Expected Range'
    END AS outlier_status
FROM combined
ORDER BY temp_staff_cost_percent DESC;


-- VIEW 1  Trust Turnover Summary

CREATE  VIEW vw_TurstTurnoverSummary AS 
with turnover_summary as (
    select
        trust_code,
        max(organisation_name) as organisation_name,
        round(avg(leaver_rate),3) as Avg_Leaver_rate
    from clean.staff_turnover_clean
    where leaver_rate between 0 and 0.3
    group by trust_code
)
select 
    trust_code,
    organisation_name,
    avg_leaver_rate,
    case
        when avg_leaver_rate <0.1 then 'Low Turnover'
        when avg_leaver_rate between 0.1 and 0.2 then 'Medium Turnover'
        else 'High Turnover'
    end as turnover_band
from turnover_summary

-- view 2  Trust Cost Structure
CREATE VIEW vw_TrustCostStructure AS
WITH finance_summary AS (
    SELECT
        trust_code,
        SUM(CAST(COALESCE(agency_staff_cost, 0) AS DECIMAL(28,4))) AS agency_cost,
        SUM(CAST(COALESCE(overtime_cost, 0) AS DECIMAL(28,4))) AS overtime_cost,
        SUM(CAST(total_pay_cost AS DECIMAL(28,4))) AS total_pay_cost
    FROM clean.finance_dataset_clean
    WHERE financial_year = '2024/25'
    GROUP BY trust_code
)
SELECT
    trust_code,
    ROUND(
        CASE 
            WHEN total_pay_cost > 0 
            THEN (agency_cost / total_pay_cost) * 100
            ELSE 0 
        END, 2
    ) AS agency_percent_of_pay,
    ROUND(
        CASE 
            WHEN total_pay_cost > 0 
            THEN (overtime_cost / total_pay_cost) * 100
            ELSE 0 
        END, 2
    ) AS overtime_percent_of_pay,
    ROUND(
        CASE 
            WHEN total_pay_cost > 0 
            THEN ((agency_cost + overtime_cost) / total_pay_cost) * 100
            ELSE 0 
        END, 2
    ) AS temp_staff_cost_percent
FROM finance_summary;

-- View 3 outlier Classification

CREATE VIEW vw_OutlierClassification AS
WITH combined AS (
    SELECT
        t.trust_code,
        t.organisation_name,
        t.avg_leaver_rate,
        c.temp_staff_cost_percent
    FROM vw_TurstTurnoverSummary t
    JOIN vw_TrustCostStructure c ON t.trust_code = c.trust_code
)
SELECT
    trust_code,
    organisation_name,
    avg_leaver_rate,
    temp_staff_cost_percent,
    CASE
        WHEN avg_leaver_rate > 0.15 AND temp_staff_cost_percent > 20 
            THEN 'Severe Outlier'
        WHEN avg_leaver_rate > 0.12 AND temp_staff_cost_percent > 15 
            THEN 'Moderate Outlier'
        ELSE 'Within Expected Range'
    END AS outlier_status
FROM combined;