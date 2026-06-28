# Power BI Dashboard

This folder documents the Power BI dashboard for the Job Market BI Analytics project.

The local `.pbix` file is not committed to GitHub because Power BI files can be large. The repository should contain dashboard documentation, DAX notes, and screenshots instead.

## Pages

Completed or in progress:

1. Executive Overview
2. Skills Demand
3. Salary Analysis
4. Remote and Location Analysis

## Page 1: Executive Overview

Purpose:

- show the overall job market snapshot
- summarize total jobs, salary coverage, remote share, top categories, and posting trends

Typical visuals:

- KPI cards
- jobs by posting date trend
- top job categories
- top skills
- remote status breakdown

## Page 2: Skills Demand

Purpose:

- identify the most requested skills
- compare skill categories
- analyze skill demand by job category and seniority
- show skills that commonly appear together

Typical visuals:

- top skills bar chart
- skill category chart
- job category by skill matrix
- seniority by skill matrix
- co-occurring skills chart

## Page 3: Salary Analysis

Purpose:

- compare annualized salary by role, seniority, skill, and remote status
- show salary distribution using cleaned salary bands
- keep salary sample size visible

Important rule:

Salary visuals use only postings with parsed salary data.

Typical visuals:

- salary KPI cards
- salary band distribution
- median salary by job category
- median salary by seniority
- median salary by skill
- remote salary comparison

## Page 4: Remote And Location Analysis

Purpose:

- analyze remote work availability
- compare remote share by role and seniority
- review location quality and geographic concentration

Important rule:

`Broad Location - Unclear` is not treated as remote.

## Files To Add Later

Recommended:

- dashboard screenshots
- final dashboard walkthrough
- exported Power BI template if small enough
- GitHub Release link for `.pbix` if shared

## Notes For Portfolio Reviewers

This dashboard is built from cleaned CSV outputs and a validated SQLite prep layer. The BI model uses a job table, a skills dimension, and a job-skill bridge table to support many-to-many skill analysis.
