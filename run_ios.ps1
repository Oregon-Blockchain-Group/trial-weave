#!/usr/bin/env pwsh
# Runs the trial-weave Flutter app on iOS (simulator or device).
# Requires macOS with Xcode and CocoaPods. Will not build from Windows/Linux.
# Usage: ./run_ios.ps1

$ErrorActionPreference = 'Stop'

if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
    Write-Error "iOS builds require macOS. This script cannot run on Windows or Linux."
    exit 1
}

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$srcDir = Join-Path $scriptDir 'src'

if (-not (Test-Path $srcDir)) {
    Write-Error "src directory not found at $srcDir"
    exit 1
}

if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
    Write-Error "fvm not found in PATH. Install from https://fvm.app/"
    exit 1
}

Set-Location -Path $srcDir
& fvm flutter run -d ios
exit $LASTEXITCODE
