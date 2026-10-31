{{ config(store_failures=true, tags=['data_quality']) }}

-- Singular test: in this source the e-mail always starts with the first letter of
-- the first name (e.g. Donalt -> dspendley0@...). A mismatch usually means two
-- records were mixed up or an e-mail was mis-keyed.

select
    employee_id,
    first_name,
    email
from {{ ref('stg_employees') }}
where lower(substr(email, 1, 1)) <> lower(substr(first_name, 1, 1))
