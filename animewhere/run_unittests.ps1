#!/usr/bin/env pwsh
param([switch]$Quiet)

$flutterPath = 'C:\develop\AI-Generated-Projects\animewhere\.dart\tool\flutter\bin\flutter'
if (-not (Test-Path $flutterPath)) {
    Write-Error "Flutter not found at $flutterPath"
    exit 1
}

$args = @(
    'test',
    'test/unit/view_models/home_view_model_test.dart'
)

if ($Quiet) {
    $args += '-q'
}

Write-Host "Running Flutter tests: $($args -join ' ')" -ForegroundColor Cyan
& $flutterPath $args 2>&1
$exitCode = $LASTEXITCODE
Write-Host "Tests completed with exit code: $exitCode" -ForegroundColor Cyan
exit $exitCode