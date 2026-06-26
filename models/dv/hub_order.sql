{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'ORDER_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    O_ORDERKEY AS ORDER_ID,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
