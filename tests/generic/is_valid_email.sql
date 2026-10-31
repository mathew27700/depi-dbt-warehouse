{#- Fails for any non-null value that is not shaped like  something@domain.tld  (no spaces). -#}
{% test is_valid_email(model, column_name) %}

select {{ column_name }} as invalid_email
from {{ model }}
where {{ column_name }} is not null
  and not (
        {{ column_name }} like '%_@_%.%_'
    and {{ column_name }} not like '% %'
  )

{% endtest %}
