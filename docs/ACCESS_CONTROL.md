# Access Control

This document describes the access control system for the dbt-clickhouse-lab project.

## Architecture

Access control is implemented using ClickHouse's built-in role-based access management:

- **Roles**: Predefined sets of permissions
- **Users**: Assigned to roles based on their responsibilities
- **Policies**: Row-level and column-level security policies

## Roles

### analyst
- Read access to staging layer
- Read access to marts layer
- Read access to semantic models
- No write access

### data_engineer
- Read access to all layers
- Write access to staging layer
- Read access to marts layer
- No write access to Data Vault

### data_owner
- Full access to assigned data domains
- Can grant/revoke access to their data
- Can create materialized views

### admin
- Full access to all data
- Can manage roles and users
- Can modify access control models

## Data Classification

| Level | Description | Access |
|-------|-------------|--------|
| Public | Non-sensitive data | analyst, data_engineer, data_owner, admin |
| Internal | Internal use only | data_engineer, data_owner, admin |
| Confidential | Sensitive data | data_owner, admin |
| Restricted | Highly sensitive | admin only |

## Implementation

Access control is implemented using:

1. **Roles**: Defined in `models/access_control/roles.sql`
2. **User assignments**: Defined in `models/access_control/users.sql`
3. **Security policies**: Defined in `models/access_control/policies.sql`

## Usage

### Grant role to user
```sql
GRANT analyst TO user_name;
```

### Revoke role
```sql
REVOKE analyst FROM user_name;
```

### Check current user's roles
```sql
SHOW GRANTS FOR CURRENT_USER;
```

## Maintenance

- Review access controls quarterly
- Audit access requests monthly
- Update roles as needed
