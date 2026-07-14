{{
    config(
        engine='MergeTree()',
        order_by=['CUSTOMER_HK']
    )
}}

SELECT
    md5(toString(C_CUSTKEY)) AS CUSTOMER_HK,
    C_CUSTKEY,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'customer') }}
