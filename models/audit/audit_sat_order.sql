-- Audit model for order satellite
-- Tracks all changes to order details

{{ config(
    materialized='incremental',
    unique_key='HK_ORDER',
    clustered_by='HK_ORDER'
) }}

WITH source_data AS (
    SELECT
        HK_ORDER,
        LD_ORDER,
        LOAD_DATE,
        SOURCE,
        HASHDIFF,
        O_CUSTKEY,
        O_ORDERSTATUS,
        O_TOTALPRICE,
        O_ORDERDATE,
        O_ORDERPRIORITY,
        O_CLERK,
        O_SHIPPRIORITY,
        O_COMMENT,
        dbt_updated_at,
        dbt_invocation_id
    FROM {{ ref('sat_order_details') }}
    {% if is_incremental() %}
    WHERE dbt_updated_at > (SELECT MAX(dbt_updated_at) FROM {{ this }})
    {% endif %}
)

SELECT
    HK_ORDER,
    LD_ORDER,
    LOAD_DATE,
    SOURCE,
    HASHDIFF,
    O_CUSTKEY,
    O_ORDERSTATUS,
    O_TOTALPRICE,
    O_ORDERDATE,
    O_ORDERPRIORITY,
    O_CLERK,
    O_SHIPPRIORITY,
    O_COMMENT,
    dbt_updated_at,
    dbt_invocation_id,
    '{{ invocation_id }}' AS audit_invocation_id,
    now64(3) AS audit_timestamp,
    currentUser() AS audit_user,
    'INSERT' AS audit_action
FROM source_data
