{{
    config(
        engine='MergeTree()',
        order_by=['CUSTOMER_HK']
    )
}}

SELECT DISTINCT
    md5(toString(C_CUSTKEY)) AS CUSTOMER_HK,
    now() AS LOAD_DATE,
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    md5(
        toString(C_CUSTKEY) ||
        C_NAME ||
        C_ADDRESS ||
        toString(C_NATIONKEY) ||
        C_PHONE ||
        toString(C_ACCTBAL) ||
        C_MKTSEGMENT ||
        C_COMMENT
    ) AS HASHDIFF
FROM {{ source('dbgen', 'customer') }}
