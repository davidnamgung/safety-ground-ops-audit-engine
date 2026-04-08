-- ==============================================================================
-- PHASE 2: DATA CLEANSING & TRANSFORMATION PIPELINE
-- Objective: Standardize text, fix physical impossibilities, and handle outliers.
-- Output: A clean table named 'staged_audit_logs'
-- ==============================================================================

-- Drop the table if we need to re-run the pipeline
DROP TABLE IF EXISTS staged_audit_logs;

-- Create the new cleaned table
CREATE TABLE staged_audit_logs AS

WITH step_1_standardize_text AS (
    -- --------------------------------------------------------------------------
    -- 1. Standardize Strings and Categorical Variables
    -- --------------------------------------------------------------------------
    SELECT 
        audit_id,
        flight_date,
        -- Remove hidden spaces and force uppercase (e.g., 'yul' -> 'YUL', ' LHR' -> 'LHR')
        TRIM(UPPER(station_code)) AS station_code,
        
        -- Consolidate duplicate handler entities into a single standard name
        CASE 
            WHEN handler_name = 'Menzies Aviation' THEN 'Menzies'
            ELSE handler_name 
        END AS handler_name,
        
        turnaround_target_mins,
        turnaround_actual_mins,
        baggage_delay_mins,
        safety_incident_flag
    FROM raw_audit_logs
),

step_2_clean_numerics AS (
    -- --------------------------------------------------------------------------
    -- 2. Handle Impossibilities and Outliers
    -- --------------------------------------------------------------------------
    SELECT 
        audit_id,
        flight_date,
        station_code,
        handler_name,
        turnaround_target_mins,
        
        -- Turnaround Outliers: Anything over 500 mins is likely a sensor/system error.
        -- We will nullify these extreme outliers so they don't skew our dashboard averages.
        CASE 
            WHEN turnaround_actual_mins > 500 THEN NULL 
            ELSE turnaround_actual_mins 
        END AS turnaround_actual_mins,
        
        -- Baggage Delays: A bag cannot arrive before the plane lands. 
        -- GREATEST() forces any negative number to become exactly 0.
        GREATEST(baggage_delay_mins, 0) AS baggage_delay_mins,
        
        safety_incident_flag
    FROM step_1_standardize_text
)

-- ------------------------------------------------------------------------------
-- 3. Final Transformation & Feature Engineering
-- Add calculated columns that the business stakeholders will want to see.
-- ------------------------------------------------------------------------------
SELECT 
    audit_id,
    flight_date,
    station_code,
    handler_name,
    turnaround_target_mins,
    turnaround_actual_mins,
    
    -- Feature Engineering: Calculate the variance from the target
    (turnaround_actual_mins - turnaround_target_mins) AS turnaround_variance_mins,
    
    -- Feature Engineering: Create a quick boolean flag for on-time performance
    CASE 
        WHEN turnaround_actual_mins <= turnaround_target_mins THEN TRUE 
        ELSE FALSE 
    END AS is_on_time,
    
    baggage_delay_mins,
    safety_incident_flag
FROM step_2_clean_numerics;

-- Add a Primary Key to our new table for database integrity
ALTER TABLE staged_audit_logs ADD PRIMARY KEY (audit_id);


COPY staged_audit_logs 
TO '/Users/davidnamgung/portfolio-projects/safety_ground_ops_engine/data/processed/ground_ops_clean_sql.csv' 
WITH (FORMAT CSV, HEADER TRUE);