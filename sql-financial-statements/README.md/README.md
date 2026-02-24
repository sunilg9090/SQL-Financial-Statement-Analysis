# 📊 SQL Financial Statements & Ratio Analysis

**Author:** G. Suneel — Finance Data Analyst | SQL | Power BI | Financial Reporting  
**Database:** SQL Server (T-SQL) | **Dataset:** Multi-country General Ledger · 7 Countries · 3 Years (2018–2020)

---

## 📌 Project Summary

This project builds **complete financial statements and ratio analysis directly from raw GL transactional data using SQL** — no manual Excel consolidation.

The project follows a structured learning path from basic SQL concepts (SubQuery, PIVOT) all the way to advanced financial analysis (12 financial ratios using merged Views).

---

## 🗂️ Repository Structure

```
sql-financial-project/
│
├── sql/
│   ├── 01_SubQuery_and_PIVOT.sql       ← Lectures 14, 15, 16
│   ├── 02_Views_and_Joins.sql          ← Lectures 17, 18, 19, 20, 21
│   ├── 03_ProfitAndLoss.sql            ← Lectures 22, 23, 24
│   ├── 04_BalanceSheet.sql             ← Lectures 25, 26, 27, 28, 29
│   ├── 05_CASEWHEN_and_PLValues.sql    ← CASE WHEN + PLValues View
│   ├── 06_BSValues.sql                 ← BSValues View
│   └── 07_FinValues_and_Ratios.sql     ← FinValues View + 12 Ratios
│
├── outputs/
│   ├── Output_ProfitAndLoss.csv        ← P&L by Country & Year
│   ├── Output_BalanceSheet.csv         ← Balance Sheet by Country & Year
│   ├── Output_PLValues.csv             ← PLValues view result
│   ├── Output_BSValues.csv             ← BSValues view result
│   └── Output_Ratios.csv              ← All 12 financial ratios
│
└── README.md
```

---

## 🗄️ Data Model

```
GL (General Ledger)          — Raw transactions (EntryNo, Date, Amount)
   ├── Territory_key   ──→   Territory  (Country, Region)
   └── Account_key     ──→   COA        (Report, Class, SubClass, SubClass2, Account, SubAccount)

Calendar                     — Date dimension (Year, Quarter, Month, Day)
```

---

## 📘 SQL Concepts Used (Step by Step)

### 📍 Step 1 — SubQuery & PIVOT  `01_SubQuery_and_PIVOT.sql`

The foundation of all financial reports. A SubQuery extracts raw data; PIVOT turns year rows into year columns.

```sql
Select [2018], [2019], [2020]
from
(
    Select YEAR(Date) as Year , Amount from GL
) as Table1
PIVOT(
    Sum(Amount) for YEAR IN ([2018], [2019], [2020])
) as Table2
```

---

### 📍 Step 2 — Views & Joins  `02_Views_and_Joins.sql`

JOIN connects GL to COA, Territory and Calendar. Views save a query so it can be reused like a table.

```sql
-- 4-table JOIN
Select * from GL
JOIN Territory ON GL.Territory_key = Territory.Territory_key
JOIN COA       ON GL.Account_key   = COA.Account_key
JOIN Calendar  ON GL.[Date]        = Calendar.[Date]
```

---

### 📍 Step 3 — Profit & Loss  `03_ProfitAndLoss.sql`

Built in 3 parts. The final P&L uses JOIN + GROUP BY + PIVOT to show each account line across all 3 years.

```sql
Select Country, Report, Class, Account,
    FORMAT([2018], 'N0') as '2018',
    FORMAT([2019], 'N0') as '2019',
    FORMAT([2020], 'N0') as '2020'
FROM (
    Select Country, GL.Account_key, Report, Class, Account, YEAR(Date) as Year, SUM(Amount) as Amount from GL
    JOIN COA       ON GL.Account_key    = COA.Account_key
    JOIN Territory ON GL.Territory_key  = Territory.Territory_key
    Where Report = 'Profit and Loss'
    Group by Country, Report, Class, Account, GL.Account_key, YEAR(Date)
) as Table1
PIVOT ( SUM(Amount) FOR Year IN ([2018], [2019], [2020])) as Table2
```

---

### 📍 Step 4 — Balance Sheet  `04_BalanceSheet.sql`

Balance Sheet needs **cumulative (running) balances**, not simple GROUP BY sums.  
The fix is `SUM() OVER (PARTITION BY ... ORDER BY Year)` — a window function that carries balances forward year by year.

```sql
-- CORRECT: Cumulative Balance Sheet using SUM OVER PARTITION BY
Select DISTINCT YEAR(Date) as YEAR, Country, Report, Class, SubClass, SubClass2, Account, SubAccount,
    SUM(Amount) OVER (PARTITION by Country, SubAccount Order by Year(Date)) as Amount
from GL
JOIN COA       ON GL.Account_key    = COA.Account_key
JOIN Territory ON GL.Territory_key  = Territory.Territory_key
Where Report = 'Balance Sheet'
```

This is then wrapped in a PIVOT to get 2018, 2019, 2020 as columns.

---

### 📍 Step 5 — PLValues View  `05_CASEWHEN_and_PLValues.sql`

CASE WHEN extracts specific financial metrics in a single pass — Sales, Gross Profit, EBITDA, Operating Profit, PBIT, Net Profit.

```sql
CREATE VIEW PLValues as
Select Country, Year(Date) as Year,
    SUM(CASE When SubClass = 'Sales' then Amount else 0 end)                                                                          as 'Sales',
    SUM(CASE When Class = 'Trading account' then Amount else 0 end)                                                                   as 'Gross_Profit',
    SUM(CASE When SubClass = 'Sales' OR SubClass = 'Cost of Sales' OR SubClass = 'Operating Expenses' then Amount else 0 end)         as 'EBITDA',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' then Amount else 0 end)                                    as 'Operating_Profit',
    SUM(CASE When Class = 'Trading account' OR Class = 'Operating account' OR Class = 'Non-operating' then Amount else 0 end)         as 'PBIT',
    SUM(CASE When Report = 'Profit and Loss' then Amount else 0 end)                                                                  as 'Net_Profit',
    SUM(CASE When SubClass = 'Cost of Sales' then Amount else 0 end)                                                                  as 'Cost_of_Sales',
    SUM(CASE When SubClass = 'Interest Expense' then Amount else 0 end)                                                               as 'Interest_Expense'
from GL
JOIN COA       ON GL.Account_key   = COA.Account_key
JOIN Territory ON GL.Territory_key = Territory.Territory_key
Group by Year(Date), Country
```

---

### 📍 Step 6 — BSValues View  `06_BSValues.sql`

Extracts Balance Sheet metrics using CASE WHEN + SUM OVER PARTITION BY. Captures Assets, Liabilities, Equity, Inventory, Trade Receivables, Trade Payables.

---

### 📍 Step 7 — FinValues + 12 Ratios  `07_FinValues_and_Ratios.sql`

FinValues merges PLValues and BSValues. The ratio query then calculates all 12 ratios in one SELECT.

```sql
CREATE VIEW FinValues AS
Select BSValues.*, PLValues.Sales, PLValues.Gross_Profit, PLValues.EBITDA,
       PLValues.Operating_Profit, PLValues.PBIT, PLValues.Net_Profit,
       PLValues.Cost_of_Sales, PLValues.Interest_Expense
from BSValues
JOIN PLValues ON BSValues.Country = PLValues.Country AND BSValues.Year = PLValues.Year
```

---

## 📐 12 Financial Ratios Calculated

| Category | Ratio | Formula |
|----------|-------|---------|
| **Profitability** | GP Margin | Gross Profit / Sales × 100 |
| | Operating Margin | Operating Profit / Sales × 100 |
| | Net Margin | Net Profit / Sales × 100 |
| **Efficiency** | Asset Turnover | Sales / Assets |
| | Inventory Days | Inventory / Cost of Sales × −365 |
| | Receivables Days | Trade Receivables / Sales × 365 |
| | Payables Days | Trade Payables / Cost of Sales × −365 |
| **Investor / Returns** | ROCE | PBIT / (Equity + Long Term Liabilities) × 100 |
| | ROE | Net Profit / Equity × 100 |
| **Leverage** | Gearing | Liabilities / Equity × 100 |
| | Interest Cover | PBIT / Interest Expense × −1 |
| **Liquidity** | Current Ratio | Current Assets / Current Liabilities |
| | Quick Ratio | (Current Assets − Inventory) / Current Liabilities |

---

## 📈 Key Results (All Countries Combined)

| Year | GP Margin | Operating Margin | Net Margin | Current Ratio | ROCE |
|------|-----------|-----------------|------------|---------------|------|
| 2018 | 66.66% | 20.72% | 17.45% | 5.17 | 23.62% |
| 2019 | 69.65% | 25.90% | 22.87% | 8.20 | 18.18% |
| 2020 | 68.17% | 19.43% | 16.46% | 8.08 | 14.14% |

---

## 🛠️ SQL Techniques Index

| Technique | File |
|-----------|------|
| SubQuery | `01_SubQuery_and_PIVOT.sql` |
| PIVOT | `01_SubQuery_and_PIVOT.sql` |
| CREATE VIEW | `02_Views_and_Joins.sql` |
| INNER JOIN | `02_Views_and_Joins.sql` |
| RIGHT JOIN | `02_Views_and_Joins.sql` |
| INSERT / DELETE | `02_Views_and_Joins.sql` |
| FORMAT('N0') | `03_ProfitAndLoss.sql` |
| BETWEEN (date filter) | `03_ProfitAndLoss.sql` |
| SUM OVER ORDER BY | `04_BalanceSheet.sql` |
| SUM OVER PARTITION BY | `04_BalanceSheet.sql` |
| CASE WHEN | `05_CASEWHEN_and_PLValues.sql` |
| Merging Views with JOIN | `07_FinValues_and_Ratios.sql` |
| Financial Ratio Formulas | `07_FinValues_and_Ratios.sql` |

---

## 👤 About

**G. Suneel** — Finance Data Analyst, Hyderabad, India  
Dual background in accounting (CMA Intermediate) and business intelligence (Power BI · SQL · Python · Excel)

📧 Sunil.g9090@gmail.com | 📞 8790091718
