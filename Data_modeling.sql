SELECT
    job_id,
    job_title_short,
    job_location
FROM job_postings_fact
LIMIT 10;

Select * from skills_dim limit 5;

SELECT * FROM job_postings_fact LIMIT 5;

SELECT * FROM company_dim LIMIT 5;

SELECT 
    J.job_title_short,
    J.salary_year_avg,
    J.job_title,
    C.name AS Company_Name,
FROM 
    job_postings_fact AS J 
LEFT JOIN 
    company_dim AS C
ON
J.company_id = C.company_id;