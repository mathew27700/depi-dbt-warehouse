{#-
    STAGING: one cleaned, typed row per employee (1:1 with the raw landing table).
    No joins, no business logic - only casting, trimming, standardising and
    *flagging* data-quality problems so they can be reported instead of hidden.
-#}

with raw as (

    select * from {{ ref('raw_employees') }}

),

standardised as (

    select
        cast(id as integer)                          as employee_id,

        {{ clean_string('first_name') }}             as first_name_raw,
        {{ clean_string('last_name') }}              as last_name_raw,

        {{ clean_string('gender') }}                 as gender,
        lower({{ clean_string('email') }})           as email,
        {{ try_cast_to('dob', 'date') }}             as date_of_birth,
        salary                                       as salary_raw,
        {{ clean_string('department') }}             as department,
        {{ clean_string('country') }}                as country

    from raw

),

named as (

    select
        *,
        {{ proper_name('first_name_raw') }}          as first_name,
        {{ proper_name('last_name_raw') }}           as last_name
    from standardised

),

final as (

    select
        employee_id,
        first_name,
        last_name,
        first_name || ' ' || last_name                          as full_name,
        gender,
        email,
        {{ dbt.split_part('email', "'@'", 2) }}                 as email_domain,
        date_of_birth,
        {{ parse_money('salary_raw') }}                         as salary,
        department,
        country,

        -- data-quality flags (surfaced in dwh.agg_data_quality_summary)
        coalesce(salary_raw like '$%', false)                   as has_currency_symbol,
        (first_name <> first_name_raw or last_name <> last_name_raw)
                                                                as name_was_fixed,
        ({{ has_special_chars('first_name') }}
            or {{ has_special_chars('last_name') }})            as has_suspicious_name_chars,

        {{ dbt.current_timestamp() }}                           as dbt_loaded_at

    from named

)

select * from final
