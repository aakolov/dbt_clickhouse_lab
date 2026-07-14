-- Access audit view for easy querying

CREATE VIEW IF NOT EXISTS audit.v_access_audit AS
SELECT
    timestamp,
    user,
    table_name,
    query_id,
    query_text,
    rows_read,
    bytes_read,
    toStartOfHour(timestamp) AS hour,
    toDayOfWeek(timestamp) AS day_of_week,
    toString(user) || '_' || toString(timestamp) AS audit_key
FROM audit.access_audit;
