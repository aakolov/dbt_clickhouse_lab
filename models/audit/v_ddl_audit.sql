-- DDL audit view for easy querying

CREATE VIEW IF NOT EXISTS audit.v_ddl_audit AS
SELECT
    timestamp,
    user,
    action,
    object_type,
    object_name,
    query_id,
    query_text,
    toStartOfHour(timestamp) AS hour,
    toDayOfWeek(timestamp) AS day_of_week,
    toString(user) || '_' || toString(timestamp) AS audit_key
FROM audit.ddl_audit;
