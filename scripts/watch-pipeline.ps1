# Simple script to watch pipeline status without pagers
# Usage: .\scripts\watch-pipeline.ps1 [run-id]

Param(
    [string]$RunId = ""
)

if ([string]::IsNullOrEmpty($RunId)) {
    Write-Host "🔍 Getting latest run..." -ForegroundColor Cyan
    $runs = gh run list --workflow=build.yml --limit 1 --json databaseId,status,conclusion,event,headBranch,createdAt 2>&1
    if ($LASTEXITCODE -eq 0) {
        $run = $runs | ConvertFrom-Json | Select-Object -First 1
        $RunId = $run.databaseId
    } else {
        Write-Host "❌ Failed to get runs: $runs" -ForegroundColor Red
        exit 1
    }
}

Write-Host "📊 Monitoring run $RunId..." -ForegroundColor Cyan
Write-Host ""

while ($true) {
    $run = gh run view $RunId --json status,conclusion,jobs 2>&1 | ConvertFrom-Json
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to get run status" -ForegroundColor Red
        break
    }
    
    Clear-Host
    Write-Host "📊 Pipeline Status - Run $RunId" -ForegroundColor Cyan
    Write-Host "Status: $($run.status)" -ForegroundColor $(if ($run.status -eq "completed") { "Green" } elseif ($run.status -eq "in_progress") { "Yellow" } else { "White" })
    Write-Host "Conclusion: $($run.conclusion)" -ForegroundColor $(if ($run.conclusion -eq "success") { "Green" } elseif ($run.conclusion -eq "failure") { "Red" } else { "Yellow" })
    Write-Host ""
    
    $jobs = $run.jobs | Where-Object { $_.name -like "*build-matrix*" -or $_.name -like "*release*" }
    Write-Host "Key Jobs:" -ForegroundColor Yellow
    foreach ($job in $jobs) {
        $color = if ($job.conclusion -eq "success") { "Green" } elseif ($job.conclusion -eq "failure") { "Red" } elseif ($job.status -eq "in_progress") { "Yellow" } else { "White" }
        Write-Host "  $($job.name): $($job.status) / $($job.conclusion)" -ForegroundColor $color
    }
    
    if ($run.status -eq "completed") {
        Write-Host ""
        Write-Host "✅ Pipeline finished!" -ForegroundColor Green
        break
    }
    
    Start-Sleep -Seconds 10
}

