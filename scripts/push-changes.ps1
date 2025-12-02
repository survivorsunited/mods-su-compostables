# Push changes to git without hanging
# Usage: .\scripts\push-changes.ps1 [commit-message] [files...]
Param(
    [Parameter(Mandatory=$false)]
    [string]$Message = "Update files",
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Files = @()
)

Write-Host "📤 Pushing changes..." -ForegroundColor Cyan

# Check if there are changes
$status = git status --porcelain 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to check git status: $status" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($status)) {
    Write-Host "  ℹ️  No changes to commit" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "📝 Changes to commit:" -ForegroundColor Yellow
$status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

# Stage files
if ($Files.Count -gt 0) {
    Write-Host "📦 Staging specific files..." -ForegroundColor Cyan
    foreach ($file in $Files) {
        git add $file 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ $file" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $file (not found or already staged)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "📦 Staging all changes..." -ForegroundColor Cyan
    git add -A 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to stage changes" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ All changes staged" -ForegroundColor Green
}

# Commit
Write-Host ""
Write-Host "💾 Committing..." -ForegroundColor Cyan
$commitOutput = git commit -m $Message 2>&1
if ($LASTEXITCODE -ne 0) {
    if ($commitOutput -match "nothing to commit") {
        Write-Host "  ℹ️  Nothing to commit" -ForegroundColor Yellow
        exit 0
    }
    Write-Host "❌ Failed to commit: $commitOutput" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Committed: $Message" -ForegroundColor Green

# Push
Write-Host ""
Write-Host "🚀 Pushing..." -ForegroundColor Cyan
$pushOutput = git push 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to push: $pushOutput" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 You may need to pull first: git pull --rebase" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✅ Pushed successfully" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Done!" -ForegroundColor Green



