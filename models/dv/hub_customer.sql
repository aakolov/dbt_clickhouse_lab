{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'CUSTOMER_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(C_CUSTKEY::TEXT) AS CUSTOMER_HK,
    C_CUSTKEY AS CUSTOMER_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'customer') }}
