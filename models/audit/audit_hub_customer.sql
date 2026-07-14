-- Audit model for customer hub
-- Tracks all changes to customer business keys

{{ config(
    materialized='incremental',
    unique_key='HK_CUSTOMER',
    clustered_by='HK_CUSTOMER'
) }}

WITH source_data AS (
    SELECT
        HK_CUSTOMER,
        LD_CUSTOMER,
        LOAD_DATE,
        SOURCE,
        HASHDIFF,
        C_CUSTKEY,
        C_NAME,
        C_ADDRESS,
        C_NATIONKEY,
        C_PHONE,
        C_ACCTBAL,
        C_MKTSEGMENT,
        C_COMMENT,
        dbt_updated_at,
        dbt_invocation_id
    FROM {{ ref('hub_customer') }}
    {% if is_incremental() %}
    WHERE dbt_updated_at > (SELECT MAX(dbt_updated_at) FROM {{ this }})
    {% endif %}
)

SELECT
    HK_CUSTOMER,
    LD_CUSTOMER,
    LOAD_DATE,
    SOURCE,
    HASHDIFF,
    C_CUSTKEY,
    C_NAME,
    C_ADDRESS,
    C_NATIONKEY,
    C_PHONE,
    C_ACCTBAL,
    C_MKTSEGMENT,
    C_COMMENT,
    dbt_updated_at,
    dbt_invocation_id,
    '{{ invocation_id }}' AS audit_invocation_id,
    now64(3) AS audit_timestamp,
    currentUser() AS audit_user,
    'INSERT' AS audit_action
FROM source_data
