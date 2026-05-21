-- =============================================================================
-- Day 4 one-shot diagnostic — paste entire script, Run All.
-- Change 'DIAG002' / 'DIAGSTK02' to new values if you re-run (e.g. DIAG003).
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE retail_wh;
USE DATABASE retail_lab;

INSERT INTO retail_lab.raw.online_retail_raw (
  invoiceno, stockcode, description, quantity, invoicedate, unitprice, customerid, country
)
VALUES (
  'DIAG002', 'DIAGSTK02', 'One-shot diagnostic row', '3',
  '2011-12-10 16:00:00', '12.34', '88888', 'United Kingdom'
);

SELECT
  'DIAG002' AS diag_id,
  (SELECT COUNT(*) FROM retail_lab.raw.online_retail_raw WHERE invoiceno = 'DIAG002') AS raw_rows,
  (SELECT COUNT(*) FROM retail_lab.raw.stream_online_retail_raw) AS stream_rows,
  (SELECT COUNT(*) FROM retail_lab.staging.online_retail_lines WHERE invoice_no = 'DIAG002') AS view_rows,
  (SELECT COUNT(*)
   FROM retail_lab.staging.online_retail_lines v
   INNER JOIN retail_lab.raw.stream_online_retail_raw s
     ON TRIM(s.invoiceno) = v.invoice_no AND TRIM(s.stockcode) = v.stock_code
   WHERE s.METADATA$ACTION = 'INSERT') AS join_rows_task_would_insert,
  (SELECT COUNT(*) FROM retail_lab.staging.online_retail_lines_tbl WHERE invoice_no = 'DIAG002') AS tbl_rows_before_task;

SHOW TASKS LIKE 'task_refresh_staging%' IN SCHEMA retail_lab.raw;

SELECT 'stream_sample' AS label, METADATA$ACTION, invoiceno, stockcode
FROM retail_lab.raw.stream_online_retail_raw
WHERE invoiceno = 'DIAG002';

SELECT 'stream_any' AS label, METADATA$ACTION, invoiceno, stockcode
FROM retail_lab.raw.stream_online_retail_raw
LIMIT 5;

SELECT 'view_sample' AS label, invoice_no, stock_code, invoice_ts, is_valid_for_kpi
FROM retail_lab.staging.online_retail_lines
WHERE invoice_no = 'DIAG002';

ALTER TASK retail_lab.raw.task_refresh_staging_from_stream RESUME;
EXECUTE TASK retail_lab.raw.task_refresh_staging_from_stream;

SELECT
  'task_history' AS label,
  scheduled_time,
  completed_time,
  state,
  error_code,
  error_message,
  query_id
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD('hour', -2, CURRENT_TIMESTAMP())
))
WHERE name ILIKE '%TASK_REFRESH_STAGING%'
ORDER BY scheduled_time DESC
LIMIT 3;

SELECT 'tbl_after_task' AS label, invoice_no, stock_code, line_revenue, is_valid_for_kpi
FROM retail_lab.staging.online_retail_lines_tbl
WHERE invoice_no = 'DIAG002';

SELECT 'tbl_diag_count_after' AS label, COUNT(*) AS cnt
FROM retail_lab.staging.online_retail_lines_tbl
WHERE invoice_no = 'DIAG002';
