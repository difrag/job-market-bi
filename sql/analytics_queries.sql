-- Job Market Intelligence Dashboard - Analytics Queries
-- Milestone 3: Key analytical queries for business insights

-- ============================================================
-- File: analytics_queries.sql
-- Purpose: Core analytics queries answering business questions
-- Usage: Run these after data is loaded in create_tables.sql
-- ============================================================

-- ==================== SKILL ANALYSIS ====================

-- Query 1: Top 20 Most Demanded Skills
-- Answers: "What skills should I prioritize learning?"
SELECT TOP 20
    s.skill_name,
    COUNT(js.job_id) AS job_count,
    CAST(COUNT(js.job_id) AS FLOAT) / 
        (SELECT COUNT(DISTINCT job_id) FROM jobs) * 100 AS percentage_of_jobs,
    s.skill_category
FROM skills s
INNER JOIN job_skills js ON s.skill_id = js.skill_id
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY job_count DESC;

-- Query 2: Skill Combinations (Skills That Appear Together)
-- Answers: "Which skills do employers expect together?"
SELECT TOP 20
    s1.skill_name AS skill_1,
    s2.skill_name AS skill_2,
    COUNT(DISTINCT js1.job_id) AS times_together
FROM job_skills js1
INNER JOIN job_skills js2 ON js1.job_id = js2.job_id
INNER JOIN skills s1 ON js1.skill_id = s1.skill_id
INNER JOIN skills s2 ON js2.skill_id = s2.skill_id
WHERE s1.skill_id < s2.skill_id  -- Avoid duplicates (s1,s2) = (s2,s1)
GROUP BY s1.skill_id, s1.skill_name, s2.skill_id, s2.skill_name
HAVING COUNT(DISTINCT js1.job_id) >= 5  -- At least 5 jobs with both
ORDER BY times_together DESC;

-- Query 3: Skills by Experience Level
-- Answers: "What skills should entry-level people focus on vs. senior?"
SELECT
    j.experience_level,
    s.skill_name,
    COUNT(js.job_id) AS job_count,
    ROW_NUMBER() OVER (PARTITION BY j.experience_level ORDER BY COUNT(js.job_id) DESC) AS rank
FROM skills s
INNER JOIN job_skills js ON s.skill_id = js.skill_id
INNER JOIN jobs j ON js.job_id = j.job_id
GROUP BY j.experience_level, s.skill_id, s.skill_name
HAVING ROW_NUMBER() OVER (PARTITION BY j.experience_level ORDER BY COUNT(js.job_id) DESC) <= 10;

-- ==================== COMPANY ANALYSIS ====================

-- Query 4: Top Hiring Companies
-- Answers: "Which companies are hiring the most for BI roles?"
SELECT TOP 20
    c.company_name,
    COUNT(j.job_id) AS job_count,
    AVG((j.salary_min + j.salary_max) / 2) AS avg_salary,
    c.company_size,
    c.industry
FROM companies c
INNER JOIN jobs j ON c.company_id = j.company_id
GROUP BY c.company_id, c.company_name, c.company_size, c.industry
ORDER BY job_count DESC;

-- Query 5: Company Tech Stack Analysis
-- Answers: "What's the tech stack for specific companies?"
-- Example: Microsoft's most required skills
SELECT
    c.company_name,
    s.skill_name,
    COUNT(js.job_id) AS skill_job_count,
    ROW_NUMBER() OVER (PARTITION BY c.company_id ORDER BY COUNT(js.job_id) DESC) AS rank
FROM companies c
INNER JOIN jobs j ON c.company_id = j.company_id
INNER JOIN job_skills js ON j.job_id = js.job_id
INNER JOIN skills s ON js.skill_id = s.skill_id
WHERE c.company_name = 'Microsoft'  -- Change for different companies
GROUP BY c.company_id, c.company_name, s.skill_id, s.skill_name
HAVING ROW_NUMBER() OVER (PARTITION BY c.company_id ORDER BY COUNT(js.job_id) DESC) <= 15
ORDER BY c.company_name, rank;

-- ==================== LOCATION & GEOGRAPHY ====================

-- Query 6: Job Distribution by Location
-- Answers: "Which locations have the most BI job opportunities?"
SELECT TOP 20
    CASE 
        WHEN l.is_remote = 1 THEN 'Remote'
        ELSE CONCAT(l.city, ', ', l.state_province)
    END AS location,
    COUNT(j.job_id) AS job_count,
    AVG((j.salary_min + j.salary_max) / 2) AS avg_salary,
    l.is_remote
FROM locations l
INNER JOIN jobs j ON l.location_id = j.location_id
GROUP BY l.location_id, l.city, l.state_province, l.is_remote
ORDER BY job_count DESC;

-- Query 7: Remote vs. On-Site Jobs
-- Answers: "What's the split between remote and office-based BI roles?"
SELECT
    CASE WHEN l.is_remote = 1 THEN 'Remote' ELSE 'On-Site' END AS job_type,
    COUNT(j.job_id) AS job_count,
    CAST(COUNT(j.job_id) AS FLOAT) / (SELECT COUNT(*) FROM jobs) * 100 AS percentage
FROM locations l
INNER JOIN jobs j ON l.location_id = j.location_id
GROUP BY l.is_remote;

-- ==================== JOB TITLE & ROLE ANALYSIS ====================

-- Query 8: Job Titles and Their Requirements
-- Answers: "What's the difference between Analyst vs. Developer vs. Engineer?"
SELECT
    jt.job_title_category,
    COUNT(j.job_id) AS job_count,
    AVG((j.salary_min + j.salary_max) / 2) AS avg_salary,
    AVG(CAST(DATEDIFF(YEAR, '1970-01-01', j.posting_date) AS FLOAT)) AS avg_experience_requirement
FROM job_titles jt
INNER JOIN jobs j ON jt.job_title_id = j.job_title_id
GROUP BY jt.job_title_category
ORDER BY job_count DESC;

-- Query 9: Top Skills by Job Title
-- Answers: "What skills should a BI Developer know vs. a Data Analyst?"
SELECT
    jt.job_title_category,
    s.skill_name,
    COUNT(js.job_id) AS skill_count,
    ROW_NUMBER() OVER (PARTITION BY jt.job_title_category ORDER BY COUNT(js.job_id) DESC) AS rank
FROM job_titles jt
INNER JOIN jobs j ON jt.job_title_id = j.job_title_id
INNER JOIN job_skills js ON j.job_id = js.job_id
INNER JOIN skills s ON js.skill_id = s.skill_id
GROUP BY jt.job_title_id, jt.job_title_category, s.skill_id, s.skill_name
HAVING ROW_NUMBER() OVER (PARTITION BY jt.job_title_category ORDER BY COUNT(js.job_id) DESC) <= 15
ORDER BY jt.job_title_category, rank;

-- ==================== SALARY & COMPENSATION ====================

-- Query 10: Salary by Experience Level
-- Answers: "What salary range should I expect at each level?"
SELECT
    j.experience_level,
    COUNT(j.job_id) AS job_count_with_salary,
    MIN(j.salary_min) AS min_salary,
    AVG(j.salary_min) AS avg_min_salary,
    MAX(j.salary_max) AS max_salary,
    AVG(j.salary_max) AS avg_max_salary,
    AVG((j.salary_min + j.salary_max) / 2) AS avg_total_salary
FROM jobs j
WHERE j.salary_min IS NOT NULL AND j.salary_max IS NOT NULL
GROUP BY j.experience_level
ORDER BY 
    CASE 
        WHEN j.experience_level = 'Entry-Level' THEN 1
        WHEN j.experience_level = 'Mid-Level' THEN 2
        WHEN j.experience_level = 'Senior' THEN 3
        ELSE 4
    END;

-- Query 11: Salary Premium for Specific Skills
-- Answers: "How much more can I earn with specific skills?"
SELECT TOP 20
    s.skill_name,
    COUNT(js.job_id) AS job_count,
    AVG((j.salary_min + j.salary_max) / 2) AS avg_salary_with_skill,
    (SELECT AVG((salary_min + salary_max) / 2) FROM jobs WHERE salary_min IS NOT NULL) AS overall_avg_salary,
    CAST((AVG((j.salary_min + j.salary_max) / 2) - 
        (SELECT AVG((salary_min + salary_max) / 2) FROM jobs WHERE salary_min IS NOT NULL)) AS INT) AS salary_premium
FROM skills s
INNER JOIN job_skills js ON s.skill_id = js.skill_id
INNER JOIN jobs j ON js.job_id = j.job_id
WHERE j.salary_min IS NOT NULL AND j.salary_max IS NOT NULL
GROUP BY s.skill_id, s.skill_name
HAVING COUNT(js.job_id) >= 10  -- At least 10 jobs with skill
ORDER BY salary_premium DESC;

-- ==================== EMPLOYMENT TYPE ====================

-- Query 12: Employment Type Distribution
-- Answers: "Are BI roles mostly full-time, contract, or mixed?"
SELECT
    employment_type,
    COUNT(job_id) AS job_count,
    CAST(COUNT(job_id) AS FLOAT) / (SELECT COUNT(*) FROM jobs) * 100 AS percentage
FROM jobs
GROUP BY employment_type
ORDER BY job_count DESC;

-- ==================== AGGREGATE STATISTICS ====================

-- Query 13: Overall Dataset Summary
-- Answers: "What does our data look like at a high level?"
SELECT
    COUNT(DISTINCT job_id) AS total_jobs,
    COUNT(DISTINCT company_id) AS unique_companies,
    COUNT(DISTINCT location_id) AS unique_locations,
    COUNT(DISTINCT j.job_title_id) AS unique_job_titles,
    COUNT(DISTINCT js.skill_id) AS unique_skills,
    MIN(posting_date) AS earliest_posting,
    MAX(posting_date) AS latest_posting,
    AVG((salary_min + salary_max) / 2) AS overall_avg_salary
FROM jobs j
LEFT JOIN job_skills js ON j.job_id = js.job_id;

-- ==================== DATA QUALITY CHECKS ====================

-- Query 14: Data Completeness Report
-- Answers: "What's the data quality like?"
SELECT
    COUNT(*) AS total_jobs,
    SUM(CASE WHEN salary_min IS NOT NULL THEN 1 ELSE 0 END) AS jobs_with_salary,
    CAST(SUM(CASE WHEN salary_min IS NOT NULL THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS salary_completeness_pct,
    COUNT(DISTINCT company_id) AS unique_companies,
    COUNT(DISTINCT location_id) AS unique_locations,
    (SELECT COUNT(*) FROM job_skills) AS total_skill_assignments,
    CAST((SELECT COUNT(*) FROM job_skills) AS FLOAT) / COUNT(*) AS avg_skills_per_job
FROM jobs;

-- ==================== USAGE NOTES ====================

/*

These queries demonstrate:

1. Business Intelligence fundamentals
   - Aggregation (COUNT, AVG)
   - Grouping and filtering
   - Ranking (ROW_NUMBER, TOP)
   - Joins across tables

2. Real analysis questions
   - What skills matter most?
   - What's the salary progression?
   - Which companies are hiring?
   - Where are the opportunities?

3. BI reporting patterns
   - Frequency analysis
   - Comparative analysis
   - Trend analysis
   - Quality checks

Next Steps (Milestone 4):
- Import these results into Power BI
- Create visualizations from these queries
- Build interactive dashboards
- Add filtering and drill-down

Practice:
- Modify these queries for different insights
- Add WHERE clauses for filtering
- Calculate new metrics (e.g., cost-to-hire per company)
- Create views for Power BI to use

*/
