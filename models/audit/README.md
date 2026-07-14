# Data Governance Summary

This view provides a summary of data governance metrics.

## Metrics

| Metric | Description |
|--------|-------------|
| Total Models | Total number of models in Data Vault |
| Total Modifications | Total number of data modifications |
| Total Access Events | Total number of data access events |
| Total DDL Events | Total number of schema changes |
| Unique Users | Number of unique users who accessed data |

## Usage

```sql
SELECT * FROM audit.v_governance_summary;
```
