-- Test: sat_history_integrity
-- Description: Проверка целостности истории изменений в satellite'ах с SCD2
-- Проверяет, что EFFECTIVE_FROM и EFFECTIVE_TO корректно задают периоды действия записей

-- Проверка sat_customer_details: все записи должны иметь IS_CURRENT = 1 и корректные периоды
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN IS_CURRENT != 1 THEN 1 ELSE 0 END) AS non_current_count,
    SUM(CASE WHEN EFFECTIVE_TO != toDateTime('9999-12-31 23:59:59') THEN 1 ELSE 0 END) AS not_effective_to_max_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(non_current_count = 0, 'Found non-current records in sat_customer_details')
   OR assert(not_effective_to_max_count = 0, 'Found records with EFFECTIVE_TO != 9999-12-31 in sat_customer_details')

-- Проверка sat_order_details: все записи должны иметь IS_CURRENT = 1 и корректные периоды
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN IS_CURRENT != 1 THEN 1 ELSE 0 END) AS non_current_count,
    SUM(CASE WHEN EFFECTIVE_TO != toDateTime('9999-12-31 23:59:59') THEN 1 ELSE 0 END) AS not_effective_to_max_count
FROM {{ ref('sat_order_details') }}
HAVING assert(non_current_count = 0, 'Found non-current records in sat_order_details')
   OR assert(not_effective_to_max_count = 0, 'Found records with EFFECTIVE_TO != 9999-12-31 in sat_order_details')

-- Проверка sat_lineitem_details: все записи должны иметь IS_CURRENT = 1 и корректные периоды
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN IS_CURRENT != 1 THEN 1 ELSE 0 END) AS non_current_count,
    SUM(CASE WHEN EFFECTIVE_TO != toDateTime('9999-12-31 23:59:59') THEN 1 ELSE 0 END) AS not_effective_to_max_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(non_current_count = 0, 'Found non-current records in sat_lineitem_details')
   OR assert(not_effective_to_max_count = 0, 'Found records with EFFECTIVE_TO != 9999-12-31 in sat_lineitem_details')

-- Проверка sat_part_details: все записи должны иметь IS_CURRENT = 1 и корректные периоды
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN IS_CURRENT != 1 THEN 1 ELSE 0 END) AS non_current_count,
    SUM(CASE WHEN EFFECTIVE_TO != toDateTime('9999-12-31 23:59:59') THEN 1 ELSE 0 END) AS not_effective_to_max_count
FROM {{ ref('sat_part_details') }}
HAVING assert(non_current_count = 0, 'Found non-current records in sat_part_details')
   OR assert(not_effective_to_max_count = 0, 'Found records with EFFECTIVE_TO != 9999-12-31 in sat_part_details')

-- Проверка sat_supplier_details: все записи должны иметь IS_CURRENT = 1 и корректные периоды
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN IS_CURRENT != 1 THEN 1 ELSE 0 END) AS non_current_count,
    SUM(CASE WHEN EFFECTIVE_TO != toDateTime('9999-12-31 23:59:59') THEN 1 ELSE 0 END) AS not_effective_to_max_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(non_current_count = 0, 'Found non-current records in sat_supplier_details')
   OR assert(not_effective_to_max_count = 0, 'Found records with EFFECTIVE_TO != 9999-12-31 in sat_supplier_details')
