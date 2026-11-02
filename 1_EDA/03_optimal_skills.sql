/* Most Optimal Skills
Question: What are the most optimal skills for data engineers-balancing both demand 
and salary?
 - Create a ranking column that combines demand count and median salary to identify
 the most valuable skills.
 - Focus only on remote Data Engineer positions with specified annual salaries.
 - Why?
    - This approach highlights skills that balance market demand and financial
    reward. It weighs core skills appropriately, rather than letting rare, outlier 
    skills distort the results.

*/

SELECT *
FROM skills_dim
LIMIT 10;

SELECT 
    jpf.job_id,
    sd.skills,
    jpf.salary_year_avg
    
FROM 
    job_postings_fact AS jpf
WHERE  
    salary_year_avg IS NOT NULL
INNER JOIN 
    skills_job_dim AS sjd
ON  
    jpf.job_id = sjd.job_id
INNER JOIN
    skills_dim AS sd
ON  
    sjd.skill_id = sd.skill_id
GROUP BY
    sd.skills
LIMIT(10);




SELECT
    COUNT(*) AS demand_all,
    COUNT(salary_year_avg) AS salaries_present,
    COUNT(*) - COUNT(salary_year_avg) AS salaries_missing
FROM job_postings_fact;



SELECT *
FROM job_postings_fact
LIMIT 10;
.last;


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









/*

SYNTAX EXPLANATION

The trick is to understand what SQL is doing to the data at each stage, rather than trying to understand the entire query as one block.

I'll break it down using simple examples based on your data engineering job-postings dataset.

## 1. First, understand what you're trying to achieve

Your query is essentially asking:

> "Among remote Data Engineer jobs that disclose salaries, which technical skills provide the best combination of job demand and median salary?"

To answer this, SQL needs to:

1. Find the relevant job postings.
2. Identify which skills each job requires.
3. Group the jobs by skill.
4. Calculate demand and median salary for each skill.
5. Calculate a score combining salary and demand.
6. Rank the skills from highest to lowest.

That's all your query does.

## 2. Understand the three tables you're joining

Before doing any calculations, SQL needs to connect information from three tables.

Table 1: `job_postings_fact` (jpf)

Contains information about each job vacancy.

| job_id | job_title_short | salary_year_avg |
| ------ | --------------- | --------------- |
| 101    | Data Engineer   | 130,000         |
| 102    | Data Engineer   | 150,000         |
| 103    | Data Analyst    | 90,000          |

Connected through `job_id`

Table 2: `skills_job_dim` (sjd)

Connects jobs to the skills they require.

| job_id | skill_id |
| ------ | -------- |
| 101    | 1        |
| 101    | 2        |
| 102    | 1        |
| 102    | 3        |

Connected through `skill_id`

Table 3: `skills_dim` (sd)

Contains the actual skill names.

| skill_id | skills |
| -------- | ------ |
| 1        | Python |
| 2        | SQL    |
| 3        | AWS    |

Notice that `skills_job_dim` doesn't contain skill names. It only connects job IDs to skill IDs.

That's why you need all three tables.

## 3. The FROM and INNER JOIN statements

```
FROM job_postings_fact AS jpf

INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id

INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
```

Read this in plain English:

- `FROM job_postings_fact AS jpf`: Start with the job postings table. Call it `jpf` for short.
- `INNER JOIN skills_job_dim AS sjd`: Connect each job to its required skills, matching on `job_id`.
- `INNER JOIN skills_dim AS sd`: Retrieve the actual skill names, matching on `skill_id`.

After joining, imagine SQL has produced this:

| job_id | skills | salary_year_avg |
| ------ | ------ | --------------- |
| 101    | Python | 130,000         |
| 101    | SQL    | 130,000         |
| 102    | Python | 150,000         |
| 102    | AWS    | 150,000         |

Important: Job 101 now appears twice because it requires two skills.

That is expected. Each row represents a job-skill combination, rather than a unique vacancy.

## 4. The WHERE clause: Filtering the records

```
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = True
    AND jpf.salary_year_avg IS NOT NULL
```

SQL retains only records satisfying all three conditions.

| Condition                           | Meaning                          |
| ----------------------------------- | -------------------------------- |
| `job_title_short = 'Data Engineer'` | Only Data Engineer positions     |
| `job_work_from_home = True`         | Only remote positions            |
| `salary_year_avg IS NOT NULL`       | Only jobs with recorded salaries |

Why `IS NOT NULL`?

`NULL` means the salary value is missing. You're excluding jobs without salaries because you need salary information to calculate medians.

## 5. GROUP BY: The most important concept

```
GROUP BY
    sd.skills
```

This is where your query starts summarising the data.

Before grouping:

| skills | salary  |
| ------ | ------- |
| Python | 130,000 |
| SQL    | 130,000 |
| Python | 150,000 |
| AWS    | 150,000 |
| Python | 140,000 |

After grouping, SQL conceptually organises the rows into groups:

Python

3 jobs

130,000

150,000

140,000

SQL

1 job

130,000

AWS

1 job

150,000

Now SQL can calculate things within each skill group.

This is what makes `MEDIAN()` and `COUNT()` useful here.

Without `GROUP BY`, you would calculate overall statistics across all the joined records rather than separate results for Python, SQL, AWS, and so on.

## 6. Understanding each calculation in SELECT

Let's tackle your `SELECT` statement one expression at a time.

### A. `sd.skills`

```
SELECT
    sd.skills,
```

Simply displays the skill name associated with each group.

### B. Median salary

```
ROUND(MEDIAN(jpf.salary_year_avg), 0)
    AS median_salary
```

Read the expression from the inside outward.

`salary_year_avg`

`MEDIAN()`

`ROUND(..., 0)`

Get salaries → calculate the middle value → round to zero decimal places.

For example, Python salaries:

`130,000`, `140,000`, `150,000`

The median is 140,000.

`AS median_salary` simply names the output column.

### C. Demand count

```
COUNT(jpf.salary_year_avg) AS demand_count
```

Counts how many non-NULL salary values exist for each skill.

For example:

- Python: 3
- SQL: 1
- AWS: 1

Because your `WHERE` clause has already removed jobs with missing salaries, this count represents the number of qualifying job-skill records.

It is not the total number of advertised vacancies across the whole market.

### D. Natural logarithm of demand

```
ROUND(LN(COUNT(jpf.*)), 1)
    AS ln_demand_count
```

This is probably the most unfamiliar part of the query.

Let's unpack the nesting:

```
COUNT(jpf.*)
```

Counts qualifying rows belonging to each skill.

```
LN(COUNT(jpf.*))
```

Takes the natural logarithm of that count.

```
ROUND(LN(COUNT(jpf.*)), 1)
```

Rounds the logarithm to one decimal place.

But why are you using `LN()`?

The natural logarithm compresses large numbers, so differences in demand don't overpower the salary component of your score.

See how the logarithm compresses demand:

0369105101,0101,5102000

Illustrative values; logarithms rounded to two decimals.

Notice something interesting: increasing demand from 100 to 1,000 postings means a 10-fold increase in jobs, but `LN()` rises only from 4.61 to 6.91.

This reduces the influence of exceptionally common skills.

### E. The optimal score

```
ROUND(
    MEDIAN(jpf.salary_year_avg)
    * LN(COUNT(jpf.*))
    / 1_000_000,
    2
) AS optimal_score
```

This combines everything you've calculated.

Your mathematical formula is:

\\[ \text{Score}=\frac{\text{Median Salary}\times\ln(\text{Demand})}{1,000,000} \\]

Using Python from your actual results:

Interactive score calculator

Try changing values

Median annual salary

135,000

Job postings

1,133

LN(Demand)

## 7.03

Optimal score

## 0.95

135,000 × LN(1,133) ÷ 1,000,000 = 0.95

Reset to Python values

The division by `1_000_000` only scales the score down to a convenient number. It doesn't change the ranking.

Remember: `0.95` is a relative index score, not 95% employability or a probability of getting hired.

## 7. HAVING: Filtering groups rather than individual rows

```
HAVING
    COUNT(jpf.*) > 100
```

You've already grouped the jobs by skill.

Now you're telling SQL:

> "Only keep skills appearing in more than 100 qualifying job-skill records."

This is different from `WHERE`.

| WHERE                      | HAVING                                   |
| -------------------------- | ---------------------------------------- |
| Filters individual records | Filters groups of records                |
| Applied before grouping    | Applied after grouping                   |
| Example: only remote jobs  | Example: skills appearing over 100 times |

A useful way to remember:

WHERE filters rows. HAVING filters groups.

## 8. ORDER BY and LIMIT

```
ORDER BY optimal_score DESC
LIMIT 20;
```

`ORDER BY optimal_score DESC` sorts the results from highest score to lowest.

`LIMIT 20` returns only the first 20 rows from those sorted results.

In other words, you get the top 20 skills by your calculated score.

## 9. Put everything together in the correct logical order

Even though SQL is written with `SELECT` at the top, the easiest way to understand it is through its logical processing order.

1

FROM

Start with the job-postings table.

2

JOIN

Connect each job to its skill names.

3

WHERE

Keep remote Data Engineer jobs with salaries.

4

GROUP BY

Organise records into individual skill groups.

5

HAVING

Discard groups containing 100 or fewer records.

6

SELECT

Calculate each skill’s salary, demand and score.

7

ORDER BY

Rank groups from highest to lowest score.

8

LIMIT

Return only the top 20.

This is the logical query-processing order, rather than a literal description of every database engine's physical execution plan.

## 10. How to build this query without getting overwhelmed

A useful way to develop complex SQL is to build it progressively.

Build the query one stage at a time

1\. Start with the joined data

2\. Add your job filters

3\. Group and calculate basic statistics

4\. Add your score and ranking

Start with the joined data

&#x20;Copy

SELECT\
&#x20;   sd.skills,\
&#x20;   jpf.salary_year_avg\
FROM job_postings_fact AS jpf\
INNER JOIN skills_job_dim AS sjd\
&#x20;   ON jpf.job_id = sjd.job_id\
INNER JOIN skills_dim AS sd\
&#x20;   ON sjd.skill_id = sd.skill_id;

One small improvement I've made here is using `COUNT(*)` instead of `COUNT(jpf.*)` for counting rows. It's clearer and widely supported. With your current salary filter, `COUNT(*)` and `COUNT(jpf.salary_year_avg)` should give the same counts, assuming each job-skill pairing appears once.

## The one concept I want you to remember

Most of your query becomes much easier once you understand the relationship between rows, groups and aggregates.

- Rows represent individual job-skill combinations.
- Groups collect all the records for each skill.
- Aggregates such as `COUNT()` and `MEDIAN()` calculate statistics within those groups.

Everything else is about deciding which records qualify, how to score each group and how to display the results.

### Quick understanding check

Suppose Python appears in 150 job postings and SQL appears in 80. Which clause removes SQL because it has fewer than 101 postings?

`WHERE COUNT(*) > 100`

`HAVING COUNT(*) > 100`

`GROUP BY sd.skills`

Correct. HAVING filters groups after the aggregate count has been calculated.

Once you can explain why `GROUP BY` comes before `HAVING` in the logical process, you've grasped one of the most important concepts behind analytical SQL queries.



 ## EXECUTIVE SUMMARY

┌────────────┬───────────────┬──────────────┬─────────────────┬──────────────────┐
│   skills   │ median_salary │ demand_count │ ln_demand_count │optimal_score│
│  varchar   │    double     │    int64     │     double      │      double      │
├────────────┼───────────────┼──────────────┼─────────────────┼──────────────────┤
│ terraform  │      184000.0 │          193 │             5.3 │             0.97 │
│ python     │      135000.0 │         1133 │             7.0 │             0.95 │
│ sql        │      130000.0 │         1128 │             7.0 │             0.91 │
│ aws        │      137320.0 │          783 │             6.7 │             0.91 │
│ airflow    │      150000.0 │          386 │             6.0 │             0.89 │
│ spark      │      140000.0 │          503 │             6.2 │             0.87 │
│ snowflake  │      135500.0 │          438 │             6.1 │             0.82 │
│ kafka      │      145000.0 │          292 │             5.7 │             0.82 │
│ azure      │      128000.0 │          475 │             6.2 │             0.79 │
│ java       │      135000.0 │          303 │             5.7 │             0.77 │
│ scala      │      137290.0 │          247 │             5.5 │             0.76 │
│ kubernetes │      150500.0 │          147 │             5.0 │             0.75 │
│ git        │      140000.0 │          208 │             5.3 │             0.75 │
│ databricks │      132750.0 │          266 │             5.6 │             0.74 │
│ redshift   │      130000.0 │          274 │             5.6 │             0.73 │
│ gcp        │      136000.0 │          196 │             5.3 │             0.72 │
│ nosql      │      134415.0 │          193 │             5.3 │             0.71 │
│ hadoop     │      135000.0 │          198 │             5.3 │             0.71 │
│ pyspark    │      140000.0 │          152 │             5.0 │              0.7 │
│ mongodb    │      135750.0 │          136 │             4.9 │             0.67 │
└────────────┴───────────────┴──────────────┴─────────────────┴──────────────────┘
  20 rows                                                              5 columns


# Data Engineering Skills: Demand, Salary and Industry Trends — 2026

Analysis of remote data engineering job postings, supported by current industry research as of November 2026.

## Key Findings and Analysis

1\. Python and SQL dominate market demand

- Python (1,133 postings) and SQL (1,128 postings) have the highest demand, with median salaries of 135,000 and 130,000, respectively.
- Both considerably outperform most specialised technologies in job availability.
- An October 2026 US job-market study independently identified SQL in 74.1% and Python in 72.2% of its analysed job descriptions.&#x20;

  [image](https://www.google.com/s2/favicons?domain=https://apiva.ai\&sz=32)

  Apiva



Insight: Python and SQL provide the strongest combination of broad employment opportunities and competitive compensation.

2\. Cloud computing remains a major requirement

- AWS leads with 783 postings and a median salary of 137,320.
- Azure follows with 475 postings (128,000), while GCP records 196 postings (136,000).
- AWS demonstrates approximately 65% higher demand than Azure and four times GCP's demand within the dataset.

Insight: AWS offers the strongest demand-salary balance among cloud platforms in the sample, although cloud preferences vary by employer and region.

3\. Data processing and orchestration command competitive salaries

| Technology     | Job postings | Median salary |
| -------------- | ------------ | ------------- |
| Apache Spark   | 503          | 140,000       |
| Snowflake      | 438          | 135,500       |
| Apache Airflow | 386          | 150,000       |
| Apache Kafka   | 292          | 145,000       |
| Databricks     | 266          | 132,750       |

- Spark leads this group in demand, reflecting the importance of distributed data processing.
- Airflow commands a higher median salary, demonstrating the market value associated with workflow orchestration.
- Current job-posting evidence also identifies ETL, data modelling, Snowflake, dbt and Airflow among commonly requested capabilities.&#x20;

  [image](https://www.google.com/s2/favicons?domain=https://apiva.ai\&sz=32)

  Apiva



Insight: Market value extends beyond programming into building, operating and maintaining reliable data pipelines.

4\. Terraform leads in salary, but not demand

- Terraform records the highest median salary (184,000) and combined index score (0.97), despite appearing in only 193 postings.
- Python follows closely in the index at 0.95, despite having nearly six times Terraform's posting count.
- Kubernetes also commands a relatively high median salary of 150,500, but appears in only 147 postings.

Insight: Infrastructure automation is associated with higher-paying, more specialised positions. However, the scoring formula compresses demand differences, and higher salaries cannot be attributed to individual skills without accounting for seniority and other factors.

5\. AI is reshaping data engineering priorities

The 2026 State of Analytics Engineering Report highlights several developments:

# 72%

Prioritise AI-assisted coding

# 83%

Prioritise trust in data and data teams

# 71%

Concerned about incorrect AI-generated data

Source: dbt Labs, 2026 State of Analytics Engineering Report. Survey findings, not job-posting percentages.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.getdbt.com\&sz=32)

dbt Labs

Insight: AI is accelerating code development, increasing the importance of data quality, governance, validation and production reliability.

6\. Salary premiums increasingly require broader technical responsibility

- Current postings combine programming with data modelling, cloud infrastructure, orchestration, testing and deployment.

- In an October 2026 US sample, only 5.5% of 1,698 data engineering vacancies were classified as entry-level or internship opportunities.&#x20;

  [image](https://www.google.com/s2/favicons?domain=https://apiva.ai\&sz=32)

  Apiva

- This suggests that experience and responsibility are important considerations when interpreting the higher salaries associated with specialised skills.

Insight: Combining complementary technical capabilities appears more valuable than focusing exclusively on individual technologies.

## Limitations of the Analysis

The original dataset includes only remote data engineering positions with disclosed salaries. Its date range, geographic coverage and salary currency are not established. Job postings can mention several skills simultaneously, while the logarithmic scoring method reduces the influence of demand. Consequently, the rankings describe associations within the sample rather than salary causation or changes in demand over time.

## Conclusion

The analysis establishes Python and SQL as the strongest foundational data engineering skills, offering the broadest demand alongside competitive compensation. AWS leads cloud-platform demand in the analysed sample, while Spark, Airflow, Snowflake and Kafka represent important capabilities within modern data infrastructure.

Terraform and Kubernetes are associated with higher compensation but comparatively fewer opportunities, indicating the value of specialised infrastructure expertise.

Current industry evidence also highlights a shift towards AI-assisted development, automated data pipelines, data quality and governance.

Overall, the most compelling skill combination is Python, SQL, cloud computing, data processing, orchestration and infrastructure automation. The strongest market positioning is likely to come from integrating these capabilities to deliver scalable, reliable and production-ready data systems, rather than pursuing high-paying technologies in isolation.



