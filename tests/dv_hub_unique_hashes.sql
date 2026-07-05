-- Проверка уникальности хеш-ключей в hub'ах
-- Проверяет, что каждый хеш-ключ встречается только один раз в каждом hub'е

-- Hub Customer
SELECT
    'hub_customer' AS table_name,
    CUSTOMER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_customer') }}
GROUP BY CUSTOMER_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Order
SELECT
    'hub_order' AS table_name,
    ORDER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_order') }}
GROUP BY ORDER_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Part
SELECT
    'hub_part' AS table_name,
    PART_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_part') }}
GROUP BY PART_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Supplier
SELECT
    'hub_supplier' AS table_name,
    SUPPLIER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_supplier') }}
GROUP BY SUPPLIER_HK
HAVING COUNT(*) > 1
