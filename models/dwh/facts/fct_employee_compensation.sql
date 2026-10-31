-- DWH fact. Grain: ONE ROW PER EMPLOYEE (a compensation snapshot).
-- Measures: salary, and salary relative to department / company.

with employees as (

    select * from {{ ref('stg_employees') }}

),

measured as (

    select
        employee_id,
        department,
        country,
        salary,
        avg(salary)          over (partition by department)               as department_avg_salary,
        rank()               over (partition by department order by salary desc) as department_salary_rank,
        percent_rank()       over (order by salary)                       as company_salary_percentile
    from employees

)

select
    cast({{ surrogate_key(['employee_id']) }} as varchar)   as employee_key,
    cast({{ surrogate_key(['department']) }} as varchar)    as department_key,
    cast({{ surrogate_key(['country']) }} as varchar)       as country_key,
    cast(employee_id as integer)                            as employee_id,

    cast(salary as numeric(12, 2))                          as salary,
    cast({{ salary_band('salary') }} as varchar)            as salary_band,
    cast({{ salary_band_order('salary') }} as integer)      as salary_band_order,

    cast(department_avg_salary as numeric(12, 2))           as department_avg_salary,
    cast(round((salary / department_avg_salary - 1) * 100, 2) as numeric(8, 2))
                                                            as pct_vs_department_avg,
    cast(department_salary_rank as integer)                 as department_salary_rank,
    cast(round(company_salary_percentile, 4) as numeric(5, 4))
                                                            as company_salary_percentile
from measured
