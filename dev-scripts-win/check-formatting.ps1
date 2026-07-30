$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

& "$repoRoot\node_modules\.bin\prettier.cmd" --check .

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
