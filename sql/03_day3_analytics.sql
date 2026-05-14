-- =============================================================================
-- Day 3 — Analytics layer on staging.online_retail_lines
-- Thin fact for KPIs + reporting views. Run after Day 2 staging view exists.
-- =============================================================================

USE WAREHOUSE retail_wh;
USE DATABASE retail_lab;
USE SCHEMA analytics;

-- Analyst-facing fact: only rows that pass staging quality flags
CREATE OR REPLACE VIEW retail_lab.analytics.fct_online_retail_kpi AS
SELECT
  invoice_no,
  stock_code,
  description,
  quantity,
  invoice_ts,
  unit_price,
  customer_id,
  country,
  line_revenue
FROM retail_lab.staging.online_retail_lines
WHERE is_valid_for_kpi;

-- Revenue and volume by calendar day
CREATE OR REPLACE VIEW retail_lab.analytics.rpt_revenue_by_day AS
SELECT
  DATE_TRUNC('day', invoice_ts)::DATE AS sale_date,
  SUM(line_revenue) AS revenue,
  SUM(quantity) AS units_sold,
  COUNT(*) AS line_count
FROM retail_lab.analytics.fct_online_retail_kpi
GROUP BY 1;

-- Product-level totals (query with ORDER BY revenue DESC LIMIT N for “top products”)
CREATE OR REPLACE VIEW retail_lab.analytics.rpt_product_revenue AS
SELECT
  stock_code,
  MAX(description) AS any_description,
  SUM(line_revenue) AS revenue,
  SUM(quantity) AS units_sold,
  COUNT(*) AS line_count
FROM retail_lab.analytics.fct_online_retail_kpi
GROUP BY stock_code;

-- Country-level totals
CREATE OR REPLACE VIEW retail_lab.analytics.rpt_country_revenue AS
SELECT
  country,
  SUM(line_revenue) AS revenue,
  SUM(quantity) AS units_sold,
  COUNT(*) AS line_count
FROM retail_lab.analytics.fct_online_retail_kpi
GROUP BY country;

-- Customer-level: invoice count and revenue (filter invoice_count > 1 for “repeat” customers)
CREATE OR REPLACE VIEW retail_lab.analytics.rpt_customer_orders AS
SELECT
  customer_id,
  COUNT(DISTINCT invoice_no) AS invoice_count,
  SUM(line_revenue) AS revenue,
  SUM(quantity) AS units_sold
FROM retail_lab.analytics.fct_online_retail_kpi
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

-- -----------------------------------------------------------------------------
-- Example ad-hoc queries (run separately; good for Query Profile practice)
-- -----------------------------------------------------------------------------

-- Top 15 products by revenue
-- SELECT * FROM retail_lab.analytics.rpt_product_revenue
-- ORDER BY revenue DESC
-- LIMIT 15;

-- Top 10 countries
-- SELECT * FROM retail_lab.analytics.rpt_country_revenue
-- ORDER BY revenue DESC
-- LIMIT 10;

-- Repeat customers (more than one invoice)
-- SELECT * FROM retail_lab.analytics.rpt_customer_orders
-- WHERE invoice_count > 1
-- ORDER BY revenue DESC
-- LIMIT 25;

-- Last 14 days of revenue (adjust date filter if your data range differs)
-- SELECT * FROM retail_lab.analytics.rpt_revenue_by_day
-- ORDER BY sale_date DESC
-- LIMIT 14;

-- -----------------------------------------------------------------------------
-- Day 3 checklist (Snowsight — no SQL required)
-- -----------------------------------------------------------------------------
-- 1) Run one of the heavy SELECTs above, then open Query History -> Query Profile.
-- 2) Optional: clone the query, resize warehouse (e.g. X-SMALL vs SMALL), compare profile/runtime/credits.
-- 3) Catalog / Database Explorer: open analytics.fct_online_retail_kpi and check Lineage upstream to staging/raw.
-- 4) Save this file to Git after objects compile successfully.
