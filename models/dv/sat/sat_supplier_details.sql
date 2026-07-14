{{
    config(
        engine='MergeTree()',
        order_by=['SUPPLIER_HK']
    )
}}

SELECT DISTINCT
    md5(toString(S_SUPPKEY)) AS SUPPLIER_HK,
    now() AS LOAD_DATE,
    S_SUPPKEY,
    S_NAME,
    S_ADDRESS,
    S_NATIONKEY,
    S_PHONE,
    S_ACCTBAL,
    S_COMMENT,
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
