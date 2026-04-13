# 📊 Automated Financial Reporting Engine — SQL-Powered FP&A Intelligence

**Author:** G. Suneel · Finance Data Analyst | SQL · Power BI · Financial Intelligence  
**Tech Stack:** SQL Server (T-SQL) · Window Functions · CTEs · Data Modelling  
**Dataset:** Multi-Country General Ledger · 7 Countries · Fiscal Years 2018–2020  

> Built to replicate real-world multi-entity financial reporting workflows used in FP&A teams.

---

## ⚡ At a Glance

| What | Result |
|---|---|
| Reporting time | Reduced from ~6 hours to under 5 minutes per cycle |
| Coverage | 7 countries · 21 reporting units |
| Output | P&L · Balance Sheet · 12 Financial Ratios |
| Data integrity | Automated balance validation (Assets = Liabilities + Equity) |
| Scalability | New entities can be added without redesign |

---

## Executive Summary

Financial reporting in many organizations relies on manual Excel-based consolidation across multiple entities, making it slow and error-prone.

This project builds a production-style SQL engine that generates:
- Profit & Loss Statement  
- Balance Sheet  
- Financial KPIs and ratios  

Directly from raw GL data.

---

## 📈 Sample Output: P&L Statement

| Metric | FY 2018 | FY 2019 | FY 2020 | YoY 19 vs 18 | YoY 20 vs 19 |
|---|---:|---:|---:|---:|---:|
| Revenue | 84,320 | 97,450 | 89,210 | +15.6% | -8.5% |
| Gross Profit | 32,840 | 38,980 | 33,570 | +18.7% | -13.9% |
| EBITDA | 14,190 | 17,640 | 12,680 | +24.3% | -28.1% |
| Operating Profit | 10,950 | 14,060 | 8,960 | +28.4% | -36.3% |
| Net Profit | 9,130 | 12,410 | 7,020 | +35.9% | -43.4% |

---

## 🏦 Sample Output: Balance Sheet

| Item | FY 2018 | FY 2019 | FY 2020 |
|---|---:|---:|---:|
| Total Assets | 73,870 | 81,470 | 82,100 |
| Total Liabilities | 31,470 | 30,640 | 29,920 |
| Total Equity | 42,400 | 50,830 | 52,180 |

Balance Check: PASS (Assets = Liabilities + Equity)

---

## 📐 Financial Ratios

- Profitability: Gross Margin, Net Margin  
- Liquidity: Current Ratio, Quick Ratio  
- Efficiency: Asset Turnover  
- Returns: ROCE, ROE  

---

## 💼 Business Impact

- Eliminates manual Excel consolidation  
- Reduces reporting time significantly  
- Improves accuracy through validation  

---

## 👤 Contact

G. Suneel  
Email: Sunil.g9090@gmail.com  
Phone: +91 8790091718  
GitHub: https://github.com/sunilg9090
