SET TARGET_SCHEMA_NAME = '{{ schema_name }}';
SET TARGET_DB_NAME = '{{ database_name }}'; -- Name of database that will have the SCHEMACHANGE Schema for change tracking.
-- Dependent Variables; Change the naming pattern if you want but not necessary
SET ADMIN_ROLE = $TARGET_DB_NAME || '_ADMIN'; -- This role will own the database and schemas.
-- Including hyphen in the role to test for hyphenated role support
SET DEPLOY_ROLE = '"' || $TARGET_DB_NAME || '-DEPLOY"'; -- This role will be granted privileges to create objects in any schema in the database
SET WAREHOUSE_NAME = $TARGET_DB_NAME || '_WH';
SET SCHEMACHANGE_NAMESPACE = $TARGET_DB_NAME || '.' || $TARGET_SCHEMA_NAME;
SET SC_M = 'SC_M_' || $TARGET_SCHEMA_NAME;
SET SC_R = 'SC_R_' || $TARGET_SCHEMA_NAME;
SET SC_W = 'SC_W_' || $TARGET_SCHEMA_NAME;
SET SC_C = 'SC_C_' || $TARGET_SCHEMA_NAME;

USE ROLE IDENTIFIER($ADMIN_ROLE);
USE DATABASE IDENTIFIER($TARGET_DB_NAME);
USE WAREHOUSE IDENTIFIER($WAREHOUSE_NAME);

CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($SC_M);
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($SC_R);
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($SC_W);
CREATE DATABASE ROLE IF NOT EXISTS IDENTIFIER($SC_C);

GRANT DATABASE ROLE IDENTIFIER($SC_M) TO DATABASE ROLE DB_M;
GRANT DATABASE ROLE IDENTIFIER($SC_R) TO DATABASE ROLE DB_R;
GRANT DATABASE ROLE IDENTIFIER($SC_W) TO DATABASE ROLE DB_W;
GRANT DATABASE ROLE IDENTIFIER($SC_C) TO DATABASE ROLE DB_C;
GRANT DATABASE ROLE IDENTIFIER($SC_M) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT DATABASE ROLE IDENTIFIER($SC_R) TO DATABASE ROLE IDENTIFIER($SC_W);
GRANT DATABASE ROLE IDENTIFIER($SC_W) TO DATABASE ROLE IDENTIFIER($SC_C);

CREATE SCHEMA IF NOT EXISTS IDENTIFIER($TARGET_SCHEMA_NAME) WITH MANAGED ACCESS;
-- USE SCHEMA INFORMATION_SCHEMA;
-- DROP SCHEMA IF EXISTS PUBLIC;
GRANT OWNERSHIP ON IDENTIFIER($TARGET_SCHEMA_NAME) TO ROLE IDENTIFIER($DEPLOY_ROLE);

USE SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE);
-- SCHEMA
-- SC_M
GRANT USAGE ON DATABASE IDENTIFIER($TARGET_DB_NAME) TO DATABASE ROLE IDENTIFIER($SC_M);
GRANT USAGE ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
-- SC_R
GRANT MONITOR ON DATABASE IDENTIFIER($TARGET_DB_NAME) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT MONITOR ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
-- SC_W
-- None
-- SC_C
GRANT MODIFY, APPLYBUDGET, ADD SEARCH OPTIMIZATION ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);

-- TABLES
-- SC_M
GRANT REFERENCES ON ALL TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
GRANT REFERENCES ON FUTURE TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
-- SC_R
GRANT SELECT ON ALL TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT SELECT ON FUTURE TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
-- SC_W
GRANT INSERT, UPDATE, DELETE, TRUNCATE, EVOLVE SCHEMA ON ALL TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_W);
GRANT INSERT, UPDATE, DELETE, TRUNCATE, EVOLVE SCHEMA ON FUTURE TABLES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_W);
-- SC_C
GRANT CREATE TABLE ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);

-- STAGES
-- SC_M
GRANT USAGE ON ALL STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
GRANT USAGE ON FUTURE STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
-- SC_R
GRANT READ ON ALL STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT READ ON FUTURE STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
-- SC_W
GRANT READ,WRITE ON ALL STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_W);
GRANT READ,WRITE ON FUTURE STAGES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_W);
-- SC_C
GRANT CREATE STAGE ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);


-- FILE FORMATS
-- SC_M
GRANT USAGE ON ALL FILE FORMATS IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
GRANT USAGE ON FUTURE FILE FORMATS IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_M);
-- SC_R
-- N/A
-- SC_W
-- N/A
-- SC_C
GRANT CREATE FILE FORMAT ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);

-- STORED PROCEDURES
-- SC_M
-- N/A
-- SC_R
GRANT USAGE ON ALL PROCEDURES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
-- SC_W
-- SC_C
GRANT CREATE PROCEDURE ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);

-- FUNCTIONS
-- SC_M
-- N/A
-- SC_R
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_R);
-- SC_W
-- SC_C
GRANT CREATE FUNCTION ON SCHEMA IDENTIFIER($SCHEMACHANGE_NAMESPACE) TO DATABASE ROLE IDENTIFIER($SC_C);
