# Data Model - Job Market Intelligence Dashboard

## Overview

This document explains how we organize and structure the data, both conceptually and technically. It progresses from simple (Milestone 2) to normalized (Milestone 3).

---

## 🎯 Design Philosophy

We follow the principle: **Start simple, normalize gradually**.

- **Milestone 2**: Single-table analysis (in CSV/Pandas)
- **Milestone 3**: Normalized database schema (in SQL)
- **Milestone 4+**: Advanced models (if needed)

This approach teaches concepts progressively and stays practical.

---

## Phase 1: Simple Model (Milestone 2) - CSV & Pandas

### Single Flat Table: Raw Kaggle Dataset

When we start, all data lives in one CSV file from the Kaggle download:

```
title | company_name | location | schedule_type | work_from_home | salary | description | ...
------|--------------|----------|---------------|----------------|--------|-------------|-----
Data Analyst | Meta | Anywhere | Full-time | Work from home | 15–25 an hour | ...
Business Analyst | Garmin | Olathe, KS | Full-time | On-site | ... | ...
```

**Advantages**:
- ✅ Simple to understand
- ✅ Easy to load into Pandas
- ✅ Fast prototyping

**Disadvantages**:
- ❌ Data repetition (company name repeated for each job)
- ❌ Difficult to update (if company info changes)
- ❌ Skills stored as text, not structured

**When we use this**: Milestones 0-2, exploratory analysis

---

## Phase 2: Relational Model (Milestone 3) - SQL Database

### Multi-Table Normalized Schema

We'll create separate tables with relationships:

```
┌─────────────────────────────────────────────────────────┐
│                      jobs (Fact Table)                   │
├──────────┬───────────────┬────────────┬──────────────────┤
│ job_id   │ company_id    │ title_id   │ location_id      │
│ (PK)     │ (FK)          │ (FK)       │ (FK)             │
├──────────┼───────────────┼────────────┼──────────────────┤
│ salary_min, salary_max, employment_type, experience_level│
│ posting_date, job_description                             │
└─────────────────────────────────────────────────────────┘
      ↓              ↓               ↓
   ┌──────────┐  ┌──────────────┐  ┌──────────────┐
   │companies │  │ job_titles   │  │  locations   │
   │(Dim)     │  │ (Dim)        │  │  (Dim)       │
   ├──────────┤  ├──────────────┤  ├──────────────┤
   │company_id│  │title_id      │  │location_id   │
   │name      │  │title_raw     │  │city          │
   │industry  │  │category      │  │state         │
   │size      │  │level         │  │country       │
   └──────────┘  └──────────────┘  └──────────────┘
           ↑
        ┌──────────────────┐
        │  job_skills      │
        │  (Bridge Table)  │
        ├──────────────────┤
        │ job_id (FK)      │
        │ skill_id (FK)    │
        └──────────────────┘
           ↓
        ┌──────────────────┐
        │     skills       │
        │     (Dim)        │
        ├──────────────────┤
        │ skill_id (PK)    │
        │ skill_name       │
        │ category         │
        └──────────────────┘
```

### Table Definitions

#### **Fact Table: `jobs`**
Contains each job posting with references to dimensions

```sql
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    company_id INT NOT NULL FOREIGN KEY REFERENCES companies(company_id),
    job_title_id INT NOT NULL FOREIGN KEY REFERENCES job_titles(job_title_id),
    location_id INT NOT NULL FOREIGN KEY REFERENCES locations(location_id),
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    employment_type VARCHAR(50),
    experience_level VARCHAR(50),
    posting_date DATE,
    job_description TEXT
);
```

#### **Dimension Table: `companies`**
Each company appears once, no repetition

```sql
CREATE TABLE companies (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(255) UNIQUE NOT NULL,
    industry VARCHAR(100),
    company_size VARCHAR(50)  -- Small, Medium, Large, Enterprise
);
```

#### **Dimension Table: `job_titles`**
Standardized job title categories

```sql
CREATE TABLE job_titles (
    job_title_id INT PRIMARY KEY,
    job_title_raw VARCHAR(255),      -- Original title
    job_title_category VARCHAR(50),  -- Standardized: Developer, Analyst, Engineer
    level VARCHAR(50)                -- Entry, Mid, Senior
);
```

#### **Dimension Table: `locations`**
Geographic information

```sql
CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100),
    is_remote BIT
);
```

#### **Dimension Table: `skills`**
List of unique skills

```sql
CREATE TABLE skills (
    skill_id INT PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50)  -- Programming, BI_Tool, Database, Cloud, etc.
);
```

#### **Bridge Table: `job_skills`**
Links jobs to skills (many-to-many relationship)

```sql
CREATE TABLE job_skills (
    job_id INT NOT NULL FOREIGN KEY REFERENCES jobs(job_id),
    skill_id INT NOT NULL FOREIGN KEY REFERENCES skills(skill_id),
    PRIMARY KEY (job_id, skill_id)
);
```

---

## 🔄 Data Flow Through the Model

### Example: A Job Posting

**Raw Data Input**:
```
"Senior BI Developer at Microsoft in Seattle earning $100-150K looking for Python, SQL, Power BI"
```

**After Normalization**:

1. **jobs table**:
   - job_id: 1001
   - company_id: 5 (points to Microsoft)
   - job_title_id: 22 (points to "BI Developer" category)
   - location_id: 8 (points to Seattle, WA)
   - salary_min: 100000
   - salary_max: 150000
   - experience_level: "Senior"
   - posting_date: 2024-06-20

2. **companies table** (referenced):
   - company_id: 5
   - company_name: "Microsoft"
   - industry: "Technology"
   - company_size: "Enterprise"

3. **locations table** (referenced):
   - location_id: 8
   - city: "Seattle"
   - state_province: "WA"
   - country: "USA"
   - is_remote: 0

4. **job_skills table** (multiple rows):
   - (job_id: 1001, skill_id: 3)  ← Python
   - (job_id: 1001, skill_id: 7)  ← SQL
   - (job_id: 1001, skill_id: 15) ← Power BI

5. **skills table** (referenced):
   - skill_id: 3, skill_name: "Python", category: "Programming"
   - skill_id: 7, skill_name: "SQL", category: "Database"
   - skill_id: 15, skill_name: "Power BI", category: "BI_Tool"

---

## 📊 Advantage: Normalized Queries

### Before (Flat File):
To find "all Python jobs at Microsoft", you'd need:
```python
data[(data['company_name'] == 'Microsoft') & (data['skills_required'].str.contains('Python'))]
# Problem: Skills are messy text, company name might vary
```

### After (Normalized Database):
```sql
SELECT DISTINCT j.job_id, j.job_title, c.company_name
FROM jobs j
JOIN companies c ON j.company_id = c.company_id
JOIN job_skills js ON j.job_id = js.job_id
JOIN skills s ON js.skill_id = s.skill_id
WHERE c.company_name = 'Microsoft' AND s.skill_name = 'Python';
```

**Benefits**:
- ✅ Data is clean and consistent
- ✅ Query is unambiguous
- ✅ Easy to update company info once, affects all jobs
- ✅ Skills are structured, not text

---

## 🎯 Why This Structure?

### Principle 1: No Repetition
Company info stored once, referenced many times.

### Principle 2: Single Source of Truth
Change company name in one place, all jobs reflect it.

### Principle 3: Structured Skills
Skills are data, not text, so we can easily analyze them.

### Principle 4: Flexibility
Add columns without breaking existing data.

---

## 📈 Phase 3: Dimensional Model (Milestone 4+) - Star Schema for Power BI

For Power BI, we might simplify to a "star schema":

```
                    ┌─────────────────┐
                    │   dim_date      │
                    │   (future)      │
                    └─────────────────┘
                           ↑
                           │
        ┌──────────────────┼──────────────────┐
        ↓                  ↓                   ↓
  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐
  │ dim_company  │  │   fact_jobs   │  │ dim_location │
  └──────────────┘  └───────────────┘  └──────────────┘
        ↑                  ↓                   ↑
        │                  │                   │
        └──────────────────┼───────────────────┘
                           ↓
                    ┌──────────────────┐
                    │ bridge_job_skills│
                    └──────────────────┘
                           ↑
                           │
                    ┌──────────────┐
                    │  dim_skills  │
                    └──────────────┘
```

This is optimized for Power BI's analytics engine.

---

## 🎓 Learning Progression

| Phase | Table Structure | Tools | Complexity | When |
|-------|-----------------|-------|-----------|------|
| 1 | Single CSV | Pandas | Low | Milestone 2 |
| 2 | Normalized DB | SQL | Medium | Milestone 3 |
| 3 | Star Schema | Power BI | Medium-High | Milestone 4+ |

---

## 📝 Design Decisions Explained

**Q: Why not keep everything in one table?**  
A: Data repetition creates errors, makes updates difficult, wastes storage.

**Q: Why use bridge tables for skills?**  
A: One job can have many skills; one skill appears in many jobs. Bridge tables handle this.

**Q: Why categorize skills?**  
A: Easier filtering and analysis (show me "Programming" skills vs "BI_Tools").

**Q: Can this design change?**  
A: Yes! As we learn more, we'll refine the model. That's part of the learning process.

---

## 🔗 Related Documentation

- See `docs/data_dictionary.md` for column definitions
- See `sql/create_tables.sql` for actual SQL code
- See `sql/analytics_queries.sql` for example queries
- See `docs/business_questions.md` for what questions we're answering

---

**Current Status**: Simple model in use (Milestone 0-2)  
**Next**: Implement normalized model in Milestone 3  
**Remember**: We design data structures to serve business questions!
