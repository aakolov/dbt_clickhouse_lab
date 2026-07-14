-- Test: business_keys
-- Description: Проверка корректности бизнес-ключей в hub'ах
-- Проверяет, что бизнес-ключи корректно маппятся на источники

-- Проверка hub_customer: C_CUSTKEY должен совпадать с источником
SELECT
    'hub_customer' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hc.C_CUSTKEY != s_c.C_CUSTKEY THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_customer') }} hc
INNER JOIN {{ source('dbgen', 'customer') }} s_c ON hc.C_CUSTKEY = s_c.C_CUSTKEY
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_customer')

-- Проверка hub_order: O_ORDERKEY должен совпадать с источником
SELECT
    'hub_order' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN ho.O_ORDERKEY != s_o.O_ORDERKEY THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_order') }} ho
INNER JOIN {{ source('dbgen', 'orders') }} s_o ON ho.O_ORDERKEY = s_o.O_ORDERKEY
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_order')

-- Проверка hub_part: P_PARTKEY должен совпадать с источником
SELECT
    'hub_part' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hp.P_PARTKEY != s_p.P_PARTKEY THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_part') }} hp
INNER JOIN {{ source('dbgen', 'part') }} s_p ON hp.P_PARTKEY = s_p.P_PARTKEY
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_part')

-- Проверка hub_supplier: S_SUPPKEY должен совпадать с источником
SELECT
    'hub_supplier' AS test_table,
    COUNT(*) AS total_count,
    SUM(CASE WHEN hs.S_SUPPKEY != s_s.S_SUPPKEY THEN 1 ELSE 0 END) AS mismatch_count
FROM {{ ref('hub_supplier') }} hs
INNER JOIN {{ source('dbgen', 'supplier') }} s_s ON hs.S_SUPPKEY = s_s.S_SUPPKEY
HAVING assert(mismatch_count = 0, 'Found business key mismatches in hub_supplier')
