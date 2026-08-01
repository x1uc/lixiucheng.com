[CmdletBinding()]
param(
  [switch]$Full
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Get-CommandPath {
  param([object]$Command)

  if ($Command.Path) {
    return $Command.Path
  }

  return $Command.Source
}

function Invoke-CommandChecked {
  param(
    [object]$Command,
    [string[]]$Arguments = @()
  )

  & (Get-CommandPath $Command) @Arguments

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-ExecutableChecked {
  param(
    [string]$Name,
    [string[]]$Arguments = @()
  )

  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($null -eq $command) {
    Write-Error "'$Name' is not installed or not available on PATH."
    exit 1
  }

  Invoke-CommandChecked $command $Arguments
}

function Invoke-PowerShellScript {
  param(
    [string]$Script,
    [string[]]$Arguments = @()
  )

  $scriptPath = Join-Path $PSScriptRoot $Script
  & powershell.exe `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $scriptPath `
    @Arguments

  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

Write-Host "Starting local CI checks..."

Write-Host "--- Installing NPM dependencies ---"
$nodeModulesPath = Join-Path $repoRoot "node_modules"
if (-not (Test-Path -LiteralPath $nodeModulesPath -PathType Container)) {
  Invoke-ExecutableChecked "npm.cmd" @("install")
} else {
  Write-Host "node_modules exists, skipping install (run 'npm install' manually if needed)"
}

Write-Host "--- Checking Whitespace ---"
Invoke-PowerShellScript "check-trailing-whitespace.ps1"
Invoke-PowerShellScript "check-trailing-newline.ps1"

Write-Host "--- Checking Formatting ---"
Invoke-PowerShellScript "check-formatting.ps1"

Write-Host "--- Linting Markdown ---"
Invoke-PowerShellScript "lint-markdown.ps1"

Write-Host "--- Building Site ---"
$hugoCommand = Get-Command hugo -ErrorAction SilentlyContinue
if ($null -eq $hugoCommand) {
  Write-Error "'hugo' is not installed. Cannot build site."
  exit 1
}

Invoke-CommandChecked $hugoCommand @("version")
Invoke-CommandChecked $hugoCommand @("--minify")

Write-Host "--- Linting HTML ---"
$htmlProoferCommand = Get-Command htmlproofer -ErrorAction SilentlyContinue
if ($null -eq $htmlProoferCommand) {
  Write-Warning "'htmlproofer' is not installed (Ruby gem). Skipping HTML linting."
  Write-Host "To install: gem install html-proofer"
} else {
  $ignoreUrls = @(
    "/adage.com/"
    "/ark.intel.com/"
    "/calculator.aws/"
    "/community.bloggingfordevs.com/"
    "/docs.github.com/"
    "/fdc.nal.usda.gov/"
    "/feinternational.com/"
    "/github.com/"
    "/gusto.com/"
    "/help.shipstation.com/"
    "/indiebound.org/"
    "/isitketo.org/"
    "/mediagoblin-v5lmqis51k.herokuapp.com/"
    "/medium.com/"
    "/newegg.com/"
    "/opensource.org/"
    "/pcpartpicker.com/"
    "/playwright.dev/"
    "/redd.it/"
    "/reddit.com/"
    "/servernope.com/"
    "/splashthat.com/"
    "/typeform.com/"
    "/upwork.com/"
    "/vimeo.com/"
    "/vmware.com/"
    "/wpengine.com/"
    "/www.amd.com/"
    "/www.bls.gov/"
    "/www.buzzfeednews.com/"
    "/www.bhphotovideo.com/"
    "/www.digitalfaq.com/"
    "/www.kissmyketo.com/"
    "/www.irs.gov/"
    "/www.raspberrypi.com/"
    "/www.raspberrypi.org/"
    "/www.reddit.com/"
    "/www.sciencedirect.com/"
    "/www.servicenow.com/"
    "/www.usta.com/"
    "/bilibili.com/"
  ) -join ","

  $ignoreFiles = @(
    "public/collect-debt/full-emails/index.html"
    "public/notes/archivebox/reddit-singlefile.html"
  ) -join ","

  $htmlProoferArguments = @(
    "--only-4xx"
    "--checks"
    "Links,Images,Scripts,Favicon,OpenGraph"
    "--allow-missing-href"
    "--allow-hash-href"
    "--ignore-empty-alt"
    "--ignore-missing-alt"
    "--ignore-files"
    $ignoreFiles
    "--swap-urls"
    "https\://lixiucheng.com/:/"
    "--ignore-urls"
    $ignoreUrls
    "--ignore-status-codes"
    "400,403,429"
    "--no-enforce-https"
  )

  if ($Full) {
    $htmlProoferArguments += "--check-external-hash"
  } else {
    Write-Host "Running quick HTML check (skipping external links). Use -Full to check external links."
    $htmlProoferArguments += "--disable-external"
  }

  $htmlProoferArguments += "public"
  Invoke-CommandChecked $htmlProoferCommand $htmlProoferArguments
}

Write-Host "--- Linting XML ---"
$xmllintCommand = Get-Command xmllint -ErrorAction SilentlyContinue
if ($null -eq $xmllintCommand) {
  Write-Warning "'xmllint' is not installed. Skipping XML linting."
  Write-Host "Install xmllint and add it to PATH to enable this check."
} else {
  $xmlFiles = Get-ChildItem -Path (Join-Path $repoRoot "public") -Recurse -File -Filter "*.xml"
  foreach ($xmlFile in $xmlFiles) {
    $output = @(& (Get-CommandPath $xmllintCommand) --noout $xmlFile.FullName 2>&1)
    $exitCode = $LASTEXITCODE
    if ($output.Count -gt 0) {
      $output | ForEach-Object { Write-Host $_ }
      exit 2
    }
    if ($exitCode -ne 0) {
      exit $exitCode
    }
  }
}

Write-Host "--- Checking SEO Metadata ---"
$seoPattern = 'name="?twitter:card"? content="summary_large_image"'
$seoMatches = Get-ChildItem -Path (Join-Path $repoRoot "public") -Recurse -File |
  Select-String -Pattern $seoPattern -ErrorAction SilentlyContinue

if ($null -eq $seoMatches) {
  Write-Error "Large Twitter cards didn't appear in site build!"
  exit 1
}

Write-Host "SUCCESS: All local checks passed!"
