# HEADING 1

## HEADING 2

### HEADING 3

**Bold text**  
*Italics text*  
`This is code`

1. number 1
2. number 2

[Link Text](https://google.com)  


![Dr.Doom](../Images\76347_alt7.webp)





```sql
SELECT 
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
    COUNT(jpf.salary_year_avg) AS demand_count,
    ROUND(LN(COUNT(jpf.*)),1) AS ln_demand_count,
    ROUND(MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*))/1_000_000,2) AS optimal_score
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = True
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY 
    sd.skills
HAVING 
    COUNT(jpf.*) > 100
ORDER BY 
    optimal_score DESC
LIMIT 20;
```


markdownguide.org/cheat-sheet



# Exploratory Data Analysis w/SQL: Job Market Analysis

![Project 1 Overview](../Images/1_1_Project1_EDA.png)


If you only have a minute, review these:

[01_top_demanded_skills.sql](/1_EDA/01_top_demanded_skills.sql)

[02_top_paying_skills.sql](/1_EDA/02_top_paying_skills.sql)

[03_optimal_skills.sql](/1_EDA/03_optimal_skills.sql)




## Executive Summary


## Problem & Context
Job market analysts need to answer questions like:  

- **Most in-demand:** *Which skills are most in-demand for data engineers?*

- **Highest paid:** *Which skills command the highest salaries?*

- **Best trade-off:** *What is the optimal skill set balancing demand and compensation?*

This project analyses a **data warehouse** built using a star schema design. The warehouse structure consists of:

![Data Warehouse](/Images/1_2_Data_Warehouse.png)



## Tech Stack


