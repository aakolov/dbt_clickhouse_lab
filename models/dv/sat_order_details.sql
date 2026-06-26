{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        O_ORDERSTATUS || '-' || 
        O_TOTALPRICE || '-' || 
        O_ORDERDATE || '-' || 
        O_ORDERPRIORITY || '-' || 
        O_CLERK || '-' || 
        O_SHIPPRIORITY
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'orders') }}
