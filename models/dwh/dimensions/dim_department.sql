-- DWH dimension: one row per department, enriched with its business function group.

with departments as (

    select distinct department as department_name
    from {{ ref('stg_employees') }}

),

reference as (

    select * from {{ ref('stg_department_reference') }}

)

select
    cast({{ surrogate_key(['d.department_name']) }} as varchar)   as department_key,
    cast(d.department_name as varchar)                            as department_name,
    cast(coalesce(r.function_group, 'Unmapped') as varchar)       as function_group
from departments as d
left join reference as r
    on d.department_name = r.department_name
