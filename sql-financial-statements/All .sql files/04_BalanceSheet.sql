-- ============================================================
-- Lecture 25 : Balance Sheet (WRONG approach - learning step)
-- Lecture 26 : SUM OVER Order by (Running Total)
-- Lecture 27 : SUM OVER Partition by Order by (by Year)
-- Lecture 28 : Balance Sheet Part 1 - SUM OVER with all columns
-- Lecture 29 : Balance Sheet Part 2 - Final PIVOT version
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- LECTURE 25 | Balance Sheet WRONG
-- Why this is wrong: Balance Sheet is cumulative (closing balance).
-- A simple SUM groups transactions, not running balances.
-- The next lectures fix this using SUM OVER (ORDER BY).
-- ─────────────────────────────────────────────────────────────

Select Country, Report, Class, Account,
    FORMAT([2018], 'N0') as '2018',
    FORMAT([2019], 'N0') as '2019',
    FORMAT([2020], 'N0') as '2020'

FROM (
    Select Country, GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
    JOIN COA ON GL.Account_key = COA.Account_key
    JOIN Territory ON GL.Territory_key = Territory.Territory_key
    Where Report = 'Balance Sheet'
    Group by Country, Report, Class, Account, GL.Account_key, YEAR(Date)
) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2


-- ─────────────────────────────────────────────────────────────
-- LECTURE 26 | SUM OVER Order by
-- Running cumulative total across all dates
-- ─────────────────────────────────────────────────────────────

Select Distinct Date, Sum(Amount) OVER (Order by Date) as Amount from GL
Order by [Date]


-- ─────────────────────────────────────────────────────────────
-- LECTURE 27 | SUM OVER Partition by Order by (by YEAR)
-- Running cumulative total partitioned by Territory and Account
-- ─────────────────────────────────────────────────────────────

Select DISTINCT Date, Territory_key, Account_key,
    Sum(Amount) OVER (PARTITION by Territory_key, Account_key Order by Date) as Amount
from GL
Order by Date

-- Same but summarised by Year instead of Date
Select DISTINCT YEAR([Date]) as Year, Territory_key, Account_key,
    Sum(Amount) OVER (PARTITION by Territory_key, Account_key Order by YEAR(Date)) as Amount
from GL
Order by YEAR(Date)


-- ─────────────────────────────────────────────────────────────
-- LECTURE 28 | Balance Sheet Part 1
-- Correct cumulative Balance Sheet using SUM OVER PARTITION BY
-- Partitioned by Country + SubAccount so each account accumulates
-- independently per country
-- ─────────────────────────────────────────────────────────────

Select DISTINCT YEAR(Date) as YEAR, Country, Report, Class, SubClass, SubClass2, Account, SubAccount,
    SUM(Amount) OVER (PARTITION by Country, SubAccount Order by Year(Date)) as Amount
from GL
JOIN COA ON GL.Account_key = COA.Account_key
JOIN Territory ON GL.Territory_key = Territory.Territory_key
Where Report = 'Balance Sheet'


-- ─────────────────────────────────────────────────────────────
-- LECTURE 29 | Balance Sheet Part 2
-- Final Balance Sheet: wrap Lecture 28 in a PIVOT
-- Version 1: By Country
-- Version 2: All countries combined (no Country column)
-- ─────────────────────────────────────────────────────────────

-- Version 1: Balance Sheet by Country
Select Country, Report, Class, SubClass, SubClass2, Account, SubAccount, [2018], [2019], [2020]
from
(
    Select DISTINCT YEAR(Date) as YEAR, Country, Report, Class, SubClass, SubClass2, Account, SubAccount,
        SUM(Amount) OVER (PARTITION by Country, SubAccount Order by Year(Date)) as Amount
    from GL
    JOIN COA ON GL.Account_key = COA.Account_key
    JOIN Territory ON GL.Territory_key = Territory.Territory_key
    Where Report = 'Balance Sheet'
) as Table1

PIVOT (SUM(Amount) FOR YEAR IN([2018], [2019], [2020])) as Table2


-- Version 2: Balance Sheet - All Countries Combined
Select Report, Class, SubClass, SubClass2, Account, SubAccount, [2018], [2019], [2020]
from
(
    Select DISTINCT YEAR(Date) as YEAR, Report, Class, SubClass, SubClass2, Account, SubAccount,
        SUM(Amount) OVER (PARTITION by SubAccount Order by Year(Date)) as Amount
    from GL
    JOIN COA ON GL.Account_key = COA.Account_key
    JOIN Territory ON GL.Territory_key = Territory.Territory_key
    Where Report = 'Balance Sheet'
) as Table1
PIVOT (SUM(Amount) FOR YEAR IN([2018], [2019], [2020])) as Table2
Order by Class, SubClass, SubClass2, Account, SubAccount
