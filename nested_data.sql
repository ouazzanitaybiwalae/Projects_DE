-- ARRAY
WITH skills AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
skills_array AS (
    SELECT ARRAY_AGG(skill) AS skills
    FROM skills
)
SELECT
    skills
FROM skills_array;
----
WITH skills AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
)
SELECT ARRAY_AGG(skill) AS skills_array
FROM skills;


----
WITH skills AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT
    skills[1] AS first_value,
    skills[2] AS second_value,
    skills[3] AS third_value,
FROM skills_array;

-- STRUCT
SELECT {skill : 'Python', type : 'programming'};
SELECT
    STRUCT_PACK(
        skill := 'Python',
        type := 'programming'
    ) AS S;

WITH struct AS(
SELECT
    STRUCT_PACK(
        skill := 'Python',
        type := 'programming'
    ) AS S
)
SELECT
    S.skill,
    S.TYPE
FROM struct;
--
WITH skills_t AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query language'
    UNION ALL
    SELECT 'r', 'programming'
) 
SELECT
    STRUCT_PACK(
        skill := skills,
        type := types
    )
FROM skills_t;

-- ARRAY OF STRUCTS
SELECT [
    {skill : 'python', type : 'programming'},
    {skill : 'sql', type : 'query language'}
] AS skills;
--
WITH skills_t AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query language'
    UNION ALL
    SELECT 'r', 'programming'
) 
SELECT
    ARRAY_AGG(
        STRUCT_PACK(
            skill := skills,
            type := types
        )
    )
FROM skills_t;
--
WITH skills_t AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        )
    FROM skills_t
)
SELECT *
FROM skills_array_struct;
--
WITH skills_t AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        ) array_struct
    FROM skills_t
)
SELECT
    array_struct[1]
FROM skills_array_struct;
--
WITH skills_t AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        ) array_struct
    FROM skills_t
)
SELECT
    array_struct[1].skill,
    array_struct[2].skill,
    array_struct[3].skill,
FROM skills_array_struct;

-- MAP
WITH skill_map AS (
    SELECT MAP {'skill': 'python', 'type' : 'programming'} AS skill_type
)
SELECT 
    skill_type['skill']
FROM skill_map;

-- JSON
SELECT
'{"skill":"python", "type":"programming"}'::JSON AS skill_json;

-- or
SELECT
    TO_JSON('{"skill":"python", "type":"programming"}') AS skill_json;

--
WITH raw_skill_json AS(
    SELECT
    '{"skill":"python", "type":"programming"}'::JSON AS skill_json
) 
SELECT
    STRUCT_PACK(
        skill := json_extract_string(skill_json ,'$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
    FROM raw_skill_json;

-- EXP 1: ARRAYS
-- Build a flat table skill for co-workers to access job titles, salary info, and skills in one table
-- SELECT
--     jpf.job_id,
--     jpf.job_title_short,
--     jpf.salary_year_avg,
--     sd.skills
-- FROM 
--     job_postings_fact jpf
-- LEFT JOIN skills_job_dim sjd 
-- ON jpf.job_id = sjd.job_id
-- LEFT JOIN skills_dim sd 
-- ON sd.skill_id = sjd.skill_id;
--
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM 
    job_postings_fact jpf
LEFT JOIN skills_job_dim sjd 
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd 
ON sd.skill_id = sjd.skill_id
GROUP BY ALL;
--
CREATE OR REPLACE TEMP TABLE job_skills_temp_tab AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM 
    job_postings_fact jpf
LEFT JOIN skills_job_dim sjd 
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd 
ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

-- Analyzing
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_array) AS skill
FROM job_skills_temp_tab
LIMIT 18;

--
WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM job_skills_temp_tab
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    skill,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_salary DESC
LIMIT 20;

-- EXP 2: ARRAY OF STRUCTS
CREATE OR REPLACE TEMP TABLE job_skills_SA_temp_tab AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) AS array_struct_skillType
FROM 
    job_postings_fact jpf
LEFT JOIN skills_job_dim sjd 
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd 
ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

-- analyzing
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(array_struct_skillType).skill_type AS type,
    UNNEST(array_struct_skillType).skill_name AS skill,
FROM job_skills_SA_temp_tab
LIMIT 20;

--
WITH skill_flat AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(array_struct_skillType).skill_type AS type,
        UNNEST(array_struct_skillType).skill_name AS skill,
    FROM job_skills_SA_temp_tab
)
SELECT 
    skill_type,
    MEDIAN(salary_year_avg)
FROM skill_flat;