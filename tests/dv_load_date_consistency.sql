-- Test: dv_load_date_consistency
-- Description: Проверка последовательности дат загрузки в satellite'ах
-- Проверяет, что LOAD_DATE в satellite'ах не уменьшается со временем для одной и той же записи

-- Проверка sat_customer_details: LOAD_DATE должен увеличиваться или оставаться равным для одного CUSTOMER_HK
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN LOAD_DATE < LAG(LOAD_DATE) OVER (PARTITION BY CUSTOMER_HK ORDER BY LOAD_DATE) THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid LOAD_DATE sequence in sat_customer_details')

-- Проверка sat_order_details: LOAD_DATE должен увеличиваться или оставаться равным для одного ORDER_HK
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN LOAD_DATE < LAG(LOAD_DATE) OVER (PARTITION BY ORDER_HK ORDER BY LOAD_DATE) THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_order_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid LOAD_DATE sequence in sat_order_details')

-- Проверка sat_lineitem_details: LOAD_DATE должен увеличиваться или оставаться равным для одной комбинации ORDER_HK, PART_HK, SUPPLIER_HK
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN LOAD_DATE < LAG(LOAD_DATE) OVER (PARTITION BY ORDER_HK, PART_HK, SUPPLIER_HK ORDER BY LOAD_DATE) THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid LOAD_DATE sequence in sat_lineitem_details')

-- Проверка sat_part_details: LOAD_DATE должен увеличиваться или оставаться равным для одного PART_HK
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN LOAD_DATE < LAG(LOAD_DATE) OVER (PARTITION BY PART_HK ORDER BY LOAD_DATE) THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_part_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid LOAD_DATE sequence in sat_part_details')

-- Проверка sat_supplier_details: LOAD_DATE должен увеличиваться или оставаться равным для одного SUPPLIER_HK
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN LOAD_DATE < LAG(LOAD_DATE) OVER (PARTITION BY SUPPLIER_HK ORDER BY LOAD_DATE) THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid LOAD_DATE sequence in sat_supplier_details')