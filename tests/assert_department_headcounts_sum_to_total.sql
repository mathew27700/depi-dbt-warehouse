{{ config(store_failures=true, tags=['reconciliation']) }}

-- Singular test: the per-department headcounts in the aggregate must add up to
-- the number of employees in the fact. Returns a row (= failure) only on mismatch.

with agg as (
    select sum(headcount) as agg_total from {{ ref('agg_department_summary') }}
),
fact as (
    select count(*) as fact_total from {{ ref('fct_employee_compensation') }}
)

select agg_total, fact_total
from agg
cross join fact
where agg_total <> fact_total
