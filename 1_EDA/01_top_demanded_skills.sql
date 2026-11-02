/* Question: What are the most in-demand skills for data engineers?
 - Identify the top 10 in-demand skills for data engineers
 - Focus on remote job postings
 - Why? Retrieves the top 10 skills with the highest demand in the remote job market,
        providing insights into the most valuable skills for data engineers seeking remote work
*/

SHOW TABLES;

DESCRIBE job_postings_fact;

SELECT
    schema_name,
    table_name,
    constraint_type,
    constraint_column_names AS columns,
    constraint_text
FROM duckdb_constraints()
WHERE database_name = 'data_jobs'
ORDER BY schema_name, table_name, constraint_type;



SELECT
    schema_name,
    table_name AS child_table,
    constraint_column_names AS child_columns,
    referenced_table AS parent_table,
    referenced_column_names AS parent_columns
FROM duckdb_constraints()
WHERE database_name = 'data_jobs'
  AND constraint_type = 'FOREIGN KEY'
ORDER BY schema_name, table_name;


DESCRIBE skills_job_dim;
DESCRIBE skills_dim;


SELECT 
    sd.skills,
    COUNT(jpf.*) AS demand_count
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = True
GROUP BY 
    sd.skills
ORDER BY 
    demand_count DESC
LIMIT 10;

/*
 - SQL and Python remain the foundational skills for data engineers.
 - Cloud platforms (AWS, Azure) are cirtical for modern data engineering.
 - Big data tools like Spark continue to be highly valued.
 - Data pipeline tools (Airflow, Snowflake, Databricks) show growing demand.
 - Java and GCP round out the top 10 most requested skills.
 
┌────────────┬──────────────┐
│   skills   │ demand_count │
│  varchar   │    int64     │
├────────────┼──────────────┤
│ sql        │        29221 │
│ python     │        28776 │
│ aws        │        17823 │
│ azure      │        14143 │
│ spark      │        12799 │
│ airflow    │         9996 │
│ snowflake  │         8639 │
│ databricks │         8183 │
│ java       │         7267 │
│ gcp        │         6446 │
└────────────┴──────────────┘
  10 rows         2 columns
*/



