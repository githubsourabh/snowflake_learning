-- Day 1: Create sandbox objects, stage CSV, load raw table, validate.
-- Run sections in order. Adjust role if your trial defaults differ.

-- -----------------------------------------------------------------------------
-- 0) Context (run and confirm output looks right)
-- -----------------------------------------------------------------------------
SELECT CURRENT_ACCOUNT() AS account,
       CURRENT_USER()   AS user_name,
       CURRENT_ROLE()   AS role_name;

-- Use a role that can create warehouses/databases (often ACCOUNTADMIN on trials).
-- USE ROLE ACCOUNTADMIN;

-- -----------------------------------------------------------------------------
-- 1) Warehouse (small, auto-suspend)
-- -----------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS retail_wh
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE retail_wh;

-- -----------------------------------------------------------------------------
-- 2) Database and schemas
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS retail_lab;
USE DATABASE retail_lab;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS sandbox;

-- -----------------------------------------------------------------------------
-- 3) File format + internal stage (you will upload the CSV here from Snowsight)
-- -----------------------------------------------------------------------------
USE SCHEMA raw;

CREATE OR REPLACE FILE FORMAT csv_ff
  TYPE = CSV
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  EMPTY_FIELD_AS_NULL = TRUE;

CREATE OR REPLACE STAGE data_load FILE_FORMAT = csv_ff;

-- -----------------------------------------------------------------------------
-- 4) Raw landing table (all STRING first — easiest load; you clean types on Day 2)
--    Column names match common "Online Retail" CSV headers (case-insensitive load below).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE online_retail_raw (
  invoiceno     STRING,
  stockcode     STRING,
  description   STRING,
  quantity      STRING,
  invoicedate   STRING,
  unitprice     STRING,
  customerid    STRING,
  country       STRING
);

-- -----------------------------------------------------------------------------
-- 5) AFTER you upload your CSV to stage @retail_lab.raw.data_load:
--    Snowsight → Databases → retail_lab → raw → Stages → data_load → Load files
--    Put exactly ONE retail CSV in this stage for the first load.
-- -----------------------------------------------------------------------------
-- List files (run after upload):
-- LIST @retail_lab.raw.data_load;

-- Load into raw table (keep only one CSV in the stage for this pattern):
-- COPY INTO online_retail_raw
--   FROM @retail_lab.raw.data_load
--   PATTERN = '.*\\.csv'
--   FILE_FORMAT = csv_ff
--   MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
--   ON_ERROR = 'CONTINUE';

-- If your CSV uses different headers, either rename columns in the file to match
-- or replace this COPY with an explicit column list / different table definition.

-- -----------------------------------------------------------------------------
-- 6) Validation queries (run after COPY succeeds)
-- -----------------------------------------------------------------------------
-- SELECT COUNT(*) AS row_count FROM retail_lab.raw.online_retail_raw;
-- SELECT * FROM retail_lab.raw.online_retail_raw LIMIT 20;
