--
DROP SCHEMA IF EXISTS skills_mart CASCADE;
CREATE SCHEMA skills_mart;

CREATE TABLE skills_mart.dim_skill  (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

INSERT INTO skills_mart.dim_skill
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;

-- dim_date_month
-- SELECT DISTINCT
--     DATE_TRUNC('month', job_posted_date) AS month_start_date,
--     EXTRACT(YEAR FROM job_posted_date) AS year,
--     EXTRACT(MONTH FROM job_posted_date) AS month,
--     EXTRACT(QUARTER FROM job_posted_date) AS quarter,
--     'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS name_quarter,
--     EXTRACT(YEAR FROM job_posted_date)::VARCHAR || 'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS name_year_quarter
-- FROM job_postings_fact
-- ORDER BY month_start_date;

CREATE TABLE skills_mart.dim_date_month (
    month_start_date TIMESTAMP PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    name_quarter VARCHAR,
    name_year_quarter VARCHAR
);

INSERT INTO skills_mart.dim_date_month
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS name_quarter,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || 'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS name_year_quarter
FROM job_postings_fact
ORDER BY month_start_date;

-- fact_skill_demand_monthly
CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date TIMESTAMP,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);


INSERT INTO skills_mart.fact_skill_demand_monthly
WITH job_postings_prep AS (
SELECT 
    sjd.skill_id skill_id,
    DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
    jpf.job_title_short job_title_short,

    CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree
FROM
job_postings_fact as jpf 
INNER JOIN 
skills_job_dim as sjd 
ON jpf.job_id = sjd.job_id
)
SELECT 
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) postings_count,
    SUM(is_remote) remote_postings_count,
    SUM(has_health_insurance) health_insurance_postings_count,
    SUM(no_degree) no_degree_postings_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;

-- data validation
SELECT 'dim_skill' as name_table, COUNT(*) AS record_count FROM skills_mart.dim_skill
UNION ALL
SELECT 'dim_date_month', COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'fact_skill_demand_monthly', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;
--
SELECT '--- dim_skill sample ---' AS info;
SELECT * FROM skills_mart.dim_skill LIMIT 5;

SELECT '--- dim_date_month sample ---' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '--- fact_skill_demand_monthly sample ---' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;