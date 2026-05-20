# Day 4 — Activity 1: Streams and tasks (concepts)

## One-line definitions

| Piece | What it is |
|-------|------------|
| **Stream** | A **change log** on a table: “what changed since we last read this stream?” |
| **Task** | A **scheduled (or triggered) job** that runs SQL using a warehouse |

Together: **new/changed rows land in raw → stream notices → task runs SQL → downstream table stays up to date.**

---

## Stream (change capture)

- Created **on a table** (not on a view): `CREATE STREAM ... ON TABLE retail_lab.raw.online_retail_raw`.
- Does **not** copy all table data by itself; it exposes **deltas** when you query the stream.
- When you read from the stream in a `MERGE`/`INSERT`, Snowflake advances what the stream considers “already processed” for that consumer pattern.
- Stream rows include metadata columns (e.g. whether the change was an insert/update/delete) — useful in merges.

**Mental model:** a bookmark on table changes, not a second full copy of the table (though streams have storage implications in production).

---

## Task (orchestration inside Snowflake)

- `CREATE TASK` defines **what SQL to run** and **when** (schedule / after another task).
- Tasks are often created **SUSPENDED**; you **`ALTER TASK ... RESUME`** when ready.
- A task needs a **warehouse** (`WAREHOUSE = retail_wh`) to run.
- For Day 4 lab: a simple **every N minutes** schedule is enough.

**Mental model:** cron + SQL inside Snowflake, without Airflow/dbt for this exercise.

---

## How this maps to *your* project

```
raw.online_retail_raw  (table — you INSERT new CSV rows or test rows)
        │
        ▼
stream on raw          (e.g. stream_online_retail_raw)
        │
        ▼
task (scheduled)       (reads stream, MERGE/INSERT into …)
        │
        ▼
staging.online_retail_lines_tbl   (TABLE — materialized cleaned rows)
```

Why a **table** downstream?

- Day 2 **`staging.online_retail_lines`** is a **view** (always fresh, no stored rows).
- Streams/tasks in this lab usually **write into a table** you refresh incrementally.
- Analytics can keep using **views** on top of that table, or you re-run aggregates later.

Your Day 2 **view logic** (TRIM, TRY_TO_*, flags) is still the definition of “clean”; the task applies that logic to **only changed rows** from the stream.

---

## What you will do in later Day 4 activities (preview)

1. **INSERT** a small test batch into `raw.online_retail_raw`.
2. **CREATE STREAM** on that raw table.
3. **CREATE TABLE** `staging.online_retail_lines_tbl` (initial load + merge target).
4. **CREATE TASK** that merges stream rows into that table.
5. **RESUME** task, wait for a run, **validate** row counts.

---

## Optional: explore your account now (run in Snowsight)

```sql
USE DATABASE retail_lab;

SHOW STREAMS IN DATABASE retail_lab;
SHOW TASKS IN DATABASE retail_lab;
```

Empty results are fine — you have not created Day 4 objects yet.

---

## Common gotchas (save time later)

- Task **suspended** → nothing runs until resumed.
- **Warehouse suspended** → task may queue or wait; ensure `retail_wh` can start.
- Stream on a **view** → not supported; use the **base table** (`online_retail_raw`).
- Forgetting **MERGE keys** (e.g. invoice + stock + date) → duplicate rows in target table.

---

## Activity 1 complete when

You can explain in your own words:

1. What a stream does on `online_retail_raw`.
2. What a task will do on a schedule.
3. Why the merge target should be a **table**, not only the staging **view**.

Next activity: choose the exact source/target names and insert a test batch into raw.
