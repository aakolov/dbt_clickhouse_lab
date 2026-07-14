SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT L_ITEMKEY) AS unique_keys
FROM {{ ref('stg_lineitem') }}
HAVING COUNT(*) != COUNT(DISTINCT L_ITEMKEY)
