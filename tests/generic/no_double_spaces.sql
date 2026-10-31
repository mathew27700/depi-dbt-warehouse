{#- Fails when a string contains two consecutive spaces. -#}
{% test no_double_spaces(model, column_name) %}

select {{ column_name }} as value_with_double_space
from {{ model }}
where {{ column_name }} like '%  %'

{% endtest %}
