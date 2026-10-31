{#-
    proper_name(column_name)
    Conservative name fixer. It deliberately does NOT use initcap(), which would
    destroy legitimate casing such as "McQuilliam" or "de Werk".

    Rules (applied in order):
      1. "O' Sullivan"  -> "O'Sullivan"   (stray space after an apostrophe)
      2. a single, all-lowercase word -> capitalised  ("oldey" -> "Oldey")
      3. everything else is left exactly as typed
-#}
{% macro proper_name(column_name) -%}
    case
        when {{ column_name }} is null then null
        else
            case
                when position(' ' in replace({{ column_name }}, ''' ', '''')) = 0
                     and replace({{ column_name }}, ''' ', '''') = lower(replace({{ column_name }}, ''' ', ''''))
                then upper(substr(replace({{ column_name }}, ''' ', ''''), 1, 1))
                     || substr(replace({{ column_name }}, ''' ', ''''), 2)
                else replace({{ column_name }}, ''' ', '''')
            end
    end
{%- endmacro %}
