{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['dbt_invocation_id']
) }}

SELECT
    dbt_invocation_id,
    model_name,
    status,
    executed_at,
    duration_ms,
    rows_affected
FROM {{ ref('dbt_invocations') }}
