#!/usr/bin/env pwsh
# Runs the trial-weave Flutter app in Chrome (web target).
# Usage: .\run_chrome.ps1

$env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')
Set-Location -Path (Join-Path $PSScriptRoot 'src')
& fvm flutter run -d chrome