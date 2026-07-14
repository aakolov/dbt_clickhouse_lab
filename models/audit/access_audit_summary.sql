{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['timestamp']
) }}

SELECT
    timestamp,
    user,
    table_name,
    query_id,
    query_text,
    rows_read,
    bytes_read
FROM audit.access_audit
