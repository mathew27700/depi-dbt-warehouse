# macOS / Linux / Git Bash shortcuts.  Windows PowerShell users: see scripts\*.ps1
# Requires the virtual environment from `make setup`.

export DBT_PROFILES_DIR := $(CURDIR)
DBT ?= $(if $(wildcard .venv/Scripts/dbt.exe),.venv/Scripts/dbt.exe,$(if $(wildcard .venv/bin/dbt),.venv/bin/dbt,dbt))

.PHONY: help setup build seed staging dwh test unit docs serve clean

help:      ## show this help
	@grep -E '^[a-z_]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-9s %s\n", $$1, $$2}'

setup:     ## create .venv and install dbt
	bash scripts/setup.sh

build:     ## seeds + models + all tests (the whole pipeline)
	@mkdir -p data
	$(DBT) build

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

docs:      ## generate the documentation site (also writes docs/index.html)
	$(DBT) docs generate --static
	@mkdir -p docs && cp target/static_index.html docs/index.html

serve: docs ## generate and serve the docs at http://localhost:8080
	$(DBT) docs serve

clean:     ## remove build artifacts and the local warehouse
	rm -rf target logs data/*.duckdb data/*.wal
