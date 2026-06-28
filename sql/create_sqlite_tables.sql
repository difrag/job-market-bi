-- SQLite schema for the Job Market Intelligence Dashboard.
-- This schema is intentionally preparation-focused: it creates the
-- star-style tables needed before writing analytics queries.

PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS bridge_job_skills;
DROP TABLE IF EXISTS fact_jobs;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_job_title;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS dim_company;
DROP TABLE IF EXISTS dim_skills;

PRAGMA foreign_keys = ON;

CREATE TABLE dim_company (
    company_id INTEGER PRIMARY KEY,
    company_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_location (
    location_id INTEGER PRIMARY KEY,
    location_clean TEXT NOT NULL,
    location_city TEXT,
    location_state TEXT,
    location_country TEXT,
    UNIQUE (location_clean, location_city, location_state, location_country)
);

CREATE TABLE dim_job_title (
    job_title_id INTEGER PRIMARY KEY,
    title_clean TEXT NOT NULL,
    job_title_category TEXT NOT NULL,
    seniority_level TEXT NOT NULL,
    experience_years_min INTEGER,
    UNIQUE (title_clean, job_title_category, seniority_level, experience_years_min)
);

CREATE TABLE dim_date (
    date_key TEXT PRIMARY KEY,
    full_date TEXT NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    day INTEGER NOT NULL,
    weekday_name TEXT NOT NULL
);

CREATE TABLE dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skill_name TEXT NOT NULL UNIQUE,
    skill_category TEXT NOT NULL
);

CREATE TABLE fact_jobs (
    job_id TEXT PRIMARY KEY,
    source_index INTEGER,
    company_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    job_title_id INTEGER NOT NULL,
    date_key TEXT,
    posting_source_clean TEXT,
    search_term_clean TEXT,
    schedule_type_simplified TEXT,
    work_from_home_clean TEXT,
    remote_status TEXT,
    is_remote INTEGER NOT NULL DEFAULT 0,
    is_broad_location INTEGER NOT NULL DEFAULT 0,
    posting_age_days INTEGER,
    salary_period TEXT,
    salary_min_annual REAL,
    salary_max_annual REAL,
    salary_midpoint_annual REAL,
    salary_band TEXT,
    has_salary_info INTEGER NOT NULL DEFAULT 0,
    skills_count INTEGER NOT NULL DEFAULT 0,
    has_skills INTEGER NOT NULL DEFAULT 0,
    has_skill_sql INTEGER NOT NULL DEFAULT 0,
    has_skill_python INTEGER NOT NULL DEFAULT 0,
    has_skill_excel INTEGER NOT NULL DEFAULT 0,
    has_skill_tableau INTEGER NOT NULL DEFAULT 0,
    has_skill_power_bi INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (job_title_id) REFERENCES dim_job_title(job_title_id),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

CREATE TABLE bridge_job_skills (
    job_id TEXT NOT NULL,
    skill_id INTEGER NOT NULL,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES fact_jobs(job_id),
    FOREIGN KEY (skill_id) REFERENCES dim_skills(skill_id)
);

CREATE INDEX idx_fact_jobs_company_id ON fact_jobs(company_id);
CREATE INDEX idx_fact_jobs_location_id ON fact_jobs(location_id);
CREATE INDEX idx_fact_jobs_job_title_id ON fact_jobs(job_title_id);
CREATE INDEX idx_fact_jobs_date_key ON fact_jobs(date_key);
CREATE INDEX idx_fact_jobs_remote_status ON fact_jobs(remote_status);
CREATE INDEX idx_fact_jobs_salary_band ON fact_jobs(salary_band);
CREATE INDEX idx_fact_jobs_seniority ON dim_job_title(seniority_level);
CREATE INDEX idx_bridge_job_skills_skill_id ON bridge_job_skills(skill_id);
CREATE INDEX idx_bridge_job_skills_job_id ON bridge_job_skills(job_id);
