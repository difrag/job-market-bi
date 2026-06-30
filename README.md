# Job Market BI Dashboard

This project looks at job postings for data and BI roles and turns a messy Kaggle dataset into a small business intelligence workflow: cleaning, quality checks, SQL prep, and Power BI reporting.

I built it as a portfolio project to practice the full path from raw data to dashboard, with a focus on questions a job seeker, analyst, or hiring team might actually ask:

- What skills show up most often?
- Which skills are commonly requested together?
- How does demand change by role and seniority?
- What can we learn from the salary data that is available?
- How common are remote roles in this dataset?

## Dashboard Preview

### Executive Overview

![Executive Overview](docs/screenshots/01_executive_overview.png?v=20260630)

### Skills Demand

![Skills Demand](docs/screenshots/02_skills_demand.png?v=20260630)

### Salary Analysis

![Salary Analysis](docs/screenshots/03_salary_analysis.png?v=20260630)

### Remote and Location Analysis

![Remote and Location Analysis](docs/screenshots/04_remote_location.png?v=20260630)
## Dataset Summary

| Metric | Value |
| --- | ---: |
| Raw rows | 61,953 |
| Cleaned job postings | 58,701 |
| Normalized skills | 134 |
| Job-skill records | 189,085 |
| Jobs with parsed salary | 9,660 |
| Salary coverage | 16.5% |
| Clearly remote jobs | 26,330 |
| Remote share | 44.9% |

Top parsed skills by job count:

| Skill | Jobs |
| --- | ---: |
| SQL | 29,223 |
| Excel | 18,683 |
| Python | 17,809 |
| Tableau | 15,748 |
| Power BI | 15,115 |

## Data Source

The dataset comes from Kaggle:

[Data Analyst Job Postings - Kaggle]([data/raw/source.txt](https://www.kaggle.com/datasets/lukebarousse/data-analyst-job-postings-google-search?resource=download))

The raw and processed CSV files are not included in this repository because they are large. The repo keeps the code, notebooks, SQL, and documentation needed to reproduce the work locally.

## Pipeline

```text
Kaggle CSV
    -> Python cleaning notebook
    -> cleaned job, skill, and bridge tables
    -> data quality checks
    -> SQLite analytical database
    -> SQL query pack
    -> Power BI dashboard
```

## Data Model

The Power BI model is built around three main tables:

- `job_postings_clean`: one row per job posting
- `skills_clean`: one row per normalized skill
- `job_skills_clean`: bridge table connecting jobs to skills

The bridge table is the important piece. A single job can ask for many skills, and the same skill can appear across many jobs. Modeling it this way makes the skills page and skill co-occurrence analysis possible.

## Power BI Pages

**Executive Overview**

High-level market snapshot: total jobs, remote share, salary coverage, top skills, job categories, and posting trend.

**Skills Demand**

Focuses on skill demand, skill categories, skill differences by role and seniority, and skills that commonly appear together.

**Salary Analysis**

Looks at annualized salary by role, seniority, skill, salary band, and remote status. Salary visuals use only postings where salary could be parsed.

**Remote and Location Analysis**

Shows remote share, location quality, top locations, and how remote availability differs by job category and seniority.

## Reproducing The Project

1. Download the Kaggle dataset listed in `data/raw/source.txt`.
2. Place the raw CSV at:

```text
data/raw/job_postings_kaggle.csv
```

3. Create a Python environment and install dependencies:

```powershell
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

4. Run the notebooks in order:

```text
notebooks/01_data_cleaning.ipynb
notebooks/02_quality_analysis.ipynb
```

5. Build the local SQLite database:

```powershell
python src/load_sqlite_db.py
```

6. Smoke-test the SQL query pack:

```powershell
python src/smoke_test_sql_queries.py
```

## Notes On Large Files

The following files are intentionally not committed:

- raw CSV files
- processed CSV files
- SQLite database files
- Power BI `.pbix` files
- local virtual environments

The local Power BI file is over the usual comfortable GitHub size for normal commits. I plan to share the dashboard through screenshots in this README, and optionally attach the `.pbix` to a GitHub Release later.

## Limitations

- Salary data is available for only part of the dataset, so salary charts need sample-size context.
- Remote status is cleaned and inferred from available fields, but broad locations such as `United States` are not treated as clearly remote.
- Skill extraction uses parsed description tokens, so it is useful for analysis but not perfect natural-language understanding.
- This is a snapshot dataset, not a live job-market feed.

## Tools Used

- Python
- Pandas
- Jupyter Notebook
- SQLite
- SQL
- Power BI
- DAX
