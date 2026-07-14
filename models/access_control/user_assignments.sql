-- User assignments for access control
-- This file creates users and assigns them to roles

-- Analytics team users - read-only access
CREATE USER IF NOT EXISTS analyst_user IDENTIFIED BY 'password';
GRANT analyst TO analyst_user;

-- Data engineering team users - read all, write staging
CREATE USER IF NOT EXISTS data_engineer_user IDENTIFIED BY 'password';
GRANT data_engineer TO data_engineer_user;

-- Data owner users - full access to assigned domains
CREATE USER IF NOT EXISTS data_owner_user IDENTIFIED BY 'password';
GRANT data_owner TO data_owner_user;

-- Admin users - full access to all data
CREATE USER IF NOT EXISTS admin_user IDENTIFIED BY 'password';
GRANT admin TO admin_user;

-- Default user for dbt runs
CREATE USER IF NOT EXISTS dbt_user IDENTIFIED BY 'password';
GRANT data_engineer TO dbt_user;

-- Read-only user for BI tools
CREATE USER IF NOT EXISTS bi_user IDENTIFIED BY 'password';
GRANT analyst TO bi_user;
