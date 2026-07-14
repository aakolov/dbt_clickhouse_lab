SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT C_CUSTKEY) AS unique_keys
FROM {{ ref('stg_customer') }}
HAVING COUNT(*) != COUNT(DISTINCT C_CUSTKEY)
