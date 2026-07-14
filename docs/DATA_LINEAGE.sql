-- Data Lineage Queries

-- ============================================
-- LINEAGE VERIFICATION QUERIES
-- ============================================
-- These queries help verify data lineage from source to target
-- Run these periodically to ensure data integrity

-- 1. Verify Orders Lineage
-- ============================================
-- This query verifies the complete lineage for a specific order
-- from source to Data Mart through all layers.

SELECT 
    'Source Layer' AS layer,
    O_ORDERKEY,
    NULL AS ORDER_HK,
    NULL AS LOAD_DATE
FROM dbgen.orders
WHERE O_ORDERKEY = 100000

UNION ALL

SELECT 
    'Staging Layer' AS layer,
    O_ORDERKEY,
    NULL AS ORDER_HK,
    NULL AS LOAD_DATE
FROM stg_orders
WHERE O_ORDERKEY = 100000

UNION ALL

SELECT 
    'Data Vault Hub' AS layer,
    O_ORDERKEY,
    ORDER_HK,
    LOAD_DATE
FROM hub_order
WHERE O_ORDERKEY = 100000

UNION ALL

SELECT 
    'Data Vault Link' AS layer,
    o.O_ORDERKEY,
    l.ORDER_HK,
    l.LOAD_DATE
FROM link_order_customer l
JOIN hub_order o ON l.ORDER_HK = o.ORDER_HK
WHERE o.O_ORDERKEY = 100000

UNION ALL

SELECT 
    'Data Vault Satellite' AS layer,
    o.O_ORDERKEY,
    s.ORDER_HK,
    s.LOAD_DATE
FROM sat_order_details s
JOIN hub_order o ON s.ORDER_HK = o.ORDER_HK
WHERE o.O_ORDERKEY = 100000

UNION ALL

SELECT 
    'Data Mart' AS layer,
    o.O_ORDERKEY,
    NULL AS ORDER_HK,
    NULL AS LOAD_DATE
FROM f_orders_stats_dv s
JOIN hub_order o ON s.O_ORDERYEAR = toYear(o.O_ORDERDATE)
WHERE o.O_ORDERKEY = 100000

ORDER BY 
    CASE layer
        WHEN 'Source Layer' THEN 1
        WHEN 'Staging Layer' THEN 2
        WHEN 'Data Vault Hub' THEN 3
        WHEN 'Data Vault Link' THEN 4
        WHEN 'Data Vault Satellite' THEN 5
        WHEN 'Data Mart' THEN 6
    END;

-- 2. Verify Line Items Lineage
-- ============================================

SELECT 
    'Source Layer' AS layer,
    L_ORDERKEY,
    L_LINENUMBER,
    NULL AS ORDER_LINEITEM_HK,
    NULL AS LOAD_DATE
FROM dbgen.lineitem
WHERE L_ORDERKEY = 100000 AND L_LINENUMBER = 1

UNION ALL

SELECT 
    'Staging Layer' AS layer,
    L_ORDERKEY,
    L_LINENUMBER,
    NULL AS ORDER_LINEITEM_HK,
    NULL AS LOAD_DATE
FROM stg_lineitem
WHERE L_ORDERKEY = 100000 AND L_LINENUMBER = 1

UNION ALL

SELECT 
    'Data Vault Link' AS layer,
    l.L_ORDERKEY,
    l.L_LINENUMBER,
    ll.ORDER_LINEITEM_HK,
    ll.LOAD_DATE
FROM link_order_lineitem ll
JOIN stg_lineitem l ON 
    md5(toString(l.L_ORDERKEY) || '_' || toString(l.L_LINENUMBER)) = ll.ORDER_LINEITEM_HK
WHERE l.L_ORDERKEY = 100000 AND l.L_LINENUMBER = 1

UNION ALL

SELECT 
    'Data Vault Satellite' AS layer,
    l.L_ORDERKEY,
    l.L_LINENUMBER,
    sl.ORDER_LINEITEM_HK,
    sl.LOAD_DATE
FROM sat_lineitem_details sl
JOIN link_order_lineitem ll ON sl.ORDER_LINEITEM_HK = ll.ORDER_LINEITEM_HK
JOIN stg_lineitem l ON ll.ORDER_LINEITEM_HK = md5(toString(l.L_ORDERKEY) || '_' || toString(l.L_LINENUMBER))
WHERE l.L_ORDERKEY = 100000 AND l.L_LINENUMBER = 1

UNION ALL

SELECT 
    'Data Mart' AS layer,
    l.L_ORDERKEY,
    l.L_LINENUMBER,
    NULL AS ORDER_LINEITEM_HK,
    NULL AS LOAD_DATE
FROM f_lineorder_flat_dv s
JOIN stg_lineitem l ON s.L_ORDERKEY = l.L_ORDERKEY
WHERE l.L_ORDERKEY = 100000 AND l.L_LINENUMBER = 1

ORDER BY 
    CASE layer
        WHEN 'Source Layer' THEN 1
        WHEN 'Staging Layer' THEN 2
        WHEN 'Data Vault Link' THEN 3
        WHEN 'Data Vault Satellite' THEN 4
        WHEN 'Data Mart' THEN 5
    END;

-- 3. Check Data Lineage Completeness
-- ============================================

-- Orders: Source to Data Vault
SELECT 
    'Orders' AS table_name,
    COUNT(*) AS source_count,
    COUNT(h.ORDER_HK) AS dv_count,
    COUNT(*) - COUNT(h.ORDER_HK) AS missing_count
FROM dbgen.orders s
LEFT JOIN hub_order h ON md5(toString(s.O_ORDERKEY)) = h.ORDER_HK;

-- Line Items: Source to Data Vault
SELECT 
    'Line Items' AS table_name,
    COUNT(*) AS source_count,
    COUNT(l.ORDER_LINEITEM_HK) AS dv_count,
    COUNT(*) - COUNT(l.ORDER_LINEITEM_HK) AS missing_count
FROM dbgen.lineitem s
LEFT JOIN link_order_lineitem l ON 
    md5(toString(s.L_ORDERKEY) || '_' || toString(s.L_LINENUMBER)) = l.ORDER_LINEITEM_HK;

-- Customers: Source to Data Vault
SELECT 
    'Customers' AS table_name,
    COUNT(*) AS source_count,
    COUNT(c.CUSTOMER_HK) AS dv_count,
    COUNT(*) - COUNT(c.CUSTOMER_HK) AS missing_count
FROM dbgen.customer s
LEFT JOIN hub_customer c ON md5(toString(s.C_CUSTKEY)) = c.CUSTOMER_HK;

-- 4. Verify Semantic Layer Mapping
-- ============================================

-- Check semantic model source data
SELECT 
    'orders_analysis' AS semantic_model,
    COUNT(*) AS record_count,
    MIN(O_ORDERDATE) AS min_date,
    MAX(O_ORDERDATE) AS max_date
FROM sat_order_details

UNION ALL

SELECT 
    'lineitem_details' AS semantic_model,
    COUNT(*) AS record_count,
    MIN(L_SHIPDATE) AS min_date,
    MAX(L_SHIPDATE) AS max_date
FROM mv_lineitem_enriched

UNION ALL

SELECT 
    'customer_history' AS semantic_model,
    COUNT(*) AS record_count,
    MIN(LOAD_DATE) AS min_date,
    MAX(LOAD_DATE) AS max_date
FROM sat_customer_details;

-- 5. Check Data Mart Aggregations
-- ============================================

-- Verify Data Mart contains expected aggregations
SELECT 
    'f_orders_stats_dv' AS mart_table,
    COUNT(*) AS record_count,
    SUM(num_orders) AS total_orders,
    SUM(revenue) AS total_revenue
FROM f_orders_stats_dv;

-- Check data freshness
SELECT 
    MAX(O_ORDERDATE) AS last_order_date,
    MAX(LOAD_DATE) AS last_load_date
FROM sat_order_details;

-- ============================================
-- END OF LINEAGE QUERIES
-- ============================================
