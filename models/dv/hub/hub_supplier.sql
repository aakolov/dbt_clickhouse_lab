{{
    config(
        engine='MergeTree()',
        order_by=['SUPPLIER_HK']
    )
}}

SELECT
    md5(toString(S_SUPPKEY)) AS SUPPLIER_HK,
    S_SUPPKEY,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'supplier') }}
