{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'ORDER_LINEITEM_HK'],
    partition_by='toYear(LOAD_DATE)'
) }}

SELECT
    MD5(L_ORDERKEY::TEXT || '-' || L_LINENUMBER::TEXT) AS ORDER_LINEITEM_HK,
    MD5(L_ORDERKEY::TEXT) AS ORDER_HK,
    MD5(L_PARTKEY::TEXT) AS PART_HK,
    MD5(L_SUPPKEY::TEXT) AS SUPPLIER_HK,
    CURRENT_TIMESTAMP AS LOAD_DATE,
    'TPCH' AS SOURCE
FROM {{ source('dbgen', 'lineitem') }}
