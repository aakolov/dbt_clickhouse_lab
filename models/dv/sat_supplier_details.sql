{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)',
    incremental_strategy='insert_overwrite'
) }}

WITH source_data AS (
    SELECT
        MD5(S_SUPPKEY::TEXT) AS SUPPLIER_HK,
        S_NAME,
        S_ADDRESS,
        S_NATIONKEY,
        S_PHONE,
        S_ACCTBAL,
        toDateTime64(CURRENT_TIMESTAMP(6), 6) AS LOAD_DATE,
        MD5(
            S_NAME || '-' || 
            S_ADDRESS || '-' || 
            S_PHONE || '-' || 
            S_ACCTBAL::TEXT
        ) AS HASHDIFF,
        'TPCH' AS SOURCE
    FROM {{ source('dbgen', 'supplier') }}
),

{% if is_incremental() %}
-- For incremental runs, only load new or changed records
incremental_filter AS (
    SELECT
        sd.*
    FROM source_data sd
    LEFT JOIN {{ this }} existing
        ON sd.SUPPLIER_HK = existing.SUPPLIER_HK
        AND sd.HASHDIFF = existing.HASHDIFF
    WHERE existing.SUPPLIER_HK IS NULL
)
SELECT * FROM incremental_filter
{% else %}
-- For full load, insert all records
SELECT * FROM source_data
{% endif %}
