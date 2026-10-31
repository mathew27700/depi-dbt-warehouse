{#-
    as_of_date()
    The "today" used by every age calculation. Defaults to the real current
    date, but can be pinned for reproducible builds / unit tests:

        dbt build --vars '{as_of_date: 2026-01-01}'
-#}
{% macro as_of_date() -%}
    {%- set pinned = var('as_of_date', none) -%}
    {%- if pinned is none -%}
        cast(current_date as date)
    {%- else -%}
        cast('{{ pinned }}' as date)
    {%- endif -%}
{%- endmacro %}


{#-
    age_in_years(dob_column, as_of=none)
    Exact age in whole years (birthday-aware, not just a year subtraction).
-#}
{% macro age_in_years(dob_column, as_of=none) -%}
    {%- set ref_date = as_of if as_of else as_of_date() -%}
    (
        extract(year from {{ ref_date }}) - extract(year from {{ dob_column }})
        - case
            when (extract(month from {{ ref_date }}) * 100 + extract(day from {{ ref_date }}))
               < (extract(month from {{ dob_column }}) * 100 + extract(day from {{ dob_column }}))
            then 1 else 0
          end
    )
{%- endmacro %}
