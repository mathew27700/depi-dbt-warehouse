{#- Fails when a string has leading/trailing whitespace. -#}
{% test is_trimmed(model, column_name) %}

select {{ column_name }} as untrimmed_value
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} <> trim({{ column_name }})

{% endtest %}
