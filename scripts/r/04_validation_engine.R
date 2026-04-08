# ==============================================================================
# PHASE 3: AUTOMATED VALIDATION ENGINE
# Objective: Audit clean data, calculate failure rates, and trigger simulated alerts.
# ==============================================================================

library(dplyr)
library(DBI)
library(RPostgres)

# ------------------------------------------------------------------------------
# 1. CONNECT TO THE STAGED DATA
# ------------------------------------------------------------------------------
print("Connecting to the 'groundops' database...")
con <- dbConnect(RPostgres::Postgres(),
                 dbname = "groundops",
                 host = "localhost",
                 port = 5432,
                 user = "davidnamgung", # Your local Mac username
                 password = "")

# Pull the clean data into R
staged_data <- dbReadTable(con, "staged_audit_logs")
dbDisconnect(con)

# ------------------------------------------------------------------------------
# 2. DEFINE THE BUSINESS RULES & THRESHOLDS
# ------------------------------------------------------------------------------
# Management Rule: If a station's safety incident rate exceeds 2.5%, ALERT IMMEDIATELY.
CRITICAL_THRESHOLD_PCT <- 2.5 

print("Running compliance audit across all global stations...")

# ------------------------------------------------------------------------------
# 3. THE AUDIT CALCULATOR
# ------------------------------------------------------------------------------
audit_results <- staged_data %>%
  group_by(station_code) %>%
  summarize(
    total_flights_handled = n(),
    total_safety_incidents = sum(safety_incident_flag == TRUE, na.rm = TRUE),
    
    # Calculate the failure rate as a percentage
    incident_rate_pct = round((total_safety_incidents / total_flights_handled) * 100, 2)
  ) %>%
  arrange(desc(incident_rate_pct))

# ------------------------------------------------------------------------------
# 4. THE ALERT TRIGGER SYSTEM
# ------------------------------------------------------------------------------
# Filter for stations that breached the threshold
failing_stations <- audit_results %>% filter(incident_rate_pct > CRITICAL_THRESHOLD_PCT)

cat("\n==================================================\n")
cat("      IATA GROUND OPS: AUTOMATED ALERT SYSTEM       \n")
cat("==================================================\n")

if (nrow(failing_stations) > 0) {
  cat("⚠️ CRITICAL ALERT: The following stations have breached the safety threshold:\n\n")
  
  # Loop through failing stations and generate a simulated email/system alert
  for (i in 1:nrow(failing_stations)) {
    cat(sprintf("   -> STATION: %s | Incident Rate: %.2f%% (Threshold: %.2f%%)\n", 
                failing_stations$station_code[i], 
                failing_stations$incident_rate_pct[i], 
                CRITICAL_THRESHOLD_PCT))
  }
  
  cat("\nACTION REQUIRED: Dispatch audit team to failing stations immediately.\n")
} else {
  cat("✅ ALL CLEAR: All stations are operating within acceptable safety thresholds.\n")
}
cat("==================================================\n\n")