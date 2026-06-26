{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'PART_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(P_PARTKEY::TEXT) AS PART_HK,
    P_PARTKEY AS PART_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'part') }}
