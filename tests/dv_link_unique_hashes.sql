-- Test: dv_link_unique_hashes
-- Description: Проверка уникальности хеш-ключей в link'ах
-- Проверяет, что каждый хеш-ключ в link'е встречается только один раз

-- Проверка link_order_customer: CUSTOMER_HK и ORDER_HK должны быть уникальны
SELECT
    'link_order_customer' AS test_table,
    COUNT(*) - COUNT(DISTINCT CUSTOMER_HK) AS duplicate_customer_hk,
    COUNT(*) - COUNT(DISTINCT ORDER_HK) AS duplicate_order_hk
FROM {{ ref('link_order_customer') }}
HAVING assert(CUSTOMER_HK = 0, 'Found duplicate CUSTOMER_HK in link_order_customer')
   OR assert(ORDER_HK = 0, 'Found duplicate ORDER_HK in link_order_customer')

-- Проверка link_order_lineitem: ORDER_HK, PART_HK, SUPPLIER_HK должны быть уникальны
SELECT
    'link_order_lineitem' AS test_table,
    COUNT(*) - COUNT(DISTINCT ORDER_HK) AS duplicate_order_hk,
    COUNT(*) - COUNT(DISTINCT PART_HK) AS duplicate_part_hk,
    COUNT(*) - COUNT(DISTINCT SUPPLIER_HK) AS duplicate_supplier_hk
FROM {{ ref('link_order_lineitem') }}
HAVING assert(ORDER_HK = 0, 'Found duplicate ORDER_HK in link_order_lineitem')
   OR assert(PART_HK = 0, 'Found duplicate PART_HK in link_order_lineitem')
   OR assert(SUPPLIER_HK = 0, 'Found duplicate SUPPLIER_HK in link_order_lineitem')
