-- Test: dv_satellite_hashdiff
-- Description: Проверка расчета hashdiff в satellite'ах
-- Проверяет, что hashdiff рассчитан корректно на основе атрибутов

-- Проверка sat_customer_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != MD5(CONCAT_WS('|', C_NAME, C_ADDRESS, C_PHONE, C_ACCTBAL, C_MKTSEGMENT, C_COMMENT, LOAD_DATE::TEXT)) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_customer_details')

-- Проверка sat_order_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != MD5(CONCAT_WS('|', O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE, O_ORDERPRIORITY, O_CLERK, O_SHIPPRIORITY, O_COMMENT, LOAD_DATE::TEXT)) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_order_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_order_details')

-- Проверка sat_lineitem_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != MD5(CONCAT_WS('|', CAST(L_QUANTITY AS VARCHAR), CAST(L_EXTENDEDPRICE AS VARCHAR), CAST(L_DISCOUNT AS VARCHAR), CAST(L_TAX AS VARCHAR), L_RETURNFLAG, L_LINESTATUS, L_SHIPDATE, L_COMMITDATE, L_RECEIPTDATE, L_SHIPINSTRUCT, L_SHIPMODE, L_COMMENT, LOAD_DATE::TEXT)) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_lineitem_details')

-- Проверка sat_part_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != MD5(CONCAT_WS('|', P_NAME, P_MFGR, P_BRAND, P_TYPE, P_SIZE, P_CONTAINER, P_RETAILPRICE, P_COMMENT, LOAD_DATE::TEXT)) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_part_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_part_details')

-- Проверка sat_supplier_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != MD5(CONCAT_WS('|', S_NAME, S_ADDRESS, S_PHONE, S_ACCTBAL, S_COMMENT, LOAD_DATE::TEXT)) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_supplier_details')
