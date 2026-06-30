# Project Overview

## Goal

Build a portfolio-ready BI project that analyzes job postings for data and BI roles. The project focuses on market demand for skills, salary patterns, seniority, job categories, and remote-work availability.

## Why This Project Matters

This project demonstrates the full BI workflow:

1. understand a raw dataset
2. clean and enrich it
3. validate data quality
4. model it for analysis
5. write analytical SQL
6. build Power BI dashboard pages
7. explain business insights and limitations

## Analytical Themes

The project is organized around these themes:

- skill demand
- skill categories
- skill co-occurrence
- job title categories
- seniority levels
- salary ranges and salary bands
- remote and location analysis
- company hiring activity

## Completed Work

- inspected the raw Kaggle job postings dataset
- removed duplicate job postings
- cleaned text fields and source fields
- parsed salary into period, annual min/max/midpoint, and bands
- parsed skills into normalized skill and bridge tables
- created job title categories and seniority levels
- generated data quality checks and reports
- built a SQLite analytical database
- created and smoke-tested SQL analytics queries
- built Power BI dashboard pages and exported screenshots

## Current Dashboard Pages

1. Executive Overview
2. Skills Demand
3. Salary Analysis
4. Remote and Location Analysis

## Final Polish Opportunities

- refresh screenshots after major dashboard design changes
- add a dashboard walkthrough document
- optionally share the `.pbix` as a GitHub Release asset

## Main Learning Outcomes

This project practices:

- Python data cleaning
- Pandas transformations
- data quality analysis
- SQL schema design
- SQL business queries
- Power BI modeling
- DAX measures
- dashboard storytelling
- GitHub portfolio preparation

## Key Dataset Limitations

- Salary data is sparse, so salary visuals must show sample size.
- Location data contains broad values such as `United States` and `Anywhere`.
- Remote status is inferred from cleaned fields and should be interpreted carefully.
- Skill extraction is based on parsed description tokens.
- The dataset is a snapshot, not a live market feed.
