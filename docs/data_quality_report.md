# Data Quality Report

## Executive Summary
- Raw rows: 61,953
- Cleaned rows: 58,701
- Rows removed: 3,252 (5.2%)
- Jobs with salary: 9,660 (16.5%)
- Jobs with at least one skill: 45,915 (78.2%)
- Unique skills: 134
- Job-skill assignments: 189,085

## BI Rules
- Salary visuals must be labeled as salary-listed postings only.
- Remote analysis must separate Remote from Broad Location - Unclear.
- Seniority visuals must keep Unknown visible.
- Skill visuals must use the job-skill bridge table.

## Integrity Check Summary
- Checks passed: 8 of 8
- Checks needing review: 0 of 8

## Output Files
- data/processed/quality/quality_scorecard.csv
- data/processed/quality/completeness_report.csv
- data/processed/quality/quality_checks.csv
- data/processed/quality/quality_recommendations.csv