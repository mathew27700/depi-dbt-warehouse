#!/usr/bin/env python3
"""
Build the DEPI Workforce Intelligence dashboard.

Reads the finished dbt warehouse (DuckDB) + the dbt run results and bakes them into ONE
self-contained HTML file (docs/index.html): no server, no CDN, no framework.

Privacy: only anonymised, analytical columns are exported (department, country,
gender, salary, age, band). Names, e-mails and dates of birth never leave the warehouse.

Usage (after `dbt build`):
    python dashboard/build_dashboard.py
    python dashboard/build_dashboard.py --db data/depi_warehouse.duckdb --out docs/index.html
"""
from __future__ import annotations

import argparse
import datetime as dt
import importlib.metadata as md
import json
import re
import sys
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent.parent
REPO_URL = "https://github.com/mathew27700/depi-dbt-warehouse"
PAGES_URL = "https://mathew27700.github.io/depi-dbt-warehouse"


def version(pkg: str) -> str:
    try:
        return md.version(pkg)
    except md.PackageNotFoundError:
        return ""


def export_warehouse(db: Path) -> dict:
    con = duckdb.connect(str(db), read_only=True)
    q = lambda sql: con.execute(sql).fetchall()

    depts = q("select department_key, department_name, function_group from dwh.dim_department order by department_name")
    countries = q("select country_key, country_name, iso_alpha2, continent from dwh.dim_country order by country_name")
    conts = sorted({c[3] for c in countries})
    funcs = sorted({d[2] for d in depts})
    dept_ix = {d[0]: i for i, d in enumerate(depts)}
    ctry_ix = {c[0]: i for i, c in enumerate(countries)}

    # one compact array per employee: [dept, country, gender(0=F,1=M), salary, age, band(0..3)]
    rows = [
        [dept_ix[dk], ctry_ix[ck], 0 if g == "Female" else 1, float(s), int(a), int(bo) - 1]
        for dk, ck, g, s, a, bo in q(
            """
            select f.department_key, f.country_key, e.gender, f.salary, e.age_years, f.salary_band_order
            from dwh.fct_employee_compensation f
            join dwh.dim_employee e on e.employee_key = f.employee_key
            order by f.employee_id
            """
        )
    ]

    dq = [
        dict(rule=r[0], description=r[1], handling=r[2], affected=int(r[3]), total=int(r[4]), pct=float(r[5]))
        for r in q("select rule_name, description, handling, affected_rows, total_rows, pct_affected from dwh.agg_data_quality_summary order by affected_rows desc")
    ]

    objects = []
    for schema, name, ttype in q(
        "select table_schema, table_name, table_type from information_schema.tables where table_schema in ('raw','staging','dwh') order by 1, 2"
    ):
        n = q(f'select count(*) from "{schema}"."{name}"')[0][0]
        kind = "seed" if schema == "raw" else ("view" if ttype == "VIEW" else "table")
        role = ""
        if schema == "dwh":
            role = "dimension" if name.startswith("dim_") else "fact" if name.startswith("fct_") else "aggregate"
        objects.append(dict(schema=schema, name=name, kind=kind, role=role, rows=int(n)))

    con.close()
    return dict(
        depts=[dict(name=d[1], fn=funcs.index(d[2])) for d in depts],
        funcs=funcs,
        countries=[dict(name=c[1], iso=c[2], ci=conts.index(c[3])) for c in countries],
        conts=conts,
        rows=rows,
        dq=dq,
        objects=objects,
    )


def read_results() -> dict:
    """Summarise the last `dbt build` (target/build_results.json, falling back to run_results.json)."""
    for name in ("build_results.json", "run_results.json"):
        p = ROOT / "target" / name
        if p.exists():
            data = json.loads(p.read_text(encoding="utf-8"))
            if data.get("results"):
                break
    else:
        return dict(available=False)

    kinds = dict(seed=0, model=0, test=0, unit_test=0, other=0)
    status = dict(ok=0, warn=0, fail=0, skipped=0)
    warnings, failures = [], []
    for r in data["results"]:
        uid = r["unique_id"]
        kind = uid.split(".")[0]
        kinds[kind if kind in kinds else "other"] += 1
        st = r["status"]
        name = uid.split(".")[2]
        if st in ("success", "pass"):
            status["ok"] += 1
        elif st == "warn":
            status["warn"] += 1
            warnings.append(dict(name=name, rows=int(r.get("failures") or 0)))
        elif st in ("skipped", "no-op"):
            status["skipped"] += 1
        else:
            status["fail"] += 1
            failures.append(dict(name=name, rows=int(r.get("failures") or 0)))
    return dict(
        available=True,
        kinds=kinds,
        status=status,
        warnings=warnings,
        failures=failures,
        seconds=round(float(data.get("elapsed_time", 0)), 1),
        dbt_version=data.get("metadata", {}).get("dbt_version", ""),
    )


def project_stats() -> dict:
    macros = 0
    for f in (ROOT / "macros").rglob("*.sql"):
        for m in re.finditer(r"{%-?\s*macro\s+(\w+)", f.read_text(encoding="utf-8")):
            if not m.group(1).startswith(("default__", "duckdb__")):
                macros += 1
    contracts = len(re.findall(r"enforced:\s*true", (ROOT / "models/dwh/schema.yml").read_text(encoding="utf-8")))
    return dict(
        macros=macros,
        generic_tests=len(list((ROOT / "tests/generic").glob("*.sql"))),
        singular_tests=len(list((ROOT / "tests").glob("*.sql"))),
        contracts=contracts,
    )


def band_cuts() -> list[int]:
    """Salary-band cut-offs: single source of truth is the dbt project variable."""
    import yaml  # installed as a dbt dependency

    cfg = yaml.safe_load((ROOT / "dbt_project.yml").read_text(encoding="utf-8"))
    t = cfg["vars"]["salary_band_thresholds"]
    return [int(t["entry_max"]), int(t["mid_max"]), int(t["senior_max"])]


def tool_stack() -> list[dict]:
    py = ".".join(map(str, sys.version_info[:3]))
    return [
        dict(cat="Transform & test", name="dbt Core", ver=version("dbt-core"), use="Models, macros, tests, unit tests, contracts, docs and lineage", mono="dbt"),
        dict(cat="Transform & test", name="dbt-duckdb", ver=version("dbt-duckdb"), use="dbt adapter that runs the project on DuckDB", mono="da"),
        dict(cat="Transform & test", name="SQL + Jinja2", ver=version("jinja2"), use="Every model is SQL; 15 macros are Jinja templating", mono="{ }"),
        dict(cat="Storage & compute", name="DuckDB", ver=version("duckdb"), use="Embedded analytical warehouse in a single file, no server", mono="Dk"),
        dict(cat="Runtime", name="Python", ver=py, use="Runs dbt; builds this dashboard from the warehouse", mono="Py"),
        dict(cat="Runtime", name="uv", ver="0.12", use="Fast virtual-environment and dependency installer", mono="uv"),
        dict(cat="Version control & CI", name="Git", ver="2.47", use="Version control for the whole project", mono="Gt"),
        dict(cat="Version control & CI", name="GitHub", ver="", use="Hosts the repository and README documentation", mono="Gh"),
        dict(cat="Version control & CI", name="GitHub Actions", ver="", use="CI: parse, build, test and publish docs on every push", mono="CI"),
        dict(cat="Version control & CI", name="GitHub Pages", ver="", use="Serves docs/index.html (this dashboard) and docs/dbt-docs.html", mono="Pg"),
        dict(cat="Task runners", name="PowerShell + Make", ver="", use="One-command setup and run scripts (Windows / macOS / Linux)", mono=">_"),
        dict(cat="Documentation", name="dbt docs", ver="", use="Searchable catalog and interactive lineage graph", mono="Dc"),
        dict(cat="Documentation", name="Mermaid", ver="", use="ER diagram and lineage rendered inside the README", mono="Mm"),
        dict(cat="Dashboard", name="Vanilla JS + SVG", ver="", use="This dashboard: zero libraries, zero CDN, works offline", mono="JS"),
        dict(cat="Dashboard", name="Playwright + Edge", ver=version("playwright") or "1.64", use="Headless browser used to test and screenshot the dashboard (dev only)", mono="Pw"),
        dict(cat="AI assistance", name="Claude Code", ver="Sonnet 5.5", use="Helped with checking and fixing errors", mono="Cc"),
    ]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--db", default=str(ROOT / "data" / "depi_warehouse.duckdb"))
    ap.add_argument("--out", default=str(ROOT / "docs" / "index.html"))
    ap.add_argument("--template", default=str(ROOT / "dashboard" / "template.html"))
    args = ap.parse_args()

    db = Path(args.db)
    if not db.exists():
        print(f"Warehouse not found: {db}\nRun `dbt build` first.", file=sys.stderr)
        return 1

    now = dt.datetime.now()
    payload = export_warehouse(db)
    payload.update(
        results=read_results(),
        stats=project_stats(),
        tools=tool_stack(),
        meta=dict(
            generated=now.strftime("%Y-%m-%d %H:%M"),
            as_of=now.strftime("%d %b %Y"),
            repo=REPO_URL,
            pages=PAGES_URL,
            bands=["Entry", "Mid", "Senior", "Executive"],
            cuts=band_cuts(),
        ),
    )

    html = Path(args.template).read_text(encoding="utf-8").replace(
        "/*__DATA__*/null", json.dumps(payload, separators=(",", ":"), ensure_ascii=False)
    )
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(html, encoding="utf-8")
    print(f"Dashboard written: {out}  ({out.stat().st_size / 1024:.0f} KB, {len(payload['rows'])} employees)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
