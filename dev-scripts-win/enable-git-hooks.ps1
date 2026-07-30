$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

git config core.hooksPath dev-scripts-win/git-hooks

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host "Git hooks enabled from dev-scripts-win/git-hooks."
