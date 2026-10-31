-- Aggregate. Grain: one row per data-quality rule applied in staging.
-- Turns the boolean flags on stg_employees into a ready-made data-quality report.

with employees as (

    select * from {{ ref('stg_employees') }}

),

rules as (

    select
        'salary_had_currency_symbol'  as rule_name,
        'Salary was written like "$1234.56"; symbol stripped and cast to DECIMAL' as description,
        'auto-fixed'                  as handling,
        sum(case when has_currency_symbol then 1 else 0 end) as affected_rows,
        count(*)                      as total_rows
    from employees

    union all

    select
        'name_was_fixed',
        'Name had stray apostrophe-space or was entirely lower-case; normalised',
        'auto-fixed',
        sum(case when name_was_fixed then 1 else 0 end),
        count(*)
    from employees

    union all

    select
        'name_has_suspicious_characters',
        'Name contains characters other than letters, space, dot, apostrophe, hyphen',
        'flagged only (needs human review)',
        sum(case when has_suspicious_name_chars then 1 else 0 end),
        count(*)
    from employees

    union all

    select
        'date_of_birth_unparseable',
        'Date of birth could not be cast to DATE',
        'flagged only (needs human review)',
        sum(case when date_of_birth is null then 1 else 0 end),
        count(*)
    from employees

)

select
    rule_name,
    description,
    handling,
    cast(affected_rows as integer)  as affected_rows,
    cast(total_rows as integer)     as total_rows,
    cast(round(100.0 * affected_rows / total_rows, 2) as numeric(5, 2)) as pct_affected
from rules
