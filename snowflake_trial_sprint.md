---
name: Snowflake Trial Sprint
overview: Build a 5-6 day Snowflake learning path focused on data engineering, analytics, platform administration, and basic metadata discovery through catalog/lineage, with a short data science exposure at the end. The plan is hands-on and sized for roughly 2 hours per day during a 1-month trial.
---

# Snowflake 6-Day Trial Sprint

## Objective
Use your trial account to build one small retail analytics project that teaches the most useful Snowflake capabilities in a short time:
- `A` Data engineering
- `B` Analytics
- `D` Admin, governance, and metadata visibility
- `C` Light Snowpark/Python exposure at the end

This plan is optimized for `5-6 days` at about `2 hours per day`.

## Recommended Project
Build a small retail analytics sandbox using one free dataset and the same objects throughout the week.

Recommended data:
- Best default: IBM `Online Retail Sample CSV` or another simple CSV version of the Online Retail dataset
- Richer option: UCI `Online Retail` dataset
- Faster fallback: a small public `orders` CSV if you want less cleanup

Recommended object layout:
- Database: `retail_lab`
- Schemas: `raw`, `staging`, `analytics`, `sandbox`
- Warehouse: one small warehouse with auto-suspend enabled
- Roles to practice with: `admin_role`, `engineer_role`, `analyst_role`

## What You Should Finish With
By the end of the sprint, you should have:
- raw tables loaded from files
- staging tables or views with cleaned columns and types
- analytics tables or views for business reporting
- a few KPI queries and saved worksheets
- one small `stream` plus `task` demo
- one RBAC demo with separate roles and grants
- one catalog walkthrough in Snowsight
- one lineage view showing upstream and downstream relationships
- one short Snowpark/Python example

## Daily Format
For each day, use this structure:
- `20 min` focused reading or video
- `75 min` hands-on in Snowsight
- `15 min` inspect query profile, history, or usage
- `10 min` write notes on what worked and what was confusing

## Day 1: Setup and Load Data
### Goal
Understand the core Snowflake building blocks and get data loaded successfully.

### Learn
- databases, schemas, warehouses, roles, stages
- how storage and compute are separated
- how data gets loaded into Snowflake

### Do
- create `retail_lab`
- create `raw`, `staging`, `analytics`, and `sandbox` schemas
- create a small warehouse with auto-suspend and auto-resume
- upload one retail CSV using Snowsight or an internal stage
- load data into `raw` tables with `COPY INTO`
- validate row counts and inspect the loaded table

### Outcome
You can explain the basic Snowflake architecture and have a working dataset in `raw`.

## Day 2: Build the Raw to Staging Layer
### Goal
Practice data engineering basics inside Snowflake using SQL transformations.

### Learn
- table vs view
- permanent vs transient table
- basic cleanup patterns for dates, nulls, numeric types, and column naming

### Do
- create cleaned staging tables or views from the raw data
- standardize data types
- derive a few useful columns such as order date, revenue, or region grouping
- rerun the load and confirm your transformation flow still works

### Outcome
You have a repeatable `raw -> staging` pipeline.

## Day 3: Build Analytics and Review Metadata
### Goal
Create analyst-friendly outputs and start exploring metadata.

### Learn
- query profile basics
- warehouse sizing concepts
- auto-suspend, auto-resume, and trial credit discipline
- how to browse objects in Catalog or Database Explorer

### Do
- create analytics views or tables for business reporting
- write a few business queries such as:
  - revenue by day
  - top products
  - orders by country or region
  - repeat customer behavior if the data supports it
- open query history and inspect at least one query profile
- browse your objects in Snowsight Catalog or Database Explorer

### Outcome
You can answer business questions from the data and understand where metadata is visible in Snowsight.

## Day 4: Incremental Pipelines with Streams and Tasks
### Goal
See how Snowflake supports lightweight in-platform automation.

### Learn
- what streams capture
- what tasks schedule or trigger
- where this fits in an ELT workflow

### Do
- insert a small batch of new rows into a raw table
- create a stream to capture changes
- create a task that moves or merges changes into a downstream table
- verify that the downstream table updates as expected

### Outcome
You understand the basics of incremental processing in Snowflake.

## Day 5: Admin, Governance, Catalog, and Lineage
### Goal
Learn how Snowflake controls access and exposes metadata relationships.

### Learn
- role-based access control
- ownership and grants
- warehouse permissions
- basic governance concepts such as masking, row access, and tags

### Do
- create or simulate `admin_role`, `engineer_role`, and `analyst_role`
- grant different levels of access to warehouse, schemas, and tables
- test what each role can and cannot query
- inspect your objects in Catalog or Database Explorer
- open one transformed object and review upstream/downstream lineage in Snowsight
- review available usage or monitoring views in the trial account

### Outcome
You can explain both access control and how Snowflake surfaces metadata, catalog, and lineage.

## Day 6: Light Snowpark/Python Exposure
### Goal
Understand where Python fits into the Snowflake workflow without going deep.

### Learn
- what Snowpark is
- when SQL is enough
- when Python is a better fit

### Do
- create a very small Snowpark or Python example
- read a Snowflake table
- apply a simple transformation or filter
- write the result back to a new table or temporary object

### Outcome
You finish with a clear mental model of how SQL-first workflows and Python-based workflows connect.

## If Time Gets Tight
Do these first:
1. Day 1
2. Day 2
3. Day 3

Then continue with:
1. Day 5
2. Day 4
3. Day 6

If you only have time for five days, keep Day 6 very short.

## Notes on Catalog and Lineage
- Catalog browsing in Snowsight should definitely be part of your learning plan.
- Lineage is best explored after you create real dependencies between raw, staging, and analytics objects.
- If a programmatic lineage function is not available in your trial edition, the Snowsight UI view is still enough for learning.

## What Not to Spend Time On
- advanced optimization before you understand the basics
- large warehouses that burn trial credits quickly
- too many disconnected demos across unrelated datasets
- deep ML work during this sprint

## Optional Next Step After the Sprint
If you still have trial time left, choose one deeper path:
- data engineering: dynamic tables, external stages, dbt integration
- analytics: BI connectivity, semantic modeling, performance tuning
- platform/admin: resource monitors, sharing, governance policies
- data science: richer Snowpark examples, UDFs, stored procedures
