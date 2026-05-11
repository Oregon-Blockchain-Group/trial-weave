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

# fvm.bat shells out to `dart`, so dart needs to be reachable. WinGet
# installs Dart but doesn't always add it to the user/machine PATH that
# fresh shell sessions inherit — find it ourselves and prepend if needed.
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\Google.DartSDK_Microsoft.Winget.Source_8wekyb3d8bbwe\dart-sdk\bin'),
        'C:\tools\dart-sdk\bin',
        (Join-Path $env:ProgramFiles 'dart\bin')
    )
    $dartBin = $candidates | Where-Object { Test-Path (Join-Path $_ 'dart.exe') } | Select-Object -First 1
    if ($dartBin) {
        $env:PATH = "$dartBin;$env:PATH"
        Write-Host "Added Dart SDK to PATH for this session: $dartBin"
    } else {
        Write-Error "Dart SDK not found. fvm needs 'dart' on PATH. Install via 'winget install Google.DartSDK' and reopen the terminal."
        exit 1
    }
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