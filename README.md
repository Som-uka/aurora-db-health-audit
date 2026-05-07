# Database Health Audit

A comprehensive schema and data quality audit of a large operational MySQL database — covering missing primary keys, absent foreign key constraints, excessive nullability, duplicate rows, and column inconsistencies.

---

## Overview

This project documents a deep-dive health audit of a production operational database with 211 tables, ~362 million rows, and ~44 GB of data. The audit surfaced structural integrity issues posing risks to data reliability, query performance, BI reporting accuracy, and future migration readiness.

---

## Database Profile

| Metric | Value |
|---|---|
| Total tables | 211 |
| Total rows (approx) | ~362 million |
| Total size (approx) | ~44 GB |
| Tables without primary keys | 62 |
| Foreign key constraints total | 7 (across 4 tables only) |
| Tables with ≥50% nullable columns | 173 |
| Column naming/type inconsistencies | 54 |

---

## Key Findings

### Missing Primary Keys
62 tables have no primary key — the most critical structural gap. Without PKs, rows cannot be uniquely identified, replication is unreliable, and ORM-based layers behave unpredictably. The worst offender had ~267M rows and ~8.8 GB with no PK defined.

### Absent Foreign Key Constraints
Only 7 FK constraints exist across the entire schema (4 tables). Referential integrity is entirely enforced at the application layer with no database-level guarantee against orphaned records.

### Duplicate Rows
- One analytics table: ~20.7% duplicate rows — highest BI reporting risk
- One lookup table: 79 duplicates out of 99 total rows (79.8%)

### Excessive Nullability
173 of 211 tables have 50%+ of columns defined as nullable, making it difficult to enforce data contracts and increasing the risk of silent gaps in reporting.

---

## Audit Queries

```sql
-- Tables with no primary key
SELECT t.table_name
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc
  ON t.table_name = tc.table_name
  AND tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema = t.table_schema
WHERE t.table_schema = '<database_name>'
  AND tc.constraint_name IS NULL
  AND t.table_type = 'BASE TABLE';

-- Tables by size
SELECT table_name,
  table_rows,
  ROUND(data_length / 1024 / 1024, 2) AS data_mb
FROM information_schema.tables
WHERE table_schema = '<database_name>'
ORDER BY data_length DESC;

-- Duplicate row detection pattern
SELECT col1, col2, col3, COUNT(*) AS cnt
FROM <table_name>
GROUP BY col1, col2, col3
HAVING COUNT(*) > 1;
```

---

## Remediation Priorities

| Priority | Finding | Action |
|---|---|---|
| 🔴 High | Analytics table duplicates (~20%) | Deduplicate + add unique constraint |
| 🔴 High | Tables >100M rows with no PK | Add surrogate or composite PK |
| 🟡 Medium | Tables 1M–10M rows with no PK | Add PK in low-traffic window |
| 🟡 Medium | Missing FK constraints | Add FKs where referential integrity is expected |
| 🟢 Low | Column naming inconsistencies | Standardize via migration scripts |

---

## Repository Structure

```
yeti-db-health-audit/
├── README.md
├── findings/
│   ├── missing-primary-keys.md
│   ├── missing-foreign-keys.md
│   ├── duplicate-row-analysis.md
│   ├── nullability-report.md
│   └── column-inconsistencies.md
├── queries/
│   ├── audit-primary-keys.sql
│   ├── audit-foreign-keys.sql
│   ├── find-duplicates.sql
│   └── table-size-report.sql
└── remediation/
    ├── deduplication-strategy.md
    └── pk-remediation-plan.md
```

---

## Tech Stack

- MySQL (Aurora-compatible), DataGrip, SQL
- AWS RDS / Aurora

> All database names, table names, and business context have been sanitized.
