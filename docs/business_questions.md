# Business Questions - Job Market Intelligence Dashboard

## Overview

This document lists the key business questions that our dashboard will answer. These questions guide our data modeling, SQL queries, and Power BI visualizations.

---

## 🎯 Core Business Questions

### 1. **Skill Demand Analysis**

**Q1.1**: What are the top 20 most in-demand skills for BI/Data roles?
- *Why*: Helps job seekers know what to learn; helps us understand market focus
- *Type*: Descriptive
- *Visualization*: Horizontal bar chart

**Q1.2**: Which skills are trending upward vs. declining?
- *Why*: Identifies emerging skills worth learning
- *Type*: Trend analysis
- *Visualization*: Line chart over time (if date data available)

**Q1.3**: Which skills appear together most frequently?
- *Why*: Shows skill combinations employers want
- *Type*: Correlation analysis
- *Visualization*: Network diagram or heatmap

**Q1.4**: What's the "minimum viable skill set" for entry-level BI roles?
- *Why*: Helps newcomers know the baseline
- *Type*: Statistical analysis
- *Visualization*: Grouped bar chart

---

### 2. **Technical Stack Analysis**

**Q2.1**: What are the most demanded programming languages?
- *Why*: Determines what programming skills to prioritize
- *Type*: Descriptive
- *Visualization*: Bar chart (Python vs SQL vs R vs others)

**Q2.2**: What are the most demanded BI platforms/tools?
- *Why*: Shows whether to learn Power BI, Tableau, Looker, etc.
- *Type*: Descriptive
- *Visualization*: Pie chart or bar chart

**Q2.3**: Which databases are most frequently required?
- *Why*: Shows database skills to invest in (SQL Server, PostgreSQL, etc.)
- *Type*: Descriptive
- *Visualization*: Bar chart

**Q2.4**: How do tool requirements vary by seniority level?
- *Why*: Senior roles need different tools than junior roles
- *Type*: Comparative analysis
- *Visualization*: Grouped bar chart

---

### 3. **Geographic & Company Analysis**

**Q3.1**: Which locations/regions have the most BI job opportunities?
- *Why*: Helps decide where to focus job search
- *Type*: Geographic analysis
- *Visualization*: Map (if location data available)

**Q3.2**: Which companies are hiring the most for BI roles?
- *Why*: Identifies major employers in the field
- *Type*: Ranking
- *Visualization*: Top 10 bar chart

**Q3.3**: Do specific companies prefer certain tools/technologies?
- *Why*: Tailor applications to company tech stacks
- *Type*: Cross-dimensional analysis
- *Visualization*: Matrix/heatmap

**Q3.4**: Are there regional differences in skill demands?
- *Why*: Job market varies by location
- *Type*: Geographic comparison
- *Visualization*: Map with skill overlays (future)

---

### 4. **Job Title & Role Analysis**

**Q4.1**: How many different job titles exist for "BI roles"?
- *Why*: Understand job title variations in the market
- *Type*: Descriptive
- *Visualization*: Word cloud or bar chart

**Q4.2**: What skills are required for "Business Analyst" vs "Data Analyst" vs "BI Developer"?
- *Why*: Understand role-specific expectations
- *Type*: Comparative analysis
- *Visualization*: Grouped comparison chart

**Q4.3**: What's the typical seniority progression (Junior → Mid → Senior)?
- *Why*: Understand career path expectations
- *Type*: Categorical analysis
- *Visualization*: Flow diagram or grouped chart

---

### 5. **Experience & Requirements**

**Q5.1**: What's the typical experience level required for BI roles?
- *Why*: Know whether to apply for entry-level or mid-level roles
- *Type*: Distribution analysis
- *Visualization*: Histogram/bar chart

**Q5.2**: Do certain skills require more experience than others?
- *Why*: Set learning priorities (learn quick-wins first)
- *Type*: Cross-analysis
- *Visualization*: Scatter plot

**Q5.3**: What's the education requirement distribution?
- *Why*: Understand whether degree is necessary
- *Type*: Categorical distribution
- *Visualization*: Pie chart or bar chart

---

### 6. **Compensation Analysis** *(If salary data is available)*

**Q6.1**: What's the salary range for BI roles by level?
- *Why*: Negotiate appropriately
- *Type*: Distribution
- *Visualization*: Box plot or violin plot

**Q6.2**: Which skills correlate with higher salaries?
- *Why*: Invest in high-value skills
- *Type*: Correlation analysis
- *Visualization*: Scatter plot or bar chart

**Q6.3**: Do certain locations or companies pay significantly more?
- *Why*: Consider relocation or company selection
- *Type*: Comparative analysis
- *Visualization*: Geographic or company comparison

---

## 📊 Dashboard Layout

The Power BI dashboard will be organized around these key areas:

1. **Overview Page**: High-level KPIs and top metrics
2. **Skills Analysis**: Deep dive into skill demand and combinations
3. **Tools & Technologies**: Programming languages, platforms, databases
4. **Companies & Geography**: Employer and location insights
5. **Job Titles & Roles**: Role definitions and progressions
6. **Trends & Insights**: Time-series and advanced analysis

---

## 🔄 Iteration Notes

As we build the dashboard:

- Start with questions 1.1, 2.1, 3.1, 4.1 (foundational questions)
- Add additional questions as data quality allows
- Refine questions based on what the data actually contains
- Some questions may need to be adjusted based on data availability

---

## 🎓 Learning Value

This section demonstrates:

- How real BI projects start with business questions (not data)
- The importance of framing analytics around user needs
- How to translate business questions into technical requirements
- The connection between data modeling and business value

**Remember**: Good BI starts with asking the right questions!
