-- =============================================================================
-- Day 4 — Streams + tasks: incremental raw -> staging table
-- Prereqs: Day 1 raw table loaded; Day 2 staging view exists.
-- =============================================================================

USE WAREHOUSE retail_wh;
USE DATABASE retail_lab;

-- -----------------------------------------------------------------------------
-- Step 1 — Materialized staging TABLE (one-time full load from Day 2 view)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE retail_lab.staging.online_retail_lines_tbl AS
SELECT *
FROM retail_lab.staging.online_retail_lines;

-- Baseline count
-- SELECT COUNT(*) AS tbl_cnt FROM retail_lab.staging.online_retail_lines_tbl;

-- -----------------------------------------------------------------------------
-- Step 2 — Stream on RAW table (captures inserts/updates/deletes)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE STREAM retail_lab.raw.stream_online_retail_raw
  ON TABLE retail_lab.raw.online_retail_raw;

-- -----------------------------------------------------------------------------
-- Step 3 — Simulate new data: insert a few test rows into RAW
--    (Use new invoice numbers so they are obvious in validation.)
-- -----------------------------------------------------------------------------
INSERT INTO retail_lab.raw.online_retail_raw (
  invoiceno, stockcode, description, quantity, invoicedate, unitprice, customerid, country
)
VALUES
  ('999991', 'TEST01', 'Day4 test product A', '2',  '2011-12-09 12:00:00', '9.99',  '99901', 'United Kingdom'),
  ('999992', 'TEST02', 'Day4 test product B', '1',  '2011-12-09 13:15:00', '4.50',  '99902', 'Germany'),
  ('999993', 'TEST03', 'Day4 test product C', '5',  '2011-12-09 14:30:00', '1.25',  NULL,    'France');

-- Stream should now show changes (run before task consumes them):
-- SELECT * FROM retail_lab.raw.stream_online_retail_raw;

-- -----------------------------------------------------------------------------
-- Step 4 — Task: append new/changed raw rows into staging TABLE
--   Reads stream, applies same rules as staging view via join to view.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TASK retail_lab.raw.task_refresh_staging_from_stream
  WAREHOUSE = retail_wh
  SCHEDULE = '1 MINUTE'
  COMMENT = 'Day4 lab: load new raw lines from stream into staging table'
AS
  INSERT INTO retail_lab.staging.online_retail_lines_tbl (
    invoice_no, stock_code, description, quantity, invoice_ts, unit_price,
    customer_id, country, line_revenue, is_cancel_or_return, is_valid_for_kpi
  )
  SELECT
    v.invoice_no, v.stock_code, v.description, v.quantity, v.invoice_ts, v.unit_price,
    v.customer_id, v.country, v.line_revenue, v.is_cancel_or_return, v.is_valid_for_kpi
  FROM retail_lab.staging.online_retail_lines v
  INNER JOIN retail_lab.raw.stream_online_retail_raw s
    ON TRIM(s.invoiceno) = v.invoice_no
   AND TRIM(s.stockcode) = v.stock_code
  WHERE s.METADATA$ACTION = 'INSERT';

-- Tasks are created SUSPENDED — resume when ready:
-- ALTER TASK retail_lab.raw.task_refresh_staging_from_stream RESUME;

-- Run once immediately (optional, instead of waiting for schedule):
-- EXECUTE TASK retail_lab.raw.task_refresh_staging_from_stream;

-- -----------------------------------------------------------------------------
-- Step 5 — Validation
-- -----------------------------------------------------------------------------
-- SELECT invoiceno, stockcode, description FROM retail_lab.raw.online_retail_raw
-- WHERE invoiceno IN ('999991','999992','999993');

-- SELECT invoice_no, stock_code, line_revenue, is_valid_for_kpi
-- FROM retail_lab.staging.online_retail_lines_tbl
-- WHERE invoice_no IN ('999991','999992','999993');

-- SELECT COUNT(*) AS stream_has_rows
-- FROM retail_lab.raw.stream_online_retail_raw;

-- SHOW TASKS IN SCHEMA retail_lab.raw;
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
--   TASK_NAME => 'TASK_REFRESH_STAGING_FROM_STREAM',
--   SCHEDULED_TIME_RANGE_START => DATEADD('hour', -1, CURRENT_TIMESTAMP())
-- ));
