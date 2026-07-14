-- Test: hashdiff_validity
-- Description: Проверка корректности расчета HASHDIFF в satellite'ах
-- Проверяет, что HASHDIFF рассчитан корректно на основе всех атрибутов

-- Проверка sat_customer_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != md5(
        toString(C_CUSTKEY) ||
        C_NAME ||
        C_ADDRESS ||
        toString(C_NATIONKEY) ||
        C_PHONE ||
        toString(C_ACCTBAL) ||
        C_MKTSEGMENT ||
        C_COMMENT
    ) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_customer_details')

-- Проверка sat_order_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != md5(
        toString(O_ORDERKEY) ||
        toString(O_CUSTKEY) ||
        O_ORDERSTATUS ||
        toString(O_TOTALPRICE) ||
        toString(O_ORDERDATE) ||
        O_ORDERPRIORITY ||
        O_CLERK ||
        toString(O_SHIPPRIORITY) ||
        O_COMMENT
    ) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_order_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_order_details')

-- Проверка sat_lineitem_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != md5(
        toString(L_ORDERKEY) ||
        toString(L_LINENUMBER) ||
        toString(L_PARTKEY) ||
        toString(L_SUPPKEY) ||
        toString(L_QUANTITY) ||
        toString(L_EXTENDEDPRICE) ||
        toString(L_DISCOUNT) ||
        toString(L_TAX) ||
        L_RETURNFLAG ||
        L_LINESTATUS ||
        toString(L_SHIPDATE) ||
        toString(L_COMMITDATE) ||
        toString(L_RECEIPTDATE) ||
        L_SHIPINSTRUCT ||
        L_SHIPMODE ||
        L_COMMENT
    ) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_lineitem_details')

-- Проверка sat_part_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != md5(
        toString(P_PARTKEY) ||
        P_NAME ||
        P_MFGR ||
        P_BRAND ||
        P_TYPE ||
        toString(P_SIZE) ||
        P_CONTAINER ||
        toString(P_RETAILPRICE) ||
        P_COMMENT
    ) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_part_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_part_details')

-- Проверка sat_supplier_details: HASHDIFF должен быть MD5 от всех атрибутов
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN HASHDIFF != md5(
        toString(S_SUPPKEY) ||
        S_NAME ||
        S_ADDRESS ||
        toString(S_NATIONKEY) ||
        S_PHONE ||
        toString(S_ACCTBAL) ||
        S_COMMENT
    ) THEN 1 ELSE 0 END) AS incorrect_hashdiff_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(incorrect_hashdiff_count = 0, 'Found incorrect HASHDIFF calculations in sat_supplier_details')
