{#-
    value_between(min_value, max_value)
    Fails rows outside [min_value, max_value]. Bounds are raw SQL expressions, so
    quote string/date literals in YAML:  min_value: "'1950-01-01'"
    Either bound may be omitted for a one-sided check.
-#}
{% test value_between(model, column_name, min_value=none, max_value=none) %}

select {{ column_name }} as out_of_range_value
from {{ model }}
where {{ column_name }} is not null
  and (
        false
        {% if min_value is not none %} or {{ column_name }} < {{ min_value }} {% endif %}
        {% if max_value is not none %} or {{ column_name }} > {{ max_value }} {% endif %}
  )

{% endtest %}
