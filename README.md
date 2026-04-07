# E-Commerce Sales & Profitability Analysis
### MySQL → Python → Power BI &nbsp;|&nbsp; 9,994 Orders &nbsp;|&nbsp; 2014–2017

![Dashboard](dashboard/dashboard_profit_view.png)

---

## Business Problem

A US-based e-commerce retailer is generating **$769K in annual revenue** but operating at only **13.73% profit margin** — well below the 20–25% industry benchmark. The goal of this project is to identify *where* profit is being lost, *which* discounting decisions are destroying margin, and *which* regions, categories, and customer segments are driving or dragging performance.

---

## Dashboard

Two views in one dashboard — toggled via bookmarks in Power BI.

| Profit View | Sales View |
|---|---|
| ![Profit View](dashboard/dashboard_profit_view.png) | ![Sales View](dashboard/dashboard_sales_view.png) |

**KPIs:** `$769.43K Total Revenue` &nbsp;·&nbsp; `$105.63K Total Profit` &nbsp;·&nbsp; `13.73% Profit Margin %` &nbsp;·&nbsp; `8,452 Total Orders`

**Interactive filters:** Order Year · Category · Customer Segment · Region

---

## Key Findings

| # | Finding | Financial Impact |
|---|---------|-----------------|
| 1 | Orders with discounts **above 20%** produce negative average profit — 977 such orders identified | ~$14,830 profit leakage |
| 2 | **Tables** sub-category is loss-making despite generating high sales revenue | Negative total profit |
| 3 | **West region** contributes the highest profit; **Central region** is the weakest performer | $20K+ gap vs West |
| 4 | **Q4 (Oct–Dec)** is consistently the peak quarter across all 4 years | Inventory planning signal |
| 5 | **57.5% of Chair sales** occur between September and December | Seasonal buying pattern |
| 6 | **Technology** has the highest profit margin %; **Office Supplies** (Paper, Accessories) leads on volume profit | Category allocation signal |

---

## Technical Pipeline

```
Raw CSV (9,994 rows)
        │
        ▼
 ── MySQL 8.0 ──────────────────────────────────────────
  • Schema design and data loading via LOAD DATA INFILE
  • Date standardisation using CASE + STR_TO_DATE()
    (handled both MM/DD/YYYY and MM-DD-YYYY formats)
  • Data quality checks — nulls, duplicates, negative sales
  • 9 business analysis queries across category, region,
    segment, discount impact, and seasonal trends
  • 3 advanced queries using window functions:
    RANK() OVER (PARTITION BY Category) for sub-category ranking
    LAG() for year-over-year revenue growth calculation
        │
        ▼
 ── Python — Jupyter Notebook ──────────────────────────
  • Pandas: data cleaning, type conversion, validation
  • Feature engineering: Discount_Band, Month_Name, Order_Year
  • Outlier treatment using 3x IQR threshold
    (business-validated — flagged rows were legitimate bulk orders)
  • Exploratory Data Analysis across 10 business questions
  • Export: ecommerce_clean.csv
        │
        ▼
 ── Power BI Desktop ────────────────────────────────────
  • DAX measures: Profit Margin %, Total Orders, Avg Profit Per Order
  • Calculated column: Discount_Band_Sort (correct slicer sort order)
  • Custom Month_Name sort (Jan to Dec, not alphabetical)
  • Bookmark-based Sales / Profit chart toggle
  • Single-page 1920x1080 dashboard
```

---

## Repository Structure

```
ecommerce-sales-analysis/
│
├── data/
│   ├── e_commerce_data.csv           # Raw dataset (9,994 rows)
│   └── ecommerce_clean.csv           # Cleaned dataset — Power BI input
│
├── notebooks/
│   └── ecommerce_analysis.ipynb      # Python EDA notebook
│
├── sql/
│   └── e_commerce_analysis.sql       # MySQL schema + all queries
│
├── dashboard/
│   ├── ecommerce_dashboard.pbix      # Power BI file
│   ├── dashboard_profit_view.png     # Dashboard screenshot — Profit view
│   └── dashboard_sales_view.png      # Dashboard screenshot — Sales view
│
└── README.md
```

---

## Notable Technical Decisions

**Mixed-format date handling in MySQL**
The raw dataset contained dates in both `MM/DD/YYYY` and `MM-DD-YYYY` formats. Instead of fixing this in Python before loading, a `CASE`-based `STR_TO_DATE()` was used inside a single `UPDATE` statement to normalise both formats directly in MySQL — keeping the cleaning logic closer to the data layer.

**Business-validated outlier threshold**
Used 3x IQR instead of the standard 1.5x after manually inspecting the flagged rows. The extreme values were legitimate bulk corporate orders — removing them would have distorted the Consumer vs Corporate segment analysis. The decision is documented in the notebook with reasoning.

**Bookmark-based chart toggle in Power BI**
Built a Sales/Profit toggle using two overlapping visual groups and Power BI bookmarks. This avoids the need for separate report pages and keeps all analysis on a single screen — suited for executive-style presentation.

**Window functions for ranking and YoY growth**
Used `RANK() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC)` to rank sub-categories within each category, and `LAG()` over year to calculate year-over-year revenue growth — demonstrating SQL beyond basic GROUP BY aggregation.

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| MySQL 8.0 | Data storage, cleaning, business queries, window functions |
| Python 3 — Pandas, Matplotlib, Seaborn | EDA, feature engineering, outlier treatment |
| Jupyter Notebook | Analysis documentation |
| Power BI Desktop | Interactive dashboard, DAX, bookmarks |

---

## Dataset

- **Source:** Sample Superstore Sales Dataset
- **Size:** 9,994 rows · 21 columns
- **Period:** January 2014 – December 2017
- **Geography:** United States
- **Categories:** Furniture · Office Supplies · Technology

---

*Part of a data analytics portfolio. Open to Junior Data Analyst and Business Analyst roles.*
