# Snowflake learning

Personal Snowflake trial sprint: SQL scripts, notes, and the learning plan in `snowflake_trial_sprint.md`.

## Contents

- `snowflake_trial_sprint.md` — 6-day plan (data engineering, analytics, admin, catalog/lineage, light Snowpark).

## SQL scripts (`sql/`)

| File | Purpose |
|------|---------|
| `00_day1_setup_and_load.sql` | Warehouse, DB, schemas, stage, raw table, `COPY INTO` |
| `01_day2_activity1_staging_contract.sql` | Day 2 diagnostics + staging contract |
| `02_day2_staging_online_retail_lines.sql` | `staging.online_retail_lines` view (types, flags, `line_revenue`) |
| `03_day3_analytics.sql` | `analytics` KPI fact + reporting views (`rpt_*`) |

Run scripts in Snowsight (workspace or worksheet) or sync from Git.
