-- Access audit for tracking SELECT queries
-- This model provides an overview of access patterns

CREATE VIEW IF NOT EXISTS audit.v_access_audit_summary AS
SELECT
    toStartOfHour(timestamp) AS hour,
    user,
    table_name,
    COUNT(*) AS query_count,
    SUM(rows_read) AS total_rows_read,
    SUM(bytes_read) AS total_bytes_read,
    AVG(rows_read) AS avg_rows_per_query,
    AVG(bytes_read) AS avg_bytes_per_query
FROM audit.access_audit
GROUP BY
    toStartOfHour(timestamp),
    user,
    table_name;
