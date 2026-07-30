$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$failed = $false
$excludedDirectories = "public", "themes", "resources", "node_modules"

foreach ($relativePath in (git ls-files --cached --others --exclude-standard)) {
  $topLevelDirectory = ($relativePath -split "[/\\]", 2)[0]
  if ($topLevelDirectory -in $excludedDirectories) {
    continue
  }

  $path = Join-Path $repoRoot $relativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    continue
  }

  $bytes = [System.IO.File]::ReadAllBytes($path)
  if ($bytes -contains 0) {
    continue
  }

  $lines = [System.IO.File]::ReadAllLines($path)
  for ($index = 0; $index -lt $lines.Length; $index++) {
    if ($lines[$index] -match "\s$") {
      Write-Host "${relativePath}:$($index + 1): trailing whitespace"
      $failed = $true
    }
  }
}

if ($failed) {
  Write-Error "Found trailing whitespace."
  exit 1
}
