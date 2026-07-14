{{
    config(
        engine='MergeTree()',
        order_by=['ORDER_HK']
    )
}}

SELECT
    md5(toString(O_ORDERKEY)) AS ORDER_HK,
    O_ORDERKEY,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'orders') }}
