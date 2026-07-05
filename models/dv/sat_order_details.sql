{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)',
    incremental_strategy='insert_overwrite'
) }}

WITH source_data AS (
    SELECT
        MD5(O_ORDERKEY::TEXT) AS ORDER_HK,
        O_ORDERSTATUS,
        O_TOTALPRICE,
        O_ORDERDATE,
        O_ORDERPRIORITY,
        O_CLERK,
        O_SHIPPRIORITY,
        O_COMMENT,
        toDateTime64(CURRENT_TIMESTAMP(6), 6) AS LOAD_DATE,
        MD5(
            O_ORDERSTATUS || '-' || 
            O_TOTALPRICE || '-' || 
            O_ORDERDATE || '-' || 
            O_ORDERPRIORITY || '-' || 
            O_CLERK || '-' || 
            O_SHIPPRIORITY || '-' ||
            O_COMMENT
        ) AS HASHDIFF,
        'TPCH' AS SOURCE
    FROM {{ source('dbgen', 'orders') }}
),

{% if is_incremental() %}
-- For incremental runs, only load new or changed records
incremental_filter AS (
    SELECT
        sd.*
    FROM source_data sd
    LEFT JOIN {{ this }} existing
        ON sd.ORDER_HK = existing.ORDER_HK
        AND sd.HASHDIFF = existing.HASHDIFF
    WHERE existing.ORDER_HK IS NULL
)
SELECT * FROM incremental_filter
{% else %}
-- For full load, insert all records
SELECT * FROM source_data
{% endif %}
