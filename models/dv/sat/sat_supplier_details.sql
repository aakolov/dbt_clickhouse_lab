{{
    config(
        engine='MergeTree()',
        order_by=['SUPPLIER_HK', 'EFFECTIVE_FROM']
    )
}}

SELECT DISTINCT
    md5(toString(S_SUPPKEY)) AS SUPPLIER_HK,
    toDateTime('1970-01-01 00:00:00') AS LOAD_DATE,
    S_SUPPKEY,
    S_NAME,
    S_ADDRESS,
    S_NATIONKEY,
    S_PHONE,
    S_ACCTBAL,
    S_COMMENT,
    toDateTime('1970-01-01 00:00:00') AS EFFECTIVE_FROM,
    toDateTime('9999-12-31 23:59:59') AS EFFECTIVE_TO,
    1 AS IS_CURRENT,
    md5(
        toString(S_SUPPKEY) ||
        S_NAME ||
        S_ADDRESS ||
        toString(S_NATIONKEY) ||
        S_PHONE ||
        toString(S_ACCTBAL) ||
        S_COMMENT
    ) AS HASHDIFF
FROM {{ source('dbgen', 'supplier') }}
