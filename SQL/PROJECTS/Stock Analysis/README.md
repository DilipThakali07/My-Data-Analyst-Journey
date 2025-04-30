# Introduction <br>
This is my first project where I analyzed the historical prices of Tesla stock using SQL. Since I’m interested in the stock market and its trends, I chose this topic to begin my data analysis journey. In this blog, I’ll guide you through the steps I followed — from cleaning the data to gaining insights using SQL queries.
<br>
## The Dataset
- The dataset includes historical prices of Tesla stock from 2000 to 2025. It contains columns such as:
- Date
- Open, Close, High, and Low Prices
- Volume <br>
The data was taken from [Kaggle](https://www.kaggle.com/datasets/taimoor888/tesla-stock-price-data-2000-2025)

### Step 1: Cleaning the Data
I used SQL to clean the data by:
1. Removing duplicate records
2. Handling missing values
3. Fixing data types (e.g., converting text to DATE)

Since this dataset had no duplicates or missing values, cleaning was straightforward. I also removed unnecessary columns and renamed some columns to make the data easier to work with.
<pre> ```SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Standardizing Data

SELECT 
  TRIM(`Date`) AS Date,
  TRIM(`Close`) AS Close,
  TRIM(High) AS High,
  TRIM(Low) AS Low,
  TRIM(`Open`) AS Open,
  TRIM(Volume) AS Volume
FROM tesla_database;

SELECT `date`,
STR_TO_DATE(`date`, '%Y-%m-%d')
FROM tesla_database;

UPDATE tesla_database
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

SELECT `date`
FROM tesla_database;

ALTER TABLE tesla_database
MODIFY COLUMN `Date` DATE;

-- Change the number of digit after decimal

ALTER TABLE tesla_database
MODIFY `Close` DECIMAL(17,4),
MODIFY High DECIMAL(17,4),
MODIFY low DECIMAL(17,4),
MODIFY `open` DECIMAL(17,4); ``` </pre>

### Step 2: Exploratory Analysis
Next, I performed exploratory analysis by writing SQL queries — from basic to advanced — to answer important questions generate by using ChatGPT. This helped me practice and demonstrate my SQL skills.
The questions I answerd are as follows. <br>
<hr>
#### Basic Level <br>
Focus: SELECT, WHERE, ORDER BY, GROUP BY, LIMIT, simple calculations<br>
1.	Get the first 10 rows of Tesla stock data.<br>
→ Use SELECT and LIMIT.<br>
2.	List all distinct stock names in the dataset.<br>
→ Use DISTINCT.<br>
3.	Find the date and closing price when Tesla had the highest price.<br>
→ Use MAX() with WHERE.<br>
4.	What is the average closing price of Tesla in 2023?<br>
→ Use AVG() with WHERE and YEAR().<br>
5.	Count how many trading days are available stock.<br>
→ Use GROUP BY and COUNT().<br>
6.	What is the highest and lowest volume traded for the given stock?<br>
→ Use GROUP BY with MAX() and MIN().<br>
<hr>
🟡 Intermediate-Level (Data Patterns & Comparisons) <br>
Focus: GROUP BY, DATE_FORMAT, CASE, calculated fields, aliases <br>
7.	Calculate the daily return (%) for Tesla. <br>
→ Formula: (close_price - open_price) / open_price * 100 <br>
List the top 5 most volatile days by daily % change (abs). <br>
→ Use ABS() and ORDER BY. <br>
8.	Find the average monthly closing price for both stocks. <br>
→ Use GROUP BY DATE_FORMAT(date, '%Y-%m'). <br>
9.	Find the number of days each stock closed higher than it opened. <br>
→ Use CASE WHEN close_price > open_price THEN 1 ELSE 0 END.<br>
10.	Compare average daily volumes of Tesla in 2024.<br>
→ Use WHERE with GROUP BY.<br>
<hr>
🔵 Advanced-Level (Analytics, Trends & Business Insights) <br>
Focus: WINDOW FUNCTIONS, CTEs, LAG(), LEAD(), JOIN, subqueries <br>
13.	Calculate the 7-day moving average of closing price of stock.<br>
→ Use AVG() OVER(PARTITION BY stock_name ORDER BY date ROWS 6 PRECEDING). <br>
14.	Find days where trading volume was twice the monthly average for that stock. <br>
→ Use CTE or JOIN with subquery on monthly average.<br>
15.	Find the maximum drawdown for each stock.<br>
16.	Identify days with a price gap-up or gap-down > 3% from previous close.<br>
→ Use LAG() and percent change.<br>
17.	Rank Tesla and NVIDIA daily based on performance.<br>
→ Use RANK() OVER(PARTITION BY date ORDER BY daily_return DESC).<br>
18.	Compare cumulative return for stock over a selected year.<br>
19.	Flag all non-trading days (weekends/holidays) missing in the dataset.<br>
→ Use a calendar table and LEFT JOIN.<br>
20.	If you invested $1000 at the beginning of each month, how much would it be worth now?<br>

The answers of the above questions are [found here](https://github.com/DilipThakali07/My-Data-Analyst-Journey/blob/main/SQL/PROJECTS/Stock%20Analysis/stock_analysis.sql)
### What I Learned
SQL is a powerful tool for analyzing large datasets and identifying patterns.
- Data cleaning is just as important as analysis — it’s a key part of the process.
- Even simple SQL queries can reveal valuable business insights.
- To use SQL queries to solve real world problems.
