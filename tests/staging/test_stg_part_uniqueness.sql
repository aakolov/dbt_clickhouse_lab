SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT P_PARTKEY) AS unique_keys
FROM {{ ref('stg_part') }}
HAVING COUNT(*) != COUNT(DISTINCT P_PARTKEY)
