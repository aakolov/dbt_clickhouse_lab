{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'ORDER_CUSTOMER_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(O_ORDERKEY::TEXT || '-' || O_CUSTKEY::TEXT) AS ORDER_CUSTOMER_HK,
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    MD5(O_CUSTKEY::TEXT) AS CUSTOMER_HK,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
