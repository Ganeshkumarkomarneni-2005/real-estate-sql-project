-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- PHASE 1: DATABASE & EXISTING SCHEMA INSPECTION SCRIPT
-- ============================================================================

-- Step 1.1: Ensure we are targeting the project database
USE real_estate_analysis;

-- Step 1.2: Check current database context and MySQL version
SELECT 
    DATABASE() AS current_database,
    VERSION() AS mysql_version;

-- Step 1.3: List all existing tables and views in 'realestate'
SHOW FULL TABLES;

-- Step 1.4: Detailed table overview (engine, row count estimate, collation)
SELECT 
    table_name,
    table_rows,
    data_length,
    create_time,
    table_collation
FROM information_schema.tables
WHERE table_schema = 'realestate'
ORDER BY table_name;

-- Step 1.5: Detailed column inspection (names, data types, nullability, keys, defaults)
SELECT 
    table_name,
    ordinal_position,
    column_name,
    data_type,
    column_type,
    is_nullable,
    column_key,
    column_default,
    extra
FROM information_schema.columns
WHERE table_schema = 'realestate'
ORDER BY table_name, ordinal_position;

-- Step 1.6: Check existing primary keys, unique keys, and foreign key constraints
SELECT 
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'realestate'
ORDER BY table_name, constraint_type;

SELECT 
    table_name,
    column_name,
    constraint_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'realestate'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name;