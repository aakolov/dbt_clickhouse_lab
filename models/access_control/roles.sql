-- Roles for access control

-- analyst role: read-only access to staging, marts, and semantic layers
CREATE ROLE IF NOT EXISTS analyst;

-- data_engineer role: read access to all, write to staging only
CREATE ROLE IF NOT EXISTS data_engineer;

-- data_owner role: full access to assigned domains
CREATE ROLE IF NOT EXISTS data_owner;

-- admin role: full access to all data
CREATE ROLE IF NOT EXISTS admin;
