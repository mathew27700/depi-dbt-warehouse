-- STAGING: country lookup (name -> ISO codes -> continent)

select
    {{ clean_string('country_name') }}           as country_name,
    upper({{ clean_string('iso_alpha2') }})      as iso_alpha2,
    upper({{ clean_string('iso_alpha3') }})      as iso_alpha3,
    {{ clean_string('continent') }}              as continent
from {{ ref('ref_country_region') }}
