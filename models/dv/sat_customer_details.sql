{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(C_CUSTKEY::TEXT) AS CUSTOMER_HK,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        C_NAME || '-' || 
        C_ADDRESS || '-' || 
        C_PHONE || '-' || 
        C_ACCTBAL || '-' || 
        C_MKTSEGMENT || '-' || 
        C_COMMENT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'customer') }}
