{{
    config(
        engine='MergeTree()',
        order_by=['CUSTOMER_HK', 'EFFECTIVE_FROM']
    )
}}

SELECT DISTINCT
    md5(toString(C_CUSTKEY)) AS CUSTOMER_HK,
    toDateTime('1970-01-01 00:00:00') AS LOAD_DATE,
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    now() AS EFFECTIVE_FROM,
    toDateTime('9999-12-31 23:59:59') AS EFFECTIVE_TO,
    1 AS IS_CURRENT,
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
