import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import datetime

print("Initializing data generation...")

# Set seed for reproducibility
np.random.seed(1042)
n_rows = 100000

# ==========================================
# 1. GENERATE THE BASE DATA
# ==========================================
stations = ["YUL", "LHR", "JFK", "DXB", "SIN", "FRA", "NRT"]
handlers = ["Swissport", "Menzies", "dnata", "WFS", "Menzies Aviation"]

# Generate random dates for the year 2025
date_range = pd.date_range(start='2025-01-01', end='2025-12-31')
flight_dates = np.random.choice(date_range, size=n_rows)

# Build the DataFrame
df = pd.DataFrame({
    'audit_id': range(1, n_rows + 1),
    
    # Error 1: Casing and spacing typos in station codes
    'station_code': np.random.choice(
        stations + ["yul", " LHR", "JFK "], 
        size=n_rows, 
        p=[0.13]*7 + [0.03, 0.03, 0.03]
    ),
    
    # Error 2: Inconsistent handler naming
    'handler_name': np.random.choice(handlers, size=n_rows),
    
    'flight_date': flight_dates,
    
    'turnaround_target_mins': np.random.choice([45, 60, 90, 120], size=n_rows),
    
    # Baseline actuals: Normal distribution around 65 mins
    'turnaround_actual_mins': np.round(np.random.normal(loc=65, scale=15, size=n_rows)),
    
    # Baseline baggage: Normal distribution around 15 mins
    'baggage_delay_mins': np.round(np.random.normal(loc=15, scale=8, size=n_rows)),
    
    'safety_incident_flag': np.random.choice([True, False], size=n_rows, p=[0.02, 0.98])
})

# ==========================================
# 2. INJECT REALISTIC AUDIT ERRORS
# ==========================================
print("Injecting operational anomalies...")

# Error 3: Impossible operational values (Negative baggage delays)
neg_baggage_idx = np.random.choice(df.index, size=500, replace=False)
df.loc[neg_baggage_idx, 'baggage_delay_mins'] = np.random.randint(-20, -1, size=500)

# Error 4: Missing data (Null actual turnaround times)
missing_turnaround_idx = np.random.choice(df.index, size=1200, replace=False)
df.loc[missing_turnaround_idx, 'turnaround_actual_mins'] = np.nan

# Error 5: Massive Outliers (Turnaround took 800+ minutes)
outlier_turnaround_idx = np.random.choice(df.index, size=50, replace=False)
df.loc[outlier_turnaround_idx, 'turnaround_actual_mins'] = np.random.randint(800, 1200, size=50)


# ==========================================
# 3. CONNECT & PUSH TO POSTGRESQL
# ==========================================
print("Connecting to local PostgreSQL database...")

# Connection string format: postgresql://username:password@host:port/database_name
# Based on your SQLTools setup: user is 'davidnamgung', no password, database is 'postgres'
engine = create_engine('postgresql://davidnamgung:@localhost:5432/groundops')

print("Writing 100,000 records to the 'raw_audit_logs' table...")

# Push DataFrame to SQL
# if_exists='replace' drops the table if it exists and recreates it.
df.to_sql('raw_audit_logs', engine, if_exists='replace', index=False)

print("Saving raw CSV to local directory...")
df.to_csv('data/raw/ground_ops_raw.csv', index=False)
# ------------------------

print("Phase 1 Complete: 100,000 records loaded into PostgreSQL and saved locally!")