-- Test: dv_business_key_mapping
-- Description: Проверка соответствия бизнес-ключей между hub'ами и источниками
-- Проверяет, что бизнес-ключи в hub'ах корректно сопоставлены с источниками

-- Проверка hub_customer: BUSINESS_KEY должен совпадать с C_CUSTKEY из источника
SELECT
    'hub_customer' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hc.BUSINESS_KEY != CAST(s_c.C_CUSTKEY AS String) THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_customer') }} hc
INNER JOIN {{ source('dbgen', 'customer') }} s_c ON hc.BUSINESS_KEY = CAST(s_c.C_CUSTKEY AS String)
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_customer')

-- Проверка hub_order: BUSINESS_KEY должен совпадать с O_ORDERKEY из источника
SELECT
    'hub_order' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN ho.BUSINESS_KEY != CAST(s_o.O_ORDERKEY AS String) THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_order') }} ho
INNER JOIN {{ source('dbgen', 'orders') }} s_o ON ho.BUSINESS_KEY = CAST(s_o.O_ORDERKEY AS String)
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_order')

-- Проверка hub_part: BUSINESS_KEY должен совпадать с P_PARTKEY из источника
SELECT
    'hub_part' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hp.BUSINESS_KEY != CAST(s_p.P_PARTKEY AS String) THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_part') }} hp
INNER JOIN {{ source('dbgen', 'part') }} s_p ON hp.BUSINESS_KEY = CAST(s_p.P_PARTKEY AS String)
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_part')

-- Проверка hub_supplier: BUSINESS_KEY должен совпадать с S_SUPPKEY из источника
SELECT
    'hub_supplier' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hs.BUSINESS_KEY != CAST(s_s.S_SUPPKEY AS String) THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_supplier') }} hs
INNER JOIN {{ source('dbgen', 'supplier') }} s_s ON hs.BUSINESS_KEY = CAST(s_s.S_SUPPKEY AS String)
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_supplier')
