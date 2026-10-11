# Business Insights: U.S. Retail Sales Forecasting

# Executive Summary

This project evaluates ARIMA and SARIMA models for forecasting monthly U.S. retail trade sales using data from the Federal Reserve Economic Data (FRED) database.

The objective is to identify a reliable short-term forecasting approach that can support retail demand analysis and business planning.

Based on the January–December 2025 test period, SARIMA outperformed the nonseasonal ARIMA benchmark across all three forecast accuracy metrics.

# Model Performance

| Metric | ARIMA | SARIMA |
|---|---:|---:|
| MAE (Million USD) | 32,328.38 | 11,816.40 |
| RMSE (Million USD) | 42,161.33 | 15,171.80 |
| MAPE | 5.52% | 2.03% |

SARIMA reduced RMSE by approximately 64%, indicating that incorporating seasonal patterns substantially improved forecast accuracy during the evaluation period.

Residual diagnostics also produced a Ljung–Box p-value of 0.3923, indicating no statistically significant evidence of remaining autocorrelation at the tested lags.

# Six-Month Sales Outlook

The selected SARIMA model was refitted using observations through December 2025 to produce forecasts for January–June 2026.

| Month | Forecast (Billion USD) |
|---|---:|
| January 2026 | 593.12 |
| February 2026 | 584.45 |
| March 2026 | 644.34 |
| April 2026 | 629.22 |
| May 2026 | 662.14 |
| June 2026 | 653.02 |

The forecasts suggest seasonal variation in consumer spending, with a February decline followed by stronger sales in March and May.

# Business Implications

Inventory planning: Businesses can use anticipated seasonal changes in retail demand as a benchmark when planning inventory purchases and replenishment.

Staffing and operations: Expected demand fluctuations can support workforce scheduling and operational capacity planning.

Financial planning: Short-term forecasts can inform market assumptions used in sales targets, budgeting, and scenario analysis.

Risk management: Prediction intervals help communicate uncertainty and support contingency planning.

# Limitations

- The analysis uses national retail trade sales, not individual company revenue.
- The series is measured in nominal U.S. dollars and is not adjusted for inflation.
- COVID-19 disruptions introduce unusually large movements that may affect model performance.
- Forecast accuracy is evaluated using one 12-month holdout period.
- Forecasts are based on observations through December 2025 and represent a historical forecasting exercise, not a current market forecast.

# Conclusion

SARIMA demonstrated better forecasting performance than the nonseasonal ARIMA benchmark during the 2025 evaluation period.

The results highlight the importance of accounting for recurring seasonal patterns when forecasting monthly retail sales. The project demonstrates how time-series analysis in R can generate interpretable forecasts that support business planning.