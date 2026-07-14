{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)',
    incremental_strategy='insert_overwrite'
) }}

WITH source_data AS (
    SELECT
        MD5(L_ORDERKEY::TEXT || '-' || L_LINENUMBER::TEXT) AS ORDER_LINEITEM_HK,
        L_PARTKEY,
        L_SUPPKEY,
        L_QUANTITY,
        L_EXTENDEDPRICE,
        L_DISCOUNT,
        L_TAX,
        L_RETURNFLAG,
        L_LINESTATUS,
        L_SHIPDATE,
        L_COMMITDATE,
        L_RECEIPTDATE,
        L_SHIPINSTRUCT,
        L_SHIPMODE,
        toDateTime64(CURRENT_TIMESTAMP(6), 6) AS LOAD_DATE,
        MD5(
            L_PARTKEY::TEXT || '-' || 
            L_SUPPKEY::TEXT || '-' || 
            L_QUANTITY::TEXT || '-' || 
            L_EXTENDEDPRICE::TEXT || '-' || 
            L_DISCOUNT::TEXT || '-' || 
            L_TAX::TEXT || '-' || 
            L_RETURNFLAG || '-' || 
            L_LINESTATUS || '-' || 
            L_SHIPDATE || '-' || 
            L_COMMITDATE || '-' || 
            L_RECEIPTDATE || '-' || 
            L_SHIPINSTRUCT || '-' || 
            L_SHIPMODE
        ) AS HASHDIFF,
        'TPCH' AS SOURCE
    FROM {{ source('dbgen', 'lineitem') }}
),

{% if is_incremental() %}
-- For incremental runs, only load new or changed records
incremental_filter AS (
    SELECT
        sd.*
    FROM source_data sd
    LEFT JOIN {{ this }} existing
        ON sd.ORDER_LINEITEM_HK = existing.ORDER_LINEITEM_HK
        AND sd.HASHDIFF = existing.HASHDIFF
    WHERE existing.ORDER_LINEITEM_HK IS NULL
)
SELECT * FROM incremental_filter
{% else %}
-- For full load, insert all records
SELECT * FROM source_data
{% endif %}
