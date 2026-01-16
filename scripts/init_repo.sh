#!/usr/bin/env bash
set -euo pipefail

# Run this INSIDE your existing local repo directory (already linked to a remote).
# Example:
#   cd /path/to/your/existing/repo
#   bash init_phase0_existing_repo.sh

# ====== CONFIG ======
DEFAULT_BRANCH="main"
LICENSE_HOLDER="YOUR_NAME"   # <-- change
YEAR="$(date +%Y)"

# ====== SAFETY CHECKS ======
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: This directory is not a git repository. cd into your repo and run again."
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

REPO_NAME="$(basename "$REPO_ROOT")"
echo "Repo root: $REPO_ROOT"
echo "Repo name: $REPO_NAME"

# Ensure a default branch exists (common in empty repos)
CURRENT_BRANCH="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ -z "$CURRENT_BRANCH" ]]; then
  # No commits yet; create branch
  git checkout -b "$DEFAULT_BRANCH" 2>/dev/null || git checkout "$DEFAULT_BRANCH"
else
  # If branch exists but isn't main, keep it as-is (don’t surprise you)
  echo "Current branch: $CURRENT_BRANCH"
fi

# Confirm remote exists (linked)
if git remote get-url origin >/dev/null 2>&1; then
  echo "Remote 'origin' is set to: $(git remote get-url origin)"
else
  echo "WARNING: No 'origin' remote found. Your repo may not be linked to a remote yet."
fi

# ====== FOLDER STRUCTURE ======
mkdir -p \
  docs/images \
  docs/templates \
  docs/model_cards \
  data/raw data/interim data/processed data/sample \
  reports/figures \
  pipelines \
  models \
  app \
  tests \
  .github/ISSUE_TEMPLATE \
  .github/PULL_REQUEST_TEMPLATE

touch docs/images/.gitkeep reports/figures/.gitkeep pipelines/.gitkeep models/.gitkeep app/.gitkeep tests/.gitkeep

# ====== .gitignore (Python + data safety) ======
cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
*.so
.venv/
venv/
ENV/
env/
pip-wheel-metadata/
*.egg-info/
dist/
build/

# Jupyter
.ipynb_checkpoints/

# OS/editor
.DS_Store
.vscode/
.idea/

# Data (do NOT commit raw data)
data/raw/
data/interim/
data/processed/
*.parquet
*.csv
*.xlsx

# Logs
*.log
EOF

# ====== LICENSE (MIT) ======
cat > LICENSE <<EOF
MIT License

Copyright (c) $YEAR $LICENSE_HOLDER

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# ====== DATA SAFETY README ======
cat > data/README.md <<'EOF'
# Data directory

This project uses a dataset that includes **Customer Name**, which is treated as **PII**.

## Rules
- Do **not** commit raw data to GitHub.
- Store local files under:
  - `data/raw/` (original downloads)
  - `data/interim/` (cleaning outputs)
  - `data/processed/` (analytics-ready tables / features)
- Commit only:
  - documentation about data
  - small **anonymized** samples (optional) in `data/sample/`

If you need a sample for tests or screenshots, create `data/sample/sample_anonymized.csv`
with a small number of rows and **no customer names**.
EOF

# ====== DOCS: PROJECT BRIEF ======
cat > docs/project_brief.md <<'EOF'
# Dealership Revenue Intelligence Platform — Project Brief

## One-liner
A production-style analytics + forecasting + pricing anomaly detection system built on dealership transaction data.

## Background
Dealership leadership needs better revenue predictability, pricing discipline, commission accuracy, and fair sales performance benchmarking.

## Users and decisions
### General Manager
- Track revenue/units trends and forecast outlook for staffing and planning.

### Sales Manager
- Identify pricing outliers and coach salespeople using fair comparisons.

### Finance / Payroll
- Validate commission payouts and detect mismatches or unusual rates.

## Goals (measurable)
- Forecast daily/weekly units and revenue with proper time-series backtesting.
- Estimate expected sale price for a given car (make/model/year + date) and flag anomalies.
- Provide salesperson benchmarking using a fairness-aware “uplift vs expected” approach.
- Deliver a dashboard for KPI monitoring + drilldowns.
- Document data quality checks, privacy handling, and model limitations.

## Non-goals
- Inventory optimization (not present in dataset).
- Marketing attribution (not present in dataset).
- Customer targeting/segmentation (PII + limited features).

## Dataset summary
- ~2.5M sales transactions over one year
- Columns: Date, Salesperson, Customer Name (PII), Car Make, Car Model, Car Year, Sale Price, Commission Rate, Commission Earned

## Deliverables
- Analytics-ready tables (documented star schema + data quality checks)
- KPI dashboard (overview, product mix, sales team, anomalies)
- Forecast model + evaluation report
- Expected-price model + anomaly flags + interpretability
- API spec (forecast + expected price + anomalies)
- Model cards + architecture diagram + operational runbook

## Success criteria
- Forecast model beats strong baselines over rolling backtests.
- Commission reconciliation rules catch mismatches with clear thresholds.
- Anomalies are actionable (review list + explanations).
- All outputs remove or anonymize PII.
EOF

# ====== DOCS: STANDARDS + PLACEHOLDERS ======
cat > docs/project_standards.md <<'EOF'
# Project standards

- Metrics are defined in `docs/kpi_spec.md`.
- Data constraints and validation rules are defined in `docs/data_contract.md` and `docs/data_quality_plan.md`.
- Every model must have a model card in `docs/model_cards/`.
- Any output intended for sharing removes/anonymizes PII (Customer Name).
- Pipeline stages are reproducible (clear inputs/outputs).
- Dashboard and API have documented run instructions (eventually Docker-based).
EOF

cat > docs/data_contract.md <<'EOF'
# Data contract (placeholder)

Define column types, allowed ranges, nullability, and business rules.
EOF

cat > docs/data_dictionary.md <<'EOF'
# Data dictionary (placeholder)

Human-friendly descriptions of each dataset field and how it is used in KPIs/models.
EOF

cat > docs/privacy_and_pii.md <<'EOF'
# Privacy and PII handling (placeholder)

- Customer Name is PII and must be removed/hashed in outputs.
- No customer-level public reporting.
EOF

cat > docs/data_quality_plan.md <<'EOF'
# Data quality plan (placeholder)

Include schema checks, validity checks, reconciliation checks, and severity levels.
EOF

cat > docs/data_model.md <<'EOF'
# Data model (star schema) (placeholder)

Describe `fact_sales` and dimension tables and keys.
EOF

cat > docs/kpi_spec.md <<'EOF'
# KPI specification (placeholder)

Define KPI formulas, segmentations, and business meaning.
EOF

cat > docs/dashboard_spec.md <<'EOF'
# Dashboard specification (placeholder)

Define pages, wireframes, filters, and drilldown behavior.
EOF

cat > docs/forecasting_spec.md <<'EOF'
# Forecasting specification (placeholder)

Targets, aggregation, baselines, rolling backtests, and evaluation metrics.
EOF

cat > docs/pricing_model_spec.md <<'EOF'
# Expected price + anomaly detection specification (placeholder)

Define feature set, leakage avoidance, anomaly thresholds, and interpretability plan.
EOF

cat > docs/salesperson_fairness.md <<'EOF'
# Salesperson fairness benchmarking (placeholder)

Define uplift vs expected methodology and reporting.
EOF

cat > docs/api_spec.md <<'EOF'
# API specification (placeholder)

Define endpoints, request/response schemas, and error cases.
EOF

cat > docs/runbook.md <<'EOF'
# Operational runbook (placeholder)

Data refresh, failure handling, retraining cadence, and anomaly review workflow.
EOF

cat > docs/architecture.md <<'EOF'
# Architecture (placeholder)

Add a simple diagram showing: Raw -> Clean -> Features -> Models -> API/Dashboard -> Monitoring.
EOF

cat > docs/screenshot_checklist.md <<'EOF'
# Screenshot checklist

- Dashboard: Executive overview
- Dashboard: Product mix
- Dashboard: Sales team (incl. uplift)
- Dashboard: Anomalies
- Forecast chart (baseline vs model)
- Expected price explanation (e.g., SHAP summary)
EOF

# ====== TEMPLATES ======
cat > docs/templates/model_card_template.md <<'EOF'
# Model card: <MODEL NAME>

## Purpose
- Intended use:
- Not intended use:

## Data
- Training data range:
- Key fields used:
- PII handling:

## Features
- Feature groups:
- Leakage checks:

## Evaluation
- Validation method:
- Metrics:
- Baselines:

## Results
- Summary of performance:

## Limitations and risks
- Data limitations:
- Bias/fairness notes:
- Failure modes:

## Monitoring plan
- Data drift signals:
- Performance checks:
- Retraining trigger:
EOF

cat > docs/templates/final_report_template.md <<'EOF'
# Final report: Dealership Revenue Intelligence Platform

## Executive summary
- Bullet 1
- Bullet 2
- Bullet 3

## Data and quality
- Data issues found:
- Cleaning/validation strategy:

## KPI insights
- Key trends:
- Product mix:
- Sales team summary:

## Forecasting
- Baselines:
- Backtesting setup:
- Results:

## Expected price + anomalies
- Modeling approach:
- Interpretability:
- Flagged patterns:

## Salesperson benchmarking (fairness-aware)
- Uplift definition:
- Summary findings:

## Recommendations
- Operational recommendations:
- Future data to collect:

## Limitations and next steps
- Limitations:
- Next steps:
EOF

cat > docs/images/README.md <<'EOF'
# Images

Store:
- Architecture diagram
- Dashboard screenshots
- Key result figures (forecast plots, anomaly examples, interpretability visuals)
EOF

# ====== reports placeholder ======
cat > reports/README.md <<'EOF'
# Reports

Store final outputs intended for reviewers:
- Final report
- Exported figures
- Dashboard screenshots (optional)
EOF

# ====== README scaffold ======
cat > README.md <<'EOF'
# Dealership Revenue Intelligence Platform

Production-style analytics + forecasting + pricing anomaly detection built on dealership transaction data.

## Problem
Dealership leadership needs:
- reliable revenue/unit forecasts,
- pricing discipline and anomaly detection,
- commission reconciliation,
- fair performance benchmarking across salespeople.

## Solution (what this repo will deliver)
- Analytics-ready tables (documented star schema + data quality checks)
- KPI dashboard: overview, product mix, sales team, anomalies
- ML models:
  - time-series forecasting for units/revenue
  - expected sale price estimation + anomaly flags
- API specification for forecast and expected-price inference
- Model cards, architecture diagram, and operational runbook

## Repository structure
- `docs/` — project specs, architecture, runbook, templates
- `data/` — local-only data storage (raw data not committed)
- `pipelines/` — ETL / feature pipeline (to be implemented)
- `models/` — training and inference code (to be implemented)
- `app/` — dashboard + API (to be implemented)
- `reports/` — final report and figures
- `tests/` — data/model tests (to be implemented)

## Data & privacy
- The source dataset includes **Customer Name** (PII).
- All public outputs remove or anonymize PII.
- Raw data must not be committed. See `data/README.md`.

## Roadmap
Use GitHub Issues/Milestones to track phases and deliverables.
EOF

# ====== GitHub templates ======
cat > .github/ISSUE_TEMPLATE/task.md <<'EOF'
---
name: Task
about: Work item for this project
title: "[Task] "
labels: ""
assignees: ""
---

## Description
-

## Acceptance criteria
- [ ]

## Notes
-
EOF

cat > .github/PULL_REQUEST_TEMPLATE/pull_request_template.md <<'EOF'
## Summary
-

## Changes
-

## Checklist
- [ ] Docs updated (if needed)
- [ ] Tests added/updated (if needed)
- [ ] No PII committed
EOF

# ====== COMMIT + PUSH ======
git add .

# Commit only if there is something to commit
if git diff --cached --quiet; then
  echo "Nothing new to commit."
else
  git commit -m "Phase 0: initialize structure, docs, templates, and README"
fi

# Push if origin exists
if git remote get-url origin >/dev/null 2>&1; then
  # If HEAD has no upstream yet, set it
  git push -u origin "$(git symbolic-ref --short HEAD 2>/dev/null || echo "$DEFAULT_BRANCH")"
else
  echo "No origin remote found; skipping push."
fi

echo "Phase 0 setup complete in existing repo: $REPO_NAME"
