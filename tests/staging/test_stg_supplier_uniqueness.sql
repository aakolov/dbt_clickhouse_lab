SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT S_SUPPKEY) AS unique_keys
FROM {{ ref('stg_supplier') }}
HAVING COUNT(*) != COUNT(DISTINCT S_SUPPKEY)
