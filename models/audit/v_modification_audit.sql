-- Modification audit view for easy querying

CREATE VIEW IF NOT EXISTS audit.v_modification_audit AS
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
    toStartOfHour(timestamp) AS hour,
    toDayOfWeek(timestamp) AS day_of_week,
    toString(user) || '_' || toString(timestamp) AS audit_key
FROM audit.audit_log;
