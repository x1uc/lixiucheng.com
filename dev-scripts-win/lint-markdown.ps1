$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

& npx.cmd markdownlint-cli2 "./content/**/*.md"

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
