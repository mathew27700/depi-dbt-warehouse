# One-time setup (Windows / PowerShell): creates .venv and installs dbt.
# Usage:  .\scripts\setup.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

if (Get-Command uv -ErrorAction SilentlyContinue) {
    uv venv .venv --python 3.12
    uv pip install --python .venv\Scripts\python.exe -r requirements.txt
} else {
    python -m venv .venv
    .\.venv\Scripts\python.exe -m pip install --upgrade pip
    .\.venv\Scripts\python.exe -m pip install -r requirements.txt
}

.\.venv\Scripts\dbt.exe --version
Write-Host "`nSetup done. Next:  .\scripts\run.ps1" -ForegroundColor Green
