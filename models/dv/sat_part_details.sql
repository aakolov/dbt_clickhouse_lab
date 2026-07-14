{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)',
    incremental_strategy='insert_overwrite'
) }}

WITH source_data AS (
    SELECT
        MD5(P_PARTKEY::TEXT) AS PART_HK,
        P_NAME,
        P_MFGR,
        P_BRAND,
        P_TYPE,
        P_SIZE,
        P_CONTAINER,
        P_RETAILPRICE,
        toDateTime64(CURRENT_TIMESTAMP(6), 6) AS LOAD_DATE,
        MD5(
            P_NAME || '-' || 
            P_MFGR || '-' || 
            P_BRAND || '-' || 
            P_TYPE || '-' || 
            P_SIZE || '-' || 
            P_CONTAINER || '-' || 
            P_RETAILPRICE::TEXT
        ) AS HASHDIFF,
        'TPCH' AS SOURCE
    FROM {{ source('dbgen', 'part') }}
),

{% if is_incremental() %}
-- For incremental runs, only load new or changed records
incremental_filter AS (
    SELECT
        sd.*
    FROM source_data sd
    LEFT JOIN {{ this }} existing
        ON sd.PART_HK = existing.PART_HK
        AND sd.HASHDIFF = existing.HASHDIFF
    WHERE existing.PART_HK IS NULL
)
SELECT * FROM incremental_filter
{% else %}
-- For full load, insert all records
SELECT * FROM source_data
{% endif %}
