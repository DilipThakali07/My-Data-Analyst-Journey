select *
from Hospital_Management

-- Q1. Total number of patients admitted
select count(*) [Total_Patients_Admitted]
from Hospital_Management

-- Q2. Monthly trend of patient admission
select datename(month, admissionDate) [Month_Name], count(*) [patient_admission]
from Hospital_Management
group by datename(month, admissionDate), month(admissiondate)
order by month(admissiondate) /* Order by month number to get chronological order from Jan (1) to Dec (12) */
/* Note: If data spans multiple years, months from all years are combined (e.g., all Januarys grouped together) */


SELECT 
    YEAR(admissionDate) AS [Year],
    DATENAME(month, admissionDate) AS [Month_Name], 
    COUNT(*) AS [patient_admission]
FROM Hospital_Management
GROUP BY YEAR(admissionDate), DATENAME(month, admissionDate), MONTH(admissionDate)
ORDER BY YEAR(admissionDate), MONTH(admissionDate) /* Monthly patient admissions by year, ordered chronologically
Includes both year and month number to prevent merging same months from different years  */

-- Q3. Patient count by department

select department, count(*)[total_Patient]
from Hospital_Management
group by Department
order by count(*) Desc;

-- Q4. Patient count by Disease
select Disease, count(*) [Total_Patients]
from Hospital_Management
group by Disease
order by count(*) desc;

--Q5. Average age of patients by disease
 
 select disease, AVG(age) [Average_Age]
 from Hospital_Management
 group by Disease
 order by Average_Age Desc

 -- Q6. Average length of Stay
 select AVG(datediff(day,admissiondate,dischargedate)) [Average_Los]
 from hospital_management -- simple query

 --Detail query
 select
    AVG(
        case
            when dischargedate is null then null --exclude ongoing patients
            when dischargedate < admissiondate then null --exclude invalid date pairs
            else datediff(day, admissiondate, dischargedate)
        end
    ) as [Average_LoS],
    count(*) as [Total_Patients],
    sum(case when dischargedate < admissiondate then 1 else 0 end) as [invalid_date_pairs]
from hospital_management

-- Q7 Average length of stay by department

select department, AVG(
        case
            when dischargedate is null then null --exclude ongoing patients
            when dischargedate < admissiondate then null --exclude invalid date pairs
            else datediff(day, admissiondate, dischargedate)
        end
    ) as [Average_LoS]
from Hospital_Management
group by department

--Q8 Patients with above average length of stay
select patientname, datediff(day, admissiondate, dischargedate) [LoS]
from Hospital_Management
where datediff(day, admissiondate, dischargedate) >
    (select AVG(datediff(day, admissiondate, dischargedate)) [Average_LoS] from hospital_management)

-- Q9. Admission by room type
select roomtype, count(*) [total_Admission]
from Hospital_Management
group by RoomType
order by count(*) desc

--Q10. Surgery rate (%)
-- Most reliable approach
SELECT 
    CAST(
        (COUNT(CASE WHEN SurgeryRequired = 1 THEN 1 END) * 100.0) / 
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS surgery_rate_percentage
FROM Hospital_Management;

--?? Q11. Total revenue generated
SELECT 
    round(SUM(TotalBillAmount) ,2)AS total_revenue
FROM Hospital_Management;

--?? Q12. Revenue by department
SELECT 
    Department,
    round(SUM(TotalBillAmount), 2) AS total_revenue
FROM Hospital_Management
GROUP BY Department
ORDER BY total_revenue DESC;

--?? Q13. Average bill amount by disease
SELECT 
    Disease,
    round(AVG(TotalBillAmount),2) AS avg_bill_amount
FROM Hospital_Management
GROUP BY Disease;

--?? Q14. Pending amount by insurance provider
SELECT 
    InsuranceProvider,
    round(SUM(PendingAmount),2) AS total_pending_amount
FROM Hospital_Management
GROUP BY InsuranceProvider;

--?? Q15. Payment completion rate
SELECT 
    round((SUM(AmountPaid) * 100.0) / SUM(TotalBillAmount),2) AS payment_completion_rate
FROM Hospital_Management;

--?? Q16. Rank departments by total revenue
SELECT 
    Department,
    round(SUM(TotalBillAmount),2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(TotalBillAmount) DESC) AS revenue_rank
FROM Hospital_Management
GROUP BY Department;

--?? Q17. Top 3 highest-billing patients per department
WITH ranked_patients AS (
    SELECT 
        Department,
        PatientName,
        TotalBillAmount,
        RANK() OVER (
            PARTITION BY Department 
            ORDER BY TotalBillAmount DESC
        ) AS rnk
    FROM Hospital_Management
)
SELECT *
FROM ranked_patients
WHERE rnk <= 3;

--?? Q18. Running total of monthly revenue
WITH monthly_revenue AS (
    SELECT 
        MONTH(AdmissionDate) AS month_no,
        DATENAME(MONTH, AdmissionDate) AS month_name,
        SUM(TotalBillAmount) AS revenue
    FROM Hospital_Management
    GROUP BY MONTH(AdmissionDate), DATENAME(MONTH, AdmissionDate)
)
SELECT *,
       SUM(revenue) OVER (ORDER BY month_no) AS running_total_revenue
FROM monthly_revenue;

--?? Q19. Rank doctors by patient volume
SELECT 
    DoctorName,
    COUNT(*) AS patient_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS doctor_rank
FROM Hospital_Management
GROUP BY DoctorName;

--?? Q20. Average feedback rating by department
SELECT 
    Department,
    AVG(FeedbackRating) AS avg_feedback_rating
FROM Hospital_Management
GROUP BY Department;



