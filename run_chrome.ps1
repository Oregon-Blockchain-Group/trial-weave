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
& fvm flutter run -d chrome
exit $LASTEXITCODE