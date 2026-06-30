# Data Model

This project uses a simple analytical model designed for SQL validation and Power BI reporting.

## Model Summary

The cleaned data is organized around a jobs fact table, supporting dimensions, and a bridge table for skills.

```text
dim_company        dim_location        dim_job_title        dim_date
     |                  |                    |                 |
     +------------------+--------------------+-----------------+
                                      |
                                  fact_jobs
                                      |
                              bridge_job_skills
                                      |
                                  dim_skills
```

## Tables

### `fact_jobs`

One row per cleaned job posting.

Important fields:

- `job_id`
- `company_id`
- `location_id`
- `job_title_id`
- `date_key`
- `remote_status`
- `is_remote`
- `is_broad_location`
- `salary_period`
- `salary_min_annual`
- `salary_max_annual`
- `salary_midpoint_annual`
- `salary_band`
- `has_salary_info`
- `skills_count`

### `dim_company`

One row per cleaned company name.

Important fields:

- `company_id`
- `company_name`

### `dim_location`

One row per cleaned location combination.

Important fields:

- `location_id`
- `location_clean`
- `location_city`
- `location_state`
- `location_country`

### `dim_job_title`

One row per cleaned title/category/seniority combination.

Important fields:

- `job_title_id`
- `title_clean`
- `job_title_category`
- `seniority_level`
- `experience_years_min`

### `dim_date`

One row per estimated posting date.

Important fields:

- `date_key`
- `full_date`
- `year`
- `quarter`
- `month`
- `month_name`
- `day`
- `weekday_name`

### `dim_skills`

One row per normalized skill.

Important fields:

- `skill_id`
- `skill_name`
- `skill_category`

### `bridge_job_skills`

Many-to-many bridge between jobs and skills.

Important fields:

- `job_id`
- `skill_id`

## Why A Bridge Table Is Needed

Job skills are many-to-many:

- one job posting can request many skills
- one skill can appear in many job postings

The bridge table makes it possible to analyze:

- top skills by demand
- skills by role category
- skills by seniority
- skills associated with salary-listed jobs
- co-occurring skills

## Power BI Modeling Notes

Recommended relationships:

- `fact_jobs[job_id]` to `bridge_job_skills[job_id]`
- `dim_skills[skill_id]` to `bridge_job_skills[skill_id]`
- `dim_company[company_id]` to `fact_jobs[company_id]`
- `dim_location[location_id]` to `fact_jobs[location_id]`
- `dim_job_title[job_title_id]` to `fact_jobs[job_title_id]`
- `dim_date[date_key]` to `fact_jobs[date_key]`

For the Power BI CSV model, the main relationship is:

```text
job_postings_clean[job_id] -> job_skills_clean[job_id]
skills_clean[skill_id] -> job_skills_clean[skill_id]
```

## Validation

The SQLite load validation passed all checks:

- fact job row count matched the cleaned data
- skill row count matched the cleaned skill table
- bridge row count matched the job-skill table
- no duplicate `job_id` values in `fact_jobs`
- no orphaned job or skill records in the bridge table
- no SQLite foreign key violations

See:

- `sql/create_sqlite_tables.sql`
- `sql/analytics_queries_sqlite.sql`
- `docs/sql_load_validation.md`
