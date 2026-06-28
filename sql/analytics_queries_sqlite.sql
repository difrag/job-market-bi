-- Job Market Intelligence Dashboard - SQLite Analytics Queries
-- Purpose: Business-ready query library for the prepared SQLite model.
-- Database: data/job_market.db
--
-- Run queries individually in SQLite, DB Browser for SQLite, VS Code SQL tools,
-- Python, or Power BI. These queries are grouped by dashboard story area.

-- ============================================================
-- 1. DATASET HEALTH
-- ============================================================

-- Query 1.1
-- Business question: What is the overall size and readiness of the dataset?
-- Dashboard use: Overview KPI cards.
-- Caveat: Salary and seniority coverage are partial and should be shown clearly.
SELECT
    COUNT(*) AS total_jobs,
    COUNT(DISTINCT company_id) AS unique_companies,
    COUNT(DISTINCT location_id) AS unique_locations,
    COUNT(DISTINCT job_title_id) AS unique_job_title_records,
    SUM(has_salary_info) AS jobs_with_salary,
    ROUND(100.0 * SUM(has_salary_info) / COUNT(*), 1) AS salary_coverage_pct,
    SUM(has_skills) AS jobs_with_skills,
    ROUND(100.0 * SUM(has_skills) / COUNT(*), 1) AS skill_coverage_pct,
    SUM(is_remote) AS remote_jobs,
    ROUND(100.0 * SUM(is_remote) / COUNT(*), 1) AS remote_pct
FROM fact_jobs;

-- Query 1.2
-- Business question: Are there any load-quality issues left in the SQL model?
-- Dashboard use: Data quality appendix or internal validation.
-- Caveat: This checks SQL integrity, not semantic correctness of all derived categories.
SELECT
    'duplicate_job_ids' AS check_name,
    COUNT(*) - COUNT(DISTINCT job_id) AS issue_count
FROM fact_jobs
UNION ALL
SELECT
    'bridge_orphan_job_ids',
    COUNT(*)
FROM bridge_job_skills b
LEFT JOIN fact_jobs f ON b.job_id = f.job_id
WHERE f.job_id IS NULL
UNION ALL
SELECT
    'bridge_orphan_skill_ids',
    COUNT(*)
FROM bridge_job_skills b
LEFT JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE s.skill_id IS NULL
UNION ALL
SELECT
    'skill_count_mismatches',
    COUNT(*)
FROM fact_jobs f
LEFT JOIN (
    SELECT job_id, COUNT(*) AS bridge_skill_count
    FROM bridge_job_skills
    GROUP BY job_id
) b ON f.job_id = b.job_id
WHERE f.skills_count != COALESCE(b.bridge_skill_count, 0);

-- Query 1.3
-- Business question: What are the key completeness limitations?
-- Dashboard use: Data quality note cards.
-- Caveat: Unknown categories should be retained in visuals, not silently removed.
SELECT
    COUNT(*) AS total_jobs,
    SUM(CASE WHEN has_salary_info = 0 THEN 1 ELSE 0 END) AS jobs_without_salary,
    ROUND(100.0 * SUM(CASE WHEN has_salary_info = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS no_salary_pct,
    SUM(CASE WHEN has_skills = 0 THEN 1 ELSE 0 END) AS jobs_without_skills,
    ROUND(100.0 * SUM(CASE WHEN has_skills = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS no_skills_pct,
    SUM(CASE WHEN jt.seniority_level = 'Unknown' THEN 1 ELSE 0 END) AS unknown_seniority_jobs,
    ROUND(100.0 * SUM(CASE WHEN jt.seniority_level = 'Unknown' THEN 1 ELSE 0 END) / COUNT(*), 1) AS unknown_seniority_pct,
    SUM(is_broad_location) AS broad_location_jobs,
    ROUND(100.0 * SUM(is_broad_location) / COUNT(*), 1) AS broad_location_pct
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id;

-- ============================================================
-- 2. SKILL DEMAND
-- ============================================================

-- Query 2.1
-- Business question: What are the top 20 most demanded skills?
-- Dashboard use: Top skills horizontal bar chart.
-- Caveat: Skill demand is based on extracted description tokens.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT b.job_id) AS job_count,
    ROUND(100.0 * COUNT(DISTINCT b.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b
JOIN dim_skills s ON b.skill_id = s.skill_id
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY job_count DESC
LIMIT 20;

-- Query 2.2
-- Business question: Which skill categories dominate the market?
-- Dashboard use: Skill category bar chart or treemap.
-- Caveat: Categories are analyst-defined, not official employer taxonomies.
SELECT
    s.skill_category,
    COUNT(*) AS skill_mentions,
    COUNT(DISTINCT b.job_id) AS jobs_with_category,
    ROUND(100.0 * COUNT(DISTINCT b.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b
JOIN dim_skills s ON b.skill_id = s.skill_id
GROUP BY s.skill_category
ORDER BY jobs_with_category DESC;

-- Query 2.3
-- Business question: Which skills appear most often in salary-listed postings?
-- Dashboard use: Salary-ready skill filter validation.
-- Caveat: This is not salary premium yet, only coverage in salary-listed jobs.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT f.job_id) AS salary_listed_jobs,
    ROUND(100.0 * COUNT(DISTINCT f.job_id) / NULLIF((SELECT SUM(has_salary_info) FROM fact_jobs), 0), 1) AS pct_of_salary_listed_jobs
FROM fact_jobs f
JOIN bridge_job_skills b ON f.job_id = b.job_id
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE f.has_salary_info = 1
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY salary_listed_jobs DESC
LIMIT 20;

-- ============================================================
-- 3. TECH STACK
-- ============================================================

-- Query 3.1
-- Business question: Which BI and analytics tools are most demanded?
-- Dashboard use: BI tools comparison chart.
-- Caveat: Excel is grouped as Spreadsheet/Office, but it is central to analyst work.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT b.job_id) AS job_count,
    ROUND(100.0 * COUNT(DISTINCT b.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE s.skill_category IN ('BI Tool', 'Spreadsheet/Office', 'ETL/Analytics Tool', 'Analytics Tool')
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY job_count DESC;

-- Query 3.2
-- Business question: Which programming and query languages matter most?
-- Dashboard use: Languages and query tools visual.
-- Caveat: SQL is classified separately as Database/Query Language.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT b.job_id) AS job_count,
    ROUND(100.0 * COUNT(DISTINCT b.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE s.skill_category IN ('Programming Language', 'Database/Query Language')
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY job_count DESC;

-- Query 3.3
-- Business question: Which cloud and data platforms show up most?
-- Dashboard use: Platform demand chart.
-- Caveat: Some tools are broad platform names and may represent many use cases.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT b.job_id) AS job_count,
    ROUND(100.0 * COUNT(DISTINCT b.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE s.skill_category IN ('Cloud Platform', 'Data Platform', 'Data Engineering', 'Database')
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY job_count DESC;

-- Query 3.4
-- Business question: What is adoption for selected anchor skills?
-- Dashboard use: KPI tiles for SQL, Python, Excel, Tableau, and Power BI.
-- Caveat: These flags come from normalized extracted skills.
SELECT
    COUNT(*) AS total_jobs,
    SUM(has_skill_sql) AS jobs_with_sql,
    ROUND(100.0 * SUM(has_skill_sql) / COUNT(*), 1) AS sql_pct,
    SUM(has_skill_python) AS jobs_with_python,
    ROUND(100.0 * SUM(has_skill_python) / COUNT(*), 1) AS python_pct,
    SUM(has_skill_excel) AS jobs_with_excel,
    ROUND(100.0 * SUM(has_skill_excel) / COUNT(*), 1) AS excel_pct,
    SUM(has_skill_tableau) AS jobs_with_tableau,
    ROUND(100.0 * SUM(has_skill_tableau) / COUNT(*), 1) AS tableau_pct,
    SUM(has_skill_power_bi) AS jobs_with_power_bi,
    ROUND(100.0 * SUM(has_skill_power_bi) / COUNT(*), 1) AS power_bi_pct
FROM fact_jobs;

-- ============================================================
-- 4. SKILL COMBINATIONS
-- ============================================================

-- Query 4.1
-- Business question: Which two-skill combinations appear together most often?
-- Dashboard use: Skill bundle table or heatmap.
-- Caveat: This query can be heavier than simple counts because it self-joins bridge rows.
SELECT
    s1.skill_name AS skill_1,
    s2.skill_name AS skill_2,
    COUNT(DISTINCT b1.job_id) AS jobs_with_both,
    ROUND(100.0 * COUNT(DISTINCT b1.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM bridge_job_skills b1
JOIN bridge_job_skills b2
    ON b1.job_id = b2.job_id
   AND b1.skill_id < b2.skill_id
JOIN dim_skills s1 ON b1.skill_id = s1.skill_id
JOIN dim_skills s2 ON b2.skill_id = s2.skill_id
GROUP BY s1.skill_name, s2.skill_name
HAVING COUNT(DISTINCT b1.job_id) >= 100
ORDER BY jobs_with_both DESC
LIMIT 25;

-- Query 4.2
-- Business question: How often do anchor skill pairs appear together?
-- Dashboard use: Focused comparison for common learning paths.
-- Caveat: Pair percentages are out of all cleaned jobs.
WITH skill_pairs AS (
    SELECT 'SQL + Python' AS pair_name, 'SQL' AS skill_1, 'Python' AS skill_2
    UNION ALL SELECT 'SQL + Excel', 'SQL', 'Excel'
    UNION ALL SELECT 'SQL + Power BI', 'SQL', 'Power BI'
    UNION ALL SELECT 'SQL + Tableau', 'SQL', 'Tableau'
    UNION ALL SELECT 'Python + Tableau', 'Python', 'Tableau'
    UNION ALL SELECT 'Python + Power BI', 'Python', 'Power BI'
)
SELECT
    p.pair_name,
    COUNT(DISTINCT b1.job_id) AS jobs_with_both,
    ROUND(100.0 * COUNT(DISTINCT b1.job_id) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM skill_pairs p
JOIN dim_skills s1 ON p.skill_1 = s1.skill_name
JOIN dim_skills s2 ON p.skill_2 = s2.skill_name
JOIN bridge_job_skills b1 ON s1.skill_id = b1.skill_id
JOIN bridge_job_skills b2 ON b1.job_id = b2.job_id AND s2.skill_id = b2.skill_id
GROUP BY p.pair_name
ORDER BY jobs_with_both DESC;

-- ============================================================
-- 5. ROLE AND JOB TITLE ANALYSIS
-- ============================================================

-- Query 5.1
-- Business question: What job title categories make up the market?
-- Dashboard use: Role mix bar chart.
-- Caveat: Job title categories are rule-based approximations.
SELECT
    jt.job_title_category,
    COUNT(*) AS job_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
GROUP BY jt.job_title_category
ORDER BY job_count DESC;

-- Query 5.2
-- Business question: What are the top skills by job title category?
-- Dashboard use: Matrix by role and skill.
-- Caveat: Limit or filter in Power BI to avoid a very wide matrix.
WITH ranked_skills AS (
    SELECT
        jt.job_title_category,
        s.skill_name,
        s.skill_category,
        COUNT(DISTINCT f.job_id) AS job_count,
        ROW_NUMBER() OVER (
            PARTITION BY jt.job_title_category
            ORDER BY COUNT(DISTINCT f.job_id) DESC
        ) AS skill_rank
    FROM fact_jobs f
    JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
    JOIN bridge_job_skills b ON f.job_id = b.job_id
    JOIN dim_skills s ON b.skill_id = s.skill_id
    GROUP BY jt.job_title_category, s.skill_id, s.skill_name, s.skill_category
)
SELECT
    job_title_category,
    skill_rank,
    skill_name,
    skill_category,
    job_count
FROM ranked_skills
WHERE skill_rank <= 10
ORDER BY job_title_category, skill_rank;

-- Query 5.3
-- Business question: How do anchor skills differ by role?
-- Dashboard use: Role vs skill adoption matrix.
-- Caveat: Percentages are within each role category.
SELECT
    jt.job_title_category,
    COUNT(*) AS jobs_in_role,
    ROUND(100.0 * SUM(f.has_skill_sql) / COUNT(*), 1) AS sql_pct,
    ROUND(100.0 * SUM(f.has_skill_python) / COUNT(*), 1) AS python_pct,
    ROUND(100.0 * SUM(f.has_skill_excel) / COUNT(*), 1) AS excel_pct,
    ROUND(100.0 * SUM(f.has_skill_tableau) / COUNT(*), 1) AS tableau_pct,
    ROUND(100.0 * SUM(f.has_skill_power_bi) / COUNT(*), 1) AS power_bi_pct
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
GROUP BY jt.job_title_category
ORDER BY jobs_in_role DESC;

-- ============================================================
-- 6. SENIORITY ANALYSIS
-- ============================================================

-- Query 6.1
-- Business question: What is the seniority distribution?
-- Dashboard use: Seniority mix chart.
-- Caveat: Unknown seniority is large and should stay visible.
SELECT
    jt.seniority_level,
    COUNT(*) AS job_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
GROUP BY jt.seniority_level
ORDER BY job_count DESC;

-- Query 6.2
-- Business question: What are the top skills by seniority level?
-- Dashboard use: Skills by seniority page.
-- Caveat: Unknown seniority should be included or filtered intentionally.
WITH ranked_skills AS (
    SELECT
        jt.seniority_level,
        s.skill_name,
        s.skill_category,
        COUNT(DISTINCT f.job_id) AS job_count,
        ROW_NUMBER() OVER (
            PARTITION BY jt.seniority_level
            ORDER BY COUNT(DISTINCT f.job_id) DESC
        ) AS skill_rank
    FROM fact_jobs f
    JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
    JOIN bridge_job_skills b ON f.job_id = b.job_id
    JOIN dim_skills s ON b.skill_id = s.skill_id
    GROUP BY jt.seniority_level, s.skill_id, s.skill_name, s.skill_category
)
SELECT
    seniority_level,
    skill_rank,
    skill_name,
    skill_category,
    job_count
FROM ranked_skills
WHERE skill_rank <= 10
ORDER BY seniority_level, skill_rank;

-- Query 6.3
-- Business question: Do senior roles ask for different anchor skills?
-- Dashboard use: Seniority vs anchor skills matrix.
-- Caveat: Seniority is inferred from title and description text.
SELECT
    jt.seniority_level,
    COUNT(*) AS jobs_in_seniority,
    ROUND(100.0 * SUM(f.has_skill_sql) / COUNT(*), 1) AS sql_pct,
    ROUND(100.0 * SUM(f.has_skill_python) / COUNT(*), 1) AS python_pct,
    ROUND(100.0 * SUM(f.has_skill_excel) / COUNT(*), 1) AS excel_pct,
    ROUND(100.0 * SUM(f.has_skill_tableau) / COUNT(*), 1) AS tableau_pct,
    ROUND(100.0 * SUM(f.has_skill_power_bi) / COUNT(*), 1) AS power_bi_pct
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
GROUP BY jt.seniority_level
ORDER BY jobs_in_seniority DESC;

-- ============================================================
-- 7. SALARY ANALYSIS
-- ============================================================

-- Query 7.1
-- Business question: What is the salary band distribution?
-- Dashboard use: Compensation page histogram/bar chart.
-- Caveat: Salary coverage is limited, so show No Salary Listed separately.
SELECT
    salary_band,
    COUNT(*) AS job_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_all_jobs,
    ROUND(100.0 * SUM(has_salary_info) / COUNT(*), 1) AS salary_listed_pct_in_band
FROM fact_jobs
GROUP BY salary_band
ORDER BY
    CASE salary_band
        WHEN 'No Salary Listed' THEN 0
        WHEN '<50K' THEN 1
        WHEN '50K-75K' THEN 2
        WHEN '75K-100K' THEN 3
        WHEN '100K-125K' THEN 4
        WHEN '125K-150K' THEN 5
        WHEN '150K+' THEN 6
        ELSE 99
    END;

-- Query 7.2
-- Business question: How does salary vary by seniority?
-- Dashboard use: Salary by seniority chart.
-- Caveat: Filters to salary-listed jobs only.
SELECT
    jt.seniority_level,
    COUNT(*) AS salary_listed_jobs,
    ROUND(AVG(f.salary_midpoint_annual), 0) AS avg_salary_midpoint,
    ROUND(MIN(f.salary_midpoint_annual), 0) AS min_salary_midpoint,
    ROUND(MAX(f.salary_midpoint_annual), 0) AS max_salary_midpoint
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
WHERE f.has_salary_info = 1
GROUP BY jt.seniority_level
ORDER BY avg_salary_midpoint DESC;

-- Query 7.3
-- Business question: How does salary vary by role category?
-- Dashboard use: Salary by role chart.
-- Caveat: Filters to salary-listed jobs only and should show sample size.
SELECT
    jt.job_title_category,
    COUNT(*) AS salary_listed_jobs,
    ROUND(AVG(f.salary_midpoint_annual), 0) AS avg_salary_midpoint,
    ROUND(MIN(f.salary_midpoint_annual), 0) AS min_salary_midpoint,
    ROUND(MAX(f.salary_midpoint_annual), 0) AS max_salary_midpoint
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
WHERE f.has_salary_info = 1
GROUP BY jt.job_title_category
HAVING COUNT(*) >= 20
ORDER BY avg_salary_midpoint DESC;

-- Query 7.4
-- Business question: Which skills are associated with higher salary-listed postings?
-- Dashboard use: Salary by skill table.
-- Caveat: This is correlation in salary-listed jobs, not causal premium.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT f.job_id) AS salary_listed_jobs,
    ROUND(AVG(f.salary_midpoint_annual), 0) AS avg_salary_midpoint,
    ROUND(AVG(f.salary_midpoint_annual) - (
        SELECT AVG(salary_midpoint_annual)
        FROM fact_jobs
        WHERE has_salary_info = 1
    ), 0) AS difference_vs_salary_listed_avg
FROM fact_jobs f
JOIN bridge_job_skills b ON f.job_id = b.job_id
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE f.has_salary_info = 1
GROUP BY s.skill_id, s.skill_name, s.skill_category
HAVING COUNT(DISTINCT f.job_id) >= 50
ORDER BY avg_salary_midpoint DESC
LIMIT 25;

-- ============================================================
-- 8. REMOTE AND LOCATION ANALYSIS
-- ============================================================

-- Query 8.1
-- Business question: What is the split by remote status?
-- Dashboard use: Remote status chart.
-- Caveat: Broad Location - Unclear should not be treated as remote.
SELECT
    remote_status,
    COUNT(*) AS job_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_jobs
FROM fact_jobs
GROUP BY remote_status
ORDER BY job_count DESC;

-- Query 8.2
-- Business question: Which roles are most remote?
-- Dashboard use: Remote by role matrix.
-- Caveat: Uses is_remote flag, while remote_status gives more nuance.
SELECT
    jt.job_title_category,
    COUNT(*) AS jobs_in_role,
    SUM(f.is_remote) AS remote_jobs,
    ROUND(100.0 * SUM(f.is_remote) / COUNT(*), 1) AS remote_pct
FROM fact_jobs f
JOIN dim_job_title jt ON f.job_title_id = jt.job_title_id
GROUP BY jt.job_title_category
ORDER BY remote_pct DESC, jobs_in_role DESC;

-- Query 8.3
-- Business question: What are the top concrete locations?
-- Dashboard use: Location bar chart or map prep table.
-- Caveat: Excludes Anywhere and United States to avoid broad locations dominating.
SELECT
    l.location_clean,
    l.location_city,
    l.location_state,
    l.location_country,
    COUNT(*) AS job_count
FROM fact_jobs f
JOIN dim_location l ON f.location_id = l.location_id
WHERE l.location_clean NOT IN ('Anywhere', 'United States', 'Unknown Location')
GROUP BY l.location_id, l.location_clean, l.location_city, l.location_state, l.location_country
ORDER BY job_count DESC
LIMIT 25;

-- Query 8.4
-- Business question: Which states have the most location-based postings?
-- Dashboard use: State-level location chart.
-- Caveat: State is only available for parsed location-based rows.
SELECT
    l.location_state,
    COUNT(*) AS job_count
FROM fact_jobs f
JOIN dim_location l ON f.location_id = l.location_id
WHERE l.location_state IS NOT NULL
  AND l.location_state != ''
GROUP BY l.location_state
ORDER BY job_count DESC
LIMIT 25;

-- Query 8.5
-- Business question: Which skills appear most in remote jobs?
-- Dashboard use: Remote skills chart.
-- Caveat: Remote jobs use explicit remote plus Anywhere-inferred remote.
SELECT
    s.skill_name,
    s.skill_category,
    COUNT(DISTINCT f.job_id) AS remote_job_count,
    ROUND(100.0 * COUNT(DISTINCT f.job_id) / NULLIF((SELECT SUM(is_remote) FROM fact_jobs), 0), 1) AS pct_of_remote_jobs
FROM fact_jobs f
JOIN bridge_job_skills b ON f.job_id = b.job_id
JOIN dim_skills s ON b.skill_id = s.skill_id
WHERE f.is_remote = 1
GROUP BY s.skill_id, s.skill_name, s.skill_category
ORDER BY remote_job_count DESC
LIMIT 20;

-- ============================================================
-- 9. COMPANY ANALYSIS
-- ============================================================

-- Query 9.1
-- Business question: Which companies have the most postings?
-- Dashboard use: Top hiring companies chart.
-- Caveat: A posting count is not the same as open headcount.
SELECT
    c.company_name,
    COUNT(*) AS job_count,
    SUM(f.has_salary_info) AS salary_listed_jobs,
    ROUND(100.0 * SUM(f.has_salary_info) / COUNT(*), 1) AS salary_coverage_pct,
    SUM(f.is_remote) AS remote_jobs,
    ROUND(100.0 * SUM(f.is_remote) / COUNT(*), 1) AS remote_pct
FROM fact_jobs f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.company_id, c.company_name
ORDER BY job_count DESC
LIMIT 25;

-- Query 9.2
-- Business question: What skills do top-posting companies ask for?
-- Dashboard use: Company skill stack table.
-- Caveat: Limited to companies with at least 50 postings to reduce noise.
WITH company_skill_counts AS (
    SELECT
        c.company_name,
        s.skill_name,
        s.skill_category,
        COUNT(DISTINCT f.job_id) AS job_count,
        ROW_NUMBER() OVER (
            PARTITION BY c.company_id
            ORDER BY COUNT(DISTINCT f.job_id) DESC
        ) AS skill_rank,
        COUNT(*) OVER (PARTITION BY c.company_id) AS rows_for_company
    FROM fact_jobs f
    JOIN dim_company c ON f.company_id = c.company_id
    JOIN bridge_job_skills b ON f.job_id = b.job_id
    JOIN dim_skills s ON b.skill_id = s.skill_id
    GROUP BY c.company_id, c.company_name, s.skill_id, s.skill_name, s.skill_category
),
company_totals AS (
    SELECT company_id, COUNT(*) AS total_jobs
    FROM fact_jobs
    GROUP BY company_id
    HAVING COUNT(*) >= 50
)
SELECT
    csc.company_name,
    csc.skill_rank,
    csc.skill_name,
    csc.skill_category,
    csc.job_count
FROM company_skill_counts csc
JOIN dim_company c ON csc.company_name = c.company_name
JOIN company_totals ct ON c.company_id = ct.company_id
WHERE csc.skill_rank <= 5
ORDER BY ct.total_jobs DESC, csc.company_name, csc.skill_rank;

-- Query 9.3
-- Business question: Which companies have the most salary-listed postings?
-- Dashboard use: Salary transparency by company.
-- Caveat: Salary-listed posting count does not imply pay quality.
SELECT
    c.company_name,
    COUNT(*) AS total_jobs,
    SUM(f.has_salary_info) AS salary_listed_jobs,
    ROUND(100.0 * SUM(f.has_salary_info) / COUNT(*), 1) AS salary_coverage_pct,
    ROUND(AVG(CASE WHEN f.has_salary_info = 1 THEN f.salary_midpoint_annual END), 0) AS avg_salary_midpoint
FROM fact_jobs f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.company_id, c.company_name
HAVING SUM(f.has_salary_info) >= 10
ORDER BY salary_listed_jobs DESC, salary_coverage_pct DESC
LIMIT 25;

-- ============================================================
-- 10. TIME ANALYSIS
-- ============================================================

-- Query 10.1
-- Business question: What date range does this dataset cover?
-- Dashboard use: Data freshness card.
-- Caveat: Date is estimated from scrape timestamp and relative posted_at.
SELECT
    MIN(d.full_date) AS earliest_estimated_posted_date,
    MAX(d.full_date) AS latest_estimated_posted_date,
    COUNT(DISTINCT f.date_key) AS active_dates,
    COUNT(*) AS jobs_with_dates
FROM fact_jobs f
JOIN dim_date d ON f.date_key = d.date_key;

-- Query 10.2
-- Business question: How many postings appear by date?
-- Dashboard use: Posting volume trend line.
-- Caveat: Do not overclaim market trend unless date coverage supports it.
SELECT
    d.full_date,
    d.weekday_name,
    COUNT(*) AS job_count
FROM fact_jobs f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.full_date, d.weekday_name
ORDER BY d.full_date;

-- Query 10.3
-- Business question: How many postings appear by month?
-- Dashboard use: Month-level posting volume chart.
-- Caveat: Scrape cadence may affect apparent volume.
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS job_count
FROM fact_jobs f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

