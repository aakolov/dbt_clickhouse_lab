{{ config(
    engine='MergeTree()',
    order_by=['LOAD_DATE', 'HASHDIFF'],
    partition_by='toYear(LOAD_DATE)',
    incremental_strategy='insert_overwrite'
) }}

WITH source_data AS (
    SELECT
        MD5(C_CUSTKEY::TEXT) AS CUSTOMER_HK,
        C_NAME,
        C_ADDRESS,
        C_NATIONKEY,
        C_PHONE,
        C_ACCTBAL,
        C_MKTSEGMENT,
        C_COMMENT,
        toDateTime64(CURRENT_TIMESTAMP(6), 6) AS LOAD_DATE,
        MD5(
            C_NAME || '-' || 
            C_ADDRESS || '-' || 
            C_PHONE || '-' || 
            C_ACCTBAL || '-' || 
            C_MKTSEGMENT || '-' || 
            C_COMMENT
        ) AS HASHDIFF,
        'TPCH' AS SOURCE
    FROM {{ source('dbgen', 'customer') }}
),

{% if is_incremental() %}
-- For incremental runs, only load new or changed records
incremental_filter AS (
    SELECT
        sd.*
    FROM source_data sd
    LEFT JOIN {{ this }} existing
        ON sd.CUSTOMER_HK = existing.CUSTOMER_HK
        AND sd.HASHDIFF = existing.HASHDIFF
    WHERE existing.CUSTOMER_HK IS NULL
)
SELECT * FROM incremental_filter
{% else %}
-- For full load, insert all records
SELECT * FROM source_data
{% endif %}
