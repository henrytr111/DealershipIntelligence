# Project Standards

This document defines the working standards for this repository to ensure reproducibility, privacy, and professional-quality deliverables.

## 1) Reproducibility Standards

### 1.1 Deterministic runs
- All model training must set a fixed random seed.
- Any non-deterministic operations should be documented in the relevant model card.

### 1.2 One-command execution (target state)
- The repository will provide a single “quickstart” path to reproduce core outputs:
  - run data pipeline
  - train models
  - launch dashboard and/or API
- Local environment instructions must be documented in `README.md`.

### 1.3 Environment management
- Dependencies must be pinned (e.g., `requirements.txt` or `pyproject.toml`).
- All steps required to run the project must be documented; no “it works on my machine” assumptions.

### 1.4 Output organization
- All generated artifacts must be written to a consistent location (e.g., `reports/` and/or `artifacts/`).
- Generated artifacts should be versioned by date/time or a run id (if applicable).

## 2) Data Quality Standards

### 2.1 Data contract
- Column definitions, types, and constraints are documented in `docs/data_contract.md`.
- Any changes to the contract require updating the data dictionary and downstream specs.

### 2.2 Validation and severity
Validation checks must be categorized:
- **Critical:** pipeline must fail (stop) if violated
- **Warning:** pipeline continues but logs the issue and counts violations

Examples of critical checks for this project:
- `Sale Price` must be > 0
- `Commission Rate` must be within expected bounds
- `Car Year` must be within expected bounds
- `Commission Earned` must reconcile with `Sale Price * Commission Rate` within tolerance (documented)

### 2.3 Quality reporting
- The project should produce a simple summary of validation results (counts of violations by rule).
- Known issues and remediation steps must be documented in the final report.

## 3) Modeling Standards

### 3.1 Baselines are mandatory
- All models must be compared to at least one baseline.
- Baseline selection and rationale must be documented in the relevant model spec.

### 3.2 Validation methodology
- Time-series targets must use time-aware validation (rolling/blocked backtesting).
- Feature leakage risks must be explicitly assessed and documented.

### 3.3 Interpretability
- Each model must provide an explanation layer appropriate to its use case:
  - global feature importance (and/or SHAP)
  - at least 2–3 example local explanations in the final report

### 3.4 Documentation (model cards)
- Every model must have a model card in `docs/model_cards/` describing:
  - intended use / not intended use
  - data used
  - features used
  - validation approach and metrics
  - limitations and risks
  - monitoring plan

## 4) Analytics and KPI Standards

### 4.1 KPI definitions are canonical
- KPI definitions and formulas are documented in `docs/kpi_spec.md`.
- The dashboard must reflect the definitions in the spec (no “silent” KPI changes).

### 4.2 Metric consistency
- All metric calculations must be consistent across:
  - dashboard
  - report
  - API outputs (if applicable)

## 5) Privacy & Security Standards

### 5.1 PII policy
- `Customer Name` is treated as PII and must not be present in:
  - committed files
  - dashboard tables
  - model outputs
  - logs
  - screenshots
  - reports

### 5.2 Data handling
- Raw and processed datasets are stored locally only (not committed).
- Only small, anonymized samples may be committed, and only if they contain no PII.

### 5.3 Secrets
- Secrets must never be committed (e.g., `.env`, API keys, credentials files).
- Any needed secrets must be supplied via environment variables or local-only config.

## 6) Review and Release Standards (portfolio workflow)

### 6.1 Definition of done for a milestone
A milestone is considered “done” when:
- relevant docs are updated
- outputs are reproducible from the documented workflow
- screenshots/figures (if relevant) are captured and saved under `reports/figures/`

### 6.2 Release tagging
- When core deliverables are complete, tag a release (e.g., `v1.0`) and ensure:
  - README is up to date
  - final report exists
  - model cards exist
  - architecture diagram exists
