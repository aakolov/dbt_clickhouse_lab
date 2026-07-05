-- Test: dv_link_integrity
-- Description: Проверка целостности связей между hub'ами и link'ами
-- Проверяет, что все ссылки в link'ах существуют в соответствующих hub'ах

-- Проверка link_order_customer: все HK должны существовать в hub_customer и hub_order
SELECT
    'link_order_customer' AS test_table,
    COUNT(*) AS missing_count
FROM {{ ref('link_order_customer') }} lo
LEFT JOIN {{ ref('hub_customer') }} hc ON lo.CUSTOMER_HK = hc.CUSTOMER_HK
LEFT JOIN {{ ref('hub_order') }} ho ON lo.ORDER_HK = ho.ORDER_HK
WHERE hc.CUSTOMER_HK IS NULL OR ho.ORDER_HK IS NULL
HAVING assert(NOT IN (1), 'Found links with missing hub references in link_order_customer')

-- Проверка link_order_lineitem: все HK должны существовать в hub_order, hub_part, hub_supplier
SELECT
    'link_order_lineitem' AS test_table,
    COUNT(*) AS missing_count
FROM {{ ref('link_order_lineitem') }} ll
LEFT JOIN {{ ref('hub_order') }} ho ON ll.ORDER_HK = ho.ORDER_HK
LEFT JOIN {{ ref('hub_part') }} hp ON ll.PART_HK = hp.PART_HK
LEFT JOIN {{ ref('hub_supplier') }} hs ON ll.SUPPLIER_HK = hs.SUPPLIER_HK
WHERE ho.ORDER_HK IS NULL OR hp.PART_HK IS NULL OR hs.SUPPLIER_HK IS NULL
HAVING assert(NOT IN (1), 'Found links with missing hub references in link_order_lineitem')
