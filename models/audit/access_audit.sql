-- Access audit trail
-- Logs all SELECT queries for compliance

CREATE TABLE IF NOT EXISTS audit.access_audit
(
    timestamp DateTime64(3) DEFAULT now64(3),
    user String DEFAULT currentUser(),
    table_name String,
    query_id String DEFAULT queryID(),
    query_text String DEFAULT currentQuery(),
    rows_read UInt64,
    bytes_read UInt64
)
ENGINE = MergeTree
ORDER BY (timestamp, user, table_name)
PARTITION BY toYear(timestamp)
TTL timestamp + INTERVAL 90 DAY;
