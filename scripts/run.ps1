# Build the whole warehouse: seeds -> staging -> dwh, run every test, generate docs.
# Usage:
#   .\scripts\run.ps1               # build + test + docs (target: dev)
#   .\scripts\run.ps1 -Serve        # ...then open the docs site in your browser
#   .\scripts\run.ps1 -Target ci    # use the in-memory profile
param(
    [string]$Target = 'dev',
    [switch]$Serve
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$env:DBT_PROFILES_DIR = (Get-Location).Path
$dbt = '.\.venv\Scripts\dbt.exe'

New-Item -ItemType Directory -Force data | Out-Null

& $dbt build --target $Target
$buildExit = $LASTEXITCODE

& $dbt docs generate --static --target $Target
New-Item -ItemType Directory -Force docs | Out-Null
Copy-Item target\static_index.html docs\index.html -Force
Write-Host "Docs written to docs\index.html" -ForegroundColor Green

if ($Serve) { & $dbt docs serve --target $Target }
exit $buildExit
