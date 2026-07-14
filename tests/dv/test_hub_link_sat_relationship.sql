-- Test: hub_link_sat_relationship
-- Description: Проверка связей между hub, link и satellite
-- Проверяет, что satellite корректно связаны с hub и link

-- Проверка sat_customer_details: все записи должны иметь соответствующий hub_customer
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN CUSTOMER_HK NOT IN (SELECT CUSTOMER_HK FROM {{ ref('hub_customer') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_customer_details without parent in hub_customer')

-- Проверка sat_order_details: все записи должны иметь соответствующий hub_order
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('hub_order') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_order_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_order_details without parent in hub_order')

-- Проверка sat_part_details: все записи должны иметь соответствующий hub_part
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN PART_HK NOT IN (SELECT PART_HK FROM {{ ref('hub_part') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_part_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_part_details without parent in hub_part')

-- Проверка sat_supplier_details: все записи должны иметь соответствующий hub_supplier
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN SUPPLIER_HK NOT IN (SELECT SUPPLIER_HK FROM {{ ref('hub_supplier') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_supplier_details without parent in hub_supplier')

-- Проверка link_order_customer: все записи должны иметь соответствующий hub_customer и hub_order
SELECT
    'link_order_customer' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN CUSTOMER_HK NOT IN (SELECT CUSTOMER_HK FROM {{ ref('hub_customer') }}) THEN 1 ELSE 0 END) AS orphan_customer_count,
    SUM(CASE WHEN ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('hub_order') }}) THEN 1 ELSE 0 END) AS orphan_order_count
FROM {{ ref('link_order_customer') }}
HAVING assert(orphan_customer_count = 0, 'Found orphan records in link_order_customer without customer in hub_customer')
   OR assert(orphan_order_count = 0, 'Found orphan records in link_order_customer without order in hub_order')
