# macOS / Linux / Git Bash shortcuts.  Windows PowerShell users: see scripts\*.ps1
# Requires the virtual environment from `make setup`.

export DBT_PROFILES_DIR := $(CURDIR)
DBT ?= $(if $(wildcard .venv/Scripts/dbt.exe),.venv/Scripts/dbt.exe,$(if $(wildcard .venv/bin/dbt),.venv/bin/dbt,dbt))
PY  ?= $(if $(wildcard .venv/Scripts/python.exe),.venv/Scripts/python.exe,$(if $(wildcard .venv/bin/python),.venv/bin/python,python))

.PHONY: help setup dashboard build seed staging dwh test unit docs serve clean

help:      ## show this help
	@grep -E '^[a-z_]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-9s %s\n", $$1, $$2}'

setup:     ## create .venv and install dbt
	bash scripts/setup.sh

build:     ## seeds + models + all tests (the whole pipeline)
	@mkdir -p data
	$(DBT) build
	@cp target/run_results.json target/build_results.json

seed:      ## load the raw layer only
	$(DBT) seed

staging:   ## build + test the staging layer (and everything upstream)
	$(DBT) build --select +tag:staging

dwh:       ## build + test the DWH layer (and everything upstream)
	$(DBT) build --select +tag:dwh

test:      ## run every data test
	$(DBT) test

unit:      ## run only the unit tests
	$(DBT) test --select "test_type:unit"

docs:      ## generate the documentation site (also writes docs/dbt-docs.html)
	$(DBT) docs generate --static
	@mkdir -p docs && cp target/static_index.html docs/dbt-docs.html

dashboard: ## build the dashboard (docs/index.html) from the warehouse (run after `make build`)
	$(PY) dashboard/build_dashboard.py

serve: docs ## generate and serve the docs at http://localhost:8080
	$(DBT) docs serve

clean:     ## remove build artifacts and the local warehouse
	rm -rf target logs data/*.duckdb data/*.wal
