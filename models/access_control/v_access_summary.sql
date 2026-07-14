-- Access control summary view
-- Provides overview of access control status

CREATE VIEW IF NOT EXISTS access_control.v_access_summary AS
SELECT
    'roles' AS category,
    COUNT(*) AS count,
    'Total roles' AS description
FROM system.roles

UNION ALL

SELECT
    'users' AS category,
    COUNT(*) AS count,
    'Total users' AS description
FROM system.users

UNION ALL

SELECT
    'grants' AS category,
    COUNT(*) AS count,
    'Total grants' AS description
FROM system.grants

UNION ALL

SELECT
    'policies' AS category,
    COUNT(*) AS count,
    'Total row policies' AS description
FROM system.row_policies;
