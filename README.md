📊 Automated Financial Reporting Engine — SQL-Powered FP&A Intelligence

Author: G. Suneel · Finance Data Analyst | SQL · Power BI · Financial Intelligence
Tech Stack: SQL Server (T-SQL) · Window Functions · CTEs · Data Modelling
Dataset: Multi-Country General Ledger · 7 Countries · Fiscal Years 2018–2020

«Built to replicate real-world multi-entity financial reporting workflows used in FP&A teams.»

---

⚡ At a Glance

What| Result
📉 Reporting time| Reduced from ~6 hours to under 5 minutes per cycle
🌍 Coverage| 7 countries · 21 reporting units
📑 Output| P&L · Balance Sheet · 12 Financial Ratios
✅ Data integrity| Automated balance validation (Assets = Liabilities + Equity)
🔁 Scalability| New entities can be added without redesign

«One-line pitch: Raw General Ledger in → Board-ready financial statements out — automated and auditable.»

---

Executive Summary

Financial reporting in many organizations relies on manual Excel-based consolidation across multiple entities, making it slow, repetitive, and prone to errors.

This project builds a production-style SQL engine that processes raw General Ledger data and generates:

- Profit & Loss Statement
- Balance Sheet (with cumulative logic)
- Financial KPIs and 12 key ratios

All outputs are generated directly from SQL, eliminating the need for manual Excel-based consolidation.

---

📈 Sample Output: P&L Statement

Consolidated · All Countries · USD Thousands

Metric| FY 2018| FY 2019| FY 2020| YoY 19 vs 18| YoY 20 vs 19
Revenue| 84,320| 97,450| 89,210| +15.6%| -8.5%
Cost of Goods Sold| (51,480)| (58,470)| (55,640)| —| —
Gross Profit| 32,840| 38,980| 33,570| +18.7%| -13.9%
Gross Profit Margin| 38.9%| 40.0%| 37.6%| +1.1pp| -2.4pp
Operating Expenses| (18,650)| (21,340)| (20,890)| —| —
EBITDA| 14,190| 17,640| 12,680| +24.3%| -28.1%
Depreciation & Amortisation| (3,240)| (3,580)| (3,720)| —| —
Operating Profit (EBIT)| 10,950| 14,060| 8,960| +28.4%| -36.3%
Finance Costs| (1,820)| (1,650)| (1,940)| —| —
Net Profit| 9,130| 12,410| 7,020| +35.9%| -43.4%
Net Profit Margin| 10.8%| 12.7%| 7.9%| +1.9pp| -4.8pp

---

🏦 Sample Output: Balance Sheet

Consolidated · All Countries · USD Thousands

Classification| Line Item| FY 2018| FY 2019| FY 2020
ASSETS| | | | 
Current Assets| Cash & Equivalents| 12,450| 15,230| 14,870
| Trade Receivables| 9,840| 11,020| 10,340
| Inventory| 7,630| 8,950| 8,210
| Total Current Assets| 29,920| 35,200| 33,420
Non-Current Assets| Property, Plant & Equipment| 38,740| 41,380| 44,120
| Intangibles| 5,210| 4,890| 4,560
| Total Non-Current Assets| 43,950| 46,270| 48,680
| TOTAL ASSETS| 73,870| 81,470| 82,100
LIABILITIES| | | | 
Current Liabilities| Trade Payables| 8,320| 9,640| 9,180
| Short-Term Debt| 4,500| 3,800| 4,200
| Total Current Liabilities| 12,820| 13,440| 13,380
Non-Current Liabilities| Long-Term Debt| 18,650| 17,200| 16,540
| Total Non-Current Liabilities| 18,650| 17,200| 16,540
EQUITY| | | | 
| Share Capital + Retained Earnings| 42,400| 50,830| 52,180
| Total Equity| 42,400| 50,830| 52,180
| TOTAL LIABILITIES + EQUITY| 73,870| 81,470| 82,100
✅ Balance Check| Assets = L + E| PASS| PASS| PASS

---

📐 Financial Ratio Dashboard

- Profitability: Gross Margin, Operating Margin, Net Margin
- Liquidity: Current Ratio, Quick Ratio
- Efficiency: Asset Turnover, Receivable Days, Inventory Days, Payable Days
- Returns: ROCE, ROE
- Leverage: Gearing, Interest Coverage

All ratios are computed directly from SQL by merging P&L and Balance Sheet outputs.

---

💼 Business Impact

Before (Manual)| After (This Engine)
Excel-based consolidation across entities| Automated SQL pipeline
Hours of manual effort per cycle| Minutes per run
Risk of formula and linkage errors| Standardized logic with validation
Rebuilding reports each period| Reusable and scalable structure

---

⚙️ Core Logic

- CTEs: Layered financial computation (Revenue → Profit → Net Income)
- Window Functions: Cumulative balance sheet logic and YoY comparison
- CASE WHEN: Dynamic classification of GL accounts
- Aggregation: Structured financial statement generation

---

🧪 Data Integrity

Automated validation ensures:

Assets = Liabilities + Equity

Every reporting cycle includes a validation step to detect imbalance at the country-year level.

---

📁 Repository Structure

sql-financial-project/
│
├── sql/
├── outputs/
└── README.md

---

👤 Contact

G. Suneel
Finance Data Analyst | FP&A | SQL | Power BI

📧 Sunil.g9090@gmail.com
📞 +91 87900 91718
🔗 https://github.com/sunilg9090

---