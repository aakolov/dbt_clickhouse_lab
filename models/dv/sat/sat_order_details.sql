{{
    config(
        engine='MergeTree()',
        order_by=['ORDER_HK', 'EFFECTIVE_FROM'],
        partition_by='toYear(O_ORDERDATE)'
    )
}}

SELECT DISTINCT
    md5(toString(O_ORDERKEY)) AS ORDER_HK,
    toDateTime('1970-01-01 00:00:00') AS LOAD_DATE,
    O_ORDERKEY,
    O_CUSTKEY,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT,
    O_ORDERDATE AS EFFECTIVE_FROM,
    toDateTime('9999-12-31 23:59:59') AS EFFECTIVE_TO,
    1 AS IS_CURRENT,
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
