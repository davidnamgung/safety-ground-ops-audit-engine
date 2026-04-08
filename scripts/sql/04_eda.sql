
-- Query: Distribution of Turnaround Variance
SELECT 
    CASE 
        WHEN turnaround_variance_mins < 0 THEN '1. Early / Rushed (< 0m)'
        WHEN turnaround_variance_mins BETWEEN 0 AND 15 THEN '2. On-Time to Slight Delay (0-15m)'
        WHEN turnaround_variance_mins BETWEEN 16 AND 45 THEN '3. Moderate Delay (16-45m)'
        ELSE '4. Severe Delay (> 45m)'
    END AS variance_bucket,
    COUNT(*) AS flight_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM staged_audit_logs), 2) AS pct_of_total
FROM staged_audit_logs
GROUP BY 1
ORDER BY 1;


-- Query: Correlating Schedule Compliance with Safety Protocols
SELECT 
    is_on_time,
    COUNT(*) AS total_turnarounds,
    SUM(CASE WHEN safety_incident_flag = TRUE THEN 1 ELSE 0 END) AS safety_breaches,
    ROUND(SUM(CASE WHEN safety_incident_flag = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS incident_rate_pct
FROM staged_audit_logs
GROUP BY is_on_time
ORDER BY is_on_time DESC;



-- Query: Vendor Performance Matrix
SELECT 
    handler_name,
    COUNT(*) AS flights_handled,
    ROUND(AVG(turnaround_variance_mins)::numeric, 1) AS avg_variance_mins,
    ROUND(AVG(baggage_delay_mins)::numeric, 1) AS avg_baggage_delay_mins,
    ROUND(SUM(CASE WHEN safety_incident_flag = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS incident_rate_pct
FROM staged_audit_logs
GROUP BY handler_name
ORDER BY avg_variance_mins DESC;



-- Query: Station Risk Profiling
SELECT 
    station_code,
    COUNT(*) AS total_flights,
    ROUND(AVG(turnaround_actual_mins)::numeric, 1) AS avg_turnaround_time,
    ROUND(SUM(CASE WHEN safety_incident_flag = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS critical_incident_rate_pct
FROM staged_audit_logs
GROUP BY station_code
ORDER BY critical_incident_rate_pct DESC;