{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(L_ORDERKEY::TEXT || '-' || L_LINENUMBER::TEXT) AS ORDER_LINEITEM_HK,
    L_PARTKEY,
    L_SUPPKEY,
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
    CURRENT_TIMESTAMP AS LOAD_DATE,
    MD5(
        L_PARTKEY::TEXT || '-' || 
        L_SUPPKEY::TEXT || '-' || 
        L_QUANTITY::TEXT || '-' || 
        L_EXTENDEDPRICE::TEXT || '-' || 
        L_DISCOUNT::TEXT || '-' || 
        L_TAX::TEXT || '-' || 
        L_RETURNFLAG || '-' || 
        L_LINESTATUS || '-' || 
        L_SHIPDATE || '-' || 
        L_COMMITDATE || '-' || 
        L_RECEIPTDATE || '-' || 
        L_SHIPINSTRUCT || '-' || 
        L_SHIPMODE
    ) AS HASHDIFF,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'lineitem') }}
