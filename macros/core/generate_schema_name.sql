{#-
    Override of dbt's built-in schema naming.

    Default dbt behaviour:  <target_schema>_<custom_schema>   (e.g. main_staging)
    This project's rule:    <custom_schema>                   (e.g. staging)

    This gives every layer its own clean, predictable schema:
        raw  ->  staging  ->  dwh      (+ dq_audit for stored test failures)

    Optional: pass --vars '{schema_prefix: pr123_}' to isolate a CI/dev run,
    e.g. pr123_staging, pr123_dwh.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set prefix = var('schema_prefix', '') -%}

    {%- if custom_schema_name is none -%}
        {{ prefix ~ target.schema }}
    {%- else -%}
        {{ prefix ~ (custom_schema_name | trim) }}
    {%- endif -%}

{%- endmacro %}
