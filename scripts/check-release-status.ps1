# Check release status without hanging
# Usage: .\scripts\check-release-status.ps1 [tag]
Param(
    [string]$Tag = ""
)

Write-Host "🔍 Checking release status..." -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($Tag)) {
    # Get latest release
    $releaseJson = gh release view --json tagName,isDraft,isPrerelease,assets,createdAt,url 2>&1
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = $releaseJson -join "`n"
        if ($errorMsg -match "release not found") {
            Write-Host "  ℹ️  No releases found" -ForegroundColor Yellow
            exit 0
        }
        Write-Host "❌ Failed to get release: $errorMsg" -ForegroundColor Red
        exit 1
    }
    
    $release = $releaseJson | ConvertFrom-Json
    $Tag = $release.tagName
} else {
    $releaseJson = gh release view $Tag --json tagName,isDraft,isPrerelease,assets,createdAt,url 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Release '$Tag' not found" -ForegroundColor Red
        exit 1
    }
    $release = $releaseJson | ConvertFrom-Json
}

Write-Host ""
Write-Host "📦 Release: $($release.tagName)" -ForegroundColor Cyan
Write-Host "  URL: $($release.url)" -ForegroundColor Yellow
Write-Host "  Created: $($release.createdAt)" -ForegroundColor Gray
Write-Host "  Draft: $($release.isDraft)" -ForegroundColor $(if ($release.isDraft) { "Yellow" } else { "Green" })
Write-Host "  Prerelease: $($release.isPrerelease)" -ForegroundColor $(if ($release.isPrerelease) { "Yellow" } else { "Green" })
Write-Host ""

Write-Host "📎 Artifacts ($($release.assets.Count)):" -ForegroundColor Cyan
if ($release.assets.Count -eq 0) {
    Write-Host "  ⚠️  No artifacts found!" -ForegroundColor Red
} else {
    foreach ($asset in $release.assets) {
        $sizeMB = [math]::Round($asset.size / 1MB, 2)
        Write-Host "  ✅ $($asset.name) ($sizeMB MB)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "💡 View release: gh release view $Tag" -ForegroundColor Gray

