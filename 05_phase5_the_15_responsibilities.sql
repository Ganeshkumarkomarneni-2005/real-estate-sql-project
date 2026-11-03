-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 05_phase5_the_15_responsibilities.sql
-- PURPOSE: The 15 Core Analytical SQL Tasks
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- ============================================================================
-- TASK 1: MAP THE REAL ESTATE DATABASE
-- Map properties, locations, listings, transactions, leases, and rental payments.
-- ============================================================================
SELECT 
    p.property_id,
    p.address,
    p.property_type,
    p.current_status,
    loc.location_name,
    loc.city,
    loc.region_type,
    pl.listing_id,
    pl.listing_price,
    pl.listing_status,
    st.transaction_id AS sale_id,
    st.sale_price,
    st.sale_date,
    rl.lease_id,
    rl.tenant_name,
    rl.monthly_rent,
    rl.lease_status,
    rp.payment_id,
    rp.due_date,
    rp.rent_amount_paid,
    rp.payment_status
FROM properties p
INNER JOIN locations loc ON p.location_id = loc.location_id
LEFT JOIN property_listings pl ON p.property_id = pl.property_id
LEFT JOIN sales_transactions st ON p.property_id = st.property_id
LEFT JOIN rental_leases rl ON p.property_id = rl.property_id
LEFT JOIN rental_payments rp ON rl.lease_id = rp.lease_id
ORDER BY loc.city, p.property_id, pl.listing_id, rl.lease_id, rp.payment_id;

-- ============================================================================
-- TASK 2: AVERAGE AND MEDIAN SALE PRICES BY LOCATION
-- Calculate average and exact median sale prices by location for completed sales.
-- ============================================================================
WITH completed_sales AS (
    SELECT 
        l.location_id,
        l.location_name,
        l.city,
        st.sale_price,
        ROW_NUMBER() OVER (
            PARTITION BY l.location_id 
            ORDER BY st.sale_price ASC, st.transaction_id ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY l.location_id
        ) AS total_sales
    FROM sales_transactions st
    INNER JOIN properties p ON st.property_id = p.property_id
    INNER JOIN locations l ON p.location_id = l.location_id
    WHERE st.sale_price IS NOT NULL AND st.sale_price > 0
),
location_medians AS (
    SELECT 
        location_id,
        ROUND(AVG(sale_price), 2) AS median_sale_price
    FROM completed_sales
    WHERE row_num IN (FLOOR((total_sales + 1) / 2.0), CEIL((total_sales + 1) / 2.0))
    GROUP BY location_id
)
SELECT 
    cs.city,
    cs.location_name,
    MAX(cs.total_sales) AS total_completed_sales,
    ROUND(AVG(cs.sale_price), 2) AS average_sale_price,
    lm.median_sale_price
FROM completed_sales cs
INNER JOIN location_medians lm ON cs.location_id = lm.location_id
GROUP BY cs.city, cs.location_name, lm.median_sale_price
ORDER BY average_sale_price DESC;

-- ============================================================================
-- TASK 3: PRICE PER SQUARE FOOT (VALID AREAS ONLY)
-- Calculates price/sqft for completed sales, excluding zero/negative/null/outliers.
-- ============================================================================
SELECT 
    p.property_id,
    p.address,
    loc.location_name,
    loc.city,
    p.property_type,
    p.area_sqft,
    st.sale_price,
    st.sale_date,
    ROUND(st.sale_price / NULLIF(p.area_sqft, 0), 2) AS price_per_sqft
FROM sales_transactions st
INNER JOIN properties p ON st.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id
WHERE p.area_sqft IS NOT NULL 
  AND p.area_sqft > 0 
  AND p.area_sqft <= 50000
  AND st.sale_price IS NOT NULL 
  AND st.sale_price > 0
ORDER BY price_per_sqft DESC;

-- ============================================================================
-- TASK 4: COMPARE PROPERTY PRICES ACROSS PROPERTY TYPES
-- Compares average, median, min, max prices, and property count by type.
-- ============================================================================
WITH valid_prices AS (
    SELECT 
        property_id,
        property_type,
        purchase_price,
        ROW_NUMBER() OVER (
            PARTITION BY property_type 
            ORDER BY purchase_price ASC, property_id ASC
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY property_type
        ) AS type_count
    FROM properties
    WHERE purchase_price IS NOT NULL AND purchase_price > 0
),
type_medians AS (
    SELECT 
        property_type,
        ROUND(AVG(purchase_price), 2) AS median_price
    FROM valid_prices
    WHERE row_num IN (FLOOR((type_count + 1) / 2.0), CEIL((type_count + 1) / 2.0))
    GROUP BY property_type
)
SELECT 
    vp.property_type,
    MAX(vp.type_count) AS property_count,
    ROUND(AVG(vp.purchase_price), 2) AS average_price,
    tm.median_price,
    MIN(vp.purchase_price) AS min_price,
    MAX(vp.purchase_price) AS max_price,
    ROUND(MAX(vp.purchase_price) - MIN(vp.purchase_price), 2) AS price_spread
FROM valid_prices vp
INNER JOIN type_medians tm ON vp.property_type = tm.property_type
GROUP BY vp.property_type, tm.median_price
ORDER BY average_price DESC;

-- ============================================================================
-- TASK 5: DAYS ON MARKET (COMPLETED SALES)
-- Calculate days on market between listing date and completed sale date.
-- ============================================================================
SELECT 
    st.transaction_id,
    p.property_id,
    p.address,
    loc.city,
    pl.listing_id,
    pl.listing_date,
    st.sale_date,
    pl.listing_price,
    st.sale_price,
    DATEDIFF(st.sale_date, pl.listing_date) AS days_on_market
FROM sales_transactions st
INNER JOIN property_listings pl ON st.listing_id = pl.listing_id
INNER JOIN properties p ON st.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id
WHERE pl.listing_date IS NOT NULL
  AND st.sale_date IS NOT NULL
  AND st.sale_date >= pl.listing_date
ORDER BY days_on_market ASC;

-- ============================================================================
-- TASK 6: UNSOLD LISTINGS BEYOND A DEFINED THRESHOLD (90 DAYS)
-- ============================================================================
WITH listing_aging AS (
    SELECT 
        pl.listing_id,
        p.property_id,
        p.address,
        loc.location_name,
        loc.city,
        p.property_type,
        pl.listing_price,
        pl.listing_date,
        pl.listing_status,
        pl.agent_name,
        DATEDIFF(COALESCE(pl.expiry_date, CURRENT_DATE), pl.listing_date) AS listing_age_days
    FROM property_listings pl
    INNER JOIN properties p ON pl.property_id = p.property_id
    INNER JOIN locations loc ON p.location_id = loc.location_id
    WHERE pl.listing_status IN ('Active', 'Expired', 'Withdrawn')
)
SELECT 
    listing_id,
    property_id,
    address,
    city,
    location_name,
    property_type,
    listing_price,
    listing_date,
    listing_status,
    agent_name,
    listing_age_days,
    CASE 
        WHEN listing_age_days > 180 THEN 'Critically Stale (> 180 Days)'
        WHEN listing_age_days > 90  THEN 'Aging Inventory (> 90 Days)'
        ELSE 'Normal'
    END AS aging_category
FROM listing_aging
WHERE listing_age_days > 90
ORDER BY listing_age_days DESC;

-- ============================================================================
-- TASK 7: MONTHLY RENTAL INCOME BY PROPERTY AND MONTH
-- ============================================================================
SELECT 
    p.property_id,
    p.address,
    loc.city,
    DATE_FORMAT(rp.due_date, '%Y-%m') AS rent_month,
    SUM(rp.rent_amount_due) AS total_rent_due,
    SUM(rp.rent_amount_paid) AS total_rent_received,
    SUM(rp.rent_amount_due - rp.rent_amount_paid) AS outstanding_amount,
    CASE 
        WHEN SUM(rp.rent_amount_due - rp.rent_amount_paid) = 0 THEN 'Fully Collected'
        WHEN SUM(rp.rent_amount_paid) > 0 THEN 'Partially Collected'
        ELSE 'Default / Unpaid'
    END AS collection_status
FROM rental_payments rp
INNER JOIN rental_leases rl ON rp.lease_id = rl.lease_id
INNER JOIN properties p ON rl.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id
GROUP BY p.property_id, p.address, loc.city, DATE_FORMAT(rp.due_date, '%Y-%m')
ORDER BY p.property_id, rent_month;

-- ============================================================================
-- TASK 8: GROSS RENTAL YIELD
-- Formula: Gross Rental Yield (%) = (Annual Gross Rental Income / Purchase Price) * 100
-- ============================================================================
WITH annualized_rental AS (
    SELECT 
        rl.property_id,
        SUM(rp.rent_amount_paid) AS actual_collected_rent,
        AVG(rl.monthly_rent) * 12 AS projected_annual_gross_rent
    FROM rental_leases rl
    LEFT JOIN rental_payments rp ON rl.lease_id = rp.lease_id
    GROUP BY rl.property_id
)
SELECT 
    p.property_id,
    p.address,
    loc.location_name,
    loc.city,
    p.property_type,
    p.purchase_price,
    ar.actual_collected_rent,
    ROUND(ar.projected_annual_gross_rent, 2) AS projected_annual_gross_rent,
    CASE 
        WHEN p.purchase_price IS NULL THEN NULL
        WHEN p.purchase_price <= 0 THEN NULL
        ELSE ROUND((ar.projected_annual_gross_rent / p.purchase_price) * 100, 2)
    END AS gross_rental_yield_pct,
    CASE 
        WHEN p.purchase_price IS NULL THEN 'Missing Purchase Price (Cannot Calculate)'
        WHEN p.purchase_price <= 0 THEN 'Invalid Purchase Price Data'
        WHEN ar.projected_annual_gross_rent IS NULL THEN 'No Rental History Available'
        ELSE 'Yield Accurately Computed'
    END AS yield_audit_remark
FROM properties p
INNER JOIN locations loc ON p.location_id = loc.location_id
LEFT JOIN annualized_rental ar ON p.property_id = ar.property_id
WHERE p.current_status IN ('Rented', 'Available')
ORDER BY gross_rental_yield_pct DESC;

-- ============================================================================
-- TASK 9: OCCUPANCY RATE (CALENDAR YEAR 2023)
-- Formula: Occupancy Rate (%) = (Occupied Eligible Days / Total Eligible Rentable Days) * 100
-- ============================================================================
WITH eligible_period AS (
    SELECT 
        DATE('2023-01-01') AS period_start,
        DATE('2023-12-31') AS period_end,
        365 AS total_eligible_days
),
lease_clipped_days AS (
    SELECT 
        rl.property_id,
        rl.lease_id,
        GREATEST(rl.lease_start_date, ep.period_start) AS eff_start,
        LEAST(rl.lease_end_date, ep.period_end) AS eff_end
    FROM rental_leases rl
    CROSS JOIN eligible_period ep
    WHERE rl.lease_start_date <= ep.period_end
      AND rl.lease_end_date >= ep.period_start
      AND rl.lease_end_date >= rl.lease_start_date
),
property_occupied_days AS (
    SELECT 
        property_id,
        SUM(DATEDIFF(eff_end, eff_start) + 1) AS occupied_days
    FROM lease_clipped_days
    GROUP BY property_id
)
SELECT 
    p.property_id,
    p.address,
    loc.location_name,
    loc.city,
    ep.total_eligible_days AS total_rentable_days_2023,
    COALESCE(pod.occupied_days, 0) AS occupied_days_2023,
    ROUND((COALESCE(pod.occupied_days, 0) / ep.total_eligible_days) * 100, 2) AS occupancy_rate_pct
FROM properties p
INNER JOIN locations loc ON p.location_id = loc.location_id
CROSS JOIN eligible_period ep
LEFT JOIN property_occupied_days pod ON p.property_id = pod.property_id
WHERE p.property_type != 'Commercial'
ORDER BY occupancy_rate_pct DESC;

-- ============================================================================
-- TASK 10: DUPLICATE LISTINGS
-- ============================================================================
SELECT 
    pl.property_id,
    p.address,
    pl.listing_price,
    pl.listing_date,
    COUNT(*) AS record_count,
    GROUP_CONCAT(pl.listing_id ORDER BY pl.listing_id SEPARATOR ', ') AS duplicate_listing_ids
FROM property_listings pl
INNER JOIN properties p ON pl.property_id = p.property_id
GROUP BY pl.property_id, p.address, pl.listing_price, pl.listing_date
HAVING COUNT(*) > 1;

-- ============================================================================
-- TASK 11: MISSING PROPERTY REFERENCES
-- ============================================================================
SELECT 
    st.transaction_id,
    st.listing_id,
    st.property_id AS transaction_property_id,
    st.sale_price,
    st.sale_date,
    st.buyer_name,
    CASE 
        WHEN st.property_id IS NULL THEN 'Missing Foreign Key (Property ID is NULL)'
        WHEN p.property_id IS NULL THEN 'Orphaned Foreign Key (Property ID does not exist)'
        ELSE 'Valid'
    END AS reference_integrity_issue
FROM sales_transactions st
LEFT JOIN properties p ON st.property_id = p.property_id
WHERE st.property_id IS NULL OR p.property_id IS NULL;

-- ============================================================================
-- TASK 12: DATA VALIDATION
-- ============================================================================
SELECT 
    'properties' AS entity,
    property_id AS record_id,
    address AS identifier,
    CASE 
        WHEN area_sqft IS NULL THEN 'Area is NULL'
        WHEN area_sqft <= 0 THEN 'Area is Zero or Negative'
        WHEN area_sqft > 50000 THEN 'Impossible Area (> 50,000 sqft)'
        WHEN purchase_price <= 0 THEN 'Purchase Price is Zero or Negative'
        WHEN location_id IS NULL THEN 'Missing mandatory location reference'
        ELSE 'Other Anomaly'
    END AS validation_issue
FROM properties
WHERE area_sqft IS NULL 
   OR area_sqft <= 0 
   OR area_sqft > 50000 
   OR purchase_price <= 0 
   OR location_id IS NULL
UNION ALL
SELECT 
    'sales_transactions',
    st.transaction_id,
    CONCAT('Listing ID: ', st.listing_id),
    'Sale date precedes listing date'
FROM sales_transactions st
INNER JOIN property_listings pl ON st.listing_id = pl.listing_id
WHERE st.sale_date < pl.listing_date
UNION ALL
SELECT 
    'rental_leases',
    lease_id,
    CONCAT('Tenant: ', tenant_name),
    'Lease end date precedes lease start date'
FROM rental_leases
WHERE lease_end_date < lease_start_date
UNION ALL
SELECT 
    'rental_payments',
    payment_id,
    CONCAT('Lease ID: ', lease_id),
    'Payment date recorded more than 365 days prior to due date (Invalid)'
FROM rental_payments
WHERE payment_date IS NOT NULL 
  AND payment_date < DATE_SUB(due_date, INTERVAL 365 DAY);

-- ============================================================================
-- TASK 13: LISTING PRICE VERSUS SALE PRICE
-- ============================================================================
SELECT 
    st.transaction_id,
    p.property_id,
    p.address,
    loc.city,
    pl.listing_price AS original_listing_price,
    st.sale_price AS actual_sale_price,
    ROUND(st.sale_price - pl.listing_price, 2) AS price_difference,
    ROUND(((st.sale_price - pl.listing_price) / pl.listing_price) * 100, 2) AS percentage_difference,
    CASE 
        WHEN st.sale_price > pl.listing_price THEN 'Sold Above Asking'
        WHEN st.sale_price < pl.listing_price THEN 'Sold Below Asking'
        ELSE 'Sold At Asking'
    END AS sale_performance
FROM sales_transactions st
INNER JOIN property_listings pl ON st.listing_id = pl.listing_id
INNER JOIN properties p ON st.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id
WHERE pl.listing_price IS NOT NULL 
  AND pl.listing_price > 0
  AND st.sale_price IS NOT NULL
ORDER BY percentage_difference DESC;

-- ============================================================================
-- TASK 14: RENTAL PAYMENT GAPS & OVERDUE RECOVERY
-- ============================================================================
WITH payment_records AS (
    SELECT 
        rp.payment_id,
        rl.lease_id,
        p.property_id,
        p.address,
        rl.tenant_name,
        rp.due_date,
        rp.payment_date,
        rp.rent_amount_due,
        rp.rent_amount_paid,
        (rp.rent_amount_due - rp.rent_amount_paid) AS outstanding_balance,
        rp.payment_status,
        DATEDIFF(rp.payment_date, rp.due_date) AS days_late
    FROM rental_payments rp
    INNER JOIN rental_leases rl ON rp.lease_id = rl.lease_id
    INNER JOIN properties p ON rl.property_id = p.property_id
),
chronic_offenders AS (
    SELECT 
        property_id,
        COUNT(*) AS gap_count
    FROM payment_records
    WHERE payment_status IN ('Unpaid', 'Partial') OR outstanding_balance > 0
    GROUP BY property_id
    HAVING COUNT(*) >= 2
)
SELECT 
    pr.property_id,
    pr.address,
    pr.tenant_name,
    pr.due_date,
    pr.payment_date,
    pr.rent_amount_due,
    pr.rent_amount_paid,
    pr.outstanding_balance,
    pr.payment_status,
    CASE 
        WHEN pr.payment_status = 'Unpaid' THEN 'Missed Payment (Total Default)'
        WHEN pr.payment_status = 'Partial' THEN 'Partial Payment (Underpaid)'
        WHEN pr.days_late > 0 THEN CONCAT('Paid ', pr.days_late, ' Days Late')
        ELSE 'On Time'
    END AS gap_classification,
    CASE 
        WHEN co.property_id IS NOT NULL THEN 'CHRONIC PAYMENT GAP RISK'
        ELSE 'Isolated Incident'
    END AS risk_profile
FROM payment_records pr
LEFT JOIN chronic_offenders co ON pr.property_id = co.property_id
WHERE pr.payment_status IN ('Unpaid', 'Partial', 'Late') OR pr.outstanding_balance > 0
ORDER BY pr.property_id, pr.due_date;

-- ============================================================================
-- TASK 15: LOCATION-LEVEL MARKET PERFORMANCE REPORT
-- Master analytical CTE query consolidating properties, sales velocity,
-- median prices, rental collections, occupancy, and yields.
-- ============================================================================
WITH loc_properties AS (
    SELECT 
        location_id,
        COUNT(property_id) AS total_properties,
        SUM(CASE WHEN current_status = 'Available' THEN 1 ELSE 0 END) AS available_inventory
    FROM properties
    GROUP BY location_id
),
loc_active_listings AS (
    SELECT 
        p.location_id,
        COUNT(pl.listing_id) AS total_active_listings
    FROM property_listings pl
    INNER JOIN properties p ON pl.property_id = p.property_id
    WHERE pl.listing_status = 'Active'
    GROUP BY p.location_id
),
loc_sales_ranked AS (
    SELECT 
        p.location_id,
        st.sale_price,
        p.area_sqft,
        DATEDIFF(st.sale_date, pl.listing_date) AS dom,
        ROW_NUMBER() OVER (
            PARTITION BY p.location_id 
            ORDER BY st.sale_price ASC, st.transaction_id ASC
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY p.location_id
        ) AS cnt
    FROM sales_transactions st
    INNER JOIN properties p ON st.property_id = p.property_id
    LEFT JOIN property_listings pl ON st.listing_id = pl.listing_id
    WHERE st.sale_price > 0 
      AND (pl.listing_date IS NULL OR st.sale_date >= pl.listing_date)
),
loc_sales_metrics AS (
    SELECT 
        location_id,
        COUNT(*) AS completed_sales,
        ROUND(AVG(sale_price), 2) AS avg_sale_price,
        ROUND(AVG(sale_price / NULLIF(area_sqft, 0)), 2) AS avg_price_per_sqft,
        ROUND(AVG(dom), 1) AS avg_days_on_market
    FROM loc_sales_ranked
    GROUP BY location_id
),
loc_medians AS (
    SELECT 
        location_id,
        ROUND(AVG(sale_price), 2) AS median_sale_price
    FROM loc_sales_ranked
    WHERE rn IN (FLOOR((cnt + 1) / 2.0), CEIL((cnt + 1) / 2.0))
    GROUP BY location_id
),
loc_rental_metrics AS (
    SELECT 
        p.location_id,
        SUM(rp.rent_amount_paid) AS total_rental_income
    FROM rental_payments rp
    INNER JOIN rental_leases rl ON rp.lease_id = rl.lease_id
    INNER JOIN properties p ON rl.property_id = p.property_id
    GROUP BY p.location_id
),
loc_occupancy AS (
    SELECT 
        p.location_id,
        ROUND(AVG(
            LEAST(100.0, (DATEDIFF(LEAST(rl.lease_end_date, '2023-12-31'), GREATEST(rl.lease_start_date, '2023-01-01')) + 1) / 3.65)
        ), 2) AS avg_occupancy_rate_pct
    FROM rental_leases rl
    INNER JOIN properties p ON rl.property_id = p.property_id
    WHERE rl.lease_start_date <= '2023-12-31' 
      AND rl.lease_end_date >= '2023-01-01'
      AND rl.lease_end_date >= rl.lease_start_date
    GROUP BY p.location_id
),
loc_yield AS (
    SELECT 
        p.location_id,
        ROUND(AVG((rl.monthly_rent * 12.0 / NULLIF(p.purchase_price, 0)) * 100), 2) AS avg_gross_rental_yield_pct
    FROM rental_leases rl
    INNER JOIN properties p ON rl.property_id = p.property_id
    WHERE p.purchase_price > 0
    GROUP BY p.location_id
)
SELECT 
    loc.city,
    loc.location_name,
    loc.region_type,
    COALESCE(lp.total_properties, 0) AS total_properties,
    COALESCE(lal.total_active_listings, 0) AS total_active_listings,
    COALESCE(lsm.completed_sales, 0) AS completed_sales,
    COALESCE(lsm.avg_sale_price, 0.00) AS avg_sale_price,
    COALESCE(lm.median_sale_price, 0.00) AS median_sale_price,
    COALESCE(lsm.avg_price_per_sqft, 0.00) AS avg_price_per_sqft,
    COALESCE(lsm.avg_days_on_market, 0) AS avg_days_on_market,
    COALESCE(lrm.total_rental_income, 0.00) AS total_rental_income,
    COALESCE(lo.avg_occupancy_rate_pct, 0.00) AS avg_occupancy_rate_pct,
    COALESCE(ly.avg_gross_rental_yield_pct, 0.00) AS avg_gross_rental_yield_pct
FROM locations loc
LEFT JOIN loc_properties lp ON loc.location_id = lp.location_id
LEFT JOIN loc_active_listings lal ON loc.location_id = lal.location_id
LEFT JOIN loc_sales_metrics lsm ON loc.location_id = lsm.location_id
LEFT JOIN loc_medians lm ON loc.location_id = lm.location_id
LEFT JOIN loc_rental_metrics lrm ON loc.location_id = lrm.location_id
LEFT JOIN loc_occupancy lo ON loc.location_id = lo.location_id
LEFT JOIN loc_yield ly ON loc.location_id = ly.location_id
ORDER BY total_properties DESC, completed_sales DESC;
