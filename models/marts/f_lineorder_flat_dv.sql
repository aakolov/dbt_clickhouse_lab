{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by=['O_ORDERKEY', 'O_CUSTKEY'],
        partition_by='toYear(O_ORDERDATE)'
    )
}}

SELECT
    md5(toString(O_ORDERKEY)) AS ORDER_HK,
    now() AS LOAD_DATE,
    O_ORDERKEY,
    O_CUSTKEY,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT,
    md5(
        toString(O_ORDERKEY) ||
        toString(O_CUSTKEY) ||
        O_ORDERSTATUS ||
        toString(O_TOTALPRICE) ||
        toString(O_ORDERDATE) ||
        O_ORDERPRIORITY ||
        O_CLERK ||
        toString(O_SHIPPRIORITY) ||
        O_COMMENT
    ) AS HASHDIFF
FROM {{ source('dbgen', 'orders') }}