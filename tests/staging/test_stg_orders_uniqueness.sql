SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT O_ORDERKEY) AS unique_keys
FROM {{ ref('stg_orders') }}
HAVING COUNT(*) != COUNT(DISTINCT O_ORDERKEY)
