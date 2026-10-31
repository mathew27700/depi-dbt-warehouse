-- STAGING: department lookup (department -> business function group)

select
    {{ clean_string('department') }}             as department_name,
    {{ clean_string('function_group') }}         as function_group
from {{ ref('ref_department_function') }}
