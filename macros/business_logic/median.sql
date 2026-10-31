{#-
    median(column_name)
    Cross-warehouse median using adapter.dispatch: DuckDB has a native
    median(), PostgreSQL & most others need percentile_cont().
-#}
{% macro median(column_name) -%}
    {{ return(adapter.dispatch('median', 'depi_dbt')(column_name)) }}
{%- endmacro %}

{% macro default__median(column_name) -%}
    percentile_cont(0.5) within group (order by {{ column_name }})
{%- endmacro %}

{% macro duckdb__median(column_name) -%}
    median({{ column_name }})
{%- endmacro %}
