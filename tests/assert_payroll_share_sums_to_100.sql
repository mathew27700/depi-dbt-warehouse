{{ config(store_failures=true, tags=['reconciliation']) }}

-- Singular test: department payroll shares must add up to ~100 %
-- (tolerance of 0.1 for rounding to 2 decimals across 12 departments).

select sum(pct_of_total_payroll) as total_pct
from {{ ref('agg_department_summary') }}
having abs(sum(pct_of_total_payroll) - 100) > 0.1
