# Access Control Summary

This folder contains access control models for the dbt-clickhouse-lab project.

## Models

### roles.sql
- Predefined roles: analyst, data_engineer, data_owner, admin

### users.sql
- User assignments to roles

### policies.sql
- Row-level and column-level security policies

### security_policies.sql
- Additional security policies

### v_access_summary.sql
- Summary of access control status

### v_data_ownership_summary.sql
- Summary of data ownership

## Usage

1. Create roles: `dbt run --models access_control.roles`
2. Create users: `dbt run --models access_control.users`
3. Apply policies: `dbt run --models access_control.policies`

## Documentation

See `docs/ACCESS_CONTROL.md` for more information.
