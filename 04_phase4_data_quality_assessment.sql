-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 04_phase4_data_quality_assessment.sql
-- PURPOSE: Pre-Analysis Data Quality & Hygiene Assessment
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- 4.1: NULL Value Audit across operational columns
SELECT 
    'properties' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN property_type IS NULL THEN 1 ELSE 0 END) AS null_property_types,
    SUM(CASE WHEN location_id IS NULL THEN 1 ELSE 0 END) AS null_locations,
    SUM(CASE WHEN area_sqft IS NULL THEN 1 ELSE 0 END) AS null_areas,
    SUM(CASE WHEN purchase_price IS NULL THEN 1 ELSE 0 END) AS null_purchase_prices
FROM properties
UNION ALL
SELECT 
    'property_listings',
    COUNT(*),
    SUM(CASE WHEN property_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN listing_price IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN listing_date IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN listing_status IS NULL THEN 1 ELSE 0 END)
FROM property_listings
UNION ALL
SELECT 
    'sales_transactions',
    COUNT(*),
    SUM(CASE WHEN property_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN listing_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN sale_price IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END)
FROM sales_transactions
UNION ALL
SELECT 
    'rental_leases',
    COUNT(*),
    SUM(CASE WHEN property_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN monthly_rent IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN lease_start_date IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN lease_end_date IS NULL THEN 1 ELSE 0 END)
FROM rental_leases
UNION ALL
SELECT 
    'rental_payments',
    COUNT(*),
    SUM(CASE WHEN lease_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN rent_amount_due IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN rent_amount_paid IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN payment_date IS NULL THEN 1 ELSE 0 END)
FROM rental_payments;

-- 4.2: Numeric Sanity Audit (Area & Price Anomalies)
SELECT 
    p.property_id,
    p.address,
    p.property_type,
    p.area_sqft,
    p.purchase_price,
    CASE 
        WHEN p.area_sqft IS NULL THEN 'Area is NULL'
        WHEN p.area_sqft < 0 THEN 'Negative Area'
        WHEN p.area_sqft = 0 THEN 'Zero Area'
        WHEN p.area_sqft > 50000 THEN 'Extreme Area Outlier (> 50,000 sqft)'
        WHEN p.purchase_price <= 0 THEN 'Negative / Zero Purchase Price'
        ELSE 'Valid'
    END AS anomaly_description
FROM properties p
WHERE p.area_sqft IS NULL 
   OR p.area_sqft <= 0 
   OR p.area_sqft > 50000 
   OR p.purchase_price <= 0;

-- 4.3: Date Sequence & Chronology Audit
-- 4.3.1 Sales before listing date
SELECT 
    st.transaction_id,
    st.listing_id,
    st.property_id,
    pl.listing_date,
    st.sale_date,
    DATEDIFF(st.sale_date, pl.listing_date) AS date_difference_days,
    'LOGICAL ERROR: Sale date precedes listing date' AS audit_issue
FROM sales_transactions st
INNER JOIN property_listings pl ON st.listing_id = pl.listing_id
WHERE st.sale_date < pl.listing_date;

-- 4.3.2 Leases ending before start date
SELECT 
    lease_id,
    property_id,
    tenant_name,
    lease_start_date,
    lease_end_date,
    DATEDIFF(lease_end_date, lease_start_date) AS lease_duration_days,
    'LOGICAL ERROR: Lease end date precedes lease start date' AS audit_issue
FROM rental_leases
WHERE lease_end_date < lease_start_date;

-- 4.4: Relational Integrity & Orphaned Record Audit
SELECT 
    st.transaction_id,
    st.listing_id,
    st.property_id AS recorded_property_id,
    st.sale_price,
    st.sale_date,
    st.buyer_name,
    CASE 
        WHEN st.property_id IS NULL THEN 'Critical: property_id is NULL'
        WHEN p.property_id IS NULL THEN 'Critical: property_id does not exist in master properties'
        ELSE 'Valid Foreign Key'
    END AS fk_integrity_status
FROM sales_transactions st
LEFT JOIN properties p ON st.property_id = p.property_id
WHERE st.property_id IS NULL OR p.property_id IS NULL;

-- 4.5: Duplicate Listings Audit
SELECT 
    pl.property_id,
    p.address,
    pl.listing_price,
    pl.listing_date,
    COUNT(*) AS total_duplicate_entries,
    GROUP_CONCAT(pl.listing_id ORDER BY pl.listing_id SEPARATOR ', ') AS duplicate_listing_ids
FROM property_listings pl
INNER JOIN properties p ON pl.property_id = p.property_id
GROUP BY pl.property_id, p.address, pl.listing_price, pl.listing_date
HAVING COUNT(*) > 1;
