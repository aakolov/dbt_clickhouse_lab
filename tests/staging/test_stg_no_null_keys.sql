SELECT
    'stg_customer' AS table_name,
    COUNT(*) AS null_count
FROM {{ ref('stg_customer') }}
WHERE C_CUSTKEY IS NULL
UNION ALL
SELECT
    'stg_orders' AS table_name,
    COUNT(*) AS null_count
FROM {{ ref('stg_orders') }}
WHERE O_ORDERKEY IS NULL
UNION ALL
SELECT
    'stg_lineitem' AS table_name,
    COUNT(*) AS null_count
FROM {{ ref('stg_lineitem') }}
WHERE L_ORDERKEY IS NULL
UNION ALL
SELECT
    'stg_part' AS table_name,
    COUNT(*) AS null_count
FROM {{ ref('stg_part') }}
WHERE P_PARTKEY IS NULL
UNION ALL
SELECT
    'stg_supplier' AS table_name,
    COUNT(*) AS null_count
FROM {{ ref('stg_supplier') }}
WHERE S_SUPPKEY IS NULL
HAVING SUM(null_count) > 0
