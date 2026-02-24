-- ============================================================
-- Lecture 14 : SubQuery
-- Lecture 15 : PIVOT
-- Lecture 16 : Practice - SubQuery & PIVOT
-- ============================================================
-- These are the building block techniques used in all
-- financial statements throughout this project.
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- LECTURE 14 | SubQuery
-- Get total GL amount summarised by Year
-- ─────────────────────────────────────────────────────────────

Select Year, Sum(Amount) as TotalAmount
from
(
    Select Year(Date) as Year, Amount from GL
) as Table1
Group by Year
Order by Year


-- ─────────────────────────────────────────────────────────────
-- LECTURE 15 | PIVOT
-- Turn Year rows into Year columns
-- ─────────────────────────────────────────────────────────────

Select [2018], [2019], [2020]
from
(
    Select YEAR(Date) as Year , Amount from GL
) as Table1

PIVOT(
    Sum(Amount) for YEAR IN ([2018], [2019], [2020])
) as Table2


-- ─────────────────────────────────────────────────────────────
-- LECTURE 16 | Practice - SubQuery & PIVOT
-- PIVOT amount by Account_key and Year
-- ─────────────────────────────────────────────────────────────

Select Account_key, [2018], [2019], [2020]
FROM (
    Select Account_key, Year(Date) as Year, Amount from GL
) as Table1
PIVOT (
    Sum(Amount) for Year IN ([2018], [2019], [2020])
) as Table2
Order by Account_key
