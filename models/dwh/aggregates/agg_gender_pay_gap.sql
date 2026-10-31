-- Aggregate. Grain: one row per department + one 'ALL DEPARTMENTS' row.
-- pay_gap_pct = (avg male salary - avg female salary) / avg male salary * 100
--   positive => men earn more on average, negative => women earn more.

with joined as (

    select
        d.department_name,
        e.gender,
        f.salary
    from {{ ref('fct_employee_compensation') }} as f
    inner join {{ ref('dim_employee') }}   as e on f.employee_key   = e.employee_key
    inner join {{ ref('dim_department') }} as d on f.department_key = d.department_key

),

per_department as (

    select
        department_name,
        avg(case when gender = 'Male'   then salary end) as avg_male_salary,
        avg(case when gender = 'Female' then salary end) as avg_female_salary,
        sum(case when gender = 'Male'   then 1 else 0 end)   as male_headcount,
        sum(case when gender = 'Female' then 1 else 0 end)   as female_headcount
    from joined
    group by 1

),

company as (

    select
        'ALL DEPARTMENTS' as department_name,
        avg(case when gender = 'Male'   then salary end) as avg_male_salary,
        avg(case when gender = 'Female' then salary end) as avg_female_salary,
        sum(case when gender = 'Male'   then 1 else 0 end)   as male_headcount,
        sum(case when gender = 'Female' then 1 else 0 end)   as female_headcount
    from joined

),

unioned as (

    select * from per_department
    union all
    select * from company

)

select
    cast(department_name as varchar)                          as department_name,
    male_headcount,
    female_headcount,
    cast(round(avg_male_salary, 2) as numeric(12, 2))         as avg_male_salary,
    cast(round(avg_female_salary, 2) as numeric(12, 2))       as avg_female_salary,
    cast(round(100.0 * (avg_male_salary - avg_female_salary) / avg_male_salary, 2) as numeric(6, 2))
                                                              as pay_gap_pct
from unioned
