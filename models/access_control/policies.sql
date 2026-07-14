-- Security policies for data protection

-- Row-level security policies
-- Analysts can only see public data
CREATE ROW POLICY IF NOT EXISTS analyst_policy ON staging.stg_customer FOR SELECT USING C_MKTSEGMENT IN ('AUTOMOBILE', 'BUILDING', 'FURNITURE');

-- Data engineers can see all data in staging
CREATE ROW POLICY IF NOT EXISTS data_engineer_policy ON staging.stg_customer FOR SELECT USING 1 = 1;

-- Data owners can see all data in their domain
CREATE ROW POLICY IF NOT EXISTS data_owner_policy ON marts.f_orders_stats FOR SELECT USING 1 = 1;

-- Admin can see all data
CREATE ROW POLICY IF NOT EXISTS admin_policy ON marts.f_orders_stats FOR SELECT USING 1 = 1;

-- Column-level security policies
-- Hide sensitive columns from analysts
REVOKE COLUMN C_PHONE ON staging.stg_customer FROM analyst;

-- Data engineers can see all columns
GRANT COLUMN C_PHONE ON staging.stg_customer TO data_engineer;

-- Data owners can see all columns in their domain
GRANT COLUMN C_PHONE ON staging.stg_customer TO data_owner;

-- Admin can see all columns
GRANT COLUMN C_PHONE ON staging.stg_customer TO admin;
