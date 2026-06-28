-- Job Market Intelligence Dashboard - SQL Setup
-- Milestone 3: Database Design and SQL Implementation

-- ============================================================
-- File: create_tables.sql
-- Purpose: Create database schema for job postings analysis
-- Usage: Run this script first to set up empty tables
-- Database: SQL Server, SQLite, or PostgreSQL
-- ============================================================

-- ==================== DIMENSION TABLES ====================

-- Companies dimension table
-- Stores unique company information (no repetition)
CREATE TABLE companies (
    company_id INT PRIMARY KEY IDENTITY(1,1),
    company_name VARCHAR(255) UNIQUE NOT NULL,
    industry VARCHAR(100),
    company_size VARCHAR(50),  -- Small, Medium, Large, Enterprise
    created_at DATETIME DEFAULT GETDATE()
);

-- Locations dimension table
-- Stores geographic information
CREATE TABLE locations (
    location_id INT PRIMARY KEY IDENTITY(1,1),
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100),
    is_remote BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);

-- Job titles dimension table
-- Maps raw job titles to standardized categories
CREATE TABLE job_titles (
    job_title_id INT PRIMARY KEY IDENTITY(1,1),
    job_title_raw VARCHAR(255),          -- Original title from posting
    job_title_category VARCHAR(50),      -- Standardized: Developer, Analyst, Engineer, Manager, Scientist, Other
    job_level VARCHAR(50),                -- Entry-Level, Mid-Level, Senior, Executive
    created_at DATETIME DEFAULT GETDATE()
);

-- Skills dimension table
-- List of all unique skills
CREATE TABLE skills (
    skill_id INT PRIMARY KEY IDENTITY(1,1),
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    skill_category VARCHAR(50),  -- Programming, Database, BI_Tool, ETL, Cloud, Other
    created_at DATETIME DEFAULT GETDATE()
);

-- ==================== FACT TABLE ====================

-- Jobs fact table
-- Main table containing each job posting with references to dimensions
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    company_id INT NOT NULL,
    job_title_id INT NOT NULL,
    location_id INT NOT NULL,
    employment_type VARCHAR(50),         -- Full-Time, Part-Time, Contract, Temporary
    experience_level VARCHAR(50),        -- Entry-Level, Mid-Level, Senior, Executive
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    is_salary_provided BIT,              -- Flag for handling missing salaries
    posting_date DATE,
    job_description TEXT,
    created_at DATETIME DEFAULT GETDATE(),
    -- Foreign keys
    CONSTRAINT fk_company FOREIGN KEY (company_id) REFERENCES companies(company_id),
    CONSTRAINT fk_job_title FOREIGN KEY (job_title_id) REFERENCES job_titles(job_title_id),
    CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- ==================== BRIDGE TABLE ====================

-- Job-Skills bridge table
-- Many-to-many relationship: one job can have many skills, one skill appears in many jobs
CREATE TABLE job_skills (
    job_id INT NOT NULL,
    skill_id INT NOT NULL,
    PRIMARY KEY (job_id, skill_id),
    -- Foreign keys
    CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES jobs(job_id),
    CONSTRAINT fk_skill FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

-- ==================== INDEXES ====================
-- Improve query performance on common searches

-- Index on company_name for quick lookups
CREATE INDEX idx_company_name ON companies(company_name);

-- Index on skill_name for quick lookups
CREATE INDEX idx_skill_name ON skills(skill_name);

-- Index on job posting date for time-based queries
CREATE INDEX idx_posting_date ON jobs(posting_date);

-- Index on job title category for filtering by role type
CREATE INDEX idx_job_title_category ON job_titles(job_title_category);

-- Index on location for geographic queries
CREATE INDEX idx_location_city ON locations(city);

-- ==================== NOTES ====================
/*

Data Model Explanation:

1. companies - Stores unique companies (no repetition)
   - company_id: Primary key
   - company_name: Unique constraint ensures no duplicates
   - Benefits: Change company info once, affects all jobs

2. locations - Geographic information
   - location_id: Primary key
   - is_remote: Boolean flag for remote work
   - Allows aggregation by city, state, country

3. job_titles - Maps raw titles to standardized categories
   - job_title_raw: Keep original for reference
   - job_title_category: Standardized category for analysis
   - job_level: Helps segment by seniority

4. skills - All unique skills in the job market
   - skill_id: Primary key
   - skill_name: Unique constraint prevents duplicates
   - skill_category: Groups related skills

5. jobs - Fact table with job postings
   - References all dimension tables
   - Contains salary, employment type, dates
   - Links to skills through bridge table

6. job_skills - Bridge table for many-to-many relationship
   - One job can require multiple skills
   - One skill can appear in multiple jobs
   - Enables skill analysis and correlation

Relationship Diagram:
                      companies
                          ↑
                          |
    job_titles ←─→ jobs ←─┴─→ locations
                          |
                          ↓
                    job_skills ←→ skills

Next Steps (Milestone 3):
1. Run this script to create tables
2. Load data using insert_clean_data.sql
3. Run analytics queries using analytics_queries.sql
4. Verify data integrity and counts

*/
