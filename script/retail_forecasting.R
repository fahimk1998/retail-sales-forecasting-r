

# U.S. Retail Sales Forecasting: ARIMA vs SARIMA

# Project: Retail Sales Forecasting
# Data Source: FRED (RSXFSN)
# Software: R
# Objective: Compare ARIMA and SARIMA forecasting accuracy

# Load required libraries
library(forecast)
library(ggplot2)
library(readxl)
library(dplyr)
library(lubridate)


# Step 4: Import Retail Sales Data


# Import the monthly retail sales worksheet
retail_data <- read_excel(
  "data/RSXFSN.xlsx",
  sheet = "Monthly"
)


# Display the first six observations
head(retail_data)

# Check the structure of the dataset
str(retail_data)

# Check column names
names(retail_data)

# Check for missing values
colSums(is.na(retail_data))



# Step 5: Prepare Time-Series Data


# Select observations from January 2015 to December 2025
retail_selected <- retail_data %>%
  filter(
    observation_date >= as.Date("2015-01-01"),
    observation_date <= as.Date("2025-12-01")
  )

# Convert monthly sales into a time-series object
retail_ts <- ts(
  retail_selected$RSXFSN,
  start = c(2015, 1),
  frequency = 12
)

# Split into training and testing datasets
train <- window(retail_ts, end = c(2024, 12))

test <- window(retail_ts, start = c(2025, 1))

# Verify the datasets
start(train)
end(train)
length(train)

start(test)
end(test)
length(test)



# Step 6: Retail Sales Time-Series Visualization


# Create a professional retail sales graph
sales_plot <- ggplot(
  retail_selected,
  aes(x = observation_date, y = RSXFSN / 1000)
) +
  geom_line(color = "#1763A6", linewidth = 0.8) +
  geom_vline(
    xintercept = as.Date("2025-01-01"),
    linetype = "dashed",
    color = "#D97706",
    linewidth = 0.7
  ) +
  scale_x_date(date_breaks = "1 year",
               date_labels = "%Y") +
  scale_y_continuous(
    labels = scales::label_number(accuracy = 1)
  ) +
  labs(
    title = "U.S. Monthly Retail Sales (2015–2025)",
    subtitle = "Historical sales with training and testing periods",
    x = "Year",
    y = "Retail Sales (Billion USD)",
    caption = paste(
      "Source: FRED (RSXFSN) | Not Seasonally Adjusted",
      "| Dashed line: Start of testing period"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(color = "gray40")
  )

# Display the graph
print(sales_plot)

# Save the graph for GitHub
ggsave(
  filename = "figures/retail_sales_trend.png",
  plot = sales_plot,
  width = 11,
  height = 6,
  dpi = 300
)



# Step 7: Seasonal Pattern Analysis


# Create a monthly seasonal plot using training data
seasonal_plot <- ggseasonplot(
  train,
  year.labels = TRUE,
  year.labels.left = TRUE
) +
  labs(
    title = "Seasonal Patterns in U.S. Retail Sales",
    subtitle = "Monthly sales patterns by year (2015–2024)",
    x = "Month",
    y = "Retail Sales (Million USD)",
    caption = "Source: FRED (RSXFSN) | Not Seasonally Adjusted"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    panel.grid.minor = element_blank()
  )

# Display seasonal plot
print(seasonal_plot)

# Save seasonal plot
ggsave(
  filename = "figures/retail_sales_seasonality.png",
  plot = seasonal_plot,
  width = 11,
  height = 6,
  dpi = 300
)



# Step 8: Stationarity and Differencing


# Determine recommended regular differencing
d_value <- ndiffs(train)

# Determine recommended seasonal differencing
D_value <- nsdiffs(train)

# Display results
cat("Recommended regular differencing (d):", d_value, "\n")
cat("Recommended seasonal differencing (D):", D_value, "\n")

# Apply recommended differencing
stationary_series <- diff(
  train,
  differences = d_value
)

if (D_value > 0) {
  stationary_series <- diff(
    stationary_series,
    lag = 12,
    differences = D_value
  )
}

# Plot differenced series
plot(
  stationary_series,
  main = "Differenced Monthly Retail Sales",
  xlab = "Year",
  ylab = "Differenced Sales",
  col = "#1763A6",
  lwd = 1.5
)



# Step 9: Estimate ARIMA and SARIMA Models

# Model 1: Nonseasonal ARIMA
model_arima <- auto.arima(
  train,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE
)

# Model 2: Seasonal ARIMA (SARIMA)
model_sarima <- auto.arima(
  train,
  seasonal = TRUE,
  stepwise = FALSE,
  approximation = FALSE
)

# Display selected models
cat("\n===== ARIMA MODEL =====\n")
summary(model_arima)

cat("\n===== SARIMA MODEL =====\n")
summary(model_sarima)

# Compare model information criteria
model_comparison <- data.frame(
  Model = c("ARIMA", "SARIMA"),
  AIC = c(AIC(model_arima), AIC(model_sarima)),
  BIC = c(BIC(model_arima), BIC(model_sarima))
)

print(model_comparison)




# Step 10: Compare Forecast Accuracy

# Generate 12-month forecasts from both models
forecast_arima <- forecast(model_arima, h = 12)

forecast_sarima <- forecast(model_sarima, h = 12)

# Evaluate forecasts against actual 2025 sales
accuracy_arima <- accuracy(forecast_arima, test)
accuracy_sarima <- accuracy(forecast_sarima, test)

# Create the comparison table using test-set errors
accuracy_comparison <- data.frame(
  Model = c("ARIMA", "SARIMA"),
  MAE = c(
    accuracy_arima["Test set", "MAE"],
    accuracy_sarima["Test set", "MAE"]
  ),
  RMSE = c(
    accuracy_arima["Test set", "RMSE"],
    accuracy_sarima["Test set", "RMSE"]
  ),
  MAPE = c(
    accuracy_arima["Test set", "MAPE"],
    accuracy_sarima["Test set", "MAPE"]
  )
)

# Display rounded results
print(
  transform(
    accuracy_comparison,
    MAE = round(MAE, 2),
    RMSE = round(RMSE, 2),
    MAPE = round(MAPE, 2)
  )
)

# Identify the model with the lowest test RMSE
best_model <- accuracy_comparison$Model[
  which.min(accuracy_comparison$RMSE)
]

cat("\nBest model based on test RMSE:", best_model, "\n")




# Step 11: Actual vs Forecast Comparison


# Prepare the forecast comparison dataset
forecast_comparison <- data.frame(
  Date = seq(
    as.Date("2025-01-01"),
    as.Date("2025-12-01"),
    by = "month"
  ),
  Actual = as.numeric(test) / 1000,
  ARIMA = as.numeric(forecast_arima$mean) / 1000,
  SARIMA = as.numeric(forecast_sarima$mean) / 1000
)

# Convert to long format for plotting
forecast_long <- tidyr::pivot_longer(
  forecast_comparison,
  cols = c("Actual", "ARIMA", "SARIMA"),
  names_to = "Series",
  values_to = "Sales"
)

# Create comparison graph
comparison_plot <- ggplot(
  forecast_long,
  aes(x = Date, y = Sales, color = Series)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.8) +
  scale_color_manual(
    values = c(
      "Actual" = "#1F2937",
      "ARIMA" = "#D97706",
      "SARIMA" = "#1763A6"
    )
  ) +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b"
  ) +
  labs(
    title = "Actual vs Forecasted U.S. Retail Sales",
    subtitle = "Out-of-sample forecast comparison: January–December 2025",
    x = "Month (2025)",
    y = "Retail Sales (Billion USD)",
    color = "Series",
    caption = "Source: FRED (RSXFSN) | Models estimated using 2015–2024 data"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.caption = element_text(color = "gray40")
  )

# Display graph
print(comparison_plot)

# Save graph
ggsave(
  filename = "figures/forecast_model_comparison.png",
  plot = comparison_plot,
  width = 11,
  height = 6,
  dpi = 300
)




# Step 12: SARIMA Residual Diagnostics


# Examine residuals of the selected SARIMA model
checkresiduals(model_sarima)

# Extract the residuals
sarima_residuals <- residuals(model_sarima)

# Display residual summary statistics
summary(sarima_residuals)

# Check average residual
cat(
  "Mean residual:",
  round(mean(sarima_residuals, na.rm = TRUE), 2),
  "\n"
)


# Step 13: Final Six-Month SARIMA Forecast


# Re-estimate selected SARIMA specification
# using all observations through December 2025
final_model <- Arima(
  retail_ts,
  model = model_sarima
)

# Generate six-month forecast
final_forecast <- forecast(
  final_model,
  h = 6,
  level = c(80, 95)
)

# Display forecast results
print(final_forecast)

# Create professional forecast visualization
final_plot <- autoplot(final_forecast) +
  autolayer(retail_ts, series = "Historical Sales") +
  labs(
    title = "Six-Month U.S. Retail Sales Forecast",
    subtitle = "SARIMA Forecast: January–June 2026",
    x = "Year",
    y = "Retail Sales (Million USD)",
    caption = "Source: FRED (RSXFSN) | 80% and 95% Prediction Intervals"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# Display graph
print(final_plot)

# Save graph
ggsave(
  filename = "figures/final_sarima_forecast.png",
  plot = final_plot,
  width = 11,
  height = 6,
  dpi = 300
)



# Step 13A: Professional SARIMA Forecast Visualization


# Prepare historical data
historical_df <- data.frame(
  Date = seq(
    as.Date("2015-01-01"),
    as.Date("2025-12-01"),
    by = "month"
  ),
  Sales = as.numeric(retail_ts) / 1000
)

# Prepare six-month forecast data
forecast_df <- data.frame(
  Date = seq(
    as.Date("2026-01-01"),
    as.Date("2026-06-01"),
    by = "month"
  ),
  Forecast = as.numeric(final_forecast$mean) / 1000,
  Lower80 = as.numeric(final_forecast$lower[, 1]) / 1000,
  Upper80 = as.numeric(final_forecast$upper[, 1]) / 1000,
  Lower95 = as.numeric(final_forecast$lower[, 2]) / 1000,
  Upper95 = as.numeric(final_forecast$upper[, 2]) / 1000
)

# Create professional forecast graph
final_plot <- ggplot() +
  geom_line(
    data = historical_df,
    aes(x = Date, y = Sales, color = "Historical Sales"),
    linewidth = 0.7
  ) +
  geom_ribbon(
    data = forecast_df,
    aes(x = Date, ymin = Lower95, ymax = Upper95),
    fill = "#93C5FD",
    alpha = 0.35
  ) +
  geom_ribbon(
    data = forecast_df,
    aes(x = Date, ymin = Lower80, ymax = Upper80),
    fill = "#3B82F6",
    alpha = 0.35
  ) +
  geom_line(
    data = forecast_df,
    aes(x = Date, y = Forecast, color = "SARIMA Forecast"),
    linewidth = 1
  ) +
  geom_vline(
    xintercept = as.Date("2026-01-01"),
    linetype = "dashed",
    color = "gray50"
  ) +
  scale_color_manual(
    values = c(
      "Historical Sales" = "#374151",
      "SARIMA Forecast" = "#1763A6"
    )
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    labels = scales::label_number(accuracy = 1)
  ) +
  labs(
    title = "Six-Month U.S. Retail Sales Forecast",
    subtitle = "SARIMA | January–June 2026",
    x = "Year",
    y = "Retail Sales (Billion USD)",
    color = NULL,
    caption = paste(
      "Source: FRED (RSXFSN) |",
      "Shaded areas: 80% and 95% prediction intervals"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Display improved graph
print(final_plot)

# Replace previously saved graph
ggsave(
  filename = "figures/final_sarima_forecast.png",
  plot = final_plot,
  width = 11,
  height = 6,
  dpi = 300
)


print(final_forecast)



# Step 14: Export Forecasting Results


# Create results folder if necessary
dir.create("results", showWarnings = FALSE)

# Create the final forecast table
final_results <- data.frame(
  Month = format(forecast_df$Date, "%B %Y"),
  Forecast_Billion_USD = round(forecast_df$Forecast, 2),
  Lower_80 = round(forecast_df$Lower80, 2),
  Upper_80 = round(forecast_df$Upper80, 2),
  Lower_95 = round(forecast_df$Lower95, 2),
  Upper_95 = round(forecast_df$Upper95, 2)
)

# Export the final forecast
write.csv(
  final_results,
  "results/sarima_six_month_forecast.csv",
  row.names = FALSE
)

# Export accuracy comparison
write.csv(
  accuracy_comparison,
  "results/model_accuracy_comparison.csv",
  row.names = FALSE
)

# Export actual vs forecast data
write.csv(
  forecast_comparison,
  "results/actual_vs_forecast_2025.csv",
  row.names = FALSE
)

# Confirm results
print(final_results)

cat("\nAll forecasting results exported successfully.\n")

