"""
Build and validate the local SQLite database for the BI model.

This script consumes the cleaned CSV outputs from the data-cleaning notebook and
creates a preparation-focused star schema:

- fact_jobs
- dim_company
- dim_location
- dim_job_title
- dim_date
- dim_skills
- bridge_job_skills

It also writes validation artifacts to data/processed/quality/ and docs/.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data"
PROCESSED_DIR = DATA_DIR / "processed"
QUALITY_DIR = PROCESSED_DIR / "quality"
DOCS_DIR = PROJECT_ROOT / "docs"

DB_PATH = DATA_DIR / "job_market.db"
SCHEMA_PATH = PROJECT_ROOT / "sql" / "create_sqlite_tables.sql"
JOBS_CSV = PROCESSED_DIR / "job_postings_clean.csv"
SKILLS_CSV = PROCESSED_DIR / "skills_clean.csv"
JOB_SKILLS_CSV = PROCESSED_DIR / "job_skills_clean.csv"


JOB_COLUMNS = [
    "index",
    "job_id",
    "company_name_clean",
    "location_clean",
    "location_city",
    "location_state",
    "location_country",
    "title_clean",
    "job_title_category",
    "seniority_level",
    "experience_years_min",
    "estimated_posted_date",
    "posting_source_clean",
    "search_term_clean",
    "schedule_type_simplified",
    "work_from_home_clean",
    "remote_status",
    "is_remote",
    "is_broad_location",
    "posting_age_days",
    "salary_period",
    "salary_min_annual",
    "salary_max_annual",
    "salary_midpoint_annual",
    "salary_band",
    "has_salary_info",
    "skills_count",
    "has_skills",
    "has_skill_sql",
    "has_skill_python",
    "has_skill_excel",
    "has_skill_tableau",
    "has_skill_power_bi",
]

BOOLEAN_COLUMNS = [
    "is_remote",
    "is_broad_location",
    "has_salary_info",
    "has_skills",
    "has_skill_sql",
    "has_skill_python",
    "has_skill_excel",
    "has_skill_tableau",
    "has_skill_power_bi",
]

INTEGER_COLUMNS = [
    "index",
    "experience_years_min",
    "posting_age_days",
    "skills_count",
]

NUMERIC_COLUMNS = [
    "salary_min_annual",
    "salary_max_annual",
    "salary_midpoint_annual",
]


def require_inputs() -> None:
    missing_paths = [
        path for path in [SCHEMA_PATH, JOBS_CSV, SKILLS_CSV, JOB_SKILLS_CSV] if not path.exists()
    ]
    if missing_paths:
        missing_display = "\n".join(str(path) for path in missing_paths)
        raise FileNotFoundError(f"Missing required input files:\n{missing_display}")


def clean_text_dimension(series: pd.Series, fallback: str) -> pd.Series:
    return series.fillna(fallback).astype(str).str.strip().replace({"": fallback})


def boolean_to_int(series: pd.Series) -> pd.Series:
    return (
        series.astype(str)
        .str.strip()
        .str.lower()
        .map({"true": 1, "false": 0, "1": 1, "0": 0})
        .fillna(0)
        .astype(int)
    )


def prepare_for_sql(df: pd.DataFrame) -> pd.DataFrame:
    return df.astype(object).where(pd.notna(df), None)


def create_schema(connection: sqlite3.Connection) -> None:
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    connection.executescript(schema_sql)
    connection.execute("PRAGMA foreign_keys = ON;")


def build_dimensions(jobs_df: pd.DataFrame, skills_df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    dim_company = (
        pd.DataFrame({"company_name": clean_text_dimension(jobs_df["company_name_clean"], "Unknown Company")})
        .drop_duplicates()
        .sort_values("company_name")
        .reset_index(drop=True)
    )
    dim_company.insert(0, "company_id", range(1, len(dim_company) + 1))

    dim_location = jobs_df[
        ["location_clean", "location_city", "location_state", "location_country"]
    ].copy()
    dim_location["location_clean"] = clean_text_dimension(dim_location["location_clean"], "Unknown Location")
    dim_location = (
        dim_location.drop_duplicates()
        .sort_values(["location_clean", "location_city", "location_state", "location_country"], na_position="last")
        .reset_index(drop=True)
    )
    dim_location.insert(0, "location_id", range(1, len(dim_location) + 1))

    dim_job_title = jobs_df[
        ["title_clean", "job_title_category", "seniority_level", "experience_years_min"]
    ].copy()
    dim_job_title["title_clean"] = clean_text_dimension(dim_job_title["title_clean"], "Unknown Title")
    dim_job_title["job_title_category"] = clean_text_dimension(
        dim_job_title["job_title_category"], "Other"
    )
    dim_job_title["seniority_level"] = clean_text_dimension(
        dim_job_title["seniority_level"], "Unknown"
    )
    dim_job_title = (
        dim_job_title.drop_duplicates()
        .sort_values(["title_clean", "job_title_category", "seniority_level", "experience_years_min"], na_position="last")
        .reset_index(drop=True)
    )
    dim_job_title.insert(0, "job_title_id", range(1, len(dim_job_title) + 1))

    dates = pd.to_datetime(jobs_df["estimated_posted_date"], errors="coerce").dropna().drop_duplicates()
    dim_date = pd.DataFrame({"full_date": dates.sort_values()})
    dim_date["date_key"] = dim_date["full_date"].dt.strftime("%Y-%m-%d")
    dim_date["full_date"] = dim_date["date_key"]
    dim_date["year"] = pd.to_datetime(dim_date["date_key"]).dt.year
    dim_date["quarter"] = pd.to_datetime(dim_date["date_key"]).dt.quarter
    dim_date["month"] = pd.to_datetime(dim_date["date_key"]).dt.month
    dim_date["month_name"] = pd.to_datetime(dim_date["date_key"]).dt.month_name()
    dim_date["day"] = pd.to_datetime(dim_date["date_key"]).dt.day
    dim_date["weekday_name"] = pd.to_datetime(dim_date["date_key"]).dt.day_name()
    dim_date = dim_date[
        ["date_key", "full_date", "year", "quarter", "month", "month_name", "day", "weekday_name"]
    ].reset_index(drop=True)

    dim_skills = skills_df[["skill_id", "skill_name", "skill_category"]].copy()
    dim_skills["skill_id"] = pd.to_numeric(dim_skills["skill_id"], errors="raise").astype(int)
    dim_skills = dim_skills.sort_values("skill_id").reset_index(drop=True)

    return {
        "dim_company": dim_company,
        "dim_location": dim_location,
        "dim_job_title": dim_job_title,
        "dim_date": dim_date,
        "dim_skills": dim_skills,
    }


def build_fact_jobs(jobs_df: pd.DataFrame, dimensions: dict[str, pd.DataFrame]) -> pd.DataFrame:
    jobs = jobs_df.copy()
    jobs["company_name_key"] = clean_text_dimension(jobs["company_name_clean"], "Unknown Company")
    jobs["location_clean_key"] = clean_text_dimension(jobs["location_clean"], "Unknown Location")
    jobs["title_clean_key"] = clean_text_dimension(jobs["title_clean"], "Unknown Title")
    jobs["job_title_category_key"] = clean_text_dimension(jobs["job_title_category"], "Other")
    jobs["seniority_level_key"] = clean_text_dimension(jobs["seniority_level"], "Unknown")

    fact = jobs.merge(
        dimensions["dim_company"],
        how="left",
        left_on="company_name_key",
        right_on="company_name",
    )
    fact = fact.merge(
        dimensions["dim_location"],
        how="left",
        left_on=["location_clean_key", "location_city", "location_state", "location_country"],
        right_on=["location_clean", "location_city", "location_state", "location_country"],
    )
    fact = fact.merge(
        dimensions["dim_job_title"],
        how="left",
        left_on=["title_clean_key", "job_title_category_key", "seniority_level_key", "experience_years_min"],
        right_on=["title_clean", "job_title_category", "seniority_level", "experience_years_min"],
    )

    fact["date_key"] = pd.to_datetime(fact["estimated_posted_date"], errors="coerce").dt.strftime("%Y-%m-%d")
    fact["source_index"] = pd.to_numeric(fact["index"], errors="coerce").astype("Int64")

    for column in BOOLEAN_COLUMNS:
        fact[column] = boolean_to_int(fact[column])
    for column in INTEGER_COLUMNS:
        if column in fact.columns:
            fact[column] = pd.to_numeric(fact[column], errors="coerce").astype("Int64")
    for column in NUMERIC_COLUMNS:
        fact[column] = pd.to_numeric(fact[column], errors="coerce")

    fact_columns = [
        "job_id",
        "source_index",
        "company_id",
        "location_id",
        "job_title_id",
        "date_key",
        "posting_source_clean",
        "search_term_clean",
        "schedule_type_simplified",
        "work_from_home_clean",
        "remote_status",
        "is_remote",
        "is_broad_location",
        "posting_age_days",
        "salary_period",
        "salary_min_annual",
        "salary_max_annual",
        "salary_midpoint_annual",
        "salary_band",
        "has_salary_info",
        "skills_count",
        "has_skills",
        "has_skill_sql",
        "has_skill_python",
        "has_skill_excel",
        "has_skill_tableau",
        "has_skill_power_bi",
    ]
    return fact[fact_columns].copy()


def build_bridge_job_skills(
    job_skills_df: pd.DataFrame, dim_skills: pd.DataFrame
) -> pd.DataFrame:
    skill_lookup = dim_skills[["skill_id", "skill_name"]]
    bridge = job_skills_df[["job_id", "skill_name"]].merge(
        skill_lookup,
        how="left",
        on="skill_name",
    )
    bridge = bridge[["job_id", "skill_id"]].drop_duplicates().copy()
    bridge["skill_id"] = pd.to_numeric(bridge["skill_id"], errors="raise").astype(int)
    return bridge


def load_tables(
    connection: sqlite3.Connection,
    dimensions: dict[str, pd.DataFrame],
    fact_jobs: pd.DataFrame,
    bridge_job_skills: pd.DataFrame,
) -> None:
    load_order = ["dim_company", "dim_location", "dim_job_title", "dim_date", "dim_skills"]
    for table_name in load_order:
        prepare_for_sql(dimensions[table_name]).to_sql(
            table_name, connection, if_exists="append", index=False
        )

    prepare_for_sql(fact_jobs).to_sql("fact_jobs", connection, if_exists="append", index=False)
    prepare_for_sql(bridge_job_skills).to_sql(
        "bridge_job_skills", connection, if_exists="append", index=False
    )
    connection.commit()


def scalar(connection: sqlite3.Connection, sql: str) -> int:
    return int(connection.execute(sql).fetchone()[0])


def validate_load(
    connection: sqlite3.Connection,
    jobs_df: pd.DataFrame,
    skills_df: pd.DataFrame,
    job_skills_df: pd.DataFrame,
    dimensions: dict[str, pd.DataFrame],
) -> pd.DataFrame:
    expected = {
        "fact_jobs row count": len(jobs_df),
        "dim_skills row count": len(skills_df),
        "bridge_job_skills row count": len(job_skills_df),
        "dim_company row count": len(dimensions["dim_company"]),
        "dim_location row count": len(dimensions["dim_location"]),
        "dim_job_title row count": len(dimensions["dim_job_title"]),
        "dim_date row count": len(dimensions["dim_date"]),
    }

    actual = {
        "fact_jobs row count": scalar(connection, "SELECT COUNT(*) FROM fact_jobs;"),
        "dim_skills row count": scalar(connection, "SELECT COUNT(*) FROM dim_skills;"),
        "bridge_job_skills row count": scalar(connection, "SELECT COUNT(*) FROM bridge_job_skills;"),
        "dim_company row count": scalar(connection, "SELECT COUNT(*) FROM dim_company;"),
        "dim_location row count": scalar(connection, "SELECT COUNT(*) FROM dim_location;"),
        "dim_job_title row count": scalar(connection, "SELECT COUNT(*) FROM dim_job_title;"),
        "dim_date row count": scalar(connection, "SELECT COUNT(*) FROM dim_date;"),
    }

    rows = [
        {
            "check_name": name,
            "expected": expected[name],
            "actual": actual[name],
            "status": "PASS" if expected[name] == actual[name] else "FAIL",
            "notes": "Loaded table count matches source preparation data",
        }
        for name in expected
    ]

    additional_checks = [
        (
            "duplicate job_id in fact_jobs",
            0,
            scalar(connection, "SELECT COUNT(*) - COUNT(DISTINCT job_id) FROM fact_jobs;"),
            "job_id should remain unique after SQL load",
        ),
        (
            "orphan bridge job_id",
            0,
            scalar(
                connection,
                """
                SELECT COUNT(*)
                FROM bridge_job_skills b
                LEFT JOIN fact_jobs f ON b.job_id = f.job_id
                WHERE f.job_id IS NULL;
                """,
            ),
            "Every bridge row should point to a loaded job",
        ),
        (
            "orphan bridge skill_id",
            0,
            scalar(
                connection,
                """
                SELECT COUNT(*)
                FROM bridge_job_skills b
                LEFT JOIN dim_skills s ON b.skill_id = s.skill_id
                WHERE s.skill_id IS NULL;
                """,
            ),
            "Every bridge row should point to a loaded skill",
        ),
        (
            "skill count mismatch",
            0,
            scalar(
                connection,
                """
                SELECT COUNT(*)
                FROM fact_jobs f
                LEFT JOIN (
                    SELECT job_id, COUNT(*) AS bridge_skill_count
                    FROM bridge_job_skills
                    GROUP BY job_id
                ) b ON f.job_id = b.job_id
                WHERE f.skills_count != COALESCE(b.bridge_skill_count, 0);
                """,
            ),
            "Fact skills_count should match bridge table rows",
        ),
        (
            "foreign key violations",
            0,
            len(connection.execute("PRAGMA foreign_key_check;").fetchall()),
            "SQLite foreign key check should return no rows",
        ),
    ]

    for check_name, expected_value, actual_value, notes in additional_checks:
        rows.append(
            {
                "check_name": check_name,
                "expected": expected_value,
                "actual": actual_value,
                "status": "PASS" if expected_value == actual_value else "FAIL",
                "notes": notes,
            }
        )

    return pd.DataFrame(rows)


def write_validation_outputs(validation_df: pd.DataFrame, connection: sqlite3.Connection) -> None:
    QUALITY_DIR.mkdir(parents=True, exist_ok=True)
    DOCS_DIR.mkdir(parents=True, exist_ok=True)

    validation_path = QUALITY_DIR / "sql_load_validation.csv"
    validation_df.to_csv(validation_path, index=False)

    table_counts = pd.read_sql_query(
        """
        SELECT 'fact_jobs' AS table_name, COUNT(*) AS row_count FROM fact_jobs
        UNION ALL
        SELECT 'dim_company', COUNT(*) FROM dim_company
        UNION ALL
        SELECT 'dim_location', COUNT(*) FROM dim_location
        UNION ALL
        SELECT 'dim_job_title', COUNT(*) FROM dim_job_title
        UNION ALL
        SELECT 'dim_date', COUNT(*) FROM dim_date
        UNION ALL
        SELECT 'dim_skills', COUNT(*) FROM dim_skills
        UNION ALL
        SELECT 'bridge_job_skills', COUNT(*) FROM bridge_job_skills
        ORDER BY table_name;
        """,
        connection,
    )
    table_counts.to_csv(QUALITY_DIR / "sql_table_counts.csv", index=False)

    def markdown_table(df: pd.DataFrame) -> str:
        headers = [str(column) for column in df.columns]
        rows = df.astype(str).values.tolist()
        lines = [
            "| " + " | ".join(headers) + " |",
            "| " + " | ".join(["---"] * len(headers)) + " |",
        ]
        lines.extend("| " + " | ".join(row) + " |" for row in rows)
        return "\n".join(lines)

    passed = int((validation_df["status"] == "PASS").sum())
    total = len(validation_df)
    lines = [
        "# SQL Load Validation",
        "",
        f"- Database: `{DB_PATH.relative_to(PROJECT_ROOT)}`",
        f"- Validation checks passed: {passed} of {total}",
        f"- Validation output: `data/processed/quality/{validation_path.name}`",
        "",
        "## Table Counts",
        "",
        markdown_table(table_counts),
        "",
        "## Validation Checks",
        "",
        markdown_table(validation_df[["check_name", "expected", "actual", "status"]]),
        "",
        "## Next Step",
        "",
        "The database is ready for analytics SQL queries and Power BI model setup.",
    ]
    (DOCS_DIR / "sql_load_validation.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> None:
    require_inputs()
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    jobs_df = pd.read_csv(JOBS_CSV, usecols=JOB_COLUMNS, dtype={"job_id": "string"}, low_memory=False)
    skills_df = pd.read_csv(SKILLS_CSV)
    job_skills_df = pd.read_csv(JOB_SKILLS_CSV, dtype={"job_id": "string"})

    jobs_df["job_id"] = jobs_df["job_id"].astype(str)
    job_skills_df["job_id"] = job_skills_df["job_id"].astype(str)

    dimensions = build_dimensions(jobs_df, skills_df)
    fact_jobs = build_fact_jobs(jobs_df, dimensions)
    bridge_job_skills = build_bridge_job_skills(job_skills_df, dimensions["dim_skills"])

    with sqlite3.connect(DB_PATH) as connection:
        connection.execute("PRAGMA foreign_keys = ON;")
        create_schema(connection)
        load_tables(connection, dimensions, fact_jobs, bridge_job_skills)
        validation_df = validate_load(connection, jobs_df, skills_df, job_skills_df, dimensions)
        write_validation_outputs(validation_df, connection)

    print(f"Created SQLite database: {DB_PATH}")
    print(f"Validation checks passed: {(validation_df['status'] == 'PASS').sum()} of {len(validation_df)}")
    print(validation_df[["check_name", "expected", "actual", "status"]].to_string(index=False))

    if not (validation_df["status"] == "PASS").all():
        raise SystemExit("One or more SQL load validation checks failed.")


if __name__ == "__main__":
    main()
