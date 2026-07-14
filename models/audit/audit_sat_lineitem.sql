-- Audit model for lineitem satellite
-- Tracks all changes to lineitem details

{{ config(
    materialized='incremental',
    unique_key='HK_LINEITEM',
    clustered_by='HK_LINEITEM'
) }}

WITH source_data AS (
    SELECT
        HK_LINEITEM,
        LD_LINEITEM,
        LOAD_DATE,
        SOURCE,
        HASHDIFF,
        L_ORDERKEY,
        L_PARTKEY,
        L_SUPPKEY,
        L_LINENUMBER,
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
        L_COMMENT,
        dbt_updated_at,
        dbt_invocation_id
    FROM {{ ref('sat_lineitem_details') }}
    {% if is_incremental() %}
    WHERE dbt_updated_at > (SELECT MAX(dbt_updated_at) FROM {{ this }})
    {% endif %}
)

SELECT
    HK_LINEITEM,
    LD_LINEITEM,
    LOAD_DATE,
    SOURCE,
    HASHDIFF,
    L_ORDERKEY,
    L_PARTKEY,
    L_SUPPKEY,
    L_LINENUMBER,
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
    L_COMMENT,
    dbt_updated_at,
    dbt_invocation_id,
    '{{ invocation_id }}' AS audit_invocation_id,
    now64(3) AS audit_timestamp,
    currentUser() AS audit_user,
    'INSERT' AS audit_action
FROM source_data
