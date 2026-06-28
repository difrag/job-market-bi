# Data Dictionary - Job Market Intelligence Dashboard

## Overview

This document describes every column in the raw job postings data. Use this as reference when cleaning data, writing SQL queries, and building Power BI dashboards.

---

## 📋 Table: job_postings_kaggle

**Source**: `data/raw/job_postings_kaggle.csv`  
**Data Source**: Kaggle dataset "Data Analyst Job Postings - Google Search"  
**Updated**: Milestone 0 (real dataset integration)  
**Rows**: Hundreds of realistic job postings (actual count depends on the Kaggle download)

### Column Definitions

| Column Name | Data Type | Description | Example | Notes |
|------------|-----------|-------------|---------|-------|
| `index` | Integer | Original row index from the downloaded file | 0 | Use only as file order metadata |
| `title` | Text | Job title displayed in the posting | "Data Analyst" | Primary field for title categorization |
| `company_name` | Text | Company name from the posting | "Meta" | May include abbreviations or inconsistent casing |
| `location` | Text | Location text from the posting | "Anywhere" or "Olathe, KS" | Includes remote and country-level values |
| `via` | Text | Source of the posting | "via LinkedIn" | Useful to understand posting source |
| `description` | Text (Long) | Full job description and requirements | "In the intersection of compliance..." | Primary source for skill extraction and role details |
| `extensions` | Text | Additional posting metadata | "['12 hours ago', 'Full-time', 'Health insurance']" | Contains structured metadata from scraping |
| `job_id` | Text | Unique identifier assigned by the scraper | "3" | May not be an external stable job ID |
| `thumbnail` | Text | Image or URL metadata | [URL string] | Not needed for early analysis |
| `posted_at` | Text | Relative posting age | "12 hours ago" | Useful for freshness analysis if normalized |
| `schedule_type` | Text | Work schedule label | "Full-time" | Helps distinguish full-time vs contract roles |
| `work_from_home` | Text | Remote work indicator | "Work from home" | Needs normalization to categories |
| `salary` | Text | Raw salary text | "15–25 an hour" | Needs parsing into numeric range |
| `search_term` | Text | Search query used to find the job | "data analyst jobs" | Useful for keyword analysis |
| `date_time` | Text | Scrape timestamp for the row | "2024-06-23 10:40:00" | Useful for dataset tracking |
| `search_location` | Text | Search location used | "United States" | Useful for geographic filtering |
| `commute_time` | Text | Commute information from posting | "" or "1 hour" | Likely sparse; optional analysis |
| `salary_pay` | Text | Raw pay description | "15–25 an hour" | Similar data to `salary`; verify usage |
| `salary_rate` | Text | Pay frequency label | "Hourly" | Needs standardization for salary analysis |
| `salary_avg` | Decimal | Average salary estimate | 20 | May be derived by the scraper; verify accuracy |
| `salary_min` | Decimal | Minimum salary estimate | 15 | Needs currency and frequency standardization |
| `salary_max` | Decimal | Maximum salary estimate | 25 | Needs currency and frequency standardization |
| `salary_hourly` | Decimal | Hourly salary conversion | 20 | Useful for salary benchmarking |
| `salary_yearly` | Decimal | Yearly salary equivalent | 41600 | Useful for salary comparison across postings |
| `salary_standardized` | Decimal | Standardized salary measure | 41600 | Useful for normalized salary analysis |
| `description_tokens` | Text | Tokenized description metadata | [text vector] | Optional; not required for early cleaning |

---

## 📊 Sample Data Preview

Here's what the raw data looks like (first 2 rows):

```
job_id: 1
company_name: "Acme Analytics Corp"
job_title: "Senior Business Intelligence Developer"
job_description: "Looking for an experienced BI developer..."
salary_min: 95000
salary_max: 140000
location: "New York, NY"
employment_type: "Full-Time"
experience_level: "Senior"
posting_date: 2024-06-20
skills_required: "Python, SQL, Power BI, DAX, Azure"
education_required: "Bachelor's Degree"
```

---

## 🔧 Data Quality Issues & Cleaning Rules

### Known Issues in Raw Data

**Issue 1: Company Name Variations**
- "Microsoft" vs "MICROSOFT" vs "Microsoft Corp"
- **Solution**: Standardize to title case in Milestone 2

**Issue 2: Salary Missing**
- Some postings don't include salary
- **Solution**: Mark as NULL; create indicator column

**Issue 3: Location Inconsistency**
- "New York, NY" vs "NY" vs "New York"
- "Remote" vs "Fully Remote" vs "WFH"
- **Solution**: Parse and standardize in Milestone 2

**Issue 4: Skills as String**
- "Python, SQL, Power BI" (comma-separated)
- "Python and SQL" (text variation)
- **Solution**: Parse into individual skills in Milestone 2

**Issue 5: Job Titles Vary Widely**
- "BI Developer", "Business Intelligence Developer", "BI Engineer"
- **Solution**: Categorize into groups (Developer, Analyst, Engineer, etc.)

---

## 🗂️ Future Table Structure

In **Milestone 3**, we'll normalize this into a proper database schema:

```
jobs (fact table)
├── job_id (PK)
├── company_id (FK)
├── job_title_id (FK)
├── location_id (FK)
├── salary_min
├── salary_max
├── employment_type
├── experience_level
├── posting_date

companies (dimension)
├── company_id (PK)
├── company_name (unique)

job_titles (dimension)
├── job_title_id (PK)
├── job_title_raw
├── job_title_category (standardized)

skills (dimension)
├── skill_id (PK)
├── skill_name

job_skills (bridge table)
├── job_id (FK)
├── skill_id (FK)
```

This structure makes analysis much easier in Power BI!

---

## 📏 Data Type Specifications

**Integer**: Whole numbers (no decimals)
- Examples: job_id, year

**Decimal/Float**: Numbers with decimals
- Examples: salary_min, salary_max

**Text**: Short text (< 255 characters)
- Examples: company_name, location, employment_type

**Text (Long)**: Long text (>255 characters)
- Examples: job_description, skills_required

**Date**: Date values (YYYY-MM-DD format)
- Examples: posting_date

**NULL**: Missing or unknown value
- Handled differently in each tool (Python, SQL, Power BI)

---

## 🎓 Learning Notes

Understanding a data dictionary is crucial because:

1. **Data Cleaning**: You know what "clean" looks like
2. **SQL Queries**: You understand column meanings for WHERE clauses
3. **Power BI**: You build visualizations with proper context
4. **Communication**: You can explain data to non-technical stakeholders

**Remember**: The data dictionary is your reference guide throughout the entire project!

---

## 📝 Updates

| Date | Version | Change |
|------|---------|--------|
| 2024-06-23 | 1.0 | Initial data dictionary for sample data |
| TBD | 2.0 | Will be updated with production data specifics |

---

**Next Step**: Review the downloaded Kaggle data in `data/raw/job_postings_kaggle.csv` to see this dictionary in action.
