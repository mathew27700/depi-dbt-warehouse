-- Analysis (compiled, not materialised): the five best-paid people in each department.
-- Run with:  dbt compile --select top_5_earners_per_department   then open target/compiled/...

select
    d.department_name,
    f.department_salary_rank as rank,
    e.full_name,
    c.country_name,
    f.salary,
    f.salary_band
from {{ ref('fct_employee_compensation') }} as f
join {{ ref('dim_employee') }}   as e on f.employee_key   = e.employee_key
join {{ ref('dim_department') }} as d on f.department_key = d.department_key
join {{ ref('dim_country') }}    as c on f.country_key    = c.country_key
where f.department_salary_rank <= 5
order by d.department_name, f.department_salary_rank, e.full_name
