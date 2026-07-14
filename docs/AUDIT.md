# Audit

This document describes the audit system for the dbt-clickhouse-lab project.

## Audit Objectives

- Track all data modifications
- Maintain data lineage
- Support compliance requirements
- Enable data reconstruction

## Audit Logs

### Access Audit
- User who accessed data
- Query executed
- Timestamp
- Data accessed

### Modification Audit
- User who made changes
- Type of modification (INSERT/UPDATE/DELETE)
- Before and after values
- Timestamp

### DDL Audit
- User who executed DDL
- DDL statement
- Timestamp

## Implementation

### Audit Table Structure

```sql
CREATE TABLE audit.audit_log
(
    timestamp DateTime64(3),
    user String,
    action LowCardinality(String),
    table_name String,
    record_id String,
    old_value String,
    new_value String,
    query_id String,
    query_text String
)
ENGINE = MergeTree
ORDER BY (timestamp, table_name, user)
PARTITION BY toYear(timestamp)
```

### Audit Model

The audit model is implemented in `models/audit/audit_model.sql` and captures:

1. All changes to hub tables
2. All changes to satellite tables
3. All changes to link tables
4. User and session information

### Audit Macros

Audit is implemented using dbt macros in `macros/audit/`:

- `audit_insert.sql`: Audit INSERT operations
- `audit_update.sql`: Audit UPDATE operations
- `audit_delete.sql`: Audit DELETE operations

## Retention

- Access logs: 90 days
- Modification logs: 7 years
- DDL logs: 7 years

## Compliance

The audit system supports:

- GDPR data subject requests
- SOX compliance requirements
- Internal audit requirements

## Access

Audit logs are accessible to:

- Admin role
- Data owners for their domains
- Compliance team (read-only)

## Maintenance

- Review audit logs monthly
- Archive old logs quarterly
- Test audit recovery procedures annually
