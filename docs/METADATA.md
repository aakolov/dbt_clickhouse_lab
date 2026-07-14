# dbt Project Metadata

This document describes the metadata configuration for the dbt-clickhouse-lab project.

## Metadata Structure

### Data Governance Section

```yaml
metadata:
  data_governance:
    enabled: true
    owners:
      - name: analytics_team
        email: analytics@company.com
        scope: all
    classification:
      default: internal
      levels:
        - public
        - internal
        - confidential
        - restricted
```

### Model Meta Section

Each model should include metadata in its config:

```yaml
{{ config(
    meta={
        'data_quality': {
            'owner': 'analytics_team',
            'classification': 'internal',
            'description': 'Model description'
        },
        'data_governance': {
            'owner': 'analytics_team',
            'classification': 'internal',
            'pii': False,
            'sensitive': False
        }
    }
) }}
```

## Classification Levels

### Public
- Non-sensitive data
- Can be shared externally
- Example: aggregated statistics

### Internal
- Internal use only
- Should not be shared externally
- Example: customer contact information

### Confidential
- Sensitive data
- Requires special access controls
- Example: financial data

### Restricted
- Highly sensitive data
- Maximum access controls
- Example: personally identifiable information (PII)

## Owner Responsibilities

- Ensure data quality
- Maintain documentation
- Approve access requests
- Manage data classification

## Metadata Standards

1. All models must have classification level
2. All models must have an owner
3. PII fields must be marked
4. Sensitive fields must be marked
5. Data lineage must be documented
