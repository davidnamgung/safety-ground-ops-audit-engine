# ✈️ Aviation Ground Ops Alerting Engine & Dashboard

## 📌 Executive Summary
In global aviation, ground operations (turnarounds) are high-risk environments where minutes of delay translate to millions in losses, and safety errors translate to lives. 

This project simulates a **Production Data Pipeline** for round audit logs, moving a synthetic dataset of 100,000 raw records through a complete ETL architecture. Beyond standardizing data, this pipeline transitions passive reporting into an **Active Alerting System**, automatically flagging critical safety breaches and visualizing vendor performance for operational stakeholders.

## 🛠️ Technical Stack
* **Ingestion:** Python (Simulated API extraction)
* **Storage & Transformation:** PostgreSQL (Bronze-to-Gold Data Modeling)
* **Validation & Alerting:** R (Statistical Thresholding & Webhooks)
* **Visualization:** Tableau (Executive KPI Dashboard)

## 🏗️ Architecture & Data Flow
1. **Raw Ingestion (Python):** 100,000 uncleaned audit logs are ingested into the `raw_audit_logs` table.
2. **Quality Gates (PostgreSQL):** A rigorous SQL transformation script cleans strings, nullifies physical impossibilities (e.g., negative baggage delays), and enforces a strict Data Quality Gate. Corrupted records (1.25% of the population missing vital turnaround data) are programmatically dropped to ensure mathematical integrity.
3. **Algorithmic Watchdog (R):** An R script connects directly to the staged PostgreSQL database, calculating real-time safety incident rates by station. If a station breaches the 2.5% acceptable risk threshold, the engine automatically triggers an alert webhook.
4. **Situational Awareness (Tableau):** A 3-Tier executive dashboard visualizes the finalized dataset, featuring Geospatial Risk Profiling and complex Dual-Axis correlation charts.

## 📊 Core Business Insights
* 🚨 **The Speed-Safety Paradox:** Dual-axis analysis reveals a direct correlation between negative turnaround variances (rushed flights) and increased safety protocol breaches.
* 🤝 **Vendor Accountability:** Evaluated third-party ground handlers (dnata, Menzies, Swissport, WFS) to identify operational volatility, providing data-backed leverage for procurement contract renewals.