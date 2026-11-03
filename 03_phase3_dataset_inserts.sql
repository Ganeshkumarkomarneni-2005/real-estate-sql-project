-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 03_phase3_dataset_inserts.sql
-- PURPOSE: Realistic Dataset Generation (Clean + Deliberate Anomalies)
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- 1. Insert Locations
INSERT INTO locations (location_id, location_name, city, state, postal_code, region_type, country) VALUES
(1, 'Downtown Core', 'Austin', 'TX', '78701', 'Downtown', 'United States'),
(2, 'Westlake Hills', 'Austin', 'TX', '78746', 'Suburban', 'United States'),
(3, 'Uptown Arts District', 'Dallas', 'TX', '75201', 'Uptown', 'United States'),
(4, 'Plano Tech Corridor', 'Dallas', 'TX', '75024', 'Suburban', 'United States'),
(5, 'Houston Riverfront', 'Houston', 'TX', '77002', 'Waterfront', 'United States'),
(6, 'The Woodlands', 'Houston', 'TX', '77380', 'Suburban', 'United States'),
(7, 'Pearl District', 'San Antonio', 'TX', '78215', 'Downtown', 'United States')
AS new_loc ON DUPLICATE KEY UPDATE location_name = new_loc.location_name;

-- 2. Insert Properties (30 records: Clean + Deliberate Quality Traps)
INSERT INTO properties (property_id, location_id, property_type, address, bedrooms, bathrooms, area_sqft, year_built, purchase_price, purchase_date, current_status) VALUES
-- Downtown Austin (Clean)
(1, 1, 'Apartment', '300 Colorado St #1204', 2, 2.0, 1150.00, 2018, 480000.00, '2021-02-15', 'Sold'),
(2, 1, 'Apartment', '405 Colorado St #2201', 1, 1.5, 820.00, 2020, 395000.00, '2021-08-10', 'Rented'),
(3, 1, 'Commercial', '100 Congress Ave Ste 400', NULL, 4.0, 4200.00, 2015, 2100000.00, '2019-05-12', 'Rented'),
-- Westlake Hills (Clean Luxury)
(4, 2, 'Villa', '1402 Westlake Dr', 5, 5.5, 5400.00, 2017, 2850000.00, '2020-01-20', 'Sold'),
(5, 2, 'Independent House', '89 Buckeye Trail', 4, 3.5, 3600.00, 2014, 1650000.00, '2020-06-18', 'Rented'),
(6, 2, 'Villa', '320 Las Lomas Dr', 4, 4.0, 4800.00, 2019, 2400000.00, '2021-11-05', 'Available'),
-- Dallas Uptown (Clean)
(7, 3, 'Apartment', '2300 McKinney Ave #8B', 2, 2.0, 1280.00, 2016, 520000.00, '2020-03-14', 'Sold'),
(8, 3, 'Apartment', '2800 Maple Ave #15A', 3, 2.5, 1750.00, 2019, 690000.00, '2021-07-22', 'Rented'),
(9, 3, 'Commercial', '2501 Cedar Springs Rd', NULL, 3.0, 3100.00, 2012, 1450000.00, '2019-10-30', 'Available'),
-- Plano Tech Corridor (Clean)
(10, 4, 'Independent House', '6401 Tennyson Pkwy', 4, 3.0, 2900.00, 2011, 720000.00, '2020-09-15', 'Sold'),
(11, 4, 'Independent House', '7200 Preston Rd', 3, 2.0, 2100.00, 2015, NULL, NULL, 'Rented'),
(12, 4, 'Apartment', '5800 Granite Pkwy #304', 2, 2.0, 1050.00, 2021, 410000.00, '2022-01-14', 'Rented'),
-- Houston Riverfront (Clean)
(13, 5, 'Apartment', '1100 Louisiana St #902', 1, 1.0, 780.00, 2017, 285000.00, '2021-04-18', 'Sold'),
(14, 5, 'Commercial', '800 Franklin St Ground Floor', NULL, 2.0, 2600.00, 2008, NULL, NULL, 'Rented'),
(15, 5, 'Apartment', '910 Travis St #1405', 2, 2.0, 1220.00, 2018, 430000.00, '2021-10-10', 'Available'),
-- The Woodlands (Clean)
(16, 6, 'Independent House', '24 Carlton Woods Dr', 5, 4.5, 4600.00, 2016, 1550000.00, '2019-12-04', 'Sold'),
(17, 6, 'Villa', '108 Grand Regency Cir', 6, 6.0, 6200.00, 2020, 3200000.00, '2021-03-25', 'Rented'),
(18, 6, 'Independent House', '45 Trace Creek Dr', 3, 2.5, 2400.00, 2013, 560000.00, '2020-07-19', 'Rented'),
-- Pearl District, San Antonio (Clean)
(19, 7, 'Apartment', '303 Pearl Pkwy #401', 2, 2.0, 1100.00, 2018, 380000.00, '2021-05-30', 'Sold'),
(20, 7, 'Independent House', '210 River Ave', 3, 2.0, 2200.00, 2010, 490000.00, '2020-04-12', 'Sold'),
-- Problematic & Edge-Case Properties for Data Quality Validation
(21, 1, 'Apartment', '101 Bad Area Ln #1', 2, 1.0, -950.00, 2020, 350000.00, '2022-02-01', 'Available'),
(22, 3, 'Apartment', '202 Zero Area Way #2', 1, 1.0, 0.00, 2021, 290000.00, '2022-03-01', 'Available'),
(23, 2, 'Villa', '303 Crazy Giant Estate', 10, 8.0, 999999.00, 2021, 5000000.00, '2022-04-01', 'Available'),
(24, 4, 'Independent House', '404 Negative Price Ct', 3, 2.0, 1900.00, 2015, -450000.00, '2021-06-01', 'Available'),
(25, 5, 'Apartment', '505 Null Area St #5', 2, 2.0, NULL, 2019, 410000.00, '2022-05-01', 'Available'),
(26, 7, 'Apartment', '606 Long Unsold St #6', 1, 1.0, 750.00, 2016, 270000.00, '2020-01-10', 'Available'),
(27, 2, 'Independent House', '707 Stale Villa Blvd', 4, 3.5, 3400.00, 2014, 1200000.00, '2020-03-15', 'Available'),
(28, 1, 'Apartment', '808 Inverted Date Ave #1', 2, 2.0, 1100.00, 2019, 450000.00, '2021-01-10', 'Sold'),
(29, 3, 'Apartment', '909 Duplicate Blvd #9A', 2, 2.0, 1250.00, 2018, 480000.00, '2021-02-01', 'Available'),
(30, 4, 'Commercial', '1010 Missing Prop Ref Office', NULL, 2.0, 2200.00, 2017, 950000.00, '2021-04-01', 'Sold')
AS new_prop ON DUPLICATE KEY UPDATE address = new_prop.address;

-- 3. Insert Property Listings (30 records)
INSERT INTO property_listings (listing_id, property_id, listing_price, listing_date, listing_status, agent_name, expiry_date) VALUES
(1, 1, 510000.00, '2022-01-10', 'Sold', 'Sarah Jenkins', '2022-04-10'),
(2, 2, 415000.00, '2022-02-01', 'Withdrawn', 'Sarah Jenkins', '2022-05-01'),
(3, 4, 3100000.00, '2022-01-15', 'Sold', 'Michael Chang', '2022-07-15'),
(4, 6, 2550000.00, '2023-01-10', 'Active', 'Michael Chang', '2023-07-10'),
(5, 7, 545000.00, '2022-03-01', 'Sold', 'David Miller', '2022-06-01'),
(6, 9, 1550000.00, '2023-02-01', 'Active', 'David Miller', '2023-08-01'),
(7, 10, 760000.00, '2022-02-15', 'Sold', 'Jessica Taylor', '2022-05-15'),
(8, 13, 299000.00, '2022-04-05', 'Sold', 'Robert Rodriguez', '2022-07-05'),
(9, 15, 450000.00, '2023-03-01', 'Active', 'Robert Rodriguez', '2023-09-01'),
(10, 16, 1680000.00, '2022-01-20', 'Sold', 'Emily Watson', '2022-05-20'),
(11, 19, 395000.00, '2022-05-10', 'Sold', 'Carlos Gomez', '2022-08-10'),
(12, 20, 520000.00, '2022-06-01', 'Sold', 'Carlos Gomez', '2022-09-01'),
(13, 6, 2600000.00, '2022-06-15', 'Expired', 'Michael Chang', '2022-09-15'),
(14, 26, 285000.00, '2022-10-01', 'Active', 'Carlos Gomez', '2023-04-01'),
(15, 27, 1290000.00, '2022-11-15', 'Active', 'Michael Chang', '2023-05-15'),
(16, 29, 495000.00, '2023-01-15', 'Active', 'David Miller', '2023-04-15'),
(17, 29, 495000.00, '2023-01-15', 'Active', 'David Miller', '2023-04-15'),
(18, 29, 490000.00, '2023-01-16', 'Active', 'David Miller', '2023-04-16'),
(19, 21, 360000.00, '2023-02-10', 'Active', 'Sarah Jenkins', '2023-05-10'),
(20, 22, 300000.00, '2023-02-15', 'Active', 'David Miller', '2023-05-15'),
(21, 23, 5200000.00, '2023-03-01', 'Active', 'Michael Chang', '2023-09-01'),
(22, 24, -460000.00, '2023-03-05', 'Active', 'Jessica Taylor', '2023-06-05'),
(23, 25, 425000.00, '2023-03-10', 'Active', 'Robert Rodriguez', '2023-06-10'),
(24, 1, 530000.00, '2021-09-01', 'Expired', 'Sarah Jenkins', '2021-12-01'),
(25, 10, 780000.00, '2021-08-01', 'Withdrawn', 'Jessica Taylor', '2021-11-01'),
(26, 16, 1750000.00, '2021-07-01', 'Expired', 'Emily Watson', '2021-10-01'),
(27, 20, 535000.00, '2021-10-15', 'Expired', 'Carlos Gomez', '2022-01-15'),
(28, 28, 470000.00, '2022-08-15', 'Sold', 'Sarah Jenkins', '2022-11-15'),
(29, 30, 990000.00, '2022-05-01', 'Sold', 'Jessica Taylor', '2022-08-01'),
(30, 2, 420000.00, '2023-04-01', 'Active', 'Sarah Jenkins', '2023-10-01')
AS new_list ON DUPLICATE KEY UPDATE listing_price = new_list.listing_price;

-- 4. Insert Sales Transactions (16 records)
INSERT INTO sales_transactions (transaction_id, listing_id, property_id, sale_price, sale_date, buyer_name, payment_mode, commission_amount) VALUES
(1, 1, 1, 495000.00, '2022-03-12', 'Alice Robertson', 'Mortgage', 24750.00),
(2, 3, 4, 3050000.00, '2022-04-18', 'Arthur Pendelton', 'Cash', 152500.00),
(3, 5, 7, 535000.00, '2022-05-05', 'Brandon Flores', 'Mortgage', 26750.00),
(4, 7, 10, 750000.00, '2022-04-20', 'Claire Redfield', 'Mortgage', 37500.00),
(5, 8, 13, 290000.00, '2022-06-14', 'Derek Vance', 'Bank Transfer', 14500.00),
(6, 10, 16, 1640000.00, '2022-04-02', 'Eleanor Vance', 'Cash', 82000.00),
(7, 11, 19, 390000.00, '2022-07-15', 'Frank Castle', 'Mortgage', 19500.00),
(8, 12, 20, 510000.00, '2022-08-25', 'Grace Hopper', 'Seller Financing', 25500.00),
(9, NULL, 1, 480000.00, '2021-02-15', 'Historic Austin Buyer', 'Mortgage', 24000.00),
(10, NULL, 4, 2850000.00, '2020-01-20', 'Historic Westlake Buyer', 'Cash', 142500.00),
(11, NULL, 7, 520000.00, '2020-03-14', 'Historic Dallas Buyer', 'Mortgage', 26000.00),
(12, NULL, 10, 720000.00, '2020-09-15', 'Historic Plano Buyer', 'Mortgage', 36000.00),
(13, NULL, 16, 1550000.00, '2019-12-04', 'Historic Woodlands Buyer', 'Cash', 77500.00),
(14, NULL, 19, 380000.00, '2021-05-30', 'Historic SA Buyer', 'Mortgage', 19000.00),
(15, 28, 28, 465000.00, '2022-06-01', 'Time Traveler Buyer', 'Cash', 23250.00),
(16, 29, NULL, 975000.00, '2022-07-20', 'Ghost Property LLC', 'Cash', 48750.00)
AS new_st ON DUPLICATE KEY UPDATE sale_price = new_st.sale_price;

-- 5. Insert Rental Leases (18 records)
INSERT INTO rental_leases (lease_id, property_id, tenant_name, lease_start_date, lease_end_date, monthly_rent, security_deposit, lease_status) VALUES
(1, 2, 'Sophia Bennett', '2022-01-01', '2022-12-31', 2400.00, 2400.00, 'Expired'),
(2, 2, 'Marcus Thorne', '2023-01-01', '2023-12-31', 2550.00, 2550.00, 'Active'),
(3, 3, 'Apex Tech Solutions', '2022-01-01', '2023-12-31', 12500.00, 25000.00, 'Active'),
(4, 5, 'Dr. Gregory House', '2022-03-01', '2023-02-28', 7500.00, 15000.00, 'Expired'),
(5, 5, 'Harrison Sterling', '2023-03-01', '2024-02-28', 8000.00, 16000.00, 'Active'),
(6, 8, 'Olivia Wilde', '2022-06-01', '2023-05-31', 3800.00, 3800.00, 'Expired'),
(7, 8, 'Nathan Drake', '2023-06-01', '2024-05-31', 4000.00, 4000.00, 'Active'),
(8, 11, 'Peter Parker', '2022-01-01', '2022-12-31', 3200.00, 3200.00, 'Expired'),
(9, 11, 'Gwen Stacy', '2023-01-01', '2023-12-31', 3400.00, 3400.00, 'Active'),
(10, 12, 'Bruce Wayne', '2022-04-01', '2023-03-31', 2200.00, 2200.00, 'Expired'),
(11, 12, 'Selina Kyle', '2023-04-01', '2024-03-31', 2350.00, 2350.00, 'Active'),
(12, 14, 'Bayou Logistics Inc', '2022-01-01', '2023-12-31', 8500.00, 17000.00, 'Active'),
(13, 17, 'Viktor Vance', '2022-01-01', '2022-12-31', 14000.00, 28000.00, 'Expired'),
(14, 17, 'Monroe Family', '2023-01-01', '2023-12-31', 15000.00, 30000.00, 'Active'),
(15, 18, 'Rachel Green', '2022-02-01', '2023-01-31', 3100.00, 3100.00, 'Expired'),
(16, 18, 'Ross Geller', '2023-02-01', '2024-01-31', 3300.00, 3300.00, 'Active'),
(17, 5, 'Short Stay Tenant', '2021-08-01', '2021-11-30', 7000.00, 7000.00, 'Terminated'),
(18, 2, 'Invalid Dates Tenant', '2024-01-01', '2023-01-01', 2500.00, 2500.00, 'Terminated')
AS new_rl ON DUPLICATE KEY UPDATE monthly_rent = new_rl.monthly_rent;

-- 6. Insert Monthly Rental Payments (48 records)
INSERT INTO rental_payments (payment_id, lease_id, due_date, payment_date, rent_amount_due, rent_amount_paid, payment_status, payment_method) VALUES
(1, 2, '2023-01-01', '2023-01-02', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(2, 2, '2023-02-01', '2023-02-01', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(3, 2, '2023-03-01', '2023-03-03', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(4, 2, '2023-04-01', '2023-04-02', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(5, 2, '2023-05-01', '2023-05-01', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(6, 2, '2023-06-01', '2023-06-02', 2550.00, 2550.00, 'Paid', 'Online Transfer'),
(7, 3, '2023-01-01', '2023-01-05', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(8, 3, '2023-02-01', '2023-02-04', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(9, 3, '2023-03-01', '2023-03-05', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(10, 3, '2023-04-01', '2023-04-03', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(11, 3, '2023-05-01', '2023-05-05', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(12, 3, '2023-06-01', '2023-06-04', 12500.00, 12500.00, 'Paid', 'Online Transfer'),
(13, 5, '2023-03-01', '2023-03-01', 8000.00, 8000.00, 'Paid', 'Online Transfer'),
(14, 5, '2023-04-01', '2023-04-02', 8000.00, 8000.00, 'Paid', 'Online Transfer'),
(15, 5, '2023-05-01', '2023-05-01', 8000.00, 8000.00, 'Paid', 'Online Transfer'),
(16, 5, '2023-06-01', '2023-06-03', 8000.00, 8000.00, 'Paid', 'Online Transfer'),
(17, 7, '2023-06-01', '2023-06-02', 4000.00, 4000.00, 'Paid', 'Credit Card'),
(18, 7, '2023-07-01', '2023-07-16', 4000.00, 4000.00, 'Late', 'Credit Card'),
(19, 7, '2023-08-01', '2023-08-02', 4000.00, 4000.00, 'Paid', 'Credit Card'),
(20, 9, '2023-01-01', '2023-01-03', 3400.00, 3400.00, 'Paid', 'Cheque'),
(21, 9, '2023-02-01', '2023-02-05', 3400.00, 2000.00, 'Partial', 'Cheque'),
(22, 9, '2023-03-01', '2023-03-22', 3400.00, 3400.00, 'Late', 'Cheque'),
(23, 9, '2023-04-01', NULL,         3400.00, 0.00,    'Unpaid', 'None'),
(24, 9, '2023-05-01', '2023-05-18', 3400.00, 3400.00, 'Late', 'Cheque'),
(25, 9, '2023-06-01', NULL,         3400.00, 0.00,    'Unpaid', 'None'),
(26, 11, '2023-04-01', '2023-04-01', 2350.00, 2350.00, 'Paid', 'Online Transfer'),
(27, 11, '2023-05-01', '2023-05-02', 2350.00, 2350.00, 'Paid', 'Online Transfer'),
(28, 11, '2023-06-01', '2023-06-01', 2350.00, 2350.00, 'Paid', 'Online Transfer'),
(29, 12, '2023-01-01', '2023-01-08', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(30, 12, '2023-02-01', '2023-02-06', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(31, 12, '2023-03-01', '2023-03-07', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(32, 12, '2023-04-01', '2023-04-05', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(33, 12, '2023-05-01', '2023-05-08', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(34, 12, '2023-06-01', '2023-06-06', 8500.00, 8500.00, 'Paid', 'Online Transfer'),
(35, 14, '2023-01-01', '2023-01-03', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(36, 14, '2023-02-01', '2023-02-02', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(37, 14, '2023-03-01', '2023-03-04', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(38, 14, '2023-04-01', '2023-04-02', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(39, 14, '2023-05-01', '2023-05-03', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(40, 14, '2023-06-01', '2023-06-02', 15000.00, 15000.00, 'Paid', 'Online Transfer'),
(41, 16, '2023-02-01', '2023-02-01', 3300.00, 3300.00, 'Paid', 'Cheque'),
(42, 16, '2023-03-01', '2023-03-05', 3300.00, 3300.00, 'Paid', 'Cheque'),
(43, 16, '2023-04-01', '2023-04-20', 3300.00, 1800.00, 'Partial', 'Cheque'),
(44, 16, '2023-05-01', NULL,         3300.00, 0.00,    'Unpaid', 'None'),
(45, 16, '2023-06-01', '2023-06-25', 3300.00, 3300.00, 'Late', 'Cheque'),
(46, 1,  '2022-01-01', '2022-01-03', 2400.00, 2400.00, 'Paid', 'Online Transfer'),
(47, 4,  '2022-03-01', '2022-03-02', 7500.00, 7500.00, 'Paid', 'Online Transfer'),
(48, 13, '2022-01-01', '2022-01-04', 14000.00, 14000.00, 'Paid', 'Online Transfer')
AS new_rp ON DUPLICATE KEY UPDATE rent_amount_paid = new_rp.rent_amount_paid;
