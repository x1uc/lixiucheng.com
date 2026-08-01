$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$failed = $false

foreach ($relativePath in (git ls-files)) {
  if ($relativePath -match "\.svg$" -or $relativePath -match "third-party") {
    continue
  }

  $path = Join-Path $repoRoot $relativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    continue
  }

  $bytes = [System.IO.File]::ReadAllBytes($path)

  if ($bytes.Length -eq 0 -or $bytes -contains 0) {
    continue
  }

  if ($bytes[-1] -ne 10) {
    Write-Error "File must end in a trailing newline: $relativePath" -ErrorAction Continue
    $failed = $true
  }
}

if ($failed) {
  exit 1
}
