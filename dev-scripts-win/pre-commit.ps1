$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Invoke-Check {
  param([string]$Script)

  & powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File "$PSScriptRoot\$Script"

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

Write-Host "Running pre-commit checks..."

Write-Host "Checking code formatting..."
Invoke-Check "check-formatting.ps1"

Write-Host "Checking for trailing whitespace..."
Invoke-Check "check-trailing-whitespace.ps1"

Write-Host "Checking for trailing newlines..."
Invoke-Check "check-trailing-newline.ps1"

Write-Host "Linting Markdown..."
Invoke-Check "lint-markdown.ps1"

Write-Host "All pre-commit checks passed!"
