# Get detailed logs for a specific job
# Usage: .\scripts\get-job-logs.ps1 [run-id] [job-name]
Param(
    [Parameter(Mandatory=$true)]
    [string]$RunId,
    
    [Parameter(Mandatory=$false)]
    [string]$JobName = ""
)

Write-Host "📋 Getting logs for run $RunId..." -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($JobName)) {
    # Get all jobs
    $runJson = gh run view $RunId --json jobs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to get run: $runJson" -ForegroundColor Red
        exit 1
    }
    
    $run = $runJson | ConvertFrom-Json
    $failedJobs = $run.jobs | Where-Object { $_.conclusion -eq "failure" }
    
    if ($failedJobs.Count -eq 0) {
        Write-Host "  ✅ No failed jobs" -ForegroundColor Green
        exit 0
    }
    
    Write-Host ""
    Write-Host "❌ Failed Jobs:" -ForegroundColor Red
    foreach ($job in $failedJobs) {
        Write-Host "  - $($job.name) (ID: $($job.databaseId))" -ForegroundColor Red
    }
    Write-Host ""
    
    # Get logs for first failed job
    $JobName = $failedJobs[0].name
    $JobId = $failedJobs[0].databaseId
    Write-Host "📝 Getting logs for: $JobName (ID: $JobId)" -ForegroundColor Yellow
    Write-Host ""
    
    # Use job ID instead of name
    $logOutput = gh run view $RunId --log --job $JobId 2>&1 | Select-Object -Last 100
} else {
    # Get job by name
    $runJson = gh run view $RunId --json jobs 2>&1
    if ($LASTEXITCODE -eq 0) {
        $run = $runJson | ConvertFrom-Json
        $job = $run.jobs | Where-Object { $_.name -eq $JobName } | Select-Object -First 1
        if ($job) {
            $JobId = $job.databaseId
            Write-Host "📝 Using job ID: $JobId" -ForegroundColor Yellow
            Write-Host ""
            $logOutput = gh run view $RunId --log --job $JobId 2>&1 | Select-Object -Last 100
        } else {
            Write-Host "❌ Job '$JobName' not found" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Failed to get run: $runJson" -ForegroundColor Red
        exit 1
    }
}

if (-not $logOutput) {
    # Fallback: try with job name
    $logOutput = gh run view $RunId --log --job "$JobName" 2>&1 | Select-Object -Last 100
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get logs: $logOutput" -ForegroundColor Red
    exit 1
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Last 100 lines of logs:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$logOutput | ForEach-Object {
    $line = $_
    if ($line -match "error|Error|ERROR|Failed|FAILED|Exception") {
        Write-Host $_ -ForegroundColor Red
    } elseif ($line -match "warning|Warning|WARNING") {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($line -match "success|Success|SUCCESS|Done|✅") {
        Write-Host $_ -ForegroundColor Green
    } else {
        Write-Host $_ -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "💡 View full logs: gh run view $RunId --log --job `"$JobName`"" -ForegroundColor Yellow

