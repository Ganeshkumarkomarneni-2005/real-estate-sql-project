-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 06_phase6_executive_market_report.sql
-- PURPOSE: Final Location-Level Market Performance Report (Executive Dashboard)
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

SELECT 
    loc.city AS `City`,
    loc.location_name AS `Sub-Market`,
    loc.region_type AS `Zone`,
    COALESCE(lp.total_properties, 0) AS `Total Inventory`,
    COALESCE(lal.total_active_listings, 0) AS `Active MLS Listings`,
    COALESCE(lsm.completed_sales, 0) AS `Completed Sales`,
    CONCAT('$', FORMAT(COALESCE(lsm.avg_sale_price, 0), 2)) AS `Avg Sale Price`,
    CONCAT('$', FORMAT(COALESCE(lm.median_sale_price, 0), 2)) AS `Median Sale Price`,
    CONCAT('$', FORMAT(COALESCE(lsm.avg_price_per_sqft, 0), 2)) AS `Avg Price / SqFt`,
    CONCAT(COALESCE(lsm.avg_days_on_market, 0), ' days') AS `Sales Velocity (DOM)`,
    CONCAT('$', FORMAT(COALESCE(lrm.total_rental_income, 0), 2)) AS `Collected Rent`,
    CONCAT(COALESCE(lo.avg_occupancy_rate_pct, 0), '%') AS `Occupancy Rate`,
    CONCAT(COALESCE(ly.avg_gross_rental_yield_pct, 0), '%') AS `Gross Rental Yield`,
    CASE 
        WHEN ly.avg_gross_rental_yield_pct >= 7.0 THEN 'High Yield / Cashflow Core'
        WHEN ly.avg_gross_rental_yield_pct >= 5.5 THEN 'Balanced Growth Hub'
        WHEN lsm.avg_sale_price > 1500000 THEN 'Ultra-Luxury Capital Appreciation'
        WHEN lsm.completed_sales > 0 AND ly.avg_gross_rental_yield_pct IS NULL THEN 'Pure Sales / Acquisition Market'
        ELSE 'Emerging / Transitional'
    END AS `Strategic Investment Profile`
FROM locations loc
LEFT JOIN (
    SELECT location_id, COUNT(property_id) AS total_properties
    FROM properties
    GROUP BY location_id
) lp ON loc.location_id = lp.location_id
LEFT JOIN (
    SELECT p.location_id, COUNT(pl.listing_id) AS total_active_listings
    FROM property_listings pl
    INNER JOIN properties p ON pl.property_id = p.property_id
    WHERE pl.listing_status = 'Active'
    GROUP BY p.location_id
) lal ON loc.location_id = lal.location_id
LEFT JOIN (
    SELECT 
        p.location_id, 
        COUNT(*) AS completed_sales,
        AVG(st.sale_price) AS avg_sale_price,
        AVG(st.sale_price / NULLIF(p.area_sqft, 0)) AS avg_price_per_sqft,
        ROUND(AVG(DATEDIFF(st.sale_date, pl.listing_date)), 1) AS avg_days_on_market
    FROM sales_transactions st
    INNER JOIN properties p ON st.property_id = p.property_id
    LEFT JOIN property_listings pl ON st.listing_id = pl.listing_id
    WHERE st.sale_price > 0 
      AND (pl.listing_date IS NULL OR st.sale_date >= pl.listing_date)
    GROUP BY p.location_id
) lsm ON loc.location_id = lsm.location_id
LEFT JOIN (
    WITH ranked AS (
        SELECT 
            p.location_id, 
            st.sale_price,
            ROW_NUMBER() OVER(PARTITION BY p.location_id ORDER BY st.sale_price ASC, st.transaction_id ASC) AS rn,
            COUNT(*) OVER(PARTITION BY p.location_id) AS cnt
        FROM sales_transactions st
        INNER JOIN properties p ON st.property_id = p.property_id
        WHERE st.sale_price > 0
    )
    SELECT location_id, ROUND(AVG(sale_price), 2) AS median_sale_price
    FROM ranked
    WHERE rn IN (FLOOR((cnt + 1) / 2.0), CEIL((cnt + 1) / 2.0))
    GROUP BY location_id
) lm ON loc.location_id = lm.location_id
LEFT JOIN (
    SELECT p.location_id, SUM(rp.rent_amount_paid) AS total_rental_income
    FROM rental_payments rp
    INNER JOIN rental_leases rl ON rp.lease_id = rl.lease_id
    INNER JOIN properties p ON rl.property_id = p.property_id
    GROUP BY p.location_id
) lrm ON loc.location_id = lrm.location_id
LEFT JOIN (
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
) lo ON loc.location_id = lo.location_id
LEFT JOIN (
    SELECT 
        p.location_id,
        ROUND(AVG((rl.monthly_rent * 12.0 / NULLIF(p.purchase_price, 0)) * 100), 2) AS avg_gross_rental_yield_pct
    FROM rental_leases rl
    INNER JOIN properties p ON rl.property_id = p.property_id
    WHERE p.purchase_price > 0
    GROUP BY p.location_id
) ly ON loc.location_id = ly.location_id
ORDER BY loc.city, `Sub-Market`;
