# Job Market BI Dashboard

This project analyzes job postings for data and BI roles and turns a raw Kaggle dataset into a small business intelligence workflow: cleaning, validation, SQL preparation, and Power BI reporting.

The goal was to practice the full path from messy source data to a dashboard that answers practical job-market questions:

- Which skills appear most often in job postings?
- Which skills are commonly requested together?
- How does demand differ by role and seniority?
- What can be learned from postings with salary data?
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

## Key Findings

- SQL was the most requested skill, appearing in 29,223 cleaned job postings.
- Excel, Python, Tableau, and Power BI were also among the strongest skill signals.
- Salary data was available for only 16.5% of postings, so salary analysis is limited to salary-listed jobs.
- Remote roles were common, but broad locations such as `Anywhere` and `United States` needed to be handled carefully.
- The job-skill bridge table made it possible to analyze skill combinations instead of only individual skills.

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

[Data Analyst Job Postings - Kaggle](https://www.kaggle.com/datasets/lukebarousse/data-analyst-job-postings-google-search?resource=download)

Large raw and processed data files are not committed to this repository. The repo contains the notebooks, SQL, scripts, screenshots, and documentation needed to understand and reproduce the project locally.

## Pipeline

```text
Kaggle CSV
    -> Python cleaning notebook
    -> cleaned jobs, skills, and job-skill bridge tables
    -> data quality checks
    -> SQLite analytical database
    -> SQL query pack
    -> Power BI dashboard
```

## Data Model

The BI model is built around three main analytical tables:

- `job_postings_clean`: one row per cleaned job posting
- `skills_clean`: one row per normalized skill
- `job_skills_clean`: bridge table connecting jobs to skills

The bridge table is the key modeling choice. A job can request many skills, and a skill can appear across many jobs. This makes skill demand, role-by-skill analysis, and skill co-occurrence analysis possible.

## Power BI Pages

**Executive Overview**

High-level market snapshot: total jobs, remote share, salary coverage, top skills, job categories, and posting trend.

**Skills Demand**

Skill demand by individual skill and category, with filters for role, seniority, remote status, and selected skills.

**Salary Analysis**

Annualized salary analysis by role, seniority, skill, salary band, and remote status. Salary visuals use only postings where salary could be parsed.

**Remote and Location Analysis**

Remote-work availability, broad location handling, top companies posting remote roles, and reported location patterns.

## Repository Structure

```text
job-market-bi/
|-- data/
|   |-- README.md
|   |-- processed/.gitkeep
|   `-- raw/source.txt
|-- docs/
|   |-- screenshots/
|   |-- business_questions.md
|   |-- data_dictionary.md
|   |-- data_model.md
|   |-- data_quality_report.md
|   `-- sql_load_validation.md
|-- notebooks/
|   |-- 01_data_cleaning.ipynb
|   `-- 02_quality_analysis.ipynb
|-- powerbi/
|   |-- DAX_Measures.md
|   `-- README.md
|-- sql/
|   |-- analytics_queries_sqlite.sql
|   `-- create_sqlite_tables.sql
|-- src/
|   |-- load_sqlite_db.py
|   `-- smoke_test_sql_queries.py
|-- PROJECT.md
|-- requirements.txt
|-- tasks.md
`-- README.md
```

## Reproducing The Project

1. Download the Kaggle dataset listed above.
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

The Power BI report is represented in this repository through screenshots and DAX documentation. The `.pbix` file can be shared separately as a GitHub Release asset if needed.

## Limitations

- Salary data is available for only part of the dataset, so salary charts need sample-size context.
- Remote status is cleaned and inferred from available fields, while broad location values are kept separate from clearly remote jobs.
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
