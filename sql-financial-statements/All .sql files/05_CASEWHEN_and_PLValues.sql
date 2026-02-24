-- ============================================================
-- CASE WHEN  : Alternative to PIVOT for column pivoting
-- PLValues1  : Simple P&L values view (no country)
-- PLValues   : Full P&L values view (with country)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- CASE WHEN - Basic Examples
-- Alternative way to create year columns without PIVOT
-- ─────────────────────────────────────────────────────────────

-- By Territory and Account
Select Territory_key, Account_key,
    Sum(Case when Year(Date) = 2018 then Amount else 0 end) as '2018',
    Sum(Case when Year(Date) = 2019 then Amount else 0 end) as '2019',
    Sum(Case when Year(Date) = 2020 then Amount else 0 end) as '2020'

 from GL
 Group by Territory_key, Account_key
 Order by Territory_key, Account_key


-- By Account only
Select  Account_key,
    Sum(Case when Year(Date) = 2018 then Amount else 0 end) as '2018',
    Sum(Case when Year(Date) = 2019 then Amount else 0 end) as '2019',
    Sum(Case when Year(Date) = 2020 then Amount else 0 end) as '2020'

 from GL
 Group by Account_key
 Order by Account_key


-- Grand Total only
Select
    Sum(Case when Year(Date) = 2018 then Amount else 0 end) as '2018',
    Sum(Case when Year(Date) = 2019 then Amount else 0 end) as '2019',
    Sum(Case when Year(Date) = 2020 then Amount else 0 end) as '2020'

 from GL


-- ─────────────────────────────────────────────────────────────
-- CASE WHEN with JOIN - Extract Sales only
-- First step toward building PLValues
-- ─────────────────────────────────────────────────────────────

Select Year(Date) as Year,
    SUM(CASE When SubClass = 'Sales' then Amount else 0 end) as 'Sales'

from GL
JOIN COA ON GL.Account_key = COA.Account_key
Group by Year(Date)
Order by Year(Date)


-- ─────────────────────────────────────────────────────────────
-- CREATE VIEW PLValues1
-- All P&L summary metrics without Country breakdown
-- ─────────────────────────────────────────────────────────────

CREATE VIEW PLValues1 AS

Select Year(Date) as Year,
    SUM(CASE When SubClass = 'Sales' then Amount else 0 end) as 'Sales',
    SUM(CASE When Class = 'Trading account' then Amount else 0 end) as 'Gross_Profit',
    SUM(CASE When SubClass = 'Sales' OR SubClass = 'Cost of Sales' OR SubClass = 'Operating Expenses' then Amount else 0 end) as 'EBITDA',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' then Amount else 0 end) as 'Operating_Profit',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' OR Class = 'Non-operating' then Amount else 0 end) as 'PBIT',
    SUM(CASE When Report = 'Profit and Loss' then Amount else 0 end) as 'Net_Profit'
from GL
JOIN COA ON GL.Account_key = COA.Account_key
Group by Year(Date)

-- Quick test - calculate GP Margin from the view
Select "Gross_Profit"/"Sales"*100 as GP_Margin
from PLValues1


-- ─────────────────────────────────────────────────────────────
-- CREATE VIEW PLValues  (Final version with Country + extra metrics)
-- Includes Cost_of_Sales and Interest_Expense for ratio analysis
-- ─────────────────────────────────────────────────────────────

CREATE VIEW PLValues as

Select Country, Year(Date) as Year,
    SUM(CASE When SubClass = 'Sales' then Amount else 0 end) as 'Sales',
    SUM(CASE When Class = 'Trading account' then Amount else 0 end) as 'Gross_Profit',
    SUM(CASE When SubClass = 'Sales' OR SubClass = 'Cost of Sales' OR SubClass = 'Operating Expenses' then Amount else 0 end) as 'EBITDA',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' then Amount else 0 end) as 'Operating_Profit',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' OR Class = 'Non-operating' then Amount else 0 end) as 'PBIT',
    SUM(CASE When Report = 'Profit and Loss' then Amount else 0 end) as 'Net_Profit',
    SUM(CASE When SubClass = 'Cost of Sales' then Amount else 0 end) as 'Cost_of_Sales',
    SUM(CASE When SubClass = 'Interest Expense' then Amount else 0 end) as 'Interest_Expense'

from GL
JOIN COA ON GL.Account_key = COA.Account_key
JOIN Territory ON GL.Territory_key = Territory.Territory_key
Group by Year(Date), Country

-- Quick test - total Sales per Year across all countries
Select Year, SUM(Sales) as 'Sales' from PLValues
Group by Year
