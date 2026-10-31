{#-
    column_sum_matches(column_name, compare_model, compare_column, tolerance=0.01)
    Reconciliation test: SUM(model.column) must equal SUM(compare_model.compare_column)
    within `tolerance`. Catches silently dropped / double-counted money.
-#}
{% test column_sum_matches(model, column_name, compare_model, compare_column, tolerance=0.01) %}

with a as (select sum({{ column_name }}) as total from {{ model }}),
     b as (select sum({{ compare_column }}) as total from {{ compare_model }})

select
    a.total as model_total,
    b.total as compare_total,
    a.total - b.total as difference
from a
cross join b
where abs(coalesce(a.total, 0) - coalesce(b.total, 0)) > {{ tolerance }}

{% endtest %}
