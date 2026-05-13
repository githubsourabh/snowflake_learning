-- =============================================================================
-- Day 2 — Activity 1: Define the staging contract
-- Goal: Decide target column names, types, and data-quality rules BEFORE you
--       write CREATE VIEW ... AS SELECT. Run the diagnostics below first.
-- =============================================================================

USE WAREHOUSE retail_wh;
USE DATABASE retail_lab;

-- -----------------------------------------------------------------------------
-- A) Diagnostics (run these; use results to confirm or tweak the contract)
-- -----------------------------------------------------------------------------

-- Raw shape
DESCRIBE TABLE retail_lab.raw.online_retail_raw;

SELECT * FROM retail_lab.raw.online_retail_raw LIMIT 30;

-- How many rows look empty on key fields?
SELECT
  COUNT(*) AS total_rows,
  COUNT_IF(TRIM(COALESCE(invoiceno, '')) = '') AS blank_invoice,
  COUNT_IF(TRIM(COALESCE(stockcode, '')) = '') AS blank_stockcode,
  COUNT_IF(TRIM(COALESCE(quantity, '')) = '') AS blank_quantity,
  COUNT_IF(TRIM(COALESCE(unitprice, '')) = '') AS blank_unitprice,
  COUNT_IF(TRIM(COALESCE(invoicedate, '')) = '') AS blank_invoicedate
FROM retail_lab.raw.online_retail_raw;

-- -----------------------------------------------------------------------------
-- B) Staging contract (fill in "Decision" if you change defaults)
--
-- Target object (suggestion): VIEW retail_lab.staging.online_retail_lines
--
-- | Target column      | Type            | Source (raw) | Rule / Decision |
-- |--------------------|-----------------|--------------|-----------------|
-- | invoice_no         | VARCHAR         | invoiceno    | TRIM; keep as text (some invoices may be alphanumeric) |
-- | stock_code         | VARCHAR         | stockcode    | TRIM |
-- | description        | VARCHAR         | description  | TRIM; allow NULL |
-- | quantity           | NUMBER(38,0)    | quantity     | TRY_TO_NUMBER; NULL if invalid |
-- | invoice_ts         | TIMESTAMP_NTZ   | invoicedate  | TRY_TO_TIMESTAMP with format that matches YOUR export (UCI exports vary) |
-- | unit_price         | NUMBER(18,4)   | unitprice    | TRY_TO_DECIMAL; NULL if invalid |
-- | customer_id        | VARCHAR         | customerid   | TRIM; NULL if blank (many rows have no customer in Online Retail) |
-- | country            | VARCHAR         | country      | TRIM |
-- | line_revenue       | NUMBER(18,4)   | derived      | quantity * unit_price when both numeric; else NULL |
-- | is_cancel_or_return| BOOLEAN         | derived      | quantity < 0 OR unit_price < 0 OR invoice_no LIKE 'C%' (tune after you inspect data) |
-- | is_valid_for_kpi   | BOOLEAN         | derived      | TRUE when core fields parse and you want KPIs to include the row |
--
-- Default decisions (change after diagnostics):
-- - Keep cancelled/return lines in staging but FLAG them (do not silently drop).
-- - Rows that fail date or number parse: keep with NULL typed fields; is_valid_for_kpi = FALSE.
--
-- -----------------------------------------------------------------------------

-- Optional: inspect invoice patterns (helps tune is_cancel_or_return)
SELECT invoiceno, COUNT(*) AS cnt
FROM retail_lab.raw.online_retail_raw
WHERE invoiceno IS NOT NULL
GROUP BY 1
ORDER BY cnt DESC
LIMIT 30;
