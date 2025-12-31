Title: Data handling policy

Sections to include

What goes in /data/

Raw dataset files are stored locally only (not committed).

Intermediate outputs may be stored locally (Parquet/CSV) but not committed if large.

PII policy

Customer Name is treated as PII.

PII must not appear in:

dashboards

model outputs

logs

screenshots

committed sample files

If a customer identifier is required, use:

a one-way hashed ID (document that the hash is not reversible)

How to obtain the dataset

Provide a placeholder “Download instructions” section:

“Place the raw dataset at data/raw/car_sales.csv (local only).”

If it’s from Kaggle or elsewhere, reference it here.

What can be committed

data/sample/ may contain a tiny anonymized sample (100–500 rows max)

Only if:

customer names removed

any IDs are hashed

no rare values that could re-identify a person

Directory layout

data/raw/ (local only)

data/processed/ (local only)

data/sample/ (committed, anonymized, small)

Professional signal: you are explicit about what is and is not allowed.