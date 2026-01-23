# Modeling overview

## 1) Forecasting
Goal: forecast near-term demand for planning.

Defaults:
- Targets: daily revenue and daily units
- Horizon: 14 days
- Evaluation: rolling time-series backtest (train on earlier dates, test on later dates)

Baselines:
- seasonal naive (same weekday last week)
- 7-day moving average

Model:
- LightGBM using lag/rolling features from `features.daily_sales`

Output:
- write results to `mart.forecast_results`

## 2) Expected price + anomaly detection
Goal: estimate expected sale price and flag unusual deals.

Model:
- regression predicting `Sale Price`

Anomaly score:
- residual = `Sale Price - expected_price`
- anomaly_score = `abs(residual)`

Defaults (flag as anomaly if both are true):
- top 1% by `anomaly_score` within each calendar month
- `anomaly_score >= 2000` USD

Output:
- write results to `mart.anomalies`

## Notes
- No PII in features or outputs.
- Keep models simple; correct evaluation matters more than heavy tuning.
