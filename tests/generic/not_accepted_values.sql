{#-
    not_accepted_values(values)
    The mirror image of dbt's accepted_values: fails when the column holds any
    of the listed *forbidden* values (e.g. placeholder codes like '??').
-#}
{% test not_accepted_values(model, column_name, values, quote=true) %}

select {{ column_name }} as forbidden_value
from {{ model }}
where {{ column_name }} in (
    {%- for v in values -%}
        {%- if quote -%}'{{ v }}'{%- else -%}{{ v }}{%- endif -%}
        {%- if not loop.last -%}, {% endif -%}
    {%- endfor -%}
)

{% endtest %}
