DESCRIBE
SELECT
    jpf.*,
    cd.*
FROM job_postings_fact jpf
LEFT JOIN company_dim cd
    ON jpf.company_id = cd.company_id
LIMIT 10;

-- CTAS
CREATE TABLE jobs_mart.staging.job_postings_flat AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_location,
    jpf.job_country,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    jpf.salary_rate,
    jpf.job_posted_date,
    jpf.job_work_from_home,
    cd.name AS Company_Name
FROM data_jobs.main.job_postings_fact jpf
LEFT JOIN data_jobs.main.company_dim cd
    ON jpf.company_id = cd.company_id;

SELECT * FROM jobs_mart.staging.job_postings_flat;
SELECT COUNT(*) FROM jobs_mart.staging.job_postings_flat;
DROP TABLE jobs_mart.staging.job_postings_flat;
-- View
CREATE OR REPLACE VIEW jobs_mart.staging.priority_jobs_flat_view AS
SELECT 
    jpf.*
FROM jobs_mart.staging.job_postings_flat jpf
JOIN jobs_mart.main.priority_roles r
    ON jpf.job_title_short = r.role_name
WHERE r.role_id = 1;

SELECT COUNT(*) FROM jobs_mart.staging.priority_jobs_flat_view;

-- SELECT table_catalog, table_schema, table_name
-- FROM information_schema.tables
-- WHERE table_name IN ('priority_roles', 'job_postings_flat');
DELETE FROM jobs_mart.staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

SELECT COUNT(*) FROM jobs_mart.staging.job_postings_flat;

TRUNCATE TABLE jobs_mart.staging.job_postings_flat;

INSERT INTO jobs_mart.staging.job_postings_flat
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_location,
    jpf.job_country,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    jpf.salary_rate,
    jpf.job_posted_date,
    jpf.job_work_from_home,
    cd.name AS Company_Name
FROM data_jobs.main.job_postings_fact jpf
LEFT JOIN data_jobs.main.company_dim cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_posted_date >= '2024-01-01';

SELECT COUNT(*) FROM jobs_mart.staging.job_postings_flat;
SELECT COUNT(*) FROM jobs_mart.staging.priority_jobs_flat_view;
