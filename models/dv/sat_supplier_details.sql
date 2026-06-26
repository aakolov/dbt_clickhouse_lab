{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(S_SUPPKEY::TEXT) AS SUPPLIER_HK,
    S_NAME,
    S_ADDRESS,
    S_NATIONKEY,
    S_PHONE,
    S_ACCTBAL,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        S_NAME || '-' || 
        S_ADDRESS || '-' || 
        S_PHONE || '-' || 
        S_ACCTBAL::TEXT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'supplier') }}
