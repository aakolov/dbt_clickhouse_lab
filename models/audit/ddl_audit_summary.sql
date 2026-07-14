{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['timestamp']
) }}

SELECT
    timestamp,
    user,
    action,
    object_type,
    object_name,
    query_id,
    query_text
FROM audit.ddl_audit
