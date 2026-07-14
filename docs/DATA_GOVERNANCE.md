# Data Governance

This document provides an overview of data governance in the dbt-clickhouse-lab project.

## Key Components

### 1. Data Owners
See `docs/DATA_OWNERS.md` for information about data ownership structure.

### 2. Access Control
See `docs/ACCESS_CONTROL.md` for information about access control system.

### 3. Audit
See `docs/AUDIT.md` for information about audit system.

### 4. Metadata
See `docs/METADATA.md` for information about metadata configuration.

## Governance Workflow

### Data Access Request
1. Submit request to data owner
2. Data owner reviews request
3. Access is granted or denied
4. Request is logged in audit trail

### Data Change Request
1. Submit change request
2. Data owner reviews impact
3. Change is approved or rejected
4. Change is logged in audit trail

### Data Classification Review
1. Review data classification annually
2. Update classification as needed
3. Notify stakeholders of changes
4. Update access controls accordingly

## Compliance

The data governance system supports:

- GDPR data subject requests
- SOX compliance requirements
- Internal audit requirements
- Data protection regulations

## Contact

For questions about data governance, contact the Analytics Team at analytics@company.com.
