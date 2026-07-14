{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['timestamp']
) }}

SELECT
    timestamp,
    user,
    action,
    table_name,
    record_id,
    old_value,
    new_value,
    query_id,
    query_text,
    audit_invocation_id,
    audit_timestamp,
    audit_user,
    audit_action
FROM audit.audit_log
