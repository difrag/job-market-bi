# Data Dictionary

This document describes the main raw fields and the cleaned analytical fields used in the project.

## Raw Source

Source file used locally:

```text
data/raw/job_postings_kaggle.csv
```

The raw CSV is not committed to GitHub because of file size.

## Raw Job Posting Fields

| Column | Description | Notes |
| --- | --- | --- |
| `index` | Source row index from the downloaded file | Used only as file-order metadata |
| `title` | Raw job title | Main input for role categorization |
| `company_name` | Raw company name | Cleaned into `company_name_clean` |
| `location` | Raw location text | Includes city/state values and broad values such as `Anywhere` |
| `via` | Posting source text | Cleaned into posting source fields |
| `description` | Full job description | Main text context for skill and role interpretation |
| `extensions` | Additional scraped posting metadata | Semi-structured source metadata |
| `job_id` | Scraper-provided job identifier | Treated as the unique job key after duplicate removal |
| `posted_at` | Relative posting age text | Used with scrape timestamp to estimate posting date |
| `schedule_type` | Work schedule label | Cleaned into schedule fields |
| `work_from_home` | Remote-work indicator | Used in remote-status cleaning |
| `salary` | Raw salary text | Parsed into annual salary fields |
| `search_term` | Search query used to collect the posting | Useful for dataset context |
| `date_time` | Scrape timestamp | Used for estimated posting date |
| `search_location` | Search location used during collection | Mostly collection context |
| `salary_pay` | Raw salary pay text | Used for salary parsing |
| `salary_rate` | Raw salary frequency | Standardized into `salary_period` |
| `salary_avg` | Source salary average estimate | Used as supporting salary input |
| `salary_min` | Source salary minimum estimate | Annualized when possible |
| `salary_max` | Source salary maximum estimate | Annualized when possible |
| `salary_hourly` | Source hourly salary estimate | Supporting salary field |
| `salary_yearly` | Source yearly salary estimate | Supporting salary field |
| `salary_standardized` | Source standardized salary estimate | Supporting salary field |
| `description_tokens` | Tokenized description metadata | Main input for skill parsing |

## Cleaned Job Fields

| Column | Description |
| --- | --- |
| `job_id` | Unique cleaned job identifier |
| `title_clean` | Standardized job title text |
| `company_name_clean` | Standardized company name |
| `location_clean` | Standardized location text |
| `location_city` | Parsed city when available |
| `location_state` | Parsed state when available |
| `location_country` | Parsed country when available |
| `posting_source_clean` | Standardized posting source |
| `schedule_type_simplified` | Simplified schedule type |
| `search_term_clean` | Standardized search term |
| `estimated_posted_date` | Estimated posting date |
| `posting_age_days` | Estimated age of the posting in days |
| `remote_status` | Cleaned remote-work category |
| `is_remote` | Boolean-style remote flag |
| `is_broad_location` | Flag for broad locations such as `Anywhere` or `United States` |
| `job_title_category` | Rule-based role category |
| `seniority_level` | Inferred seniority label |
| `experience_years_min` | Parsed minimum years of experience when available |
| `salary_period` | Standardized salary frequency |
| `salary_min_annual` | Annualized salary minimum |
| `salary_max_annual` | Annualized salary maximum |
| `salary_midpoint_annual` | Annualized midpoint used for salary visuals |
| `salary_band` | Salary band for grouped analysis |
| `has_salary_info` | Flag for postings with parsed salary data |
| `skills_count` | Number of parsed skills assigned to the job |
| `has_skills` | Flag for jobs with at least one parsed skill |

## Skill Tables

`skills_clean.csv`

| Column | Description |
| --- | --- |
| `skill_id` | Unique skill identifier |
| `skill_name` | Normalized skill name |
| `skill_category` | Analyst-defined skill category |

`job_skills_clean.csv`

| Column | Description |
| --- | --- |
| `job_id` | Job identifier |
| `skill_id` | Skill identifier |
| `skill_name` | Skill name used for Power BI convenience |

## Important BI Rules

- Salary visuals should use only postings where `has_salary_info = True`.
- Remote visuals should not combine `Broad Location - Unclear` with clearly remote jobs.
- Skill visuals should use the job-skill bridge table instead of counting skill names directly.
- Unknown seniority should remain visible unless a visual is intentionally filtered.
