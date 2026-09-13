-- .read ddl_dml.sql
USE data_jobs;

DROP DATABASE IF EXISTS jobs_mart;
CREATE DATABASE IF NOT EXISTS jobs_mart;
USE jobs_mart;


DROP SCHEMA IF EXISTS staging;
CREATE SCHEMA IF NOT EXISTS staging;
SELECT * FROM information_schema.schemata;


DROP TABLE IF EXISTS preferred_roles;

-- SHOW DATABASES;

CREATE TABLE IF NOT EXISTS preferred_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);
CREATE TABLE staging.preferred_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

SHOW TABLES;

SELECT * FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

INSERT INTO preferred_roles
VALUES 
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer');

SELECT * FROM preferred_roles;

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

-- ALTER TABLE preferred_roles
-- DROP COLUMN preferred_role;

UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id = 1 OR role_id = 2;

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

SELECT * FROM priority_roles;

ALTER TABLE priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

ALTER TABLE priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

SELECT * FROM priority_roles;

