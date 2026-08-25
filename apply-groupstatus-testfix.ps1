<#
.SYNOPSIS
    Prepares this Baileys fork for publishing to npm as "blacklord-socket".
    Idempotent: safe to re-run.

.USAGE
    From the repo root:
        .\prepare-npm-publish.ps1
    Optional:
        .\prepare-npm-publish.ps1 -RepoRoot "C:\path\to\Baileys" -RepoUrl "https://github.com/blacklorddev15/blacklord-socket"
#>

param(
    [string]$RepoRoot = ".",
    [string]$RepoUrl = "https://github.com/blacklorddev15/blacklord-socket",
    [string]$NewVersion = "1.0.0"
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    $msg" -ForegroundColor Yellow }

$pkgPath = Join-Path $RepoRoot "package.json"
$licensePath = Join-Path $RepoRoot "LICENSE"

if (-not (Test-Path $pkgPath)) {
    Write-Host "ERROR: $pkgPath not found. Run from repo root or pass -RepoRoot." -ForegroundColor Red
    exit 1
}

# --- 1. package.json -----------------------------------------------------
Write-Step "Updating package.json"
$pkg = Get-Content $pkgPath -Raw

if ($pkg -match '"name":\s*"blacklord-socket"') {
    Write-Ok "name already set to blacklord-socket"
} else {
    $pkg = $pkg -replace '"name":\s*"baileys",', '"name": "blacklord-socket",'
    Write-Ok "name -> blacklord-socket"
}

$pkg = $pkg -replace '"version":\s*"[^"]*",', "`"version`": `"$NewVersion`","

$pkg = $pkg -replace '"description":\s*"[^"]*",', '"description": "Blacklord fork of Baileys with native Group Status support for text, image, video, audio, and sticker posts.",'

$pkg = $pkg -replace '"keywords":\s*\[\s*"whatsapp",\s*"automation"\s*\],', @'
"keywords": [
    "whatsapp",
    "automation",
    "baileys",
    "group-status"
  ],
'@.TrimEnd()

$pkg = $pkg -replace '"homepage":\s*"[^"]*",', "`"homepage`": `"$RepoUrl`","
$pkg = $pkg -replace '"repository":\s*\{\s*"url":\s*"[^"]*"\s*\},', "`"repository`": {`n    `"url`": `"$RepoUrl.git`"`n  },"
$pkg = $pkg -replace '"author":\s*"[^"]*",', '"author": "Briton Kiplangat",'

Set-Content -Path $pkgPath -Value $pkg -NoNewline
Write-Ok "package.json updated (name, version, description, keywords, homepage, repository, author)"

# --- 2. LICENSE attribution ------------------------------------------------
Write-Step "Checking LICENSE attribution"
if (-not (Test-Path $licensePath)) {
    Write-Warn2 "LICENSE file not found -- skipping (make sure you keep MIT attribution somewhere!)"
} else {
    $license = Get-Content $licensePath -Raw
    $marker = "Portions Copyright (c)"
    if ($license -match [regex]::Escape($marker)) {
        Write-Ok "attribution addendum already present"
    } else {
        $addendum = "`n`n---`n`nThis package (blacklord-socket) is a modified fork of Baileys (https://github.com/WhiskeySockets/Baileys),`nused and redistributed under the MIT License above. The original copyright notice`nis preserved unmodified as required.`n`nPortions Copyright (c) 2026 Briton Kiplangat -- modifications`nand additions (including Group Status support) are licensed under the same MIT terms.`n"
        Add-Content -Path $licensePath -Value $addendum
        Write-Ok "attribution addendum appended to LICENSE"
    }
}

Write-Step "Done. Review package.json + LICENSE, then see PUBLISHING.md for the publish steps."