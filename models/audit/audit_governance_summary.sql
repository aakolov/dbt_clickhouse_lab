-- Audit summary for tracking data governance metrics

SELECT
    metric,
    value,
    description
FROM audit.v_governance_summary;
