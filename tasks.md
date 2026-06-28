# Project Tasks

This file tracks the project at a practical milestone level.

## Milestone 1: Project Setup

Status: complete

Completed:

- created project folder structure
- created Python environment
- added requirements file
- added documentation folders
- added Git ignore rules

## Milestone 2: Data Cleaning

Status: complete

Completed:

- loaded raw Kaggle job postings data
- removed unnamed columns
- removed duplicate job postings
- standardized text fields
- improved remote-status classification
- parsed posting dates
- parsed salary fields
- built salary bands
- categorized job titles
- inferred seniority levels
- parsed and normalized skills
- created job-skill bridge table

Main output:

- `notebooks/01_data_cleaning.ipynb`

## Milestone 3: Data Quality Analysis

Status: complete

Completed:

- compared raw and cleaned row counts
- checked duplicate handling
- checked completeness
- checked relationship integrity
- created distribution tables
- generated a data quality report

Main output:

- `notebooks/02_quality_analysis.ipynb`
- `docs/data_quality_report.md`

## Milestone 4: SQL Prep Layer

Status: complete

Completed:

- created SQLite table definitions
- loaded cleaned data into SQLite
- created dimensions and bridge table
- validated table counts and relationships
- created SQL analytics query pack
- smoke-tested the SQL queries

Main outputs:

- `src/load_sqlite_db.py`
- `sql/create_sqlite_tables.sql`
- `sql/analytics_queries_sqlite.sql`
- `docs/sql_load_validation.md`

## Milestone 5: Power BI Dashboard

Status: in progress

Completed:

- Executive Overview page
- Skills Demand page
- skill co-occurrence measure
- Salary Analysis page
- DAX documentation started

Remaining:

- Remote and Location Analysis page
- dashboard layout polish
- final visual QA
- screenshots for GitHub
- dashboard walkthrough documentation

## Milestone 6: GitHub Portfolio Publishing

Status: in progress

Completed:

- updated `.gitignore`
- excluded large data, database, virtual environment, and Power BI binary artifacts
- refreshed main README
- added data folder documentation
- added GitHub publishing checklist
- documented Power BI measures

Remaining:

- create first Git commit
- create GitHub repository
- add remote
- push to GitHub
- add dashboard screenshots after the dashboard is final
