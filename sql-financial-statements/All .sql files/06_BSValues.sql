-- ============================================================
-- BSValues View : Balance Sheet summary metrics
-- Uses SUM OVER PARTITION BY to calculate cumulative balances
-- (correct method for Balance Sheet as shown in Lecture 28-29)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- CREATE VIEW BSValues  (Final version)
-- Adds Trade_Receivables and Trade_Payables vs earlier version
-- for use in Receivables and Payables turnover ratio
-- ─────────────────────────────────────────────────────────────

CREATE VIEW BSValues as
Select DISTINCT Country, Year(Date) as 'Year',
    SUM(CASE WHEN Class = 'Assets' then Amount else 0 end) OVER(PARTITION by Country     Order by Year(Date)) as 'Assets',
    SUM(CASE WHEN SubClass2 = 'Current Assets' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Current_Assets',
    SUM(CASE WHEN SubClass2 = 'Non-Current Assets' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'NonCurrent_Assets',
    SUM(CASE WHEN SubClass = 'Liabilities' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Liabilities',
    SUM(CASE WHEN SubClass2 = 'Current Liabilities' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Current_Liabilities',
    SUM(CASE WHEN SubClass2 = 'Long Term Liabilities' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'NonCurent_Liabilities',
    SUM(CASE WHEN SubClass = 'Owners Equity' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Equity',
    SUM(CASE WHEN Class = 'Liabilities and Owners Equity' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Liabilities_and_Equity',
    SUM(CASE WHEN Account = 'Inventory' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Inventory',
    SUM(CASE WHEN SubAccount = 'Trade Receivables' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Trade_Receivables',
    SUM(CASE WHEN Account = 'Trade Payables' then Amount else 0 end) OVER(PARTITION by Country Order by Year(Date)) as 'Trade_Payables'

from GL
JOIN COA ON GL.Account_key = COA.Account_key
JOIN Territory ON GL.Territory_key = Territory.Territory_key
