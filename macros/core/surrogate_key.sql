{#-
    surrogate_key(field_list)
    Deterministic MD5 hash over one or more columns/expressions.
    NULLs are made explicit so that (NULL, 'a') and ('a', NULL) never collide.
    Works on any warehouse that has md5() (DuckDB, Postgres, Redshift, Snowflake...).

        {{ surrogate_key(['employee_id']) }}
        {{ surrogate_key(['country', 'department']) }}
-#}
{% macro surrogate_key(field_list) -%}
    md5(
        {%- for field in field_list -%}
            coalesce(cast({{ field }} as {{ dbt.type_string() }}), '_null_')
            {%- if not loop.last %} || '|' || {% endif -%}
        {%- endfor -%}
    )
{%- endmacro %}
