-- Aggregate. Grain: one row per department.

with fact as (

    select * from {{ ref('fct_employee_compensation') }}

),

employees as (

    select employee_key, gender from {{ ref('dim_employee') }}

),

departments as (

    select * from {{ ref('dim_department') }}

),

summary as (

    select
        d.department_key,
        d.department_name,
        d.function_group,
        count(*)                                                     as headcount,
        sum(f.salary)                                                as total_payroll,
        avg(f.salary)                                                as avg_salary,
        {{ median('f.salary') }}                                     as median_salary,
        min(f.salary)                                                as min_salary,
        max(f.salary)                                                as max_salary,
        sum(case when e.gender = 'Female' then 1 else 0 end)         as female_headcount,
        sum(case when e.gender = 'Male' then 1 else 0 end)           as male_headcount
    from fact as f
    inner join departments as d on f.department_key = d.department_key
    inner join employees   as e on f.employee_key   = e.employee_key
    group by 1, 2, 3

)

select
    department_key,
    department_name,
    function_group,
    headcount,
    cast(total_payroll as numeric(14, 2))                            as total_payroll,
    cast(round(avg_salary, 2) as numeric(12, 2))                     as avg_salary,
    cast(round(median_salary, 2) as numeric(12, 2))                  as median_salary,
    min_salary,
    max_salary,
    female_headcount,
    male_headcount,
    cast(round(100.0 * female_headcount / headcount, 1) as numeric(5, 1))
                                                                     as pct_female,
    cast(round(100.0 * total_payroll / sum(total_payroll) over (), 2) as numeric(5, 2))
                                                                     as pct_of_total_payroll
from summary
