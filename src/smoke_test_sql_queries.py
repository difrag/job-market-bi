"""
Smoke-test the SQLite analytics query library.

This does not validate business meaning. It confirms each statement in
sql/analytics_queries_sqlite.sql can execute against data/job_market.db.
"""

from __future__ import annotations

import re
import sqlite3
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DB_PATH = PROJECT_ROOT / "data" / "job_market.db"
QUERY_PATH = PROJECT_ROOT / "sql" / "analytics_queries_sqlite.sql"


def split_sql_statements(sql_text: str) -> list[str]:
    statements = []
    current_lines = []
    for line in sql_text.splitlines():
        current_lines.append(line)
        if line.strip().endswith(";"):
            statement = "\n".join(current_lines).strip()
            if statement:
                statements.append(statement)
            current_lines = []
    trailing_statement = "\n".join(current_lines).strip()
    if trailing_statement:
        statements.append(trailing_statement)
    return statements


def statement_name(statement: str, index: int) -> str:
    match = re.search(r"-- Query ([0-9.]+)", statement)
    if match:
        return f"Query {match.group(1)}"
    return f"Statement {index}"


def main() -> None:
    sql_text = QUERY_PATH.read_text(encoding="utf-8")
    statements = split_sql_statements(sql_text)

    failures = []
    with sqlite3.connect(DB_PATH) as connection:
        for index, statement in enumerate(statements, start=1):
            name = statement_name(statement, index)
            try:
                cursor = connection.execute(statement)
                cursor.fetchmany(1)
                print(f"PASS {name}")
            except sqlite3.Error as error:
                failures.append((name, str(error)))
                print(f"FAIL {name}: {error}")

    print(f"Statements tested: {len(statements)}")
    print(f"Failures: {len(failures)}")

    if failures:
        raise SystemExit("One or more SQL analytics queries failed.")


if __name__ == "__main__":
    main()
