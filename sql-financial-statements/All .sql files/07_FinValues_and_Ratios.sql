-- ============================================================
-- Merging Views : FinValues = BSValues + PLValues
-- Ratios 1     : GP Margin, Operating Margin, Net Margin
-- Ratios 2     : Full set of 12 financial ratios
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- CREATE VIEW FinValues
-- Merges BSValues and PLValues into one combined view
-- This single view powers all ratio calculations
-- ─────────────────────────────────────────────────────────────

CREATE VIEW FinValues AS

Select BSValues.*, PLValues.Sales, PLValues.Gross_Profit, PLValues.EBITDA,
    PLValues.Operating_Profit, PLValues.PBIT, PLValues.Net_Profit,
    PLValues.Cost_of_Sales, PLValues.Interest_Expense
from BSValues
JOIN PLValues ON BSValues.Country = PLValues.Country AND BSValues.Year = PLValues.Year


-- ─────────────────────────────────────────────────────────────
-- RATIOS 1 : Profitability Margins
-- GP Margin, Operating Margin, Net Margin - all countries combined
-- ─────────────────────────────────────────────────────────────

Select Year,
        Sum(Gross_Profit)     / Sum(Sales) * 100 as 'GP_Margin',
        Sum(Operating_Profit) / Sum(Sales) * 100 as 'Operating_Margin',
        Sum(Net_Profit)       / Sum(Sales) * 100 as 'Net_Margin'

from PLValues
Group by Year


-- ─────────────────────────────────────────────────────────────
-- RATIOS 2 : Full Financial Ratio Dashboard
-- 12 ratios covering profitability, efficiency, liquidity,
-- leverage and investor metrics
-- Filtered by Country = 'Germany' as example
-- Remove the WHERE clause to see all countries
-- ─────────────────────────────────────────────────────────────

Select Year,

        -- Profitability Ratios
        Sum(Gross_Profit)     / Sum(Sales) * 100          as 'GP_Margin',
        Sum(Operating_Profit) / Sum(Sales) * 100          as 'Operating_Margin',
        Sum(Net_Profit)       / Sum(Sales) * 100          as 'Net_Margin',

        -- Efficiency Ratios
        Sum(Sales) / Sum(Assets)                          as 'Asset_Turnover',
        Sum(Inventory) / Sum(Cost_of_Sales) * -365        as 'Inventory_turnover_period',
        Sum(Trade_Receivables) / Sum(Sales) * 365         as 'Receivables_turnover_period',
        Sum(Trade_Payables) / Sum(Cost_of_Sales) * -365   as 'Payables_turnover_period',

        -- Investor / Return Ratios
        Sum(PBIT) / Sum(Equity+NonCurent_Liabilities) * 100 as 'ROCE',
        Sum(Net_Profit) / Sum(Equity) * 100               as 'ROE',

        -- Leverage / Solvency Ratios
        Sum(Liabilities) / Sum(Equity) * 100              as 'Gearing',
        Sum(PBIT) / Sum(Interest_Expense)*-1              as 'Interest_Cover',

        -- Liquidity Ratios
        Sum(Current_Assets) / Sum(Current_Liabilities)    as 'Current_Ratio',
        (Sum(Current_Assets) - Sum(Inventory)) / SUM(Current_Liabilities) as 'Quick_Ratio'

from FinValues
Where Country = 'Germany'
Group by YEAR
Order by YEAR
