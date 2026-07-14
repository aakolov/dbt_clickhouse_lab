{{
    config(
        engine='MergeTree()',
        order_by=['ORDER_LINEITEM_HK', 'LOAD_DATE'],
        partition_by='toYear(L_SHIPDATE)'
    )
}}

SELECT DISTINCT
    md5(toString(L_ORDERKEY) || '_' || toString(L_LINENUMBER)) AS ORDER_LINEITEM_HK,
    now() AS LOAD_DATE,
    L_ORDERKEY,
    L_PARTKEY,
    L_SUPPKEY,
    L_LINENUMBER,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    L_DISCOUNT,
    L_TAX,
    L_RETURNFLAG,
    L_LINESTATUS,
    L_SHIPDATE,
    L_COMMITDATE,
    L_RECEIPTDATE,
    L_SHIPINSTRUCT,
    L_SHIPMODE,
    L_COMMENT,
    md5(
        toString(L_ORDERKEY) ||
        toString(L_LINENUMBER) ||
        toString(L_PARTKEY) ||
        toString(L_SUPPKEY) ||
        toString(L_QUANTITY) ||
        toString(L_EXTENDEDPRICE) ||
        toString(L_DISCOUNT) ||
        toString(L_TAX) ||
        L_RETURNFLAG ||
        L_LINESTATUS ||
        toString(L_SHIPDATE) ||
        toString(L_COMMITDATE) ||
        toString(L_RECEIPTDATE) ||
        L_SHIPINSTRUCT ||
        L_SHIPMODE ||
        L_COMMENT
    ) AS HASHDIFF
FROM {{ source('dbgen', 'lineitem') }}
