-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- PHASE 2: RELATIONAL SCHEMA SETUP
-- Target Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- ----------------------------------------------------------------------------
-- Table 1: Locations
-- Normalized geography table to analyze regional markets
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    region_type ENUM('Downtown', 'Suburban', 'Waterfront', 'Metropolitan', 'Uptown') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 2: Properties
-- Master inventory of real estate assets with purchase cost & physical specs
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS properties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT NULL,
    property_type ENUM('Apartment', 'Villa', 'Independent House', 'Commercial') NOT NULL,
    address VARCHAR(255) NOT NULL,
    bedrooms INT NULL,
    bathrooms DECIMAL(3,1) NULL,
    area_sqft DECIMAL(10,2) NULL,        -- Allows zero/negatives/null for data quality testing
    year_built INT NULL,
    purchase_price DECIMAL(14,2) NULL,   -- Acquisition price (basis for yield)
    purchase_date DATE NULL,
    current_status ENUM('Available', 'Rented', 'Sold', 'Under Maintenance') NOT NULL DEFAULT 'Available',
    CONSTRAINT fk_properties_location 
        FOREIGN KEY (location_id) REFERENCES locations(location_id) 
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 3: Property Listings
-- Historical and active market listings (asking prices, dates, statuses)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS property_listings (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NULL,
    listing_price DECIMAL(14,2) NULL,    -- Allows test anomalies
    listing_date DATE NOT NULL,
    listing_status ENUM('Active', 'Sold', 'Unsold', 'Expired', 'Withdrawn') NOT NULL DEFAULT 'Active',
    agent_name VARCHAR(100) NOT NULL,
    expiry_date DATE NULL,
    CONSTRAINT fk_listings_property 
        FOREIGN KEY (property_id) REFERENCES properties(property_id) 
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 4: Sales Transactions
-- Closed sale events (actual realized price, sale date, buyer)
-- Intentionally allows NULL property_id to test orphaned transaction handling (Task 11)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sales_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NULL,
    property_id INT NULL,                -- May contain missing/orphaned IDs for Task 11 test
    sale_price DECIMAL(14,2) NULL,
    sale_date DATE NOT NULL,
    buyer_name VARCHAR(100) NOT NULL,
    payment_mode ENUM('Cash', 'Mortgage', 'Bank Transfer', 'Seller Financing') NOT NULL,
    commission_amount DECIMAL(10,2) NULL,
    CONSTRAINT fk_sales_listing 
        FOREIGN KEY (listing_id) REFERENCES property_listings(listing_id) 
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 5: Rental Leases
-- Lease agreements with contractual start/end dates and agreed monthly rents
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rental_leases (
    lease_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    tenant_name VARCHAR(100) NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2) NULL,
    lease_status ENUM('Active', 'Expired', 'Terminated') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_leases_property 
        FOREIGN KEY (property_id) REFERENCES properties(property_id) 
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table 6: Rental Payments
-- Detailed ledger of monthly rent obligations, actual payments, and payment status
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rental_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    lease_id INT NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE NULL,              -- NULL indicates unpaid/missed rent
    rent_amount_due DECIMAL(10,2) NOT NULL,
    rent_amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('Paid', 'Late', 'Partial', 'Unpaid') NOT NULL,
    payment_method ENUM('Online Transfer', 'Cheque', 'Credit Card', 'Cash', 'None') NOT NULL DEFAULT 'None',
    CONSTRAINT fk_payments_lease 
        FOREIGN KEY (lease_id) REFERENCES rental_leases(lease_id) 
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;
SHOW FULL TABLES IN real_estate_analysis;
SELECT 'locations' AS table_name, COUNT(*) AS total_rows FROM locations
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