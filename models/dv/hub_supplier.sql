{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'SUPPLIER_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(S_SUPPKEY::TEXT) AS SUPPLIER_HK,
    S_SUPPKEY AS SUPPLIER_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'supplier') }}
