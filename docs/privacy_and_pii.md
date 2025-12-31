# Privacy and PII Handling

## 1) What is considered PII in this project
- Customer Name is PII.
- Any direct identifier or combination of fields that could identify an individual is treated as sensitive.

## 2) Non-negotiable rules
- Customer Name must never appear in:
  - dashboards (including tables and filters)
  - model outputs (training data exports, predictions, explanations)
  - logs
  - screenshots or demo videos
  - committed sample files
  - reports

## 3) Allowed alternative identifiers
If customer-level grouping is required:
- Create a one-way hashed customer id derived from Customer Name.
- The hash must be stable (same input → same output) and not reversible for practical purposes.
- Do not publish the hashing salt/secret if used.

## 4) How we prevent accidental leaks
- Raw data is stored locally only under `data/raw/` and is ignored by git.
- Processed data under `data/processed/` is ignored by git.
- Only a small anonymized sample (optional) may be committed under `data/sample/`.

## 5) Demo and screenshot checklist (must pass before release)
Before publishing any screenshot/video/report:
- Verify no customer names are visible.
- Verify no raw rows with identifiable information are visible.
- Use aggregated views by default.
- If showing row-level anomalies, ensure customer identifier is removed or replaced with a hashed id.
