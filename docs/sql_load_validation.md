# SQL Load Validation

- Database: `data\job_market.db`
- Validation checks passed: 12 of 12
- Validation output: `data/processed/quality/sql_load_validation.csv`

## Table Counts

| table_name | row_count |
| --- | --- |
| bridge_job_skills | 189085 |
| dim_company | 13428 |
| dim_date | 841 |
| dim_job_title | 25147 |
| dim_location | 971 |
| dim_skills | 134 |
| fact_jobs | 58701 |

## Validation Checks

| check_name | expected | actual | status |
| --- | --- | --- | --- |
| fact_jobs row count | 58701 | 58701 | PASS |
| dim_skills row count | 134 | 134 | PASS |
| bridge_job_skills row count | 189085 | 189085 | PASS |
| dim_company row count | 13428 | 13428 | PASS |
| dim_location row count | 971 | 971 | PASS |
| dim_job_title row count | 25147 | 25147 | PASS |
| dim_date row count | 841 | 841 | PASS |
| duplicate job_id in fact_jobs | 0 | 0 | PASS |
| orphan bridge job_id | 0 | 0 | PASS |
| orphan bridge skill_id | 0 | 0 | PASS |
| skill count mismatch | 0 | 0 | PASS |
| foreign key violations | 0 | 0 | PASS |

## Next Step

The database is ready for analytics SQL queries and Power BI model setup.