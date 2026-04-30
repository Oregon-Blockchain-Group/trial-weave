#!/usr/bin/env pwsh
# Runs the trial-weave Flutter app on iOS (simulator or device).
# Requires macOS with Xcode and CocoaPods. Will not build from Windows/Linux.
# Usage: .\run_ios.ps1

$env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')
Set-Location -Path (Join-Path $PSScriptRoot 'src')
& fvm flutter run -d ios


