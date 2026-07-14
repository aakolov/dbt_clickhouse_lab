{{
    config(
        engine='MergeTree()',
        order_by=['ORDER_HK', 'ORDER_LINEITEM_HK']
    )
}}

SELECT DISTINCT
    md5(toString(L_ORDERKEY)) AS ORDER_HK,
    md5(toString(L_ORDERKEY) || '_' || toString(L_LINENUMBER)) AS ORDER_LINEITEM_HK,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'lineitem') }}
