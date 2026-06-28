# DAX Measures

These are the main measures used in the Power BI dashboard.

## Core Measures

```DAX
Total Jobs =
DISTINCTCOUNT('job_postings_clean'[job_id])
```

```DAX
Jobs With Salary =
CALCULATE(
    [Total Jobs],
    KEEPFILTERS(
        NOT ISBLANK('job_postings_clean'[salary_midpoint_annual])
    )
)
```

```DAX
Salary Coverage % =
DIVIDE(
    [Jobs With Salary],
    [Total Jobs]
)
```

```DAX
Remote Jobs =
CALCULATE(
    [Total Jobs],
    'job_postings_clean'[remote_status] = "Remote"
)
```

```DAX
Remote Job % =
DIVIDE(
    [Remote Jobs],
    [Total Jobs]
)
```

## Skills Measures

```DAX
Jobs With Skills =
DISTINCTCOUNT('job_skills_clean'[job_id])
```

```DAX
Skill Demand Count =
DISTINCTCOUNT('job_skills_clean'[job_id])
```

```DAX
Skill Mentions =
COUNTROWS('job_skills_clean')
```

```DAX
Distinct Skills =
DISTINCTCOUNT('job_skills_clean'[skill_id])
```

```DAX
Average Skills Per Job =
DIVIDE(
    [Skill Mentions],
    [Jobs With Skills]
)
```

```DAX
Skill Demand % of Jobs =
VAR JobsInScope =
    CALCULATE(
        [Total Jobs],
        REMOVEFILTERS('skills_clean'),
        REMOVEFILTERS('job_skills_clean')
    )
RETURN
DIVIDE([Skill Demand Count], JobsInScope)
```

## Skill Co-Occurrence

Disconnected selector table:

```DAX
Skill Selector =
SELECTCOLUMNS(
    'skills_clean',
    "skill_id", VALUE('skills_clean'[skill_id]),
    "skill_name", 'skills_clean'[skill_name]
)
```

Measure:

```DAX
Co-occurring Skill Jobs =
VAR SelectedSkillID =
    SELECTEDVALUE('Skill Selector'[skill_id])

VAR CurrentSkillID =
    VALUE(SELECTEDVALUE('skills_clean'[skill_id]))

VAR JobsWithSelectedSkill =
    CALCULATETABLE(
        VALUES('job_skills_clean'[job_id]),
        REMOVEFILTERS('skills_clean'),
        'job_skills_clean'[skill_id] = SelectedSkillID
    )

RETURN
IF(
    NOT ISBLANK(SelectedSkillID)
        && CurrentSkillID <> SelectedSkillID,
    CALCULATE(
        DISTINCTCOUNT('job_skills_clean'[job_id]),
        TREATAS(JobsWithSelectedSkill, 'job_skills_clean'[job_id])
    )
)
```

## Salary Measures

```DAX
Average Annual Salary =
CALCULATE(
    AVERAGE('job_postings_clean'[salary_midpoint_annual]),
    KEEPFILTERS(
        NOT ISBLANK('job_postings_clean'[salary_midpoint_annual])
    )
)
```

```DAX
Median Annual Salary =
CALCULATE(
    MEDIAN('job_postings_clean'[salary_midpoint_annual]),
    KEEPFILTERS(
        NOT ISBLANK('job_postings_clean'[salary_midpoint_annual])
    )
)
```

```DAX
Jobs With Salary by Skill =
VAR JobsInSkillContext =
    VALUES('job_skills_clean'[job_id])
RETURN
CALCULATE(
    [Jobs With Salary],
    TREATAS(
        JobsInSkillContext,
        'job_postings_clean'[job_id]
    )
)
```

```DAX
Median Annual Salary by Skill =
VAR JobsInSkillContext =
    VALUES('job_skills_clean'[job_id])
RETURN
CALCULATE(
    [Median Annual Salary],
    TREATAS(
        JobsInSkillContext,
        'job_postings_clean'[job_id]
    )
)
```

## Modeling Notes

- Use `Skill Demand Count` for skill demand visuals.
- Use salary-by-skill measures when the visual axis comes from `skills_clean`.
- Keep salary sample size visible in tooltips.
- Keep `Unknown` seniority visible unless the visual is explicitly filtered.
- Do not combine `Broad Location - Unclear` with `Remote`.
