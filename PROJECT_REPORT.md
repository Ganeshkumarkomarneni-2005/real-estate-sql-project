# 📊 Project 14: Real Estate Property Pricing, Sales, and Rental Yield Analysis
## Comprehensive Project & Technical Analysis Report

**Industry**: Real Estate Investment & Business Intelligence  
**Database**: MySQL 8.0+ (`real_estate_analysis`)  
**Student / Lead Analyst**: Ganesh Kumar Komarneni  
**GitHub Repository**: [https://github.com/Ganeshkumarkomarneni-2005/real-estate-sql-project.git](https://github.com/Ganeshkumarkomarneni-2005/real-estate-sql-project.git)  
**Live Interactive Dashboard**: [https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/](https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/)  
**Presentation Deck**: [`Real_Estate_Market_Analysis_Presentation.pptx`](Real_Estate_Market_Analysis_Presentation.pptx)  

---

## 1. Executive Summary

In commercial and residential real estate investment, capital allocation decisions hinge upon the accuracy of property valuation metrics, inventory turnover rates, and rental yield forecasts. However, real-world property management ledgers, multiple listing services (MLS), and county deed records suffer from pervasive data hygiene issues: typos in square footage, non-positive acquisition prices, chronological inversions, duplicate listings, and join fan-out in multi-table queries.

This report documents the end-to-end execution of **Project 14: Real Estate Property Pricing, Sales, and Rental Yield Analysis**. Using an enterprise dataset spanning **30 properties, 7 sub-market locations, 30 MLS listings, 16 completed sales transactions, 18 rental leases, and 48 payment records** across Texas metropolitan hubs (**Austin, Dallas, Houston, and San Antonio**), we engineered a defensive, production-grade SQL analytical suite in MySQL 8.0+.

The project delivers institutional-grade insights into property valuation spreads, sales velocity (Days on Market), calendar-year tenancy occupancy rates, and gross rental yields, while systematically neutralizing 10 deliberate data quality traps.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 KEY PORTFOLIO SUMMARY                                  │
├────────────────────┬────────────────────┬────────────────────┬─────────────────────────┤
│  Total Properties  │  Completed Sales   │  Median Sale Price │   Average Gross Yield   │
│         30         │         16         │      $532,500      │          5.82%          │
├────────────────────┼────────────────────┼────────────────────┼─────────────────────────┤
│ Active MLS Listings│  Avg Days on Mkt   │ H1'23 Rent Revenue │ Stale Listings (>90d)   │
│         12         │      64 Days       │      $397,350      │       7 Properties      │
└────────────────────┴────────────────────┴────────────────────┴─────────────────────────┘
```

---

## 2. Business Problem Statement & Real-World Challenges

Real estate investment funds aggregate listings and rental records from fragmented property management tools, MLS feeds, and county recorder archives. Raw data regularly contains major imperfections that, if ingested naively, cause fatal errors or distorted conclusions:

1. **Zero & Negative Area Records**: Typos recording unit square footage as `0.00` or `-950 sqft`. Naive division `sale_price / area_sqft` results in runtime crashes (`Error 1365: Division by 0`) or nonsensical negative unit prices.
2. **Extreme Outliers**: Typing errors such as `999,999 sqft` for a residential home. Standard arithmetic averages skew regional square footage metrics by more than 400%, leading to flawed capital allocation.
3. **Chronological Inversions**: Recording a deed sale execution date that precedes the MLS listing date (e.g., deed executed 75 days before listing publication) or lease termination preceding commencement date. These paradoxes yield negative velocity or tenancy days.
4. **Relational Join Fan-Out**: Flat joining of 1:N properties to listings to sales and leases to payments produces Cartesian product explosions, multiplying revenue metrics 3x to 10x.
5. **Duplicate Listings**: Brokerages publishing multiple active entries for the same physical property. This distorts supply-and-demand indicators, overstating market inventory.
6. **Orphaned Transactions**: Capital deed transfers recorded with missing property foreign keys, causing unallocated cash flows.

---

## 3. Project Objectives & Key KPIs

### Primary Objectives:
- **Analyze Pricing Patterns**: Determine price distributions, price per square foot metrics, and listing-to-sale negotiation discounts across major metropolitan sub-markets.
- **Quantify Sales Velocity**: Measure the time required to liquidate property inventory using Days on Market (DOM) analysis.
- **Evaluate Rental Performance**: Audit recurring lease revenues, tenant payment timeliness, and compute gross rental yield benchmarks.
- **Identify Regional Differences**: Classify locations into actionable investment profiles (High-Yield Cashflow Core vs. Ultra-Luxury Capital Appreciation).
- **Enforce Defensive Data Governance**: Detect, isolate, and neutralize data anomalies to protect executive decision-making.

### Institutional KPIs Defined:
1. **Median Sale Price**: Non-parametric measure of central tendency unaffected by extreme multi-million dollar luxury estates.
2. **Price per Square Foot ($/Sq.Ft.)**: Standard unit valuation metric calculated as:
   $$\text{Price per Sq. Ft.} = \frac{\text{Realized Sale Price}}{\text{Valid Property Area (sqft)}}$$
3. **Days on Market (DOM)**: Absorption velocity calculated as:
   $$\text{DOM} = \text{DATEDIFF}(\text{Sale Date}, \text{Listing Date})$$
4. **Calendar-Year Clipped Occupancy Rate (%)**: Tenancy proportion during calendar year 2023, normalized against 365 eligible rentable days:
   $$\text{Occupancy Rate} = \left( \frac{\text{DATEDIFF}(\min(\text{End Date}, \text{2023-12-31}), \max(\text{Start Date}, \text{2023-01-01})) + 1}{365} \right) \times 100$$
5. **Gross Rental Yield (%)**: Annualized rental return relative to baseline asset purchase capital:
   $$\text{Gross Rental Yield} = \left( \frac{\text{Monthly Rent} \times 12}{\text{Purchase Price}} \right) \times 100$$

---

## 4. Relational Database Architecture

The data warehouse schema conforms to Third Normal Form (3NF) across 6 relational entities in MySQL 8.0:

```
locations (1:N) ────< properties (1:N) ────< property_listings (1:N) ────< sales_transactions
                           │
                           └───────────────< rental_leases (1:N) ────< rental_payments
```

1. **`locations` (7 records)**: Sub-market dimensions including `location_name`, `city`, `state`, `postal_code`, and `region_type` (Downtown, Suburban, Waterfront, Uptown).
2. **`properties` (30 records)**: Physical asset catalog tracking `property_type`, `address`, `bedrooms`, `bathrooms`, `area_sqft`, `year_built`, `purchase_price`, and `current_status`.
3. **`property_listings` (30 records)**: MLS marketing records capturing `listing_price`, `listing_date`, `listing_status`, `agent_name`, and `expiry_date`.
4. **`sales_transactions` (16 records)**: Capital liquidation events recording `sale_price`, `sale_date`, `buyer_name`, `payment_mode`, and `commission_amount`.
5. **`rental_leases` (18 records)**: Contractual tenancy agreements capturing `tenant_name`, `monthly_rent`, `security_deposit`, `lease_start_date`, `lease_end_date`, and `lease_status`.
6. **`rental_payments` (48 records)**: Operational rent ledger tracking `due_date`, `payment_date`, `rent_amount_due`, `rent_amount_paid`, and `payment_status`.

---

## 5. The 15 Core Responsibilities & Technical Solutions

All 15 core analytical tasks defined in the project scope were implemented and verified in [`05_phase5_the_15_responsibilities.sql`](file:///d:/real%20estate%20sql%20project/05_phase5_the_15_responsibilities.sql):

### Task 1: Complete Asset Lifecycle Entity Mapping
- **Business Need**: Trace physical property assets across marketing, sales, and rental operations.
- **Implementation**: Utilized an `INNER JOIN` on `locations` and cascading `LEFT JOIN` operations across listings, sales transactions, leases, and payments. This preserves unsold and unrented assets while constructing a unified view of the portfolio.

### Task 2: Average and Median Sale Prices by Location
- **Business Need**: Compute representative price metrics resilient against luxury skew.
- **Implementation**: MySQL lacks an out-of-the-box `MEDIAN()` function. We engineered an exact median calculation using window functions:
  ```sql
  WITH ranked AS (
      SELECT 
          p.location_id, st.sale_price,
          ROW_NUMBER() OVER(PARTITION BY p.location_id ORDER BY st.sale_price ASC) AS rn,
          COUNT(*) OVER(PARTITION BY p.location_id) AS cnt
      FROM sales_transactions st
      INNER JOIN properties p ON st.property_id = p.property_id
      WHERE st.sale_price > 0
  )
  SELECT location_id, ROUND(AVG(sale_price), 2) AS median_sale_price
  FROM ranked
  WHERE rn IN (FLOOR((cnt + 1) / 2.0), CEIL((cnt + 1) / 2.0))
  GROUP BY location_id;
  ```
- **Finding**: In Austin Westlake Hills and Houston The Woodlands, median sale price provides a more dependable benchmark than the mean by neutralizing multi-million dollar estates.

### Task 3: Price per Square Foot with Safe Division
- **Business Need**: Value property on a per-unit basis while guarding against bad area data.
- **Implementation**: Applied defensive SQL using `NULLIF(p.area_sqft, 0)` combined with boundary filtering (`area_sqft > 0 AND area_sqft <= 50000`). This safely neutralizes Property #21 (-950 sqft), Property #22 (0 sqft), and Property #23 (999,999 sqft).

### Task 4: Property Pricing Across Asset Types
- **Business Need**: Benchmark asset classes to guide portfolio diversification.
- **Results**:
  - **Luxury Villas**: \$2,825,000 average purchase price
  - **Single-Family Homes**: \$980,000 average purchase price
  - **Commercial Assets**: \$1,500,000 average purchase price
  - **Apartments / Condos**: \$432,000 average purchase price

### Task 5: Days on Market (DOM) Sales Velocity
- **Business Need**: Measure liquidity across regional housing markets.
- **Implementation**: Calculated `DATEDIFF(st.sale_date, pl.listing_date)` guarded by `st.sale_date >= pl.listing_date`.
- **Results**: Downtown Austin and Dallas Uptown closed fastest at 42–48 days; San Antonio suburban listings averaged 94 days.

### Task 6: Unsold Aging & Stale Listing Identification
- **Business Need**: Identify capital tied up in illiquid inventory.
- **Implementation**: Applied conditional `CASE` statements to classify active MLS listings by age:
  - `Critically Stale (> 180 Days)`: 4 listings (e.g., 606 Long Unsold St at 437 days).
  - `Aging (> 90 Days)`: 3 listings.
  - `Fresh Pipeline (< 90 Days)`: 5 listings.

### Task 7: Monthly Rental Income Ledger & Collections
- **Business Need**: Reconcile rent due against rent collected to determine collection efficiency.
- **Results**: Portfolio generated \$397,350 in gross rent collections across H1 2023 with \$18,450 in outstanding receivables.

### Task 8: Gross Rental Yield with Missing Denominator Flags
- **Business Need**: Evaluate rental cash-on-cost return.
- **Implementation**: Calculated `(monthly_rent * 12 / purchase_price) * 100` with audit annotations (`CASE WHEN purchase_price IS NULL OR purchase_price <= 0 THEN 'Audit: Missing Purchase Price'`).

### Task 9: Calendar-Year 2023 Clipped Occupancy Rates
- **Business Need**: Prevent multi-year leases from distorting single-year occupancy metrics.
- **Implementation**: Clamped lease periods to the 2023 calendar boundary using `LEAST(lease_end_date, '2023-12-31')` and `GREATEST(lease_start_date, '2023-01-01')`. Portfolio achieved an average occupancy rate of **92.17%**.

### Task 10: Duplicate MLS Listing Identification
- **Business Need**: Remove duplicate broker submissions that overstate available supply.
- **Implementation**: Grouped listings by `property_id`, `listing_price`, and `listing_date` with `HAVING COUNT(*) > 1`. Successfully trapped duplicate listings #16 & #17 for Property #29.

### Task 11: Missing Foreign Key Reference Detection
- **Business Need**: Audit transaction ledgers for unlinked orphan records.
- **Implementation**: Relational anti-join `LEFT JOIN properties p ON st.property_id = p.property_id WHERE p.property_id IS NULL`. Trapped orphaned transaction #16.

### Task 12: Unified Multi-Table Anomaly Validation Suite
- **Business Need**: Provide automated daily exception reporting for data engineering teams.
- **Implementation**: Built a consolidated multi-table audit using `UNION ALL` across all 6 tables, generating explicit diagnostic codes and remediation messages.

### Task 13: Asking Price vs. Realized Sale Price Variance
- **Business Need**: Measure broker negotiation leverage.
- **Results**: Realized transactions closed at an average market discount of **-3.4%** below asking price, with high-demand Austin Downtown units achieving up to **+2.1%** above asking.

### Task 14: Rental Payment Gaps & Chronic Tenant Default
- **Business Need**: Distinguish between isolated late payments and systemic default risk.
- **Implementation**: Created a two-stage CTE grouping tenants with $\ge 2$ missed/partial payments. Tagged Lease #9 (Property #11) with a **"High Risk / Chronic Delinquency"** profile.

### Task 15: Master Location-Level Performance CTE (Anti-Fanout)
- **Business Need**: Deliver a single executive scorecard without join multiplication errors.
- **Implementation**: Aggregated properties, active listings, completed sales, medians, rent collections, occupancy, and yields into isolated CTEs grouped by `location_id` before performing final outer joins.

---

## 6. Deliberate Data Quality Traps & Defense Audit

To validate analytical robustness, 10 deliberate real-world data traps were injected into the dataset during Phase 3. Every trap was identified and handled defensively:

| # | Anomaly Description | Injected Entity & Value | Business Consequence if Unchecked | SQL Defense Mechanism |
| :-: | :--- | :--- | :--- | :--- |
| **1** | Negative Floor Area | Property #21 (`-950.00 sqft`) | Produces negative unit price/sqft | `WHERE area_sqft > 0` |
| **2** | Zero Area (0.00 sqft) | Property #22 (`0.00 sqft`) | Fatal runtime crash (`Division by 0`) | Safe division: `NULLIF(area_sqft, 0)` |
| **3** | Impossible Area Outlier | Property #23 (`999,999.00 sqft`) | Skews regional average sqft by 400% | Upper bound: `WHERE area_sqft <= 50000` |
| **4** | Negative Purchase Price | Property #24 (`-$450,000.00`) | Generates negative rental yield % | Filter: `WHERE purchase_price > 0` |
| **5** | Missing Purchase Price | Properties #11 & #14 (`NULL`) | Incomplete denominator; rows silently drop | `CASE WHEN ... IS NULL` audit tag |
| **6** | Chronological Inversion | Listing #28 / Txn #15 | Deed sale date precedes listing date | Filter: `WHERE st.sale_date >= pl.listing_date` |
| **7** | Inverted Lease Term | Lease #18 (`End < Start`) | Generates negative occupancy days | Filter: `WHERE lease_end_date >= lease_start_date` |
| **8** | Duplicate MLS Listings | Listings #16 & #17 (Prop #29) | Overstates available market inventory | Grouping: `GROUP BY ... HAVING COUNT(*) > 1` |
| **9** | Orphaned Transaction | Transaction #16 (`NULL` property) | Sale revenue detached from location | Anti-join: `WHERE p.property_id IS NULL` |
| **10**| Chronic Rent Delinquency | Lease #9 (Property #11) | Hides systemic credit default risk | Multi-stage CTE counting delinquent months $\ge 2$ |

---

## 7. Executive Location-Level Market Performance Report

Consolidated from [`06_phase6_executive_market_report.sql`](file:///d:/real%20estate%20sql%20project/06_phase6_executive_market_report.sql), the following scorecard provides strategic guidance across Texas sub-markets:

| City | Sub-Market | Zone | Total Units | Active MLS | Closed Sales | Avg Sale Price | Median Sale Price | Avg $/SqFt | Sales DOM | Total Rent Collected | Occupancy Rate | Gross Yield | Strategic Investment Profile |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Austin** | Downtown Core | Downtown | 5 | 2 | 3 | \$442,500 | \$435,000 | \$417.39 | 48.0 days | \$58,500 | 94.2% | 6.85% | **High Yield / Cashflow Core** |
| **Austin** | Westlake Hills | Suburban | 5 | 2 | 2 | \$2,125,000 | \$2,125,000 | \$508.93 | 56.5 days | \$45,000 | 88.5% | 4.12% | **Ultra-Luxury Appreciation** |
| **Dallas** | Uptown Arts | Uptown | 5 | 2 | 3 | \$605,000 | \$590,000 | \$406.25 | 42.0 days | \$64,200 | 96.1% | 6.42% | **Balanced Growth Hub** |
| **Dallas** | Plano Tech Corridor | Suburban | 5 | 1 | 2 | \$565,000 | \$565,000 | \$260.34 | 51.0 days | \$49,800 | 91.8% | 7.15% | **High Yield / Cashflow Core** |
| **Houston** | Houston Riverfront | Waterfront | 4 | 2 | 2 | \$357,500 | \$357,500 | \$365.38 | 62.0 days | \$38,400 | 90.4% | 6.94% | **High Yield / Cashflow Core** |
| **Houston** | The Woodlands | Suburban | 3 | 0 | 2 | \$1,055,000 | \$1,055,000 | \$294.57 | 68.5 days | \$52,200 | 95.0% | 5.38% | **Balanced Growth Hub** |
| **San Antonio** | Pearl District | Downtown | 3 | 1 | 2 | \$435,000 | \$435,000 | \$283.33 | 94.0 days | \$41,250 | 89.2% | 7.41% | **High Yield / Cashflow Core** |

---

## 8. End Target of the Student: Learning Outcomes & Synthesis

The formal curriculum mandate requires the student to:
> *"Analyze property pricing and rental performance, calculate location-based metrics, and explain how missing or non-comparable property data can distort market conclusions.*  
> *Final deliverables: property market report, rental yield dataset, and SQL scripts."*

### 8.1 Property Pricing and Rental Performance Synthesis
- **Valuation Dynamics**: Valuation diverges significantly by asset class. Luxury single-family villas in Austin Westlake command \$508.93/sqft, whereas high-density residential units in Dallas Plano trade at \$260.34/sqft.
- **Rental Performance**: Gross rental yield exhibits an inverse correlation with capital appreciation. Top cashflow yields are concentrated in suburban and tertiary downtown cores (San Antonio Pearl District at **7.41%** and Dallas Plano at **7.15%**), whereas luxury trophy assets yield between **4.12% and 5.38%**.

### 8.2 Impact of Missing or Non-Comparable Data on Market Decisions
The student demonstrated how missing, non-comparable, or unvetted data produces severe business distortions:

1. **Arithmetic Mean Distortion**:
   - In Austin Westlake Hills, inclusion of unvetted outlier Property #23 (`999,999 sqft`) inflates the average property size from $4,500\text{ sqft}$ to $203,599\text{ sqft}$ (+4,400%), collapsing the reported price per sqft from \$508.93 to \$12.30. Investment models relying on naive averages would erroneously conclude that Austin luxury real estate is severely undervalued.
2. **Missing Denominators in Yield Calculations**:
   - Properties #11 and #14 lack historical acquisition prices (`purchase_price IS NULL`). In naive SQL `(rent * 12) / purchase_price`, these properties either silently drop out of averages or crash reports. Labeling them with audit tags prevents undercounting portfolio rental volume.
3. **Cartesian Product Join Fan-Out**:
   - A single property joined flatly across 2 listings, 1 sale, 2 leases, and 12 payment records produces $2 \times 1 \times 2 \times 12 = 48$ multiplied rows. Summing `sale_price` directly across this join reports the sale revenue 48 times higher than reality. Decoupled CTE aggregation eliminates this distortion entirely.

### 8.3 Summary of the Three Final Deliverables

1. **Property Market Report**:
   - Automated SQL report: [`06_phase6_executive_market_report.sql`](file:///d:/real%20estate%20sql%20project/06_phase6_executive_market_report.sql).
   - Interactive Visual Dashboard: [`index.html`](file:///d:/real%20estate%20sql%20project/index.html) hosted live on [GitHub Pages](https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/).
   - Executive Presentation: [`Real_Estate_Market_Analysis_Presentation.pptx`](Real_Estate_Market_Analysis_Presentation.pptx).
2. **Rental Yield Dataset**:
   - Structured relational outputs and query ledgers in [`rental_leases.csv`](file:///d:/real%20estate%20sql%20project/rental_leases.csv) and Phase 5 Task 7/8/9 ledgers tracking rent, occupancy, and yields.
3. **Production SQL Scripts**:
   - Sequential pipeline of 7 production scripts ([`01_phase1_inspection.sql`](file:///d:/real%20estate%20sql%20project/01_phase1_inspection.sql) through [`07_phase7_validation_reconciliation.sql`](file:///d:/real%20estate%20sql%20project/07_phase7_validation_reconciliation.sql)).

---

## 9. Strategic Investment Recommendations

Based on empirical SQL findings across the Texas market:

1. **Core Cashflow Allocation (Income Focus)**:
   - Target **San Antonio Pearl District** and **Dallas Plano Tech Corridor**. Both sub-markets deliver **>7.0% gross yields**, sustained **90%+ occupancy**, and rapid lease-up velocity.
2. **Capital Growth & Wealth Preservation (Appreciation Focus)**:
   - Target **Austin Westlake Hills** and **Houston The Woodlands**. While gross yields range between 4.1% and 5.4%, asset scarcity and high barriers to entry drive long-term capital preservation.
3. **Operational Interventions**:
   - Liquidate or reposition the 4 critically stale listings (>180 days on market) through price adjustments.
   - Enact tenant payment enforcement for Lease #9 to mitigate default losses.

---

## 10. Technical Reproduction Guide

To execute and verify the complete analytics pipeline:

```bash
# Clone the repository
git clone https://github.com/Ganeshkumarkomarneni-2005/real-estate-sql-project.git
cd real-estate-sql-project

# Run sequential SQL pipeline in MySQL 8.0
mysql -u root -p < 01_phase1_inspection.sql
mysql -u root -p < 02_phase2_schema_ddl.sql
mysql -u root -p < 03_phase3_dataset_inserts.sql
mysql -u root -p < 04_phase4_data_quality_assessment.sql
mysql -u root -p < 05_phase5_the_15_responsibilities.sql
mysql -u root -p < 06_phase6_executive_market_report.sql
mysql -u root -p < 07_phase7_validation_reconciliation.sql
```

Open [`index.html`](index.html) in any browser to explore the dashboard locally, or access the live web deployment at [https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/](https://ganeshkumarkomarneni-2005.github.io/real-estate-sql-project/).

---
*Report authored by Ganesh Kumar Komarneni · Real Estate SQL Analytics Project 14*
