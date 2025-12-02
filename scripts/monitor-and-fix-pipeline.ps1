# Monitor pipeline and attempt to fix common issues
# Usage: .\scripts\monitor-and-fix-pipeline.ps1 [run-id]
Param(
    [string]$RunId = "",
    [int]$CheckInterval = 30,
    [switch]$AutoFix
)

Write-Host "🔍 Pipeline Monitor & Fix Tool" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($RunId)) {
    Write-Host "📊 Getting latest run..." -ForegroundColor Cyan
    $runsJson = gh run list --workflow=build.yml --limit 1 --json databaseId,status,conclusion 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to get runs: $runsJson" -ForegroundColor Red
        exit 1
    }
    $runs = $runsJson | ConvertFrom-Json
    $RunId = $runs[0].databaseId
    Write-Host "  Using Run ID: $RunId" -ForegroundColor Yellow
    Write-Host ""
}

$iteration = 0
while ($true) {
    $iteration++
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "Check #$iteration - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    Write-Host ""
    
    # Get run status
    $runJson = gh run view $RunId --json status,conclusion,jobs,url 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to get run status" -ForegroundColor Red
        Start-Sleep -Seconds $CheckInterval
        continue
    }
    
    $run = $runJson | ConvertFrom-Json
    
    Write-Host "Status: $($run.status)" -ForegroundColor $(if ($run.status -eq "completed") { "Green" } elseif ($run.status -eq "in_progress") { "Yellow" } else { "White" })
    Write-Host "Conclusion: $($run.conclusion)" -ForegroundColor $(if ($run.conclusion -eq "success") { "Green" } elseif ($run.conclusion -eq "failure") { "Red" } else { "Yellow" })
    Write-Host "URL: $($run.url)" -ForegroundColor Yellow
    Write-Host ""
    
    # Check for failed jobs
    $failedJobs = $run.jobs | Where-Object { $_.conclusion -eq "failure" }
    if ($failedJobs.Count -gt 0) {
        Write-Host "❌ Failed Jobs:" -ForegroundColor Red
        foreach ($job in $failedJobs) {
            Write-Host "  - $($job.name)" -ForegroundColor Red
        }
        Write-Host ""
        
        if ($AutoFix) {
            Write-Host "🔧 Attempting to identify and fix issues..." -ForegroundColor Yellow
            & "$PSScriptRoot\get-pipeline-errors.ps1" -RunId $RunId
            Write-Host ""
            Write-Host "💡 Review errors above and fix manually" -ForegroundColor Yellow
        }
    }
    
    # Check for in-progress jobs
    $inProgressJobs = $run.jobs | Where-Object { $_.status -eq "in_progress" }
    if ($inProgressJobs.Count -gt 0) {
        Write-Host "⏳ In Progress:" -ForegroundColor Yellow
        foreach ($job in $inProgressJobs) {
            Write-Host "  - $($job.name)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    # Check for successful jobs
    $successJobs = $run.jobs | Where-Object { $_.conclusion -eq "success" }
    if ($successJobs.Count -gt 0) {
        Write-Host "✅ Successful Jobs ($($successJobs.Count)):" -ForegroundColor Green
        $successJobs | Select-Object -First 5 | ForEach-Object {
            Write-Host "  - $($_.name)" -ForegroundColor Green
        }
        if ($successJobs.Count -gt 5) {
            Write-Host "  ... and $($successJobs.Count - 5) more" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    # Exit if completed
    if ($run.status -eq "completed") {
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        if ($run.conclusion -eq "success") {
            Write-Host "✅ Pipeline completed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Pipeline completed with failures" -ForegroundColor Red
            Write-Host ""
            Write-Host "💡 Run this to see errors:" -ForegroundColor Yellow
            Write-Host "   .\scripts\get-pipeline-errors.ps1 -RunId $RunId" -ForegroundColor Gray
        }
        break
    }
    
    Write-Host "⏳ Waiting $CheckInterval seconds before next check..." -ForegroundColor Gray
    Write-Host ""
    Start-Sleep -Seconds $CheckInterval
}



