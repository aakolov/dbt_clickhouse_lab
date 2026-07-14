-- DDL audit trail
-- Logs all schema changes

CREATE TABLE IF NOT EXISTS audit.ddl_audit
(
    timestamp DateTime64(3) DEFAULT now64(3),
    user String DEFAULT currentUser(),
    action LowCardinality(String),
    object_type LowCardinality(String),
    object_name String,
    query_id String DEFAULT queryID(),
    query_text String DEFAULT currentQuery()
)
ENGINE = MergeTree
ORDER BY (timestamp, user, action, object_type)
PARTITION BY toYear(timestamp)
TTL timestamp + INTERVAL 7 YEAR;
