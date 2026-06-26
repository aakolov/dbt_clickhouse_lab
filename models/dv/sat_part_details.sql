{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(P_PARTKEY::TEXT) AS PART_HK,
    P_NAME,
    P_MFGR,
    P_BRAND,
    P_TYPE,
    P_SIZE,
    P_CONTAINER,
    P_RETAILPRICE,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        P_NAME || '-' || 
        P_MFGR || '-' || 
        P_BRAND || '-' || 
        P_TYPE || '-' || 
        P_SIZE || '-' || 
        P_CONTAINER || '-' || 
        P_RETAILPRICE::TEXT
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'part') }}
