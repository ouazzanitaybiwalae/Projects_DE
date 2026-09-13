--
DROP SCHEMA IF EXISTS flat_mart CASCADE;
CREATE SCHEMA flat_mart;

SELECT '--- Loading Flat table ---' AS info;

CREATE OR REPLACE TABLE flat_mart.job_postings AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,

    cd.company_id,
    cd.name as company_name,

    ARRAY_AGG(
        STRUCT_PACK(
            type := sd.type,
            name := sd.skills
        )
    ) AS skills_type
FROM
job_postings_fact jpf
LEFT JOIN company_dim cd 
ON jpf.company_id = cd.company_id
LEFT JOIN skills_job_dim sjd 
ON sjd.job_id = jpf.job_id
LEFT JOIN skills_dim sd 
ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

-- VALIDATION
SELECT 'Flat job postings table' AS Table_name, COUNT(*) AS record_count FROM flat_mart.job_postings;

SELECT '--- Flat table sample ---' AS info;
SELECT * FROM flat_mart.job_postings LIMIT 5;
