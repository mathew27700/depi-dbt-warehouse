{#-
    salary_band(column_name) / salary_band_order(column_name)
    Cut-offs come from the `salary_band_thresholds` var in dbt_project.yml,
    so HR can re-define the bands without touching any model.

        < entry_max   -> Entry        (1)
        < mid_max     -> Mid          (2)
        < senior_max  -> Senior       (3)
        otherwise     -> Executive    (4)
-#}
{% macro salary_band(column_name) -%}
    {%- set t = var('salary_band_thresholds') -%}
    case
        when {{ column_name }} is null            then 'Unknown'
        when {{ column_name }} < {{ t.entry_max }}  then 'Entry'
        when {{ column_name }} < {{ t.mid_max }}    then 'Mid'
        when {{ column_name }} < {{ t.senior_max }} then 'Senior'
        else                                           'Executive'
    end
{%- endmacro %}

{% macro salary_band_order(column_name) -%}
    {%- set t = var('salary_band_thresholds') -%}
    case
        when {{ column_name }} is null            then 0
        when {{ column_name }} < {{ t.entry_max }}  then 1
        when {{ column_name }} < {{ t.mid_max }}    then 2
        when {{ column_name }} < {{ t.senior_max }} then 3
        else                                           4
    end
{%- endmacro %}
