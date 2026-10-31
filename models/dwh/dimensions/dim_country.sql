-- DWH dimension: one row per country, enriched with ISO codes and continent.
-- A country missing from the lookup becomes 'Unmapped' (and trips a warn-level test)
-- instead of silently disappearing from reports.

with countries as (

    select distinct country as country_name
    from {{ ref('stg_employees') }}

),

reference as (

    select * from {{ ref('stg_country_reference') }}

)

select
    cast({{ surrogate_key(['c.country_name']) }} as varchar)   as country_key,
    cast(c.country_name as varchar)                            as country_name,
    cast(coalesce(r.iso_alpha2, '??') as varchar)              as iso_alpha2,
    cast(coalesce(r.iso_alpha3, '???') as varchar)             as iso_alpha3,
    cast(coalesce(r.continent, 'Unmapped') as varchar)         as continent
from countries as c
left join reference as r
    on c.country_name = r.country_name
