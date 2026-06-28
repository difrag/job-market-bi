# GitHub Publishing Checklist

Use this checklist before pushing the project to GitHub.

## 1. Keep Large Artifacts Out Of Git

Do not commit:

- raw CSV files
- processed CSV files
- SQLite database files
- Power BI `.pbix` files over normal GitHub limits
- virtual environments
- temporary inspection files

These are ignored in `.gitignore`.

## 2. Commit The Project Logic

Commit:

- notebooks
- Python scripts
- SQL scripts
- documentation
- README files
- Power BI notes, DAX documentation, and screenshots

## 3. Recommended Portfolio Repository Contents

The repository should explain:

- the business problem
- the data source
- cleaning steps
- quality checks
- data model
- SQL analytics layer
- Power BI dashboard pages
- limitations of the dataset

## 4. Suggested Git Commands

From the project folder:

```powershell
git init
git add .
git status
git commit -m "Initial job market BI project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/job-market-bi.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username.

## 5. Optional Power BI Sharing

If you want to share the `.pbix`, use one of these options:

- upload it as a GitHub Release asset
- use Git LFS
- publish screenshots and document the dashboard in the repo

For a portfolio, screenshots plus clear documentation are usually enough.
