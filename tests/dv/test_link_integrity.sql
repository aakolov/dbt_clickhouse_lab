-- Test: link_integrity
-- Description: Проверка ссылочной целостности link'ов
-- Проверяет, что все ссылки в link'ах существуют в соответствующих hub'ах

-- Проверка link_order_customer: все HK должны существовать в hub_customer и hub_order
SELECT
    'link_order_customer' AS test_table,
    COUNT(*) AS missing_count
FROM {{ ref('link_order_customer') }} lo
LEFT JOIN {{ ref('hub_customer') }} hc ON lo.CUSTOMER_HK = hc.CUSTOMER_HK
LEFT JOIN {{ ref('hub_order') }} ho ON lo.ORDER_HK = ho.ORDER_HK
WHERE hc.CUSTOMER_HK IS NULL OR ho.ORDER_HK IS NULL
