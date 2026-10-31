{#- Fails for dates later than the project's as-of date (see as_of_date()). -#}
{% test not_future_date(model, column_name) %}

select {{ column_name }} as future_date
from {{ model }}
where {{ column_name }} > {{ as_of_date() }}

{% endtest %}
