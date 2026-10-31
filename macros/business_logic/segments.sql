{#- generation_label(dob_column): sociological generation from year of birth -#}
{% macro generation_label(dob_column) -%}
    case
        when {{ dob_column }} is null                         then 'Unknown'
        when extract(year from {{ dob_column }}) <= 1964      then 'Baby Boomer'
        when extract(year from {{ dob_column }}) <= 1980      then 'Gen X'
        when extract(year from {{ dob_column }}) <= 1996      then 'Millennial'
        else                                                       'Gen Z'
    end
{%- endmacro %}


{#- age_band(age_column): '<30' | '30-39' | '40-49' | '50+' -#}
{% macro age_band(age_column) -%}
    case
        when {{ age_column }} is null then 'Unknown'
        when {{ age_column }} < 30    then '<30'
        when {{ age_column }} < 40    then '30-39'
        when {{ age_column }} < 50    then '40-49'
        else                               '50+'
    end
{%- endmacro %}
