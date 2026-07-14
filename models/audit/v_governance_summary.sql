-- Audit summary for tracking data governance metrics

CREATE VIEW IF NOT EXISTS audit.v_governance_summary AS
SELECT
    'Total Models' AS metric,
    COUNT(DISTINCT table_name) AS value,
    'Total number of models in Data Vault' AS description
FROM audit.audit_log

UNION ALL

SELECT
    'Total Modifications' AS metric,
    COUNT(*) AS value,
    'Total number of data modifications' AS description
FROM audit.audit_log

UNION ALL

SELECT
    'Total Access Events' AS metric,
    COUNT(*) AS value,
    'Total number of data access events' AS description
FROM audit.access_audit

UNION ALL

SELECT
    'Total DDL Events' AS metric,
    COUNT(*) AS value,
    'Total number of schema changes' AS description
FROM audit.ddl_audit

UNION ALL

SELECT
    'Unique Users' AS metric,
    COUNT(DISTINCT user) AS value,
    'Number of unique users who accessed data' AS description
FROM audit.access_audit;
