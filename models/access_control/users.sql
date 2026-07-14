-- User assignments to roles

-- Analytics team users
CREATE USER IF NOT EXISTS analyst_user IDENTIFIED BY 'password';
GRANT analyst TO analyst_user;

-- Data engineering team users
CREATE USER IF NOT EXISTS data_engineer_user IDENTIFIED BY 'password';
GRANT data_engineer TO data_engineer_user;

-- Data owner users
CREATE USER IF NOT EXISTS data_owner_user IDENTIFIED BY 'password';
GRANT data_owner TO data_owner_user;

-- Admin users
CREATE USER IF NOT EXISTS admin_user IDENTIFIED BY 'password';
GRANT admin TO admin_user;
