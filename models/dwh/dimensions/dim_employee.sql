-- DWH dimension: one row per employee, descriptive attributes only (no money).

with employees as (

    select * from {{ ref('stg_employees') }}

),

with_age as (

    select
        *,
        cast({{ age_in_years('date_of_birth') }} as integer) as age_years
    from employees

)

select
    cast({{ surrogate_key(['employee_id']) }} as varchar)   as employee_key,
    cast(employee_id as integer)                            as employee_id,
    cast(first_name as varchar)                             as first_name,
    cast(last_name as varchar)                              as last_name,
    cast(full_name as varchar)                              as full_name,
    cast(gender as varchar)                                 as gender,
    cast(email as varchar)                                  as email,
    cast(email_domain as varchar)                           as email_domain,
    cast(date_of_birth as date)                             as date_of_birth,
    age_years,
    cast({{ age_band('age_years') }} as varchar)            as age_band,
    cast({{ generation_label('date_of_birth') }} as varchar) as generation
from with_age
