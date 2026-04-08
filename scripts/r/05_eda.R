library(ggplot2)
library(dplyr)

# Load your cleaned data
df <- read.csv("data/processed/ground_ops_clean_sql.csv")

# 1. Distribution of Turnaround Variance
# Helps identify if our delays are "normal" or if we have a "fat tail" of disasters.
p1 <- ggplot(df, aes(x = turnaround_variance_mins)) +
  geom_histogram(binwidth = 5, fill = "#1B4F72", color = "white") +
  theme_minimal(base_size = 14) +
  labs(
   title = "Ground Operations Performance Distribution",
    subtitle = "Analysis of 100,000 Turnaround Events",
    x = "Variance from Target (Minutes)",
    y = "Flight Count"
    )

# Save as High-Res PNG
ggsave(filename = paste0("visualizations/turnaround_distribution.png"), 
       plot = p1, width = 10, height = 6, dpi = 300)

# 2. Safety Incidents by Station
# Visualizing the 'Risk Profile' of each airport.
p2 <-ggplot(df, aes(x = station_code, fill = safety_incident_flag)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("#BDC3C7", "#D35400")) + # Grey vs Safety Orange
  theme_minimal(base_size = 14) +
  labs(title = "Safety Incident Proportion by Station",
       x = "Station Code", 
       y = "Incident Rate (%)",
       fill = "Incident Reported")

# Save as High-Res PNG
ggsave(filename = paste0("visualizations/safety_risk_profile.png"), 
       plot = p2, width = 10, height = 6, dpi = 300)

print("Success: All visualizations exported to the /visualizations folder.")