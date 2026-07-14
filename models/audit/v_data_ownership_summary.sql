-- Data ownership summary view
-- Provides overview of data ownership

CREATE VIEW IF NOT EXISTS audit.v_data_ownership_summary AS
SELECT
    'hub_customer' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'hub_order' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'hub_part' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'hub_supplier' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'sat_customer_details' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'sat_order_details' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'sat_lineitem_details' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification
UNION ALL
SELECT
    'sat_supplier_details' AS table_name,
    'analytics_team' AS owner,
    'internal' AS classification;
