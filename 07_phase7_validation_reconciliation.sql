-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 07_phase7_validation_reconciliation.sql
-- PURPOSE: Final Validation & Integrity Reconciliation
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- 7.1: Reconcile Total Sales Revenue & Transaction Counts
WITH direct_sales AS (
    SELECT 
        'Direct Sales Table' AS source_metric,
        COUNT(*) AS total_transactions,
        SUM(sale_price) AS total_revenue
    FROM sales_transactions
    WHERE sale_price > 0
),
aggregated_report_sales AS (
    SELECT 
        'Aggregated Location Report' AS source_metric,
        SUM(loc_sales.completed_sales) AS total_transactions,
        ROUND(SUM(loc_sales.completed_sales * loc_sales.avg_sale_price), 2) AS total_revenue
    FROM (
        SELECT 
            p.location_id, 
            COUNT(*) AS completed_sales, 
            AVG(st.sale_price) AS avg_sale_price
        FROM sales_transactions st
        INNER JOIN properties p ON st.property_id = p.property_id
        WHERE st.sale_price > 0
        GROUP BY p.location_id
    ) loc_sales
)
SELECT * FROM direct_sales
UNION ALL
SELECT * FROM aggregated_report_sales
UNION ALL
SELECT 
    'VARIANCE (Difference)',
    (SELECT total_transactions FROM direct_sales) - (SELECT total_transactions FROM aggregated_report_sales),
    (SELECT total_revenue FROM direct_sales) - (SELECT total_revenue FROM aggregated_report_sales);

-- 7.2: Reconcile Total Rental Cash Flow (Anti-Duplication Audit)
SELECT 
    'Direct Rental Payments Table' AS audit_source,
    SUM(rent_amount_paid) AS total_rent_collected
FROM rental_payments
UNION ALL
SELECT 
    'Joined Location Report Aggregation',
    SUM(rp.rent_amount_paid)
FROM rental_payments rp
INNER JOIN rental_leases rl ON rp.lease_id = rl.lease_id
INNER JOIN properties p ON rl.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id;

-- 7.3: Occupancy & Lease Integrity Audit
SELECT 
    p.property_id,
    p.address,
    loc.location_name,
    SUM(DATEDIFF(
        LEAST(rl.lease_end_date, '2023-12-31'), 
        GREATEST(rl.lease_start_date, '2023-01-01')
    ) + 1) AS total_occupied_days,
    ROUND((SUM(DATEDIFF(
        LEAST(rl.lease_end_date, '2023-12-31'), 
        GREATEST(rl.lease_start_date, '2023-01-01')
    ) + 1) / 365.0) * 100, 2) AS calculated_occupancy_pct,
    CASE 
        WHEN ROUND((SUM(DATEDIFF(LEAST(rl.lease_end_date, '2023-12-31'), GREATEST(rl.lease_start_date, '2023-01-01')) + 1) / 365.0) * 100, 2) > 100.00 
            THEN 'FAIL: Overlapping Leases Detected (> 100%)'
        ELSE 'PASS: Valid Occupancy Bound'
    END AS occupancy_audit_flag
FROM rental_leases rl
INNER JOIN properties p ON rl.property_id = p.property_id
INNER JOIN locations loc ON p.location_id = loc.location_id
WHERE rl.lease_start_date <= '2023-12-31' 
  AND rl.lease_end_date >= '2023-01-01'
  AND rl.lease_end_date >= rl.lease_start_date
GROUP BY p.property_id, p.address, loc.location_name;

-- 7.4: Final Record Count Reconciliation
SELECT 'locations' AS base_table, COUNT(*) AS confirmed_rows FROM locations
UNION ALL
SELECT 'properties', COUNT(*) FROM properties
UNION ALL
SELECT 'property_listings', COUNT(*) FROM property_listings
UNION ALL
SELECT 'sales_transactions', COUNT(*) FROM sales_transactions
UNION ALL
SELECT 'rental_leases', COUNT(*) FROM rental_leases
UNION ALL
SELECT 'rental_payments', COUNT(*) FROM rental_payments;
