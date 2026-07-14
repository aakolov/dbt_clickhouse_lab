{{
    config(
        engine='MergeTree()',
        order_by=['ORDER_HK']
    )
}}

SELECT DISTINCT
    md5(toString(O_ORDERKEY)) AS ORDER_HK,
    md5(toString(O_CUSTKEY)) AS CUSTOMER_HK,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'orders') }}
