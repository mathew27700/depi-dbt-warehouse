{#-
    has_special_chars(column_name)
    TRUE when a name contains anything other than letters, spaces, dots,
    apostrophes or hyphens (e.g. "Giovannacc@i").  Used to *flag* rows,
    never to silently rewrite them.

    Implemented with adapter.dispatch because regex syntax differs per warehouse.
-#}
{% macro has_special_chars(column_name) -%}
    {{ return(adapter.dispatch('has_special_chars', 'depi_dbt')(column_name)) }}
{%- endmacro %}

{% macro default__has_special_chars(column_name) -%}
    ({{ column_name }} ~ '[^A-Za-z .''-]')
{%- endmacro %}

{% macro duckdb__has_special_chars(column_name) -%}
    regexp_matches({{ column_name }}, '[^A-Za-z .''-]')
{%- endmacro %}
