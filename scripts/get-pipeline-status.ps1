# Get current pipeline status without hanging
# Usage: .\scripts\get-pipeline-status.ps1 [workflow] [limit]
Param(
    [string]$Workflow = "build.yml",
    [int]$Limit = 5
)

Write-Host "🔍 Checking pipeline status..." -ForegroundColor Cyan

$runsJson = gh run list --workflow=$Workflow --limit $Limit --json databaseId,status,conclusion,event,headBranch,createdAt,displayTitle 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get runs: $runsJson" -ForegroundColor Red
    exit 1
}

$runs = $runsJson | ConvertFrom-Json

if ($runs.Count -eq 0) {
    Write-Host "  No runs found" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "📊 Recent Pipeline Runs:" -ForegroundColor Cyan
Write-Host ""

foreach ($run in $runs) {
    $statusColor = switch ($run.status) {
        "completed" { "Green" }
        "in_progress" { "Yellow" }
        "queued" { "Cyan" }
        default { "White" }
    }
    
    $conclusionColor = switch ($run.conclusion) {
        "success" { "Green" }
        "failure" { "Red" }
        "cancelled" { "Yellow" }
        default { "White" }
    }
    
    Write-Host "  Run ID: $($run.databaseId)" -ForegroundColor White
    Write-Host "    Title: $($run.displayTitle)" -ForegroundColor Gray
    Write-Host "    Event: $($run.event)" -ForegroundColor Gray
    Write-Host "    Branch: $($run.headBranch)" -ForegroundColor Gray
    Write-Host "    Status: $($run.status)" -ForegroundColor $statusColor
    Write-Host "    Conclusion: $($run.conclusion)" -ForegroundColor $conclusionColor
    Write-Host "    Created: $($run.createdAt)" -ForegroundColor Gray
    Write-Host ""
}

# Get latest run details
$latestRun = $runs[0]
Write-Host "📋 Latest Run Details ($($latestRun.databaseId)):" -ForegroundColor Cyan

$runDetailsJson = gh run view $latestRun.databaseId --json status,conclusion,jobs,url 2>&1
if ($LASTEXITCODE -eq 0) {
    $runDetails = $runDetailsJson | ConvertFrom-Json
    Write-Host "  URL: $($runDetails.url)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Jobs:" -ForegroundColor Yellow
    
    foreach ($job in $runDetails.jobs) {
        $jobColor = switch ($job.conclusion) {
            "success" { "Green" }
            "failure" { "Red" }
            "cancelled" { "Yellow" }
            default { if ($job.status -eq "in_progress") { "Yellow" } else { "White" } }
        }
        Write-Host "    $($job.name): $($job.status) / $($job.conclusion)" -ForegroundColor $jobColor
    }
} else {
    Write-Host "  Could not get detailed run info" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 View full details: gh run view $($latestRun.databaseId)" -ForegroundColor Gray

