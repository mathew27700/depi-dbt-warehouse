{#-
    clean_string(column_name)
    Trim, collapse any run of whitespace into a single space, and turn
    empty strings into NULL so downstream `not_null` tests are meaningful.

        '  Human   Resources ' -> 'Human Resources'
        '   '                  -> NULL
-#}
{% macro clean_string(column_name) -%}
    nullif(trim(regexp_replace({{ column_name }}, '\s+', ' ', 'g')), '')
{%- endmacro %}
