-- ==============================================================================
-- DATA PROFILING & HEALTH INSPECTION
-- Identify missing data, formatting errors, and statistical outliers
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. MACRO SHAPE & COMPLETENESS
-- Check total row count and hunt for NULL values across critical columns.
-- ------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_records,
    COUNT(audit_id) AS valid_audit_ids,
    (COUNT(*) - COUNT(turnaround_actual_mins)) AS missing_turnaround_actuals,
    (COUNT(*) - COUNT(baggage_delay_mins)) AS missing_baggage_delays
FROM raw_audit_logs;

-- missing turnaround actuals: 1200
-- missing baggage delays: 0


-- ------------------------------------------------------------------------------
-- 2. STATION CODES
-- Check for cardinality and data entry typos (casing, trailing/leading spaces).
-- ------------------------------------------------------------------------------
SELECT 
    station_code, 
    COUNT(*) AS frequency,
    LENGTH(station_code) AS string_length
FROM raw_audit_logs
GROUP BY station_code, LENGTH(station_code)
ORDER BY station_code ASC;


-- ------------------------------------------------------------------------------
-- 3. HANDLER NAMES
-- Check for duplicate entities / inconsistent naming conventions.
-- ------------------------------------------------------------------------------
SELECT 
    handler_name, 
    COUNT(*) AS frequency
FROM raw_audit_logs
GROUP BY handler_name
ORDER BY frequency DESC;


-- ------------------------------------------------------------------------------
-- 4. BAGGAGE DELAY
-- Check the statistical bounds (Min, Max, Avg) to find impossible physical values.
-- ------------------------------------------------------------------------------
SELECT 
    MIN(baggage_delay_mins) AS min_baggage_delay,
    MAX(baggage_delay_mins) AS max_baggage_delay,
    ROUND(AVG(baggage_delay_mins)::numeric, 2) AS avg_baggage_delay
FROM raw_audit_logs;


-- ------------------------------------------------------------------------------
-- 5. NUMERICAL PROFILING: TURNAROUND TIMES
-- Identify massive outliers that could skew compliance reporting.
-- ------------------------------------------------------------------------------
SELECT 
    MIN(turnaround_actual_mins) AS min_turnaround,
    MAX(turnaround_actual_mins) AS max_turnaround,
    ROUND(AVG(turnaround_actual_mins)::numeric, 2) AS avg_turnaround
FROM raw_audit_logs;

-- min_turnaround: 5
-- max_turnaround: 1194


-- ------------------------------------------------------------------------------
-- 6. SAFETY INCIDENTS
-- Check the distribution of our critical compliance metric.
-- ------------------------------------------------------------------------------
SELECT 
    safety_incident_flag, 
    COUNT(*) AS total_occurrences,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw_audit_logs)), 2) AS percentage
FROM raw_audit_logs
GROUP BY safety_incident_flag;

-- safety_incident_flag	total_occurrences	percentage
-- False	97931	97.93
-- True	2069	2.07