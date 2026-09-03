/*
What are the most in-demand skills for data engineers?
- Top 10
- Remote jobs
*/

SELECT 
    D1.skills skills,
    COUNT(F.*) Total_Job_Postings
FROM
    job_postings_fact F 
INNER JOIN 
    skills_job_dim D 
ON F.job_id =  D.job_id
INNER JOIN
    skills_dim D1
ON D.skill_id = D1.skill_id
WHERE F.job_work_from_home = TRUE
AND F.job_title_short = 'Data Engineer'
GROUP BY D1.skills
ORDER BY Total_Job_Postings DESC
LIMIT 10;

/*
┌────────────┬────────────────────┐
│   skills   │ Total_Job_Postings │
│  varchar   │       int64        │
├────────────┼────────────────────┤
│ sql        │              29221 │
│ python     │              28776 │
│ aws        │              17823 │
│ azure      │              14143 │
│ spark      │              12799 │
│ airflow    │               9996 │
│ snowflake  │               8639 │
│ databricks │               8183 │
│ java       │               7267 │
│ gcp        │               6446 │
└────────────┴────────────────────┘
*/