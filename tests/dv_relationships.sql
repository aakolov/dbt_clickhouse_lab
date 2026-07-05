-- Test: dv_relationships
-- Description: Проверка связей между satellite'ами и их родительскими hub'ами/link'ами
-- Проверяет, что все satellite'ы корректно связаны со своими parent_hk

-- Проверка sat_customer_details: все записи должны ссылаться на существующие клиенты в hub_customer
SELECT
    'sat_customer_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN CUSTOMER_HK NOT IN (SELECT CUSTOMER_HK FROM {{ ref('hub_customer') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_customer_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_customer_details without parent in hub_customer')

-- Проверка sat_order_details: все записи должны ссылаться на существующие заказы в hub_order
SELECT
    'sat_order_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('hub_order') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_order_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_order_details without parent in hub_order')

-- Проверка sat_lineitem_details: все записи должны ссылаться на существующие записи в link_order_lineitem
SELECT
    'sat_lineitem_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN ORDER_HK NOT IN (SELECT ORDER_HK FROM {{ ref('link_order_lineitem') }}) THEN 1 ELSE 0 END) AS orphan_order_count,
    SUM(CASE WHEN PART_HK NOT IN (SELECT PART_HK FROM {{ ref('link_order_lineitem') }}) THEN 1 ELSE 0 END) AS orphan_part_count,
    SUM(CASE WHEN SUPPLIER_HK NOT IN (SELECT SUPPLIER_HK FROM {{ ref('link_order_lineitem') }}) THEN 1 ELSE 0 END) AS orphan_supplier_count
FROM {{ ref('sat_lineitem_details') }}
HAVING assert(orphan_order_count = 0, 'Found orphan records in sat_lineitem_details without order in link_order_lineitem')
   OR assert(orphan_part_count = 0, 'Found orphan records in sat_lineitem_details without part in link_order_lineitem')
   OR assert(orphan_supplier_count = 0, 'Found orphan records in sat_lineitem_details without supplier in link_order_lineitem')

-- Проверка sat_part_details: все записи должны ссылаться на существующие детали в hub_part
SELECT
    'sat_part_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN PART_HK NOT IN (SELECT PART_HK FROM {{ ref('hub_part') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_part_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_part_details without parent in hub_part')

-- Проверка sat_supplier_details: все записи должны ссылаться на существующих поставщиков в hub_supplier
SELECT
    'sat_supplier_details' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN SUPPLIER_HK NOT IN (SELECT SUPPLIER_HK FROM {{ ref('hub_supplier') }}) THEN 1 ELSE 0 END) AS orphan_count
FROM {{ ref('sat_supplier_details') }}
HAVING assert(orphan_count = 0, 'Found orphan records in sat_supplier_details without parent in hub_supplier')