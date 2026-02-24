-- ============================================================
-- Cash Flow Statement (Indirect Method)
-- Author  : G. Suneel | Finance Data Analyst
-- Method  : Indirect Method
--           Start with Net Profit → add back non-cash items
--           → adjust working capital changes
--           → Investing activities
--           → Financing activities
--           → Net Change in Cash
-- Techniques used : CASE WHEN, SUM OVER PARTITION BY,
--                   CREATE VIEW, JOIN, PIVOT
-- ============================================================


-- ============================================================
-- STEP 1 : CREATE VIEW CFOperating
-- Operating Activities
-- Net Profit + Non-Cash Items + Working Capital Changes
-- ============================================================

CREATE VIEW CFOperating AS

SELECT DISTINCT
    Country,
    YEAR(Date) AS Year,

    -- Net Profit (starting point of Indirect Method)
    SUM(CASE WHEN Report = 'Profit and Loss'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Net_Profit,

    -- Add back Non-Cash Items (Depreciation & Amortization)
    -- These are expenses that reduce profit but not cash
    SUM(CASE WHEN SubClass2 = 'Depreciation'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Depreciation,

    SUM(CASE WHEN SubClass2 = 'Amortization'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Amortization,

    -- Working Capital Changes (Balance Sheet movements)
    -- Increase in Receivables = cash used (negative)
    SUM(CASE WHEN Account = 'Receivables'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Change_Receivables,

    -- Increase in Inventory = cash used (negative)
    SUM(CASE WHEN Account = 'Inventory'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Change_Inventory,

    -- Increase in Trade Payables = cash received (positive)
    SUM(CASE WHEN Account = 'Trade Payables'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Change_Trade_Payables,

    -- Increase in Other Payables = cash received (positive)
    SUM(CASE WHEN Account = 'Other Payables'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Change_Other_Payables

FROM GL
JOIN COA       ON GL.Account_key    = COA.Account_key
JOIN Territory ON GL.Territory_key  = Territory.Territory_key


-- ============================================================
-- STEP 2 : CREATE VIEW CFInvesting
-- Investing Activities
-- Purchase of PPE, Intangible Assets, Investments
-- ============================================================

CREATE VIEW CFInvesting AS

SELECT DISTINCT
    Country,
    YEAR(Date) AS Year,

    -- Capital expenditure on fixed assets (cash outflow)
    SUM(CASE WHEN Account = 'Property, Plant, & Equipment'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Purchase_PPE,

    -- Purchase of Intangible Assets
    SUM(CASE WHEN Account = 'Intangible Assets'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Purchase_Intangibles,

    -- Purchase of Investments
    SUM(CASE WHEN Account = 'Investments'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Purchase_Investments,

    -- Gain or Loss on Sale of Assets
    SUM(CASE WHEN Account = 'Gain/Loss on Sales of Asset'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS GainLoss_Asset_Sales

FROM GL
JOIN COA       ON GL.Account_key    = COA.Account_key
JOIN Territory ON GL.Territory_key  = Territory.Territory_key


-- ============================================================
-- STEP 3 : CREATE VIEW CFFinancing
-- Financing Activities
-- Share Capital, Dividends Paid, Long Term Borrowings
-- ============================================================

CREATE VIEW CFFinancing AS

SELECT DISTINCT
    Country,
    YEAR(Date) AS Year,

    -- Share Capital raised (cash inflow)
    SUM(CASE WHEN Account = 'Share Capital'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Share_Capital,

    -- Dividends paid to shareholders (cash outflow)
    SUM(CASE WHEN Account = 'Dividends paid'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS Dividends_Paid,

    -- Long Term borrowings raised or repaid
    SUM(CASE WHEN Account = 'Long Term Obligations'
             THEN Amount ELSE 0 END)
        OVER (PARTITION BY Country ORDER BY YEAR(Date))        AS LongTerm_Borrowings

FROM GL
JOIN COA       ON GL.Account_key    = COA.Account_key
JOIN Territory ON GL.Territory_key  = Territory.Territory_key


-- ============================================================
-- STEP 4 : CREATE VIEW CashFlowValues
-- Merge all 3 views + calculate section totals
-- ============================================================

CREATE VIEW CashFlowValues AS

SELECT
    op.Country,
    op.Year,

    -- ── OPERATING ACTIVITIES ──────────────────────────────
    op.Net_Profit,
    op.Depreciation,
    op.Amortization,
    op.Change_Receivables,
    op.Change_Inventory,
    op.Change_Trade_Payables,
    op.Change_Other_Payables,

    -- Total Operating Cash Flow
    ( op.Net_Profit
    + op.Depreciation
    + op.Amortization
    - op.Change_Receivables
    - op.Change_Inventory
    + op.Change_Trade_Payables
    + op.Change_Other_Payables )                               AS CFO,

    -- ── INVESTING ACTIVITIES ──────────────────────────────
    inv.Purchase_PPE,
    inv.Purchase_Intangibles,
    inv.Purchase_Investments,
    inv.GainLoss_Asset_Sales,

    -- Total Investing Cash Flow
    ( inv.Purchase_PPE
    + inv.Purchase_Intangibles
    + inv.Purchase_Investments
    + inv.GainLoss_Asset_Sales )                               AS CFI,

    -- ── FINANCING ACTIVITIES ──────────────────────────────
    fin.Share_Capital,
    fin.Dividends_Paid,
    fin.LongTerm_Borrowings,

    -- Total Financing Cash Flow
    ( fin.Share_Capital
    + fin.Dividends_Paid
    + fin.LongTerm_Borrowings )                                AS CFF

FROM CFOperating  op
JOIN CFInvesting  inv ON op.Country = inv.Country AND op.Year = inv.Year
JOIN CFFinancing  fin ON op.Country = fin.Country AND op.Year = fin.Year


-- ============================================================
-- STEP 5 : Final Cash Flow Statement Query
-- Summary view with Net Change in Cash
-- All countries combined, pivoted by Year
-- ============================================================

SELECT
    Section,
    Line_Item,
    FORMAT([2018], 'N0') AS '2018',
    FORMAT([2019], 'N0') AS '2019',
    FORMAT([2020], 'N0') AS '2020'

FROM (
    SELECT
        '1. Operating Activities'           AS Section,
        'Net Profit'                        AS Line_Item,
        Year, SUM(Net_Profit)               AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Add: Depreciation',
        Year, SUM(Depreciation * -1)        AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Add: Amortization',
        Year, SUM(Amortization * -1)        AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Change in Receivables',
        Year, SUM(Change_Receivables * -1)  AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Change in Inventory',
        Year, SUM(Change_Inventory * -1)    AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Change in Trade Payables',
        Year, SUM(Change_Trade_Payables)    AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'Change in Other Payables',
        Year, SUM(Change_Other_Payables)    AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '1. Operating Activities', 'TOTAL - Operating (CFO)',
        Year, SUM(CFO)                      AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '2. Investing Activities', 'Purchase of PPE',
        Year, SUM(Purchase_PPE)             AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '2. Investing Activities', 'Purchase of Intangibles',
        Year, SUM(Purchase_Intangibles)     AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '2. Investing Activities', 'Purchase of Investments',
        Year, SUM(Purchase_Investments)     AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '2. Investing Activities', 'Gain/Loss on Asset Sales',
        Year, SUM(GainLoss_Asset_Sales)     AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '2. Investing Activities', 'TOTAL - Investing (CFI)',
        Year, SUM(CFI)                      AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '3. Financing Activities', 'Share Capital Raised',
        Year, SUM(Share_Capital)            AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '3. Financing Activities', 'Dividends Paid',
        Year, SUM(Dividends_Paid)           AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '3. Financing Activities', 'Long Term Borrowings',
        Year, SUM(LongTerm_Borrowings)      AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '3. Financing Activities', 'TOTAL - Financing (CFF)',
        Year, SUM(CFF)                      AS Amount FROM CashFlowValues GROUP BY Year
    UNION ALL
    SELECT '4. Net Change in Cash', 'NET CASH MOVEMENT',
        Year, SUM(CFO + CFI + CFF)          AS Amount FROM CashFlowValues GROUP BY Year

) AS Table1

PIVOT (
    SUM(Amount) FOR Year IN ([2018], [2019], [2020])
) AS Table2

ORDER BY Section, Line_Item
