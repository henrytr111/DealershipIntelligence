#!/usr/bin/env bash
set -euo pipefail

# scripts/simplify_repo_fresh_grad.sh
# Goal: simplify docs to a "fresh-grad" clean set and move non-essential items out of the way.
#
# What it does:
# - Creates a small public docs set:
#   docs/README.md
#   docs/project_brief.md
#   docs/privacy_and_pii.md
#   docs/data_dictionary.md
#   docs/data_quality_plan.md
#   docs/modeling_overview.md
#   docs/architecture.md
#   docs/runbook.md
# - Merges model-related specs into docs/modeling_overview.md (append-only, non-destructive)
# - Moves extra/low-value docs into docs/_drafts/ or docs/internal/
# - Moves root clutter (main.py, init script) to better locations (or trash)
# - Removes unnecessary .gitkeep files when a folder already has real files
# - Never hard-deletes; it moves removed items to .trash/<timestamp>/ for easy restore.
#
# Usage:
#   bash scripts/simplify_repo_fresh_grad.sh
#
# After:
#   git status
#   review changes, then commit.

# -------- helpers --------
require_git_root() {
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "ERROR: Not inside a git repository. cd to your repo root first."
    exit 1
  fi
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  cd "$REPO_ROOT"
}

timestamp() { date +%Y%m%d_%H%M%S; }

ensure_file() {
  local f="$1"
  local content="$2"
  if [ ! -f "$f" ]; then
    mkdir -p "$(dirname "$f")"
    printf "%s\n" "$content" > "$f"
  fi
}

append_if_exists() {
  local src="$1"
  local dst="$2"
  local title="$3"
  if [ -f "$src" ]; then
    {
      echo
      echo "---"
      echo "## Imported from: $title"
      echo
      cat "$src"
      echo
    } >> "$dst"
  fi
}

move_to_trash() {
  local p="$1"
  if [ -e "$p" ]; then
    mkdir -p "$TRASH_DIR/$(dirname "$p")"
    echo "MOVE -> $TRASH_DIR/$p"
    mv "$p" "$TRASH_DIR/$p"
  fi
}

move_to_dir() {
  local src="$1"
  local dst_dir="$2"
  if [ -e "$src" ]; then
    mkdir -p "$dst_dir"
    echo "MOVE -> $dst_dir/$(basename "$src")"
    mv "$src" "$dst_dir/$(basename "$src")"
  fi
}

# -------- main --------
require_git_root

TRASH_DIR=".trash/$(timestamp)"
mkdir -p "$TRASH_DIR"

echo "Repo root: $(pwd)"
echo "Trash dir: $TRASH_DIR"
echo

# 1) Docs structure
mkdir -p docs/_drafts docs/internal

# 2) Ensure the "fresh-grad" public docs exist (create minimal content if missing)
ensure_file "docs/project_brief.md" \
"# Project brief

- Problem:
- Users:
- Decisions supported:
- Deliverables:
- Success criteria:
- Out of scope:
"

ensure_file "docs/privacy_and_pii.md" \
"# Privacy and PII

- Customer Name is treated as PII.
- Do not commit raw customer data to the repo.
- Outputs should avoid customer identifiers (use hashing if needed).
"

ensure_file "docs/data_dictionary.md" \
"# Data dictionary

| Column | Type | Description | Example | Constraints | Used in |
|---|---|---|---|---|---|
| Date | date | Sale date | 2024-01-15 | not null | KPIs, models |
| Salesperson | text | Salesperson name | Alex Kim | not null | KPIs, models |
| Customer Name | text | PII | (redacted) | PII | (excluded/hashed) |
| Car Make | text | Make | Toyota | not null | KPIs, models |
| Car Model | text | Model | Corolla | not null | KPIs, models |
| Car Year | int | Year | 2018 | 2010–2022 | KPIs, models |
| Sale Price | numeric | Price | 22000 | > 0 | KPIs, models |
| Commission Rate | numeric | Rate | 0.10 | 0.05–0.15 | checks |
| Commission Earned | numeric | Commission | 2200 | ~= price*rate | checks |
"

ensure_file "docs/data_quality_plan.md" \
"# Data quality plan

## Critical checks (block pipeline)
- Required fields not null
- Car Year within [2010, 2022]
- Commission Rate within [0.05, 0.15]
- Sale Price > 0

## Reconciliation checks (warn/fail based on threshold)
- abs(Commission Earned - Sale Price*Commission Rate) <= tolerance

## Duplicates
- Define transaction key and drop/flag duplicates
"

ensure_file "docs/modeling_overview.md" \
"# Modeling overview

## Models
1) Forecasting model (units/revenue)
2) Expected sale price model (pricing sanity check) + anomaly flags

## Evaluation
- Baselines for forecasting
- Time-series backtesting
- Error metrics (MAE/MAPE) and segment checks

## Notes
- Avoid leakage (time-aware splits)
- Treat Customer Name as PII (exclude)
"

ensure_file "docs/architecture.md" \
"# Architecture

## Components
- Postgres: system of record (raw → clean → mart → features)
- Dashboard (Streamlit): reads KPI views/tables
- API (FastAPI): serves forecasts/anomalies

## Data flow
Raw CSV → Postgres staging → cleaned star schema → KPI/feature tables → dashboard/API
"

ensure_file "docs/runbook.md" \
"# Runbook

## Run locally
- Copy .env.example to .env
- docker compose up --build

## Data refresh
- Place raw CSV in data/raw (gitignored)
- Run ingestion + SQL pipeline (document exact commands)

## Retraining
- Retrain cadence (e.g., monthly)
- Where artifacts/results are stored
"

# 3) Create docs/README.md (TOC)
ensure_file "docs/README.md" \
"# Documentation (start here)

## What to read
1) Project: project_brief.md
2) Privacy: privacy_and_pii.md
3) Data: data_dictionary.md, data_quality_plan.md
4) Modeling: modeling_overview.md
5) System: architecture.md
6) Operations: runbook.md

## Internal / drafts
- internal/: notes for building (not required for reviewers)
- _drafts/: WIP docs moved out of the main story
"

# 4) Merge/relocate extra docs to keep docs/ clean
# Model-related: merge into modeling_overview.md then move to drafts
MODEL_SPECS=(
  "docs/forecasting_spec.md"
  "docs/pricing_model_spec.md"
  "docs/salesperson_fairness.md"
)
for f in "${MODEL_SPECS[@]}"; do
  if [ -f "$f" ]; then
    append_if_exists "$f" "docs/modeling_overview.md" "$(basename "$f")"
    move_to_dir "$f" "docs/_drafts"
  fi
done

# API spec: merge into runbook OR keep as draft (fresh-grad: prefer README/runbook)
if [ -f "docs/api_spec.md" ]; then
  append_if_exists "docs/api_spec.md" "docs/runbook.md" "api_spec.md"
  move_to_dir "docs/api_spec.md" "docs/_drafts"
fi

# KPI/dashboard specs: move to drafts (or merge into project brief if you want later)
for f in "docs/kpi_spec.md" "docs/dashboard_spec.md"; do
  if [ -f "$f" ]; then
    move_to_dir "$f" "docs/_drafts"
  fi
done

# Data contract: move to drafts (fresh-grad: keep dictionary as the public artifact)
if [ -f "docs/data_contract.md" ]; then
  # If it has real content, append into data_dictionary under a Constraints section
  append_if_exists "docs/data_contract.md" "docs/data_dictionary.md" "data_contract.md"
  move_to_dir "docs/data_contract.md" "docs/_drafts"
fi

# Data model/architecture overlap: keep architecture public; move data_model to drafts
if [ -f "docs/data_model.md" ]; then
  move_to_dir "docs/data_model.md" "docs/_drafts"
fi

# Data quality plan stays public; if you had a separate placeholder plan file, move it
# (Your repo used data_quality_plan.md already; included here for safety)
# If there's a duplicate doc name, move it:
if [ -f "docs/data_quality_plan_draft.md" ]; then
  move_to_dir "docs/data_quality_plan_draft.md" "docs/_drafts"
fi

# Internal-only docs
for f in "docs/screenshot_checklist.md" "docs/project_standards.md"; do
  if [ -f "$f" ]; then
    move_to_dir "$f" "docs/internal"
  fi
done

# Templates: move to drafts (fresh-grad clean); restore later if you truly use them
if [ -d "docs/templates" ]; then
  move_to_trash "docs/templates"
fi

# 5) Root cleanup
# Root placeholder main.py -> trash
if [ -f "main.py" ]; then
  move_to_trash "main.py"
fi

# Move root init script into scripts/
if [ -f "init_phase0_existing_repo.sh" ]; then
  mkdir -p scripts
  echo "MOVE -> scripts/init_repo.sh"
  mv "init_phase0_existing_repo.sh" "scripts/init_repo.sh"
fi

# 6) Remove .gitkeep where not needed (move to trash; do not delete)
while IFS= read -r -d '' keep; do
  dir="$(dirname "$keep")"
  # count non-.gitkeep files in directory
  count="$(find "$dir" -maxdepth 1 -type f ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')"
  if [ "$count" -gt 0 ]; then
    move_to_trash "$keep"
  fi
done < <(find . -name ".gitkeep" -print0)

echo
echo "Done."
echo "Next:"
echo "  git status"
echo "  git diff"
echo "If you want to undo, restore from:"
echo "  $TRASH_DIR"
