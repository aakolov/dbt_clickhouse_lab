-- Test: dv_load_date_consistency
-- Description: Проверка последовательности дат эффективности в satellite'ах с SCD2
-- Проверяет, что EFFECTIVE_FROM и EFFECTIVE_TO корректно отражают историю изменений

-- Проверка sat_customer_details: EFFECTIVE_TO должен быть больше EFFECTIVE_FROM или быть 9999-12-31 для текущих записей
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN EFFECTIVE_TO <= EFFECTIVE_FROM THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid EFFECTIVE_FROM/EFFECTIVE_TO sequence in sat_customer_details')

-- Проверка sat_order_details: EFFECTIVE_TO должен быть больше EFFECTIVE_FROM или быть 9999-12-31 для текущих записей
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN EFFECTIVE_TO <= EFFECTIVE_FROM THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_order_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid EFFECTIVE_FROM/EFFECTIVE_TO sequence in sat_order_details')

-- Проверка sat_lineitem_details: EFFECTIVE_TO должен быть больше EFFECTIVE_FROM или быть 9999-12-31 для текущих записей
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN EFFECTIVE_TO <= EFFECTIVE_FROM THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid EFFECTIVE_FROM/EFFECTIVE_TO sequence in sat_lineitem_details')

-- Проверка sat_part_details: EFFECTIVE_TO должен быть больше EFFECTIVE_FROM или быть 9999-12-31 для текущих записей
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN EFFECTIVE_TO <= EFFECTIVE_FROM THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_part_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid EFFECTIVE_FROM/EFFECTIVE_TO sequence in sat_part_details')

-- Проверка sat_supplier_details: EFFECTIVE_TO должен быть больше EFFECTIVE_FROM или быть 9999-12-31 для текущих записей
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN EFFECTIVE_TO <= EFFECTIVE_FROM THEN 1 ELSE 0 END) AS invalid_date_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(invalid_date_count = 0, 'Found invalid EFFECTIVE_FROM/EFFECTIVE_TO sequence in sat_supplier_details')