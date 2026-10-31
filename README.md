<div align="center">

# DEPI Workforce Intelligence

### A tested **dbt** data warehouse, and a dashboard that sits on top of it

`raw` → `staging` → `dwh` · star schema · **146 checks passing** · runs on a laptop with zero infrastructure

[![dbt](https://img.shields.io/badge/dbt-1.12-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![DuckDB](https://img.shields.io/badge/DuckDB-2.0-FFF000?logo=duckdb&logoColor=black)](https://duckdb.org/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Tests](https://img.shields.io/badge/tests-146%20passing%20%C2%B7%201%20warning-0ca30c)](#testing-strategy)
[![CI](https://github.com/mathew27700/depi-dbt-warehouse/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/mathew27700/depi-dbt-warehouse/actions/workflows/dbt-ci.yml)

**[Live dashboard](https://mathew27700.github.io/depi-dbt-warehouse/)** ·
**[dbt docs & lineage](https://mathew27700.github.io/depi-dbt-warehouse/dbt-docs.html)** ·
**[Quick start](#quick-start)** ·
**[Tool stack](#tool-stack)**

<br>

<img src="docs/assets/dashboard-dark.png" alt="DEPI Workforce Intelligence dashboard (dark theme)" width="100%">

</div>

> The links above work once GitHub Pages is switched on: **Settings → Pages → Deploy from a branch → `main` / `/docs`**.
> Until then, just open `docs/index.html` in a browser; it is a single offline file.

---

## Contents

1. [What this project is](#what-this-project-is)
2. [Tool stack](#tool-stack)
3. [The dashboard](#the-dashboard)
4. [Quick start](#quick-start)
5. [Architecture and data model](#architecture-and-data-model)
6. [What the raw data looked like](#what-the-raw-data-looked-like-and-what-staging-does-about-it)
7. [Testing strategy](#testing-strategy)
8. [Custom macros](#custom-macros-macros)
9. [Documentation](#documentation)
10. [Repository layout](#repository-layout)
11. [Notes and limits](#notes--limits)

---

## What this project is

One messy HR extract (`DEPI_data.csv`, **3,000 employees**) goes in. Out comes a **tested, documented star schema**
and an interactive dashboard that reads from it.

| | |
|---|---|
| **Layers** | `raw` (seeds) → `staging` (views) → `dwh` (tables), each in its own database schema |
| **Models** | 3 staging views · 3 dimensions · 1 fact · 4 aggregates (11 models, 3 seeds) |
| **Quality** | 130 data tests + 2 unit tests + enforced contracts on every dimension and the fact |
| **Custom code** | 15 macros · 8 custom generic tests · 6 singular tests |
| **Result** | `PASS=146  WARN=1  ERROR=0` (the one warning is deliberate: a surname `Giovannacc@i` flagged for human review) |
| **Money check** | Payroll reconciles to the cent between staging and the fact table: **$19,352,774.90** |

---

## Tool stack

Everything used to build, test, document, ship and visualise the project.

| Category | Tool | Version | What it does here |
|---|---|---|---|
| **Transform & test** | **dbt Core** | 1.12.6 | Models, macros, tests, unit tests, contracts, docs and lineage |
| | **dbt-duckdb** | 1.11.1 | The dbt adapter that runs everything on DuckDB |
| | **SQL + Jinja2** | Jinja 3.1.6 | Every model is SQL; the 15 macros are Jinja templating |
| **Storage & compute** | **DuckDB** | 2.0.0 | Embedded analytical warehouse in one file (`data/depi_warehouse.duckdb`), no server needed |
| **Runtime** | **Python** | 3.12 | Runs dbt and builds the dashboard from the warehouse |
| | **uv** | 0.12 | Fast virtual-environment and dependency installer |
| **Version control & CI** | **Git** | 2.47 | Version control |
| | **GitHub** | | Hosts the repository and this README |
| | **GitHub Actions** | | CI: parse, build, run all tests, generate docs and dashboard on every push and PR |
| | **GitHub Pages** | | Serves the dashboard and the dbt docs site |
| **Task runners** | **PowerShell + Make** | | One-command setup and run on Windows / macOS / Linux |
| **Documentation** | **dbt docs** | | Searchable catalog and interactive lineage graph |
| | **Mermaid** | | The ER diagram below, rendered natively by GitHub |
| **Dashboard** | **Vanilla JavaScript + SVG** | | The dashboard: **no frameworks, no CDN, no build step**, works offline |
| | **Playwright + Microsoft Edge** | 1.64 | Headless browser used to test and screenshot the dashboard (dev only) |
| **AI assistance** | **Claude Code** | Sonnet 5.5 | Helped with checking and fixing errors |

---

## The dashboard

<table>
<tr>
<td width="50%"><img src="docs/assets/dashboard-light.png" alt="Dashboard, light theme"></td>
<td width="50%"><img src="docs/assets/pipeline-dark.png" alt="Pipeline and data-quality section"></td>
</tr>
<tr><td align="center"><sub>Light theme: same file, one click</sub></td><td align="center"><sub>Live view of the pipeline, test scoreboard and data-quality fixes</sub></td></tr>
</table>

A single self-contained file, **`docs/index.html`** (~135 KB), generated *from the warehouse itself*, so every number
on it is a number dbt produced and tested.

**What you can do with it**

* **Cross-filter everything.** Pick a department, continent, salary band or gender, or click a bar in any chart.
  All eight views, the hero number and the KPI tiles recompute instantly.
* **Eight views:** department headcount / average salary / payroll · salary distribution with band boundaries ·
  gender pay gap (diverging) · salary-band mix by business function · average salary by age ·
  age × gender · top-10 countries · headcount by continent.
* **Table view on every chart** (the accessible twin), **tooltips on every mark**, full **keyboard** support.
* **Light / dark theme**, responsive down to phone width, respects *reduced motion*.
* **Pipeline & quality section:** the three layers with live row counts, test scoreboard
  (146 passed · 1 warning · 0 failed), and what the cleaning layer fixed.
* **Optional texture overlay** (hatching) for colour-blind and print use.

**Design decisions** (not decoration)

* Chart form follows the job: single-hue bars for magnitude, a **diverging** chart for the pay gap, an ordinal blue ramp
  for ordered salary bands, a headline number where the story is one number.
* One colour per meaning everywhere: **blue = men, orange = women**, in every chart.
* The palette was **validated** (colour-vision-deficiency separation, contrast, lightness band) in both themes.
* **Privacy by design:** only anonymised columns are published (department, country, gender, salary, age).
  **No names, e-mails or birth dates** are in the file.

**Build it yourself** (after `dbt build`):

```bash
python dashboard/build_dashboard.py        # writes docs/index.html
```

`scripts/run.ps1` and `make dashboard` do this for you. The band cut-offs on the dashboard are read from
`dbt_project.yml`, so there is a single source of truth.

---

## Quick start

Prerequisite: Python 3.10+ (or [`uv`](https://docs.astral.sh/uv/)). **No database server needed**: the default target is a local DuckDB file.

**Windows (PowerShell)**
```powershell
git clone https://github.com/mathew27700/depi-dbt-warehouse.git; cd depi-dbt-warehouse
.\scripts\setup.ps1          # creates .venv and installs dbt
.\scripts\run.ps1 -Serve     # seed + build + 130 tests + 2 unit tests + dbt docs + dashboard
```

**macOS / Linux / Git Bash**
```bash
make setup                   # creates .venv and installs dbt
make build                   # seeds -> models -> tests, in dependency order
make dashboard               # builds docs/index.html
make serve                   # dbt docs at http://localhost:8080
```

**Plain dbt** (any OS, after `pip install -r requirements.txt`)
```bash
export DBT_PROFILES_DIR=.          # PowerShell:  $env:DBT_PROFILES_DIR = "."
dbt build
dbt docs generate && dbt docs serve
```

Expected result: **`PASS=146 WARN=1 ERROR=0`**. Then open **`docs/index.html`**.

### Handy commands

| Goal | Command |
|---|---|
| Only the staging layer (+ upstream) | `dbt build --select +tag:staging` |
| Only the DWH layer (+ upstream) | `dbt build --select +tag:dwh` |
| One model and everything it feeds | `dbt build --select stg_employees+` |
| Only unit tests | `dbt test --select "test_type:unit"` |
| Only singular tests | `dbt test --select "test_type:singular"` |
| Only reconciliation checks | `dbt test --select tag:reconciliation` |
| Pin "today" for reproducible ages | `dbt build --vars '{as_of_date: 2026-01-01}'` |
| Re-define salary bands | `dbt build --vars '{salary_band_thresholds: {entry_max: 4000, mid_max: 6000, senior_max: 8000}}'` |
| Preview an analysis | `dbt show --select top_5_earners_per_department` |
| Build into isolated schemas (`dev_raw`, `dev_staging`, `dev_dwh`) | `dbt build --vars '{schema_prefix: dev_}'` (full build, not a single `run`) |
| Run on PostgreSQL | `pip install dbt-postgres`, set `DBT_PG_*` env vars, `dbt build --target postgres` |

Query the warehouse with any DuckDB client (e.g. `duckdb data/depi_warehouse.duckdb`):

```sql
select department_name, headcount, avg_salary, pct_female from dwh.agg_department_summary order by avg_salary desc;
select * from dwh.agg_gender_pay_gap order by pay_gap_pct desc;
select * from dwh.agg_data_quality_summary;
select * from dq_audit.assert_no_suspicious_names;   -- the rows behind the warning
```

---

## Architecture and data model

```text
 RAW (seeds)                 STAGING (views)                    DWH (tables)
 ───────────────             ─────────────────────────          ───────────────────────────────
 raw_employees          ──►  stg_employees               ──►    dim_employee ─┐
 ref_country_region     ──►  stg_country_reference       ──►    dim_country  ─┼─► fct_employee_compensation
 ref_department_function ─►  stg_department_reference    ──►    dim_department┘        │
                                                                                       ▼
                                                              agg_department_summary · agg_country_summary
                                                              agg_gender_pay_gap · agg_data_quality_summary
                                                                                       │
                                                                                       ▼
                                                                    dashboard/build_dashboard.py → docs/index.html
```

| Schema | What lives there | Materialisation |
|---|---|---|
| `raw` | Data exactly as received (all text) | seed tables |
| `staging` | Typed, trimmed, standardised, quality-flagged | views |
| `dwh` | Dimensions, fact, aggregates | tables (with **enforced contracts**) |
| `dq_audit` | The exact rows that failed a business / warn-level test | tables |

> Schema names are exact (`staging`, `dwh`, ...) thanks to the overridden `generate_schema_name` macro.

```mermaid
erDiagram
    dim_employee   ||--|| fct_employee_compensation : "employee_key (1:1 - grain)"
    dim_department ||--o{ fct_employee_compensation : "department_key"
    dim_country    ||--o{ fct_employee_compensation : "country_key"
    dim_employee {
        varchar employee_key PK
        int     employee_id
        varchar full_name
        varchar gender
        varchar email
        date    date_of_birth
        int     age_years
        varchar age_band
        varchar generation
    }
    dim_department {
        varchar department_key PK
        varchar department_name
        varchar function_group
    }
    dim_country {
        varchar country_key PK
        varchar country_name
        varchar iso_alpha2
        varchar continent
    }
    fct_employee_compensation {
        varchar employee_key PK, FK
        varchar department_key FK
        varchar country_key FK
        numeric salary
        varchar salary_band
        numeric pct_vs_department_avg
        int     department_salary_rank
        numeric company_salary_percentile
    }
```

**Grain:** `fct_employee_compensation` = one row per employee. Surrogate keys are deterministic MD5 hashes of the
business key (`surrogate_key` macro), so the fact never has to join the dimensions to get its keys, and
`relationships` tests prove the keys line up.

---

## What the raw data looked like (and what staging does about it)

Profiled before writing a single test. The data is structurally sound (3,000 unique ids/e-mails, no nulls,
12 departments, 159 countries) but has real-world mess:

| Problem found | Rows | Handling |
|---|---|---|
| Salary written as `$3206.23` in some rows, `3206.23` / `4102` in others | 2,000 / 1,000 | `parse_money` → `DECIMAL(12,2)`; counted in `agg_data_quality_summary` |
| `O' Sullivan`, `O' Mara`, `O' Timony` (stray space) | 3 | auto-fixed |
| Single lowercase surname (`oldey`, `ducarme`) | 2 | auto-capitalised (but `de Werk`, `de Broke` are left alone: legitimate particles) |
| Surname `Giovannacc@i` | 1 | **flagged, not guessed** → warn test + `dq_audit` table |
| Everything arrives as text | all | typed in staging (`integer`, `date`, `numeric`) |

---

## Testing strategy

**130 data tests + 2 unit tests**

| Type | Where | Examples |
|---|---|---|
| **Built-in generic** | `schema.yml` files | `unique`, `not_null`, `accepted_values`, `relationships` |
| **Custom generic** (8) | `tests/generic/` | `is_valid_email`, `value_between`, `is_trimmed`, `no_double_spaces`, `not_future_date`, `not_accepted_values`, `equal_rowcount`, `column_sum_matches` |
| **Singular** (6) | `tests/*.sql` | headcounts sum to total, payroll share = 100 %, e-mail matches first initial, working-age window, suspicious names (warn), gender pay-gap threshold (warn) |
| **Unit tests** (2) | `staging/schema.yml`, `dwh/schema.yml` | cleaning rules on hand-written rows; age/generation boundaries with a pinned date |
| **Contracts** | `dwh/schema.yml` | column names, data types and `not_null` enforced on all dimensions + the fact |
| **Reconciliation** | fact | `SUM(salary)` staging = fact to the cent; row counts raw = staging = fact |

Severity is deliberate: structural guarantees **fail** the build; business signals (pay scale, new/unmapped country,
pay-gap > 15 %, suspicious names) only **warn** and store the offending rows in `dq_audit`.

> The tests themselves were tested: eight defects were injected into the raw table (unparseable salary, invalid
> e-mail, unknown department, bad gender, future birth date, unmapped country, ...) and every one was caught.

---

## Custom macros (`macros/`)

| Macro | Purpose |
|---|---|
| `generate_schema_name` | Exact schema names per layer (+ optional `schema_prefix` var) |
| `surrogate_key` | NULL-safe MD5 surrogate keys |
| `clean_string` | trim + collapse whitespace + empty → NULL |
| `proper_name` | conservative name repair (no `initcap` damage to `McQuilliam`) |
| `parse_money` | `'$3,206.23'` → `3206.23::numeric(12,2)` |
| `try_cast_to` | adapter-dispatched safe cast (bad value → NULL, not a crash) |
| `has_special_chars` | adapter-dispatched regex check used to flag names |
| `as_of_date`, `age_in_years` | birthday-exact age with a pinnable "today" |
| `generation_label`, `age_band` | demographic segments |
| `salary_band`, `salary_band_order` | pay grades driven by project variables |
| `median` | adapter-dispatched median (DuckDB native vs `percentile_cont`) |
| `log_run_summary` | `on-run-end` scoreboard of OK / WARN / FAIL |

---

## Documentation

* Every model and column is described; reusable text lives in `models/docs.md` (`{{ doc() }}` blocks) and the
  landing page of the docs site is a custom `__overview__`.
* Descriptions are pushed into the database as table/column comments (`persist_docs`).
* Lineage is colour-coded: grey raw, green staging, blue dimensions, red fact, orange aggregates.
* Two **exposures** show the (example) dashboards that depend on the warehouse.
* `docs/dbt-docs.html` is the pre-built, single-file dbt docs site; `docs/index.html` is the dashboard.
  Regenerate both with `.\scripts\run.ps1` or `make docs dashboard`.
* Two **analyses** (`analyses/`) hold ad-hoc queries: top-5 earners per department, payroll by continent × function.

---

## Repository layout

```text
dbt_project.yml  profiles.yml  requirements.txt  Makefile
seeds/        raw_employees.csv  ref_country_region.csv  ref_department_function.csv  schema.yml
models/
  docs.md                              doc blocks + project overview
  staging/    schema.yml  stg_employees.sql  stg_country_reference.sql  stg_department_reference.sql
  dwh/        schema.yml  exposures.yml
    dimensions/  dim_employee  dim_department  dim_country
    facts/       fct_employee_compensation
    aggregates/  agg_department_summary  agg_country_summary  agg_gender_pay_gap  agg_data_quality_summary
macros/       core/ cleaning/ business_logic/ operations/
tests/        generic/ (8 custom tests)   assert_*.sql (6 singular tests)
analyses/     top_5_earners_per_department.sql  payroll_by_continent_and_function.sql
dashboard/    build_dashboard.py  template.html          builds the dashboard from the warehouse
scripts/      setup.ps1  run.ps1  setup.sh
.github/workflows/dbt-ci.yml           parse + build + docs + dashboard on every push / PR
docs/         index.html (dashboard)  dbt-docs.html (dbt docs)  assets/ (README images)
```

## Notes & limits

* Verified on **DuckDB** (dbt-core 1.12.6, dbt-duckdb 1.11.1). The PostgreSQL target is provided but **not tested**; macros use
  `adapter.dispatch` / cross-db dbt macros where syntax differs. On PostgreSQL, `try_cast_to` is a normal cast (a malformed value raises instead of becoming NULL).
* The source is a **static roster**, so no snapshot / incremental model was added; both would be natural next steps once a
  periodic extract exists (SCD2 snapshot on `stg_employees`).
* `raw_employees.csv` is the original file with only the header row lower-cased (dbt `column_types` are case-sensitive).
* The warehouse contains personal-looking fields (names, e-mails, birth dates). The data appears to be synthetic; if yours is real, keep the repository private.
  The **published dashboard never contains** those fields.
* The exposure URLs/owners are placeholders. Replace them with your real dashboard links.
* Ages are computed against the build date (`as_of_date` var), so the "age" views shift slightly each time you rebuild.
