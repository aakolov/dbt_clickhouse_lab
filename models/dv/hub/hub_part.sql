{{
    config(
        engine='MergeTree()',
        order_by=['PART_HK']
    )
}}

SELECT
    md5(toString(P_PARTKEY)) AS PART_HK,
    P_PARTKEY,
    now() AS LOAD_DATE
FROM {{ source('dbgen', 'part') }}
