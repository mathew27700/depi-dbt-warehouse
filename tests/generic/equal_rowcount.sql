{#-
    equal_rowcount(compare_model)
    Model-level test: no rows may be lost or duplicated between two relations.
    Returns one diagnostic row when the counts differ.
-#}
{% test equal_rowcount(model, compare_model) %}

with a as (select count(*) as n from {{ model }}),
     b as (select count(*) as n from {{ compare_model }})

select
    a.n as rows_in_model,
    b.n as rows_in_compare_model,
    a.n - b.n as difference
from a
cross join b
where a.n <> b.n

{% endtest %}
