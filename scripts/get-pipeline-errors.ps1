# Get errors from pipeline without hanging
# Usage: .\scripts\get-pipeline-errors.ps1 [run-id]
Param(
    [string]$RunId = ""
)

if ([string]::IsNullOrEmpty($RunId)) {
    Write-Host "🔍 Getting latest failed run..." -ForegroundColor Cyan
    $runsJson = gh run list --workflow=build.yml --limit 10 --json databaseId,status,conclusion,event 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to get runs: $runsJson" -ForegroundColor Red
        exit 1
    }
    
    $runs = $runsJson | ConvertFrom-Json
    $failedRun = $runs | Where-Object { $_.conclusion -eq "failure" } | Select-Object -First 1
    
    if (-not $failedRun) {
        Write-Host "  ✅ No failed runs found" -ForegroundColor Green
        exit 0
    }
    
    $RunId = $failedRun.databaseId
    Write-Host "  Using Run ID: $RunId" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📋 Checking errors for run $RunId..." -ForegroundColor Cyan
Write-Host ""

# Get failed jobs
$runJson = gh run view $RunId --json jobs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get run: $runJson" -ForegroundColor Red
    exit 1
}

$run = $runJson | ConvertFrom-Json
$failedJobs = $run.jobs | Where-Object { $_.conclusion -eq "failure" }

if ($failedJobs.Count -eq 0) {
    Write-Host "  ✅ No failed jobs found" -ForegroundColor Green
    exit 0
}

Write-Host "❌ Failed Jobs:" -ForegroundColor Red
foreach ($job in $failedJobs) {
    Write-Host "  - $($job.name)" -ForegroundColor Red
}
Write-Host ""

# Get error messages from logs (non-blocking, limited output)
Write-Host "🔍 Extracting error messages..." -ForegroundColor Cyan

$errorPatterns = @(
    "error:",
    "Error:",
    "ERROR:",
    "Failed",
    "FAILED",
    "Exception",
    "syntax error",
    "Could not",
    "Unable to"
)

$logOutput = gh run view $RunId --log --job $($failedJobs[0].databaseId) 2>&1 | Select-Object -First 200

if ($LASTEXITCODE -eq 0 -and $logOutput) {
    Write-Host ""
    Write-Host "📝 Key Error Messages:" -ForegroundColor Yellow
    
    $foundErrors = @()
    foreach ($line in $logOutput) {
        foreach ($pattern in $errorPatterns) {
            if ($line -match $pattern) {
                $foundErrors += $line
                break
            }
        }
    }
    
    if ($foundErrors.Count -gt 0) {
        $foundErrors | Select-Object -First 20 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  No obvious error patterns found in first 200 lines" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Could not extract logs (this is normal if run is still in progress)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 View full logs: gh run view $RunId --log" -ForegroundColor Gray



