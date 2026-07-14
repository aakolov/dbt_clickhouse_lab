-- Data classification summary view
-- Provides overview of data classification

CREATE VIEW IF NOT EXISTS audit.v_data_classification_summary AS
SELECT
    'hub_customer' AS table_name,
    'C_CUSTKEY' AS column_name,
    'internal' AS classification,
    'No' AS pii,
    'No' AS sensitive
UNION ALL
SELECT
    'hub_customer',
    'C_NAME',
    'internal',
    'Yes',
    'No'
UNION ALL
SELECT
    'hub_customer',
    'C_ADDRESS',
    'internal',
    'Yes',
    'No'
UNION ALL
SELECT
    'hub_customer',
    'C_PHONE',
    'internal',
    'Yes',
    'No'
UNION ALL
SELECT
    'hub_order',
    'O_ORDERKEY',
    'internal',
    'No',
    'No'
UNION ALL
SELECT
    'hub_order',
    'O_TOTALPRICE',
    'internal',
    'No',
    'Yes'
UNION ALL
SELECT
    'sat_lineitem_details',
    'L_EXTENDEDPRICE',
    'internal',
    'No',
    'No'
UNION ALL
SELECT
    'sat_lineitem_details',
    'L_DISCOUNT',
    'internal',
    'No',
    'No';
