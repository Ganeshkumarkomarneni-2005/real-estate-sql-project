-- ============================================================================
-- PROJECT 14: REAL ESTATE PROPERTY PRICING, SALES & RENTAL YIELD ANALYSIS
-- FILE: 01_phase1_inspection.sql
-- PURPOSE: Database & Schema Inspection
-- Database: real_estate_analysis (MySQL 8.0+)
-- ============================================================================

USE real_estate_analysis;

-- 1. Check current database and MySQL engine version
SELECT 
    DATABASE() AS current_database,
    VERSION() AS mysql_version;

-- 2. List all existing tables and views
SHOW FULL TABLES;

-- 3. Detailed table overview (engine, row count estimate, collation)
SELECT 
    table_name,
    table_rows,
    data_length,
    create_time,
    table_collation
FROM information_schema.tables
WHERE table_schema = 'real_estate_analysis'
ORDER BY table_name;

-- 4. Column inspection across tables
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
WHERE table_schema = 'real_estate_analysis'
ORDER BY table_name, ordinal_position;

-- 5. Foreign keys and constraints inspection
SELECT 
    table_name,
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'real_estate_analysis'
ORDER BY table_name, constraint_type;

SELECT 
    table_name,
    column_name,
    constraint_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'real_estate_analysis'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name;
