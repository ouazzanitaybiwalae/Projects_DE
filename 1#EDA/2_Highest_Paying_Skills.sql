/*
What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
Why?
Helps identify which skills command the highest compensation while
also showing how common those skills are, providing a more complete picture for skill development priorities.
The median is used instead of the average to reduce the impact of outlier salaries.
*/

SELECT 
    sd.skills Skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) Median_salary,
    COUNT(jpf.*) Frequency_skills
FROM 
    job_postings_fact jpf 
INNER JOIN
    skills_job_dim sjd 
ON jpf.job_id = sjd.job_id
INNER JOIN
    skills_dim sd 
ON sd.skill_id = sjd.skill_id
WHERE jpf.job_title_short = 'Data Engineer'
AND jpf.job_work_from_home = TRUE
GROUP BY Skills
HAVING Frequency_skills > 100
ORDER BY Median_salary DESC
LIMIT 25;


/*
* Rust has the highest median salary at **$210K**, despite appearing in only **232 job postings**, suggesting a high-value but relatively specialized skill.
* Golang and Terraform\ both have a median salary of **$184K**, but Terraform is much more frequently requested (**3,248 vs. 912**).
* Terraform stands out as a strong combination of **high salary and high demand**, making it particularly valuable in the job market.
* Spring ranks fourth with a median salary of **$175.5K**, indicating strong demand for enterprise Java development skills.
* **Neo4j** has a high median salary (**$170K**) but relatively low frequency (**277**), suggesting that graph database expertise is more specialized.
* **GDPR** also shows a high median salary (**$169.6K**) with moderate frequency (**582**), highlighting the value of data privacy and compliance skills.
* **GraphQL** and **MongoDB** offer relatively high salaries (**$167.5K** and **$162.25K**) with moderate demand.
* **FastAPI** has the lowest median salary among the top 10 (**$157.5K**) but remains a valuable modern Python backend skill.
* Overall, the results suggest that **cloud/infrastructure skills such as Terraform** can combine **high compensation with substantial demand**, while skills like **Rust and Neo4j** appear more specialized.
┌────────────┬───────────────┬──────────────────┐
│   Skills   │ Median_salary │ Frequency_skills │
│  varchar   │    double     │      int64       │
├────────────┼───────────────┼──────────────────┤
│ rust       │      210000.0 │              232 │
│ terraform  │      184000.0 │             3248 │
│ golang     │      184000.0 │              912 │
│ spring     │      175500.0 │              364 │
│ neo4j      │      170000.0 │              277 │
│ gdpr       │      169616.0 │              582 │
│ zoom       │      168438.0 │              127 │
│ graphql    │      167500.0 │              445 │
│ mongo      │      162250.0 │              265 │
│ fastapi    │      157500.0 │              204 │
│ django     │      155000.0 │              265 │
│ bitbucket  │      155000.0 │              478 │
│ crystal    │      154224.0 │              129 │
│ c          │      151500.0 │              444 │
│ atlassian  │      151500.0 │              249 │
│ typescript │      151000.0 │              388 │
│ kubernetes │      150500.0 │             4202 │
│ ruby       │      150000.0 │              736 │
│ node       │      150000.0 │              179 │
│ css        │      150000.0 │              262 │
│ airflow    │      150000.0 │             9996 │
│ redis      │      149000.0 │              605 │
│ vmware     │      148798.0 │              136 │
│ ansible    │      148798.0 │              475 │
│ jupyter    │      147500.0 │              400 │
└────────────┴───────────────┴──────────────────┘
*/