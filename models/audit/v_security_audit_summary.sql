-- Security audit summary view
-- Provides overview of security-related events

CREATE VIEW IF NOT EXISTS audit.v_security_audit_summary AS
SELECT
    'Access Audit' AS category,
    COUNT(*) AS event_count
FROM audit.access_audit
WHERE timestamp > now() - INTERVAL 30 DAY

UNION ALL

SELECT
    'Modification Audit' AS category,
    COUNT(*) AS event_count
FROM audit.audit_log
WHERE timestamp > now() - INTERVAL 30 DAY

UNION ALL

SELECT
    'DDL Audit' AS category,
    COUNT(*) AS event_count
FROM audit.ddl_audit
WHERE timestamp > now() - INTERVAL 30 DAY;
