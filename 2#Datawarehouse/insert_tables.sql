
SELECT '--- company_dim table is being loaded ---' AS info;

INSERT INTO company_dim
SELECT company_id, name, link, link_google, thumbnail
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', AUTO_DETECT = TRUE);

SELECT '--- skills_dim table is being loaded ---' AS info;

INSERT INTO skills_dim
SELECT skill_id, skills, type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv', AUTO_DETECT = TRUE);

SELECT '--- job_postings_fact table is being loaded ---' AS info;

INSERT INTO job_postings_fact
SELECT 
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv', AUTO_DETECT = TRUE);

SELECT '--- skills_job_dim table is being loaded ---' AS info;

INSERT INTO skills_job_dim
SELECT job_id, skill_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', AUTO_DETECT = TRUE);

--
SELECT 'Company Dim' AS table_name, COUNT(*) AS record_count FROM company_dim
UNION ALL
SELECT 'Skills Dim', COUNT(*) FROM skills_dim
UNION ALL
SELECT 'Job Fact', COUNT(*) FROM job_postings_fact
UNION ALL
SELECT 'Skills Jobs Dim' ,COUNT(*) FROM skills_job_dim;

-- View the first rows
SELECT '--- Company Dim table Sample ---' as info;
SELECT * FROM company_dim LIMIT 5;

SELECT '--- Skills Dim table Sample ---' as info;
SELECT * FROM skills_dim LIMIT 5;

SELECT '--- Job postings fact table Sample ---' as info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '--- Skills job Dim table Sample ---' as info;
SELECT * FROM skills_job_dim LIMIT 5;

