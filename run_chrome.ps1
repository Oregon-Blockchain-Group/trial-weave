#!/usr/bin/env pwsh
# Runs the trial-weave Flutter app in Chrome (web target).
# Usage: .\run_chrome.ps1

$ErrorActionPreference = 'Stop'

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$srcDir = Join-Path $scriptDir 'src'

if (-not (Test-Path $srcDir)) {
    Write-Error "src directory not found at $srcDir"
    exit 1
}

if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
    $machinePath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    $env:PATH = "$machinePath;$userPath;$env:PATH"
}

if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
    Write-Error "fvm not found in PATH. Install from https://fvm.app/"
    exit 1
}

Set-Location -Path $srcDir

# Bootstrap .env from .env.example on first run so flutter_dotenv's asset
# requirement is satisfied. The app's MisconfiguredScreen handles the
# still-blank values from there.
if (-not (Test-Path .env)) {
    if (Test-Path .env.example) {
        Copy-Item .env.example .env
        Write-Host "Created src/.env from .env.example. Fill in SUPABASE_URL and SUPABASE_ANON_KEY before sign-in will work."
    } else {
        Write-Warning "Neither src/.env nor src/.env.example found. Build may fail."
    }
}

& fvm flutter run -d chrome
exit $LASTEXITCODE