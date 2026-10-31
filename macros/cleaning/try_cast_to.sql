{#-
    try_cast_to(expression, data_type)
    A cast that returns NULL instead of raising when the value is malformed, so
    one bad row becomes a failing `not_null` test rather than a crashed run.

      * DuckDB                  -> native try_cast()
      * everything else         -> dbt's cross-db safe_cast() (Snowflake, BigQuery,
                                   Spark... are safe; on PostgreSQL it is a normal
                                   cast and a malformed value will raise an error)
-#}
{% macro try_cast_to(expression, data_type) -%}
    {{ return(adapter.dispatch('try_cast_to', 'depi_dbt')(expression, data_type)) }}
{%- endmacro %}

{% macro default__try_cast_to(expression, data_type) -%}
    {{ dbt.safe_cast(expression, data_type) }}
{%- endmacro %}

{% macro duckdb__try_cast_to(expression, data_type) -%}
    try_cast({{ expression }} as {{ data_type }})
{%- endmacro %}
