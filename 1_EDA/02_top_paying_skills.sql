/* What are the highest-paying skills for data engineers?
 - Calculate the median salary for each skill srequired in data engineer positions
 - Focus on remote positions with specified salaries
 - Include skill frequency to identify both salary and demand
 - Why?
    - Helps identify which skills command the highest compensation while also 
    showing how common those skills are, providiing a more complete picture for 
    skill development priorities.
    - The median is used instead of the average to reduce the impact of outlier salaries.
*/

SELECT *
FROM job_postings_fact
LIMIT 10;

SELECT *
FROM skills_dim
LIMIT 15;

SELECT *
FROM skills_job_dim
LIMIT 15;

SHOW TABLES;


SELECT 
    sd.skills,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary,
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
HAVING 
    COUNT(jpf.*) > 100
ORDER BY 
    median_salary DESC
LIMIT 15;

/*

┌───────────┬───────────────┬──────────────┐
│  skills   │ median_salary │ demand_count │
│  varchar  │    double     │    int64     │
├───────────┼───────────────┼──────────────┤
│ rust      │      210000.0 │          232 │
│ terraform │      184000.0 │         3248 │
│ golang    │      184000.0 │          912 │
│ spring    │      175500.0 │          364 │
│ neo4j     │      170000.0 │          277 │
│ gdpr      │      169616.0 │          582 │
│ zoom      │      168438.0 │          127 │
│ graphql   │      167500.0 │          445 │
│ mongo     │      162250.0 │          265 │
│ fastapi   │      157500.0 │          204 │
└───────────┴───────────────┴──────────────┘


"Key Insights:"

The strongest insight is that high salary and broad job opportunity are different things. Rust leads on salary, but Terraform stands out for combining high pay with substantially more demand.

I attempted to check live sources, but web retrieval failed. I therefore can’t reliably verify developments as of 30 October 2026. Below is a comparison with established technology trends, with interpretations clearly distinguished from what your data proves.

1. Terraform looks stronger than Rust when you consider both salary and demand.
Skill	Median salary*	Demand count	Interpretation within your dataset
Rust	210,000	232	Highest salary, relatively small market
Terraform	184,000	3,248	Strong combination of salary and demand
Golang	184,000	912	Same salary as Terraform, fewer opportunities


Terraform appears 14 times as often as Rust, while its median salary is only about 12.4% lower.

This aligns with the importance of cloud infrastructure: companies need repeatable ways to provision and manage networks, compute, databases, permissions, and deployment environments. AI systems also require infrastructure, extending this need.

However, Terraform is generally part of a broader cloud, DevOps, or platform engineering role. The salary belongs to the whole job and its responsibilities—not to knowing Terraform alone.

2. Rust’s premium is consistent with specialised engineering roles.

Rust is associated with systems programming, performance-sensitive services, infrastructure, and memory safety. These areas can involve technically demanding work and experienced engineers.

That helps explain why Rust could show a higher salary alongside fewer listings. But your table cannot distinguish between:
- Employers paying a premium specifically for Rust.
- Rust appearing disproportionately in senior roles.
- Rust roles being concentrated in higher-paying locations or companies.
Its first-place ranking therefore does not establish that learning Rust produces the highest return for a beginner.

3. Go and Terraform fit the continuing importance of cloud platforms.

Go is widely associated with infrastructure tools, network services, and cloud backends. Terraform is used to define infrastructure as code. Their shared median of 184,000 is consistent with well-paid infrastructure work.

The distinction matters: Go is a programming language used to build software; Terraform is a tool used to provision infrastructure. They often belong to overlapping ecosystems, but they are not interchangeable career choices.

For data engineering, Terraform can complement cloud storage, warehouses, orchestration, and access management. Go is usually a more specialised addition.

4. FastAPI and GraphQL fit different developments in software.
Skill	Established connection	What the table does not prove
FastAPI	Python APIs, including serving models and exposing data services	That its salary is driven specifically by AI
GraphQL	Flexible APIs for querying application data	That it is replacing REST or SQL
Neo4j	Graph databases and relationship-heavy applications, including some AI retrieval systems	That graph databases are becoming a universal requirement


FastAPI has a natural connection to Python-based AI applications: a model or pipeline often needs an API through which another application can use it.

Neo4j also has a plausible connection to knowledge graphs and graph-assisted retrieval. But a plausible connection to AI is not evidence that AI caused the salary ranking. You would need posting dates and job descriptions to test that.

5. Spring and Django show why established technologies still matter.

Spring’s 175,500 median and Django’s 155,000 median are consistent with valuable work maintaining and extending business applications.

Technology discussions often focus on new frameworks and AI tools, while employers also need engineers who can operate existing systems reliably, integrate services, fix failures, and deliver features. Mature technologies can remain commercially valuable even when they attract less attention.

6. Some entries reveal a classification problem.

Your table mixes several different categories:
Category	Examples
Programming languages	Rust, Go, C, Crystal
Frameworks	Spring, FastAPI, Django
Infrastructure tooling	Terraform
Databases	Neo4j, Mongo
API technology	GraphQL
Regulation or compliance knowledge	GDPR
Collaboration tools or vendor names	Zoom, Bitbucket, Atlassian


Zoom’s high salary should not be interpreted as evidence that learning Zoom commands a premium. It may simply appear in the descriptions of highly paid roles. Likewise, GDPR is a regulation, and “Atlassian” is a vendor name rather than one specific technical skill.

These entries are a reminder that a keyword appearing in a high-paying job advert does not make it the reason the job pays well.

What this means for your learning decisions

For your data engineering direction, this table gives a reasonable reason to investigate Terraform as a complementary skill. It offers much less justification for switching your focus to Rust solely because Rust ranks first.

A sensible sequence is to strengthen Python, SQL, data modelling, pipelines, and a cloud platform, then use Terraform to make that infrastructure reproducible. FastAPI can be useful when you want applications to access the outputs of your pipelines.

Before treating this as a current market ranking, check the dataset’s date, geography, job-title filters, currency, and number of salary-disclosing postings per skill. Also check whether demand_count counts all postings or only those with salary data. Until those are known, this is a useful ranking of your query results, but not a verified picture of today’s global—or Kenyan—tech market.
















