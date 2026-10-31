#!/usr/bin/env bash
# One-time setup (macOS / Linux / Git Bash): creates .venv and installs dbt.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate 2>/dev/null || source .venv/Scripts/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
dbt --version
echo "Setup done. Next: make build"
