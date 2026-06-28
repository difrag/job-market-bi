# Data Folder

This project uses a Kaggle job-postings dataset as the raw source.

The large raw, processed, and database files are intentionally not committed to GitHub. They are generated or downloaded locally and are ignored by `.gitignore`.

## Source

The raw dataset source is listed in `data/raw/source.txt`.

## Local Files Used During Development

- `data/raw/job_postings_kaggle.csv`
- `data/processed/for BI/job_postings_clean.csv`
- `data/processed/for BI/skills_clean.csv`
- `data/processed/for BI/job_skills_clean.csv`
- `data/job_market.db`

## Why These Files Are Not In Git

These files are large generated artifacts. Keeping them out of GitHub makes the repository easier to clone, review, and maintain.

To reproduce them, run the notebooks and scripts documented in the main `README.md`.
