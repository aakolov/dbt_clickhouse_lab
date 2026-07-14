-- Modification audit summary view
-- Provides overview of data modifications

CREATE VIEW IF NOT EXISTS audit.v_modification_audit_summary AS
SELECT
    toStartOfHour(timestamp) AS hour,
    user,
    action,
    table_name,
    COUNT(*) AS modification_count
FROM audit.audit_log
GROUP BY
    toStartOfHour(timestamp),
    user,
    action,
    table_name;
