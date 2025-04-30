SELECT * 
FROM tesla_stock_data_2000_2025;

ALTER TABLE tesla_stock_data_2000_2025
RENAME COLUMN Price TO `Date`;

DELETE FROM tesla_stock_data_2000_2025
WHERE (`Date` = 'Ticker' AND `Close` = 'TSLA');

DELETE FROM tesla_stock_data_2000_2025
WHERE (`Date` = `Date` AND `Close` = '');

CREATE TABLE Tesla_Database LIKE tesla_stock_data_2000_2025; 

INSERT INTO Tesla_Database SELECT * FROM tesla_stock_data_2000_2025;

SELECT * FROM Tesla_Database;

DROP TABLE tesla_databse;


SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Date`, `Close`, High, Low, `Open`, Volume) AS row_num
FROM tesla_database;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Date`, `Close`, High, Low, `Open`, Volume) AS row_num
FROM tesla_database
)
SELECT *
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
MODIFY `open` DECIMAL(17,4);

 -- Questions
 -- 1.	Get the first 10 rows of Tesla stock data.
 SELECT *
 FROM tesla_database
 LIMIT 10;
 
 -- 2.	List all distinct stock names in the dataset
 SELECT DISTINCT * 
FROM tesla_database;

-- 3. Find the date and closing price when Tesla had the highest price.
SELECT `Date`, `Close`, `High`
FROM tesla_database
WHERE `High` = (SELECT MAX(`High`) FROM tesla_database);

-- OR

SELECT `Date`, `Close`, `High`
FROM tesla_database
ORDER BY `High` DESC
LIMIT 1;

-- 4. What is the average closing price of Tesla in 2023?
SELECT 
  YEAR(`Date`) AS year,
  ROUND(AVG(`Close`), 4) AS average_closing_price
FROM tesla_database
WHERE YEAR(`Date`) = 2023
GROUP BY YEAR(`Date`);

-- 5.Count how many trading days are available for each stock.
SELECT 
COUNT(DISTINCT `Date`) AS Trading_Days
FROM tesla_database;

-- 6. What is the highest and lowest volume traded for stock?
SELECT MAX(VOLUME) AS Max_Volume, MIN(VOLUME) AS Min_Volume
FROM tesla_database;

-- Intermediate -Level (Data Patterns and Comparison)

-- 7.	Calculate the daily return (%) for Tesla.
SELECT `Date`, `open`, `close`,
ROUND(((`close` - `open`)/ `open`) * 100, 2) AS Daily_Return_Pct
FROM tesla_database
WHERE `open` IS NOT NULL AND `close` IS NOT NULL
ORDER BY `Date`;

-- 8.	List the top 5 most volatile days by daily % change (abs).

SELECT `Date`, `open`, `close`,
ROUND(((`close` - `open`)/ `open`) * 100, 2) AS Daily_Return_Pct,
ROUND(ABS((`close` - `open`)/ `open`) * 100, 2) AS daily_volatility_pct
FROM tesla_database
WHERE `open` IS NOT NULL AND `close` IS NOT NULL
ORDER BY daily_volatility_pct DESC
LIMIT 5;

-- 9.Find the average monthly closing price.
SELECT 
DATE_FORMAT(`Date`, '%Y-%m') AS `Month`,
ROUND(AVG(`close`), 2) AS Avg_Monthly_Close
FROM tesla_database
WHERE `close` IS NOT NULL
GROUP BY DATE_FORMAT(`Date`, '%Y-%m')
ORDER BY `Month`;

-- 10.	Find the number of days closed higher than it opened.

SELECT 
 SUM(CASE WHEN close > open THEN 1 ELSE 0 END) AS days_closed_higher
FROM tesla_database;

-- OR
SELECT 
  COUNT(*) AS days_closed_higher
FROM tesla_database
WHERE close > open;

-- 11.Compare average daily volumes of Tesla in 2024.

SELECT 
	AVG(volume) AS avg_daiy_volume_2024
FROM tesla_database
WHERE YEAR(date) = 2024;

-- Monthly Comparison in 2024

SELECT 
MONTH(DATE) AS month,
AVG(volume) AS avg_daily_volume
FROM tesla_database
WHERE YEAR(date) = 2024
GROUP BY MONTH(date)
ORDER BY MONTH(Date);

-- Advance Level
-- 1. Calculate the 7-day moving average of closing price for each stock.

SELECT 
	`Date`,
    `Close`,
    ROUND(AVG(`Close`) OVER (
    ORDER BY `Date`
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 4) AS moving_avg_7_day
FROM tesla_database;

-- Find days where trading volume was twice the monthly average for that stock.

SELECT 
	sp.Date,
    sp.Volume,
    ma.avg_volume,
    ROUND(sp.Volume / ma.avg_volume, 2) AS ratio
FROM tesla_database sp
JOIN (
	SELECT
		YEAR(Date) AS year,
        MONTH(Date) AS month,
        ROUND(AVG(Volume), 2) AS avg_volume
	FROM tesla_database
    GROUP BY YEAR(Date), MONTH(Date)
) AS ma
	ON YEAR(sp.Date) = ma.year
    AND MONTH(sp.Date) = ma.month
WHERE sp.Volume > 2 * ma.avg_volume;

-- OR

WITH monthyly_avg AS (
SELECT 
	YEAR(Date) AS year,
    MONTH(Date) AS month,
    ROUND(AVG(Volume), 2) AS avg_volume
FROM tesla_database
GROUP BY YEAR(Date), MONTH(Date)
)

SELECT 
sp.Date,
sp.Volume,
ma.avg_volume,
ROUND(sp.Volume / ma.avg_volume, 2) AS ratio
FROM tesla_database sp
JOIN monthyly_avg ma 
	ON YEAR(sp.Date) = ma.year
  AND MONTH(sp.Date) = ma.month
WHERE sp.Volume > 2 * ma.avg_volume;
	
-- Find the maximum drawdown for each stock.

WITH price_lagged AS (
    SELECT
        Date,
        Close,
        LAG(Close) OVER (ORDER BY Date) AS prev_close
    FROM tesla_database
),
peaks_and_drawdown AS (
    SELECT
        Date,
        Close,
        MAX(Close) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS peak_price,
        (Close - MAX(Close) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) 
            / MAX(Close) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS drawdown
    FROM price_lagged
)
SELECT 
    MIN(drawdown) AS max_drawdown
FROM peaks_and_drawdown;

SELECT 
    Date,
    drawdown
FROM (
    SELECT 
        Date,
        Close,
        MAX(Close) OVER (ORDER BY Date) AS peak_price,
        (Close - MAX(Close) OVER (ORDER BY Date)) / MAX(Close) OVER (ORDER BY Date) AS drawdown
    FROM tesla_database
) AS sub
ORDER BY drawdown ASC
LIMIT 1;

-- Identify days with a price gap-up or gap-down > 3% from previous close.
WITH price_gaps AS (
    SELECT
        Date,
        `Open`,
        `Close`,
        LAG(`Close`) OVER (ORDER BY Date) AS prev_close,
        ROUND(((`Open` - LAG(`Close`) OVER (ORDER BY Date)) / LAG(`Close`) OVER (ORDER BY Date)) * 100, 2) AS gap_percent
    FROM tesla_database
)
SELECT *
FROM price_gaps
WHERE ABS(gap_percent) > 3;

SELECT
    Date,
    `Open`,
    `Close`,
    ROUND((`Close` - `Open`) / `Open` * 100, 2) AS daily_return_percent,
    RANK() OVER (ORDER BY (`Close` - `Open`) / `Open` DESC) AS performance_rank
FROM tesla_database;

--	If you invested $1000 at the beginning of each month, how much would it be worth now?

WITH first_trading_days AS (
    SELECT MIN(Date) AS invest_date
    FROM tesla_database
    GROUP BY YEAR(Date), MONTH(Date)
),
monthly_prices AS (
    SELECT t.Date AS invest_date, t.Open AS start_price
    FROM tesla_database t
    JOIN first_trading_days f ON t.Date = f.invest_date
),
daily_returns AS (
    SELECT Date, (Close - Open) / Open AS daily_return
    FROM tesla_database
),
investment_growth AS (
    SELECT 
        m.invest_date,
        t.Date AS current_day,
        m.start_price,
        EXP(SUM(LOG(1 + d.daily_return)) OVER (PARTITION BY m.invest_date ORDER BY t.Date)) AS growth_multiplier
    FROM monthly_prices m
    JOIN tesla_database t ON t.Date >= m.invest_date
    JOIN daily_returns d ON d.Date = t.Date
),
latest_value_per_investment AS (
    SELECT 
        invest_date,
        ROUND(1000 * MAX(growth_multiplier), 2) AS value_today
    FROM investment_growth
    GROUP BY invest_date
),
investment_tracker AS (
    SELECT 
        invest_date,
        SUM(1000) OVER (ORDER BY invest_date) AS monthly_investment_value,
        SUM(ROUND(1000 * MAX(growth_multiplier), 2)) OVER (ORDER BY invest_date) AS total_portfolio_value
    FROM investment_growth
    GROUP BY invest_date
)

SELECT 
    invest_date AS month_start_date,
    monthly_investment_value,
    total_portfolio_value
FROM investment_tracker
ORDER BY invest_date;
