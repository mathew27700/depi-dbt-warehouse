{#-
    parse_money(column_name, precision=12, scale=2)
    Turns messy money text into a proper DECIMAL.
    The raw salary column is inconsistent - 2/3 of rows look like '$3206.23',
    the rest like '8658.72' (or even '4102').  Handles '$', ',' and spaces.

    Uses try_cast_to, so garbage ('abc') becomes NULL (and is then caught by the
    not_null test) rather than crashing the whole run.
-#}
{% macro parse_money(column_name, precision=12, scale=2) -%}
    {{ try_cast_to(
        "replace(replace(replace(" ~ column_name ~ ", '$', ''), ',', ''), ' ', '')",
        "numeric(" ~ precision ~ ", " ~ scale ~ ")"
    ) }}
{%- endmacro %}
