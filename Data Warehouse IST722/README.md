# United States FEC Individual Contribution Data Analysis (2007-2008 Election)

## 📌 Project Overview

This repository contains data modeling and visualization resources for analyzing the individual contributions data from the Federal Election Commission (FEC) during the 2007-2008 election cycle. The analysis was performed using Snowflake, dbt, and Power BI, enabling comprehensive insights into campaign contributions and expenditures.

## 📂 Data Source

- **Federal Election Commission (FEC)**: Individual contribution data for the 2007-2008 election.

## 🛠️ Technologies Used

- **Snowflake**: Cloud data warehousing and storage
- **dbt (Data Build Tool)**: Data modeling, transformation, and documentation
- **Power BI**: Interactive data visualization and dashboarding

## 🔄 Data Modeling & Transformation

- Created dimensional and fact tables using dbt, including:
  - Dimension tables: Candidates, Committees, Contributors, Dates, Expense Categories, Expense Purposes, Payees, States, Transaction Types
  - Fact tables: Individual Contributions, Campaign Expenditures

- Developed dbt models for structured data transformations and documentation.

## 📈 Visualization & Analysis

- Developed interactive dashboards using Power BI to visualize:
  - Total contributions by state
  - Contributions by candidate
  - Contributions by occupation
  - Trends and distributions of campaign expenditures and contributions

## 📊 Data Model Structure

### Fact Table - Individual Contributions
- Contribution amount
- Transaction type
- Contributor details
- Candidate and committee affiliations

### Fact Table - Campaign Expenditures
- Expenditure details
- Payee information
- Committee and candidate affiliations

## 🚀 Key Insights
- Analyzed key contributors by occupation and geographic distribution
- Provided interactive analytics on the fundraising performance of various candidates
- Identified significant expenditure categories and their trends
