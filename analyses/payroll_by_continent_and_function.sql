-- Analysis: where does the payroll sit? Continent x business function group.

select
    c.continent,
    d.function_group,
    count(*)                       as headcount,
    round(sum(f.salary), 2)        as payroll,
    round(avg(f.salary), 2)        as avg_salary
from {{ ref('fct_employee_compensation') }} as f
join {{ ref('dim_department') }} as d on f.department_key = d.department_key
join {{ ref('dim_country') }}    as c on f.country_key    = c.country_key
group by 1, 2
order by payroll desc
