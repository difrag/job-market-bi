# Job Market BI Analytics Project

This is a business intelligence portfolio project that analyzes job postings to understand demand for data and BI skills, salary patterns, seniority, and remote-work trends.

The project follows a realistic BI workflow:

1. inspect the raw dataset
2. clean and enrich the data with Python
3. validate data quality
4. prepare a SQL analytics layer
5. build Power BI dashboard pages
6. document the business story and limitations

## Current Status

Completed:

- raw dataset inspection
- data cleaning notebook
- salary parsing and annualized salary fields
- skills parsing and normalized skill tables
- job title categories and seniority levels
- quality analysis notebook and reports
- SQLite analytical database
- SQL analytics query pack
- Power BI pages started:
  - Executive Overview
  - Skills Demand
  - Salary Analysis

In progress:

- Remote and Location Analysis page
- final dashboard polish
- dashboard screenshots and portfolio write-up

## Business Questions

This project is designed to answer questions such as:

- Which skills are most requested in data and BI job postings?
- Which skill categories dominate the market?
- Which skills commonly appear together?
- How do required skills differ by job category and seniority?
- Which roles and seniority levels show higher salary ranges?
- How common are remote jobs?
- Which companies and locations appear most often?

## Data Source

The raw dataset comes from Kaggle:

`data/raw/source.txt`

Large raw and processed data files are not committed to this repository. See `data/README.md` for details.

## Project Structure

```text
job-market-bi/
|-- data/
|   |-- README.md
|   |-- raw/
|   |   `-- source.txt
|   `-- processed/
|-- docs/
|   |-- business_questions.md
|   |-- data_dictionary.md
|   |-- data_model.md
|   |-- data_quality_report.md
|   |-- github_publish_checklist.md
|   `-- sql_load_validation.md
|-- notebooks/
|   |-- 01_data_cleaning.ipynb
|   `-- 02_quality_analysis.ipynb
|-- powerbi/
|   `-- README.md
|-- sql/
|   |-- analytics_queries_sqlite.sql
|   |-- create_sqlite_tables.sql
|   `-- create_tables.sql
|-- src/
|   |-- clean_jobs.py
|   |-- extract_skills.py
|   |-- load_sqlite_db.py
|   `-- smoke_test_sql_queries.py
|-- requirements.txt
`-- README.md
```

## Main Outputs

Generated locally:

- cleaned job postings table
- normalized skills dimension
- job-skill bridge table
- quality scorecards
- SQLite database
- Power BI dashboard file

Documented in the repository:

- cleaning approach
- data quality findings
- SQL validation
- analytics queries
- BI dashboard design notes

## Data Model Summary

The BI model uses a fact-style jobs table plus skill dimensions:

- jobs table: one row per job posting
- skills table: one row per normalized skill
- job-skill bridge table: many-to-many relationship between jobs and skills

This allows analysis such as top skills, skill combinations, skill demand by role, and salary by skill.

## Reproduce The Project Locally

Create and activate a Python environment:

```powershell
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

Run the notebooks in order:

```text
notebooks/01_data_cleaning.ipynb
notebooks/02_quality_analysis.ipynb
```

Build the SQLite database:

```powershell
python src/load_sqlite_db.py
```

Smoke test the SQL analytics queries:

```powershell
python src/smoke_test_sql_queries.py
```

## Dashboard Notes

Power BI Desktop is used for the dashboard.

The `.pbix` file is intentionally not committed because Power BI files can be large. For portfolio sharing, use dashboard screenshots, documentation, or a GitHub Release asset.

## Limitations

- Salary data is available for only a subset of postings, so salary charts must show sample size.
- Remote-work classification depends on cleaned location and remote indicators.
- Skill extraction is based on parsed job-description tokens, not perfect natural-language understanding.
- The dataset is a snapshot and should not be interpreted as a live labor-market feed.

## Tech Stack

- Python
- Pandas
- Jupyter Notebook
- SQLite
- SQL
- Power BI
- DAX
