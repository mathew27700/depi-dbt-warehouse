{{ config(store_failures=true, tags=['data_quality']) }}

-- Singular test: every employee must be of plausible working age.
-- The window comes from the min_working_age / max_working_age project vars.

select
    employee_key,
    employee_id,
    date_of_birth,
    age_years
from {{ ref('dim_employee') }}
where age_years < {{ var('min_working_age') }}
   or age_years > {{ var('max_working_age') }}
