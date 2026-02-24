-- ============================================================
-- Lecture 22 : P&L Part 1 - Single Period (Date Filter)
-- Lecture 23 : P&L Part 2 - Multi-Year PIVOT (No Country)
-- Lecture 24 : P&L Part 3 - Multi-Year PIVOT (By Country)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- LECTURE 22 | P&L Part 1
-- Single month P&L (March 2020) - no PIVOT yet
-- Shows Account_key, Class, Account and summed Amount
-- ─────────────────────────────────────────────────────────────

Select GL.Account_key, Report, Class, Account , SUM(Amount) as Amount from GL
JOIN COA ON GL.Account_key = COA.Account_key
Where Report = 'Profit and Loss' AND [Date] BETWEEN '2020-03-01' AND '2020-03-30'
Group by Report, Class, Account, GL.Account_key
Order by GL.Account_key


-- ─────────────────────────────────────────────────────────────
-- LECTURE 23 | P&L Part 2
-- Full P&L pivoted by Year (2018, 2019, 2020) - all countries combined
-- ─────────────────────────────────────────────────────────────

Select Report, Class, Account,
    FORMAT([2018], 'N0') as '2018',
    FORMAT([2019], 'N0') as '2019',
    FORMAT([2020], 'N0') as '2020'

FROM (
    Select GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
    JOIN COA ON GL.Account_key = COA.Account_key
    Where Report = 'Profit and Loss'
    Group by Report, Class, Account, GL.Account_key, YEAR(Date)
) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2


-- ─────────────────────────────────────────────────────────────
-- LECTURE 24 | P&L Part 3
-- Full P&L pivoted by Year - broken down by Country
-- ─────────────────────────────────────────────────────────────

Select Country, Report, Class, Account,
    FORMAT([2018], 'N0') as '2018',
    FORMAT([2019], 'N0') as '2019',
    FORMAT([2020], 'N0') as '2020'

FROM (
    Select Country, GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
    JOIN COA ON GL.Account_key = COA.Account_key
    JOIN Territory ON GL.Territory_key = Territory.Territory_key
    Where Report = 'Profit and Loss'
    Group by Country, Report, Class, Account, GL.Account_key, YEAR(Date)
) as Table1
PIVOT
( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2
