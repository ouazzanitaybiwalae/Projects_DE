# Job Postings Data Warehouse

A production-style analytics warehouse built on **DuckDB / MotherDuck**, modeling raw job posting data into a proper **star schema** and serving it through purpose-built **data marts** for different analytical use cases.

This project was built to practice the full data engineering lifecycle: source ingestion, dimensional modeling, mart design, and incremental (upsert) updates — the same patterns used in production warehouses, just at a scale that runs entirely on a laptop.

---

## Architecture

```
Data Storage          Data Warehouse         Data Marts              Data Serving
─────────────         ───────────────        ──────────────          ─────────────
   CSV files      →    job_postings      →    flat_mart          →    Excel
 (Google Cloud          warehouse              skills_mart             Power BI
   Storage)             (DuckDB /              priority_mart           Tableau
                        MotherDuck)                                    Python
```

Raw CSVs are ingested directly from cloud storage into a normalized warehouse (fact + dimension + bridge tables). From there, three specialized marts reshape the data for different consumption patterns — a flat denormalized table for ad-hoc BI tools, a monthly aggregate fact table for trend analysis, and an operational snapshot table for role prioritization.

> Diagram: see `architecture.png` in this folder.

---

## Project Goals

1. Build a **production-ready data warehouse** using star schema design patterns
2. Implement **proper data modeling** with fact tables, dimension tables, and bridge tables
3. Create **specialized data marts** optimized for different analytical use cases

---

## Data Model (Warehouse Layer)

The core warehouse is a classic star schema:

| Table | Type | Purpose |
|---|---|---|
| `job_postings_fact` | Fact | One row per job posting — title, location, salary, remote flag, benefits flags, etc. |
| `company_dim` | Dimension | Company name, links, thumbnail |
| `skills_dim` | Dimension | Skill name and type (e.g. programming language, cloud, tool) |
| `skills_job_dim` | Bridge | Resolves the many-to-many relationship between jobs and skills |

A single job posting can require many skills, and a skill can appear across many postings — hence the bridge table (`skills_job_dim`) rather than a direct foreign key.

Source data is loaded straight from CSVs hosted on Google Cloud Storage using DuckDB's `read_csv(..., AUTO_DETECT = TRUE)`, with row counts and sample rows validated after each load.

---

## Data Marts

Each mart answers a different question and is deliberately shaped differently — this is the "specialized data marts" part of the project, not just three copies of the same table.

### 1. Flat Mart (`flat_mart.job_postings`)
A single denormalized table joining fact + both dimensions, with all of a job's skills collapsed into one nested array field using `ARRAY_AGG(STRUCT_PACK(...))`. Built for tools like Excel or quick Python/Pandas exploration where joins aren't convenient.

### 2. Skills Mart (`skills_mart`)
A proper mini star schema of its own, built for trend analysis:
- `dim_skill` — skill dimension
- `dim_date_month` — a generated month/quarter date dimension (`month_start_date`, `year`, `quarter`, `name_quarter`, `name_year_quarter`)
- `fact_skill_demand_monthly` — monthly posting counts per skill and job title, including remote/health-insurance/no-degree breakdowns

This mart answers questions like *"how has demand for Python grown month over month?"* or *"what share of Data Engineer postings mentioning SQL are remote?"*

### 3. Priority Mart (`priority_mart`)
An operational mart for tracking a curated list of high-priority roles (e.g. Senior Data Engineer, Data Engineer, Data Scientist) with a **priority level**, refreshed via an incremental upsert rather than a full rebuild:
- `priority_roles` — the role → priority level mapping (editable business rule table)
- `priority_jobs_snapshot` — a snapshot of matching postings, kept in sync using `MERGE INTO` logic:
  - updates `priority_lvl` when it changes,
  - inserts new matching postings,
  - **removes postings that no longer match** (`WHEN NOT MATCHED BY SOURCE THEN DELETE`)

This is the closest piece to a real SCD-style incremental load pattern in the project — priority levels can be updated (e.g. promoting "Data Engineer" from priority 2 to 1) without rebuilding the whole table from scratch.

---

## Tech Stack

- **DuckDB** — embedded OLAP engine for local development
- **MotherDuck** — cloud-hosted DuckDB for sharing/serving the warehouse
- **SQL** — all transformation logic (no external orchestration tool yet)
- **Google Cloud Storage** — raw CSV hosting
- Designed to be queried from **Excel, Power BI, Tableau, and Python**

---

## How to Run

The whole warehouse is built by running one script that calls the others in order:

```bash
duckdb dw_marts.duckdb -c ".read build_dw.sql"
```

`build_dw.sql` runs the following steps in sequence:

| Step | Script | Description |
|---|---|---|
| 1 | `create_tables.sql` | Creates the core fact/dimension/bridge tables |
| 2 | `insert_tables.sql` | Loads data from CSVs in Google Cloud Storage, with row-count and sample validation |
| 3 | `create_flatMart.sql` | Builds the denormalized flat mart |
| 4 | `create_skills_mart.sql` | Builds the skills demand mart (dim_skill, dim_date_month, fact_skill_demand_monthly) |
| 5 | `create_priority_mart.sql` | Builds the priority roles mart and initial snapshot |
| 6 | `update_priority_mart.sql` | Demonstrates an incremental upsert/delete refresh of the priority snapshot |

Each script prints validation output (row counts + `LIMIT 5` samples) after it runs, so you can confirm the load succeeded at every stage.

**Requirements:** [DuckDB CLI](https://duckdb.org/docs/installation/) (or a MotherDuck connection string if running against MotherDuck instead of a local `.duckdb` file).

---

## Repo Structure

```
2#Datawarehouse/
├── build_dw.sql              # Orchestrates the full build
├── create_tables.sql         # Warehouse schema (fact, dims, bridge)
├── insert_tables.sql         # CSV ingestion + validation
├── create_flatMart.sql       # Flat mart
├── create_skills_mart.sql    # Skills demand mart
├── create_priority_mart.sql  # Priority mart (initial build)
├── update_priority_mart.sql  # Priority mart incremental refresh (MERGE)
└── architecture.png          # Architecture diagram
```

---

## Example Questions This Warehouse Can Answer

- Which skills had the fastest-growing demand in Data Engineer postings over the last 6 months?
- What percentage of remote postings mention health insurance?
- Which currently open postings match our top-priority target roles, and how has that list changed since the last refresh?

---

## Possible Next Steps

- Orchestrate the build with a scheduler (e.g. dbt or a simple cron + script) instead of manual `.read` calls
- Add automated data quality tests (null checks, referential integrity between fact and dims)
- Parameterize the CSV source path so the pipeline can run against fresh data drops
- Add a BI dashboard (Power BI / Tableau) on top of the skills mart as a companion deliverable