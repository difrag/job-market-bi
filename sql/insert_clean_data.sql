-- Job Market Intelligence Dashboard - Data Loading
-- Milestone 3: Load cleaned data into database

-- ============================================================
-- File: insert_clean_data.sql
-- Purpose: Load cleaned CSV data into SQL database tables
-- Usage: Run this AFTER creating tables with create_tables.sql
-- Note: Paths and methods vary by database system
-- ============================================================

-- ==================== IMPORTANT ====================
/*

This file is a TEMPLATE. Actual implementation depends on:

1. Your database system (SQL Server, SQLite, PostgreSQL, etc.)
2. Your data file locations
3. Whether you're using bulk insert, Python/SQLAlchemy, or manual load

For Milestone 2-3 transition, we'll likely use Python/pandas:

    import pandas as pd
    import sqlalchemy
    
    # Read cleaned data
    df = pd.read_csv('data/processed/job_postings_clean.csv')
    
    # Connect to database
    engine = sqlalchemy.create_engine('sqlite:///data/job_market.db')
    
    # Load data (this will populate the tables below)
    df.to_sql('jobs', con=engine, if_exists='append', index=False)

This file documents the logical flow for reference.

*/

-- ==================== SAMPLE SQL INSERTS ====================

-- Example: Insert unique companies (no duplicates)
-- In practice, this would be generated from your cleaned data

INSERT INTO companies (company_name, industry, company_size)
VALUES 
    ('Acme Analytics Corp', 'Technology', 'Large'),
    ('TechCorp Solutions', 'Technology', 'Large'),
    ('Global Finance Inc', 'Finance', 'Enterprise'),
    ('StartUp Innovations', 'Technology', 'Small'),
    ('Enterprise Solutions Ltd', 'Consulting', 'Large')
ON CONFLICT DO NOTHING;  -- Skip if already exists

-- Example: Insert unique locations

INSERT INTO locations (city, state_province, country, is_remote)
VALUES 
    ('New York', 'NY', 'USA', 0),
    ('San Francisco', 'CA', 'USA', 0),
    ('Chicago', 'IL', 'USA', 0),
    ('Remote', NULL, 'USA', 1),
    ('Boston', 'MA', 'USA', 0),
    ('Seattle', 'WA', 'USA', 0),
    ('Dallas', 'TX', 'USA', 0),
    ('Austin', 'TX', 'USA', 0)
ON CONFLICT DO NOTHING;

-- Example: Insert unique skills

INSERT INTO skills (skill_name, skill_category)
VALUES 
    ('Python', 'Programming'),
    ('SQL', 'Database'),
    ('Power BI', 'BI_Tool'),
    ('DAX', 'BI_Tool'),
    ('Azure', 'Cloud'),
    ('Tableau', 'BI_Tool'),
    ('Pandas', 'Programming'),
    ('R', 'Programming'),
    ('Excel', 'BI_Tool'),
    ('Statistics', 'Domain Knowledge'),
    ('Machine Learning', 'Domain Knowledge'),
    ('Data Modeling', 'Domain Knowledge')
ON CONFLICT DO NOTHING;

-- Example: Insert job titles with standardization

INSERT INTO job_titles (job_title_raw, job_title_category, job_level)
VALUES 
    ('Senior Business Intelligence Developer', 'Developer', 'Senior'),
    ('Data Analyst', 'Analyst', 'Mid-Level'),
    ('BI Developer', 'Developer', 'Mid-Level'),
    ('Junior Data Analyst', 'Analyst', 'Entry-Level'),
    ('BI Analytics Manager', 'Manager', 'Senior'),
    ('Data Engineer', 'Engineer', 'Mid-Level'),
    ('Business Analyst', 'Analyst', 'Entry-Level'),
    ('Senior Data Scientist', 'Scientist', 'Senior'),
    ('BI Consultant', 'Consultant', 'Mid-Level'),
    ('Reporting Specialist', 'Analyst', 'Mid-Level')
ON CONFLICT DO NOTHING;

-- ==================== NOTES FOR IMPLEMENTATION ====================

/*

Actual data loading flow (Milestone 2-3):

1. Start with cleaned CSV: data/processed/job_postings_clean.csv
   - Columns: job_id, company_name, job_title, location, 
              salary_min, salary_max, employment_type, 
              experience_level, posting_date, skills_required

2. Python script to populate database:
   
   a. Extract unique values from cleaned data:
      - Get unique companies
      - Get unique locations (after standardization)
      - Get unique job titles
      - Get unique skills (from skills_required column)
   
   b. Insert dimension tables:
      INSERT companies
      INSERT locations
      INSERT job_titles
      INSERT skills
   
   c. Create mapping (cleaned data → dimension IDs):
      - For each job posting, look up:
        * company_name → company_id
        * location → location_id
        * job_title → job_title_id
   
   d. Insert fact table:
      INSERT jobs with foreign key IDs
   
   e. Insert bridge table:
      For each skill in job posting:
        INSERT INTO job_skills (job_id, skill_id)

3. Validation queries to verify loads:
   - Check row counts match source data
   - Check for referential integrity
   - Check for orphaned records

Database-Specific Notes:

SQL Server:
- Use BULK INSERT or SQL Server Management Studio Import
- Handle IDENTITY columns carefully
- Use ON CONFLICT clause in newer versions

SQLite:
- Good for learning/local development
- File-based: data/job_market.db
- Python/SQLAlchemy integration is straightforward

PostgreSQL:
- Similar to SQL Server but different syntax
- Use UPSERT for duplicate handling
- Good for production use

Recommended Approach for Learning:
- Use SQLite for development
- Use Python/SQLAlchemy for data loading
- This keeps skills transferable across databases

*/

-- ==================== PLACEHOLDER FOR BULK INSERT ====================

/*

SQL Server example (adjust for your system):

BULK INSERT jobs
FROM 'C:\path\to\data\job_postings_clean.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- Skip header row
);

This will be implemented in Milestone 3 with actual file paths.

*/

-- ==================== NEXT STEPS ====================

-- After data is loaded, verify with analytics_queries.sql
-- These queries validate the load and provide first insights

SELECT 'Setup complete - Ready for analytics queries' AS status;
