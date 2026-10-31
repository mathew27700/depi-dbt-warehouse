-- Aggregate. Grain: one row per country.

with fact as (

    select * from {{ ref('fct_employee_compensation') }}

),

countries as (

    select * from {{ ref('dim_country') }}

)

select
    c.country_key,
    c.country_name,
    c.iso_alpha2,
    c.continent,
    count(*)                                          as headcount,
    cast(sum(f.salary) as numeric(14, 2))             as total_payroll,
    cast(round(avg(f.salary), 2) as numeric(12, 2))   as avg_salary,
    cast(round({{ median('f.salary') }}, 2) as numeric(12, 2)) as median_salary,
    rank() over (order by count(*) desc)              as headcount_rank
from fact as f
inner join countries as c on f.country_key = c.country_key
group by 1, 2, 3, 4
