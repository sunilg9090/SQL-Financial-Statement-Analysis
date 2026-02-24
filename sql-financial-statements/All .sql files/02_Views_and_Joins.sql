-- ============================================================
-- Lecture 17 : VIEW
-- Lecture 18 : JOIN (Part 1)
-- Lecture 19 : JOIN (Part 2) - RIGHT JOIN, INSERT, DELETE
-- Lecture 20 : JOIN (Part 3)
-- Lecture 21 : JOIN Practice
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- LECTURE 17 | VIEW
-- Create a reusable summary view and query it
-- ─────────────────────────────────────────────────────────────

Create View MySummary AS
Select Account_key, [2018], [2019], [2020]
FROM (
    Select Account_key, Year(Date) as Year, Amount from GL
) as Table1
PIVOT (
    Sum(Amount) for Year IN ([2018], [2019], [2020])
) as Table2

-- Query the view
Select * from MySummary where Account_key = 121


-- ─────────────────────────────────────────────────────────────
-- LECTURE 18 | JOIN Part 1
-- Join GL with COA and Territory separately
-- ─────────────────────────────────────────────────────────────

Select * from GL
JOIN COA ON GL.Account_key = COA.Account_key

Select * from GL
JOIN Territory ON GL.Territory_key = Territory.Territory_key


-- ─────────────────────────────────────────────────────────────
-- LECTURE 19 | JOIN Part 2
-- Select specific columns after JOIN
-- ─────────────────────────────────────────────────────────────

Select Date, GL.Territory_key, Amount, Country from GL
JOIN Territory ON GL.Territory_key = Territory.Territory_key

Select Date, Amount, Report, SubAccount from GL
JOIN COA ON GL.Account_key = COA.Account_key


-- ─────────────────────────────────────────────────────────────
-- LECTURE 20 | JOIN Part 3
-- RIGHT JOIN + INSERT + DELETE
-- ─────────────────────────────────────────────────────────────

-- RIGHT JOIN (shows all Territory rows even if no GL data)
Select Date, GL.Territory_key, Amount, Country from GL
RIGHT JOIN Territory ON GL.Territory_key = Territory.Territory_key

-- Add test countries
INSERT INTO Territory (Territory_key, Country, Region) VALUES
(8, 'India', 'Asia'),
(9, 'Pakistan', 'Asia')

-- Remove test countries
DELETE FROM Territory WHERE Territory_key IN (8, 9)


-- ─────────────────────────────────────────────────────────────
-- LECTURE 21 | JOIN Practice
-- Join all 4 tables together
-- ─────────────────────────────────────────────────────────────

Select * from GL
JOIN Territory ON GL.Territory_key = Territory.Territory_key
JOIN COA ON GL.Account_key = COA.Account_key
JOIN Calendar ON GL.[Date] = Calendar.[Date]
