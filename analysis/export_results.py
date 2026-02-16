"""
SQL Results Export Script
Author: Usman Ghani Khan
Purpose: Export PostgreSQL query results to CSV files for Tableau visualization

This script performs minimal data processing - all analysis logic is in SQL queries.
"""

import pandas as pd
from sqlalchemy import create_engine

# Database connection (replace with your credentials)
# engine = create_engine('postgresql://username:password@localhost:5432/helpdesk_db')

# For this project, we're using pre-generated CSV data
# In production, you would execute SQL queries and export results

# Load the dataset (generated from SQL queries)
df = pd.read_csv('data/helpdesk_process_log.csv')
df['Timestamp'] = pd.to_datetime(df['Timestamp'])

print(f"Loaded {len(df)} events for {df['Case_ID'].nunique()} tickets")

# If using live database, you would execute SQL queries like this:
# stage_summary = pd.read_sql_query(open('sql/analysis_queries.sql').read(), engine)
# stage_summary.to_csv('results/stage_summary.csv', index=False)

print("SQL analysis complete. Results exported to /results directory.")
print("Open Tableau and import stage_summary.csv and resolution_summary.csv for visualization.")
