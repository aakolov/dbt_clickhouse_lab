-- Test: hash_key_uniqueness
-- Description: Проверка уникальности хеш-ключей в hub'ах и satellite'ах
-- Проверяет, что каждый хеш-ключ встречается только один раз в таблице

-- Hub Customer: CUSTOMER_HK должен быть уникален
SELECT
    'hub_customer' AS table_name,
    CUSTOMER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_customer') }}
GROUP BY CUSTOMER_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Order: ORDER_HK должен быть уникален
SELECT
    'hub_order' AS table_name,
    ORDER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_order') }}
GROUP BY ORDER_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Part: PART_HK должен быть уникален
SELECT
    'hub_part' AS table_name,
    PART_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_part') }}
GROUP BY PART_HK
HAVING COUNT(*) > 1

UNION ALL

-- Hub Supplier: SUPPLIER_HK должен быть уникален
SELECT
    'hub_supplier' AS table_name,
    SUPPLIER_HK,
    COUNT(*) AS cnt
FROM {{ ref('hub_supplier') }}
GROUP BY SUPPLIER_HK
HAVING COUNT(*) > 1

UNION ALL

-- Satellite Customer: CUSTOMER_HK + EFFECTIVE_FROM должен быть уникален для SCD2
SELECT
    'sat_customer_details' AS table_name,
    concat(toString(CUSTOMER_HK), '_', toString(EFFECTIVE_FROM)) AS composite_key,
    COUNT(*) AS cnt
FROM {{ ref('sat_customer_details') }}
GROUP BY CUSTOMER_HK, EFFECTIVE_FROM
HAVING COUNT(*) > 1

UNION ALL

-- Satellite Order: ORDER_HK + EFFECTIVE_FROM должен быть уникален для SCD2
SELECT
    'sat_order_details' AS table_name,
    concat(toString(ORDER_HK), '_', toString(EFFECTIVE_FROM)) AS composite_key,
    COUNT(*) AS cnt
FROM {{ ref('sat_order_details') }}
GROUP BY ORDER_HK, EFFECTIVE_FROM
HAVING COUNT(*) > 1

UNION ALL

-- Satellite Lineitem: ORDER_LINEITEM_HK + EFFECTIVE_FROM должен быть уникален для SCD2
SELECT
    'sat_lineitem_details' AS table_name,
    concat(toString(ORDER_LINEITEM_HK), '_', toString(EFFECTIVE_FROM)) AS composite_key,
    COUNT(*) AS cnt
FROM {{ ref('sat_lineitem_details') }}
GROUP BY ORDER_LINEITEM_HK, EFFECTIVE_FROM
HAVING COUNT(*) > 1

UNION ALL

-- Satellite Part: PART_HK + EFFECTIVE_FROM должен быть уникален для SCD2
SELECT
    'sat_part_details' AS table_name,
    concat(toString(PART_HK), '_', toString(EFFECTIVE_FROM)) AS composite_key,
    COUNT(*) AS cnt
FROM {{ ref('sat_part_details') }}
GROUP BY PART_HK, EFFECTIVE_FROM
HAVING COUNT(*) > 1

UNION ALL

-- Satellite Supplier: SUPPLIER_HK + EFFECTIVE_FROM должен быть уникален для SCD2
SELECT
    'sat_supplier_details' AS table_name,
    concat(toString(SUPPLIER_HK), '_', toString(EFFECTIVE_FROM)) AS composite_key,
    COUNT(*) AS cnt
FROM {{ ref('sat_supplier_details') }}
GROUP BY SUPPLIER_HK, EFFECTIVE_FROM
HAVING COUNT(*) > 1
