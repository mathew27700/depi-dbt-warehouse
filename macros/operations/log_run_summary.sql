{#-
    log_run_summary(results)
    Wired to `on-run-end` in dbt_project.yml. Prints a compact scoreboard after
    every dbt invocation: what ran, what passed, what warned, what failed and why.
-#}
{% macro log_run_summary(results) -%}
    {%- if execute and results | length > 0 -%}
        {%- set ns = namespace(models=0, seeds=0, tests=0, ok=0, warned=0, failed=0, skipped=0, secs=0.0, notes=[]) -%}

        {%- for r in results -%}
            {%- set kind = (r.node.resource_type | string) | lower -%}
            {%- set status = (r.status | string) | lower -%}
            {%- set ns.secs = ns.secs + (r.execution_time or 0) -%}

            {%- if 'seed' in kind -%}{%- set ns.seeds = ns.seeds + 1 -%}
            {%- elif 'model' in kind -%}{%- set ns.models = ns.models + 1 -%}
            {%- elif 'test' in kind -%}{%- set ns.tests = ns.tests + 1 -%}
            {%- endif -%}

            {%- if status in ['success', 'pass'] -%}{%- set ns.ok = ns.ok + 1 -%}
            {%- elif status == 'warn' -%}
                {%- set ns.warned = ns.warned + 1 -%}
                {%- set ns.notes = ns.notes + ['  WARN  ' ~ r.node.name ~ '  (' ~ r.failures ~ ' rows)'] -%}
            {%- elif status in ['skipped', 'no-op'] -%}{%- set ns.skipped = ns.skipped + 1 -%}
            {%- else -%}
                {%- set ns.failed = ns.failed + 1 -%}
                {%- set ns.notes = ns.notes + ['  FAIL  ' ~ r.node.name ~ '  ' ~ (r.message or '')] -%}
            {%- endif -%}
        {%- endfor -%}

        {%- set bar = '=' * 66 -%}
        {{ log(bar, info=True) }}
        {{ log('  DEPI DWH run summary  |  target: ' ~ target.name ~ '  |  ' ~ (ns.secs | round(1)) ~ 's of work', info=True) }}
        {{ log(bar, info=True) }}
        {{ log('  seeds: ' ~ ns.seeds ~ '   models: ' ~ ns.models ~ '   tests: ' ~ ns.tests, info=True) }}
        {{ log('  OK: ' ~ ns.ok ~ '   WARN: ' ~ ns.warned ~ '   FAIL: ' ~ ns.failed ~ '   SKIPPED: ' ~ ns.skipped, info=True) }}
        {%- for note in ns.notes -%}
            {{ log(note, info=True) }}
        {%- endfor -%}
        {{ log(bar, info=True) }}
    {%- endif -%}
{%- endmacro %}
