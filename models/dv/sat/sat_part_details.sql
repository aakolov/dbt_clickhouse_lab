{{
    config(
        engine='MergeTree()',
        order_by=['PART_HK', 'EFFECTIVE_FROM']
    )
}}

SELECT DISTINCT
    md5(toString(P_PARTKEY)) AS PART_HK,
    toDateTime('1970-01-01 00:00:00') AS LOAD_DATE,
    P_PARTKEY,
    P_NAME,
    P_MFGR,
    P_BRAND,
    P_TYPE,
    P_SIZE,
    P_CONTAINER,
    P_RETAILPRICE,
    P_COMMENT,
    toDateTime('1970-01-01 00:00:00') AS EFFECTIVE_FROM,
    toDateTime('9999-12-31 23:59:59') AS EFFECTIVE_TO,
    1 AS IS_CURRENT,
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
