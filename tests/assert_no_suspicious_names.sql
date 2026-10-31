{{ config(severity='warn', store_failures=true, tags=['data_quality']) }}

-- Singular test (WARN): names containing characters like '@' or digits are almost
-- certainly typos. We don't guess a correction - we surface them for a human.
-- Today this catches employee 288 ("Giovannacc@i").

select
    employee_id,
    first_name,
    last_name
from {{ ref('stg_employees') }}
where has_suspicious_name_chars
