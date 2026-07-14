-- Security policies for access control
-- This file contains row-level and column-level security policies

-- Row-level security policies for analyst role
CREATE ROW POLICY IF NOT EXISTS analyst_staging_policy ON staging.stg_customer FOR SELECT
    USING c_mktsegment IN ('AUTOMOBILE', 'BUILDING', 'FURNITURE', 'MACHINERY', 'HOUSEHOLD');

CREATE ROW POLICY IF NOT EXISTS analyst_marts_policy ON marts.f_orders_stats FOR SELECT
    USING 1 = 1;

-- Row-level security policies for data_engineer role
CREATE ROW POLICY IF NOT EXISTS data_engineer_staging_policy ON staging.stg_customer FOR SELECT
    USING 1 = 1;

CREATE ROW POLICY IF NOT EXISTS data_engineer_marts_policy ON marts.f_orders_stats FOR SELECT
    USING 1 = 1;

-- Row-level security policies for data_owner role
CREATE ROW POLICY IF NOT EXISTS data_owner_staging_policy ON staging.stg_customer FOR SELECT
    USING 1 = 1;

CREATE ROW POLICY IF NOT EXISTS data_owner_marts_policy ON marts.f_orders_stats FOR SELECT
    USING 1 = 1;

-- Row-level security policies for admin role
CREATE ROW POLICY IF NOT EXISTS admin_staging_policy ON staging.stg_customer FOR SELECT
    USING 1 = 1;

CREATE ROW POLICY IF NOT EXISTS admin_marts_policy ON marts.f_orders_stats FOR SELECT
    USING 1 = 1;

-- Column-level security policies
-- Hide phone numbers from analyst role
REVOKE COLUMN c_phone ON staging.stg_customer FROM analyst;

-- Allow phone numbers for data_engineer and above
GRANT COLUMN c_phone ON staging.stg_customer TO data_engineer;
GRANT COLUMN c_phone ON staging.stg_customer TO data_owner;
GRANT COLUMN c_phone ON staging.stg_customer TO admin;

-- Hide address from analyst role
REVOKE COLUMN c_address ON staging.stg_customer FROM analyst;

-- Allow address for data_engineer and above
GRANT COLUMN c_address ON staging.stg_customer TO data_engineer;
GRANT COLUMN c_address ON staging.stg_customer TO data_owner;
GRANT COLUMN c_address ON staging.stg_customer TO admin;
