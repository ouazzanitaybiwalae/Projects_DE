/*
Question: What are the most optimal skills for data engineers — balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
Why?
This approach highlights skills that balance market demand and financial reward. 
It weights core skills appropriately, rather than letting rare, 
outlier skills distort the results.
*/

SELECT
    sd.skills Skills,
    -- COUNT(jpf.*) demand_count,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) Median_salary,
    ROUND(LN(COUNT(jpf.*)), 1) ln_demand_count,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(sd.*)))/1_000_000, 2) Optimal_score
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
AND jpf.salary_year_avg IS NOT NULL
GROUP BY Skills
HAVING COUNT(jpf.*) > 100
ORDER BY Optimal_score DESC
LIMIT 25;

/*
- Terraform has the highest optimal score (0.97), combining high salary and good demand.
- Python and SQL score highly because of their very strong demand, despite lower median salaries.
- AWS (0.91) ranks higher than Azure (0.79) in this dataset.
- Airflow, Spark, Snowflake, and Kafka show strong potential for data engineering careers.
- The results show that high demand can compensate for a lower salary when calculating the overall score.
┌────────────┬───────────────┬─────────────────┬───────────────┐
│   Skills   │ Median_salary │ ln_demand_count │ Optimal_score │
│  varchar   │    double     │     double      │    double     │
├────────────┼───────────────┼─────────────────┼───────────────┤
│ terraform  │      184000.0 │             5.3 │          0.97 │
│ python     │      135000.0 │             7.0 │          0.95 │
│ sql        │      130000.0 │             7.0 │          0.91 │
│ aws        │      137320.0 │             6.7 │          0.91 │
│ airflow    │      150000.0 │             6.0 │          0.89 │
│ spark      │      140000.0 │             6.2 │          0.87 │
│ snowflake  │      135500.0 │             6.1 │          0.82 │
│ kafka      │      145000.0 │             5.7 │          0.82 │
│ azure      │      128000.0 │             6.2 │          0.79 │
│ java       │      135000.0 │             5.7 │          0.77 │
│ scala      │      137290.0 │             5.5 │          0.76 │
│ git        │      140000.0 │             5.3 │          0.75 │
│ kubernetes │      150500.0 │             5.0 │          0.75 │
│ databricks │      132750.0 │             5.6 │          0.74 │
│ redshift   │      130000.0 │             5.6 │          0.73 │
│ gcp        │      136000.0 │             5.3 │          0.72 │
│ hadoop     │      135000.0 │             5.3 │          0.71 │
│ nosql      │      134415.0 │             5.3 │          0.71 │
│ pyspark    │      140000.0 │             5.0 │           0.7 │
│ mongodb    │      135750.0 │             4.9 │          0.67 │
│ docker     │      135000.0 │             5.0 │          0.67 │
│ go         │      140000.0 │             4.7 │          0.66 │
│ r          │      134775.0 │             4.9 │          0.66 │
│ github     │      135000.0 │             4.8 │          0.65 │
│ bigquery   │      135000.0 │             4.8 │          0.65 │
└────────────┴───────────────┴─────────────────┴───────────────┘
*/