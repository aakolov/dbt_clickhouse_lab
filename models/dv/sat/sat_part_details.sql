{{
    config(
        engine='MergeTree()',
        order_by=['PART_HK']
    )
}}

SELECT DISTINCT
    md5(toString(P_PARTKEY)) AS PART_HK,
    now() AS LOAD_DATE,
    P_PARTKEY,
    P_NAME,
    P_MFGR,
    P_BRAND,
    P_TYPE,
    P_SIZE,
    P_CONTAINER,
    P_RETAILPRICE,
    P_COMMENT,
    md5(
        toString(P_PARTKEY) ||
        P_NAME ||
        P_MFGR ||
        P_BRAND ||
        P_TYPE ||
        toString(P_SIZE) ||
        P_CONTAINER ||
        toString(P_RETAILPRICE) ||
        P_COMMENT
    ) AS HASHDIFF
FROM {{ source('dbgen', 'part') }}
