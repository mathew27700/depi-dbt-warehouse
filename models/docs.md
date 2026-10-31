{% docs __overview__ %}

# DEPI Employee Data Warehouse

A dbt project that turns one messy HR extract (`DEPI_data.csv`, 3,000 employees)
into a tested, documented **star schema**.

```
 raw (seeds)            staging (views)              dwh (tables)
 ───────────            ───────────────              ────────────────────────────────
 raw_employees   ───►   stg_employees        ───►    dim_employee
 ref_country_region ──► stg_country_reference ──►    dim_country
 ref_department_function ► stg_department_reference ► dim_department
                                                      fct_employee_compensation
                                                      agg_department_summary
                                                      agg_country_summary
                                                      agg_gender_pay_gap
                                                      agg_data_quality_summary
```

| Schema | Purpose |
|---|---|
| `raw` | Data exactly as received (all text). |
| `staging` | Typed, trimmed, standardised, flagged. One model per source. |
| `dwh` | Dimensions, one fact table and ready-to-query aggregates. |
| `dq_audit` | Rows that failed a test (`store_failures`). |

**Tip:** click the green *lineage graph* button (bottom-right) and filter by
`tag:dimension`, `tag:fact` or `tag:aggregate`.

{% enddocs %}


{% docs stg_employees %}

One row per employee, cleaned and correctly typed.

**What staging does**

* trims & collapses whitespace in every text column (`clean_string`)
* fixes names conservatively (`proper_name`): `O' Sullivan` → `O'Sullivan`, `oldey` → `Oldey`
* turns `$3206.23` **and** `3206.23` into `DECIMAL(12,2)` (`parse_money`)
* lower-cases e-mail and derives `email_domain`
* **flags** (never hides) quality problems: currency symbol, fixed name, suspicious characters

{% enddocs %}


{% docs salary_cleaning %}

Monthly salary as `DECIMAL(12,2)`.

The source mixes two formats - about two thirds of rows are written `$3206.23`
and the rest `3206.23` (or just `4102`). The `parse_money` macro strips `$`, `,`
and spaces, then uses a *safe* cast, so an unparseable value becomes `NULL` and
is caught by the `not_null` test instead of crashing the run.

{% enddocs %}


{% docs salary_band %}

Pay grade derived from `salary` using the cut-offs in the `salary_band_thresholds`
project variable (default: Entry < 4,500 ≤ Mid < 6,500 ≤ Senior < 8,500 ≤ Executive).

{% enddocs %}


{% docs generation %}

Sociological generation from year of birth: **Baby Boomer** (≤1964),
**Gen X** (1965-1980), **Millennial** (1981-1996), **Gen Z** (1997+).

{% enddocs %}


{% docs surrogate_keys %}

Keys such as `employee_key`, `department_key` and `country_key` are deterministic
MD5 hashes of the natural key (macro `surrogate_key`). Because they are pure
functions of the business value, a fact table can compute them independently of
the dimension and still join correctly - verified by `relationships` tests.

{% enddocs %}
