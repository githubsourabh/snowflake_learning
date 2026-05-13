-- =============================================================================
-- Day 2 — Staging view: raw.online_retail_raw -> staging.online_retail_lines
-- Run after Day 1 load. Uses CTE so invoice_ts is parsed once; COALESCE covers
-- common UCI / Excel export shapes (UK retailer often DD/MM/YYYY).
-- =============================================================================

USE WAREHOUSE retail_wh;
USE DATABASE retail_lab;
USE SCHEMA staging;

CREATE OR REPLACE VIEW retail_lab.staging.online_retail_lines AS
WITH base AS (
  SELECT
    TRIM(r.invoiceno) AS invoice_no,
    TRIM(r.stockcode) AS stock_code,
    NULLIF(TRIM(r.description), '') AS description,
    TRY_TO_NUMBER(NULLIF(TRIM(r.quantity), '')) AS quantity,
    COALESCE(
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate)),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'DD/MM/YYYY HH24:MI'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'DD/MM/YYYY HH24:MI:SS'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'DD/MM/RR HH24:MI'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'MM/DD/YYYY HH24:MI'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'MM/DD/YYYY HH24:MI:SS'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'YYYY-MM-DD HH24:MI:SS'),
      TRY_TO_TIMESTAMP_NTZ(TRIM(r.invoicedate), 'YYYY-MM-DD HH24:MI')
    ) AS invoice_ts,
    TRY_TO_DECIMAL(NULLIF(TRIM(r.unitprice), ''), 18, 4) AS unit_price,
    NULLIF(TRIM(r.customerid), '') AS customer_id,
    NULLIF(TRIM(r.country), '') AS country
  FROM retail_lab.raw.online_retail_raw AS r
)
SELECT
  invoice_no,
  stock_code,
  description,
  quantity,
  invoice_ts,
  unit_price,
  customer_id,
  country,
  IFF(
    quantity IS NOT NULL AND unit_price IS NOT NULL,
    quantity * unit_price,
    NULL
  ) AS line_revenue,
  (
    COALESCE(quantity, 0) < 0
    OR COALESCE(unit_price, 0) < 0
    OR STARTSWITH(UPPER(invoice_no), 'C')
  ) AS is_cancel_or_return,
  (
    invoice_ts IS NOT NULL
    AND quantity IS NOT NULL
    AND unit_price IS NOT NULL
    AND quantity > 0
    AND unit_price >= 0
    AND NOT STARTSWITH(UPPER(invoice_no), 'C')
  ) AS is_valid_for_kpi
FROM base;

-- -----------------------------------------------------------------------------
-- Validation (run after CREATE VIEW)
-- -----------------------------------------------------------------------------
-- SELECT COUNT(*) AS raw_cnt FROM retail_lab.raw.online_retail_raw;
-- SELECT COUNT(*) AS stg_cnt FROM retail_lab.staging.online_retail_lines;
--
-- SELECT * FROM retail_lab.staging.online_retail_lines LIMIT 30;
--
-- SELECT
--   COUNT_IF(invoice_ts IS NULL) AS null_ts,
--   COUNT_IF(quantity IS NULL) AS null_qty,
--   COUNT_IF(unit_price IS NULL) AS null_price,
--   COUNT_IF(is_valid_for_kpi) AS kpi_rows,
--   COUNT_IF(is_cancel_or_return) AS cancel_or_return_rows
-- FROM retail_lab.staging.online_retail_lines;
--
-- SELECT DATE_TRUNC('day', invoice_ts) AS d, SUM(line_revenue) AS rev
-- FROM retail_lab.staging.online_retail_lines
-- WHERE is_valid_for_kpi
-- GROUP BY 1
-- ORDER BY 1
-- LIMIT 14;
