-- Audit log table
-- Stores all modifications to Data Vault models

CREATE TABLE IF NOT EXISTS audit.audit_log
(
    timestamp DateTime64(3) DEFAULT now64(3),
    user String DEFAULT currentUser(),
    action LowCardinality(String),
    table_name String,
    record_id String,
    old_value String,
    new_value String,
    query_id String DEFAULT queryID(),
    query_text String DEFAULT currentQuery()
)
ENGINE = MergeTree
ORDER BY (timestamp, table_name, user)
PARTITION BY toYear(timestamp)
TTL timestamp + INTERVAL 7 YEAR;
