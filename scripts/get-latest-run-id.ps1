# Get the latest pipeline run ID
# Usage: .\scripts\get-latest-run-id.ps1 [workflow]
Param(
    [string]$Workflow = "build.yml"
)

$runsJson = gh run list --workflow=$Workflow --limit 1 --json databaseId,status,conclusion,event,headBranch 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get runs: $runsJson" -ForegroundColor Red
    exit 1
}

$runs = $runsJson | ConvertFrom-Json
if ($runs.Count -eq 0) {
    Write-Host "No runs found" -ForegroundColor Yellow
    exit 1
}

$run = $runs[0]
Write-Output $run.databaseId



