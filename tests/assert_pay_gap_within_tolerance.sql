{{ config(severity='warn', store_failures=true, tags=['business_rule']) }}

-- Singular test (WARN): flag any department whose average gender pay gap is larger
-- (in either direction) than `pay_gap_warn_threshold_pct`. This is a business signal
-- for HR, not a pipeline defect, so it warns rather than fails.

select
    department_name,
    avg_male_salary,
    avg_female_salary,
    pay_gap_pct
from {{ ref('agg_gender_pay_gap') }}
where abs(pay_gap_pct) > {{ var('pay_gap_warn_threshold_pct') }}
