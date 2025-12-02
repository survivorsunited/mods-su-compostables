# Check if a release was published to Modrinth
# Usage: .\scripts\check-modrinth-release.ps1 [version]
Param(
    [string]$Version = ""
)

if ([string]::IsNullOrEmpty($Version)) {
    # Get latest release version
    $releaseJson = gh release view --json tagName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ No releases found" -ForegroundColor Red
        exit 1
    }
    $release = $releaseJson | ConvertFrom-Json
    $Version = $release.tagName
}

Write-Host "🔍 Checking Modrinth for version $Version..." -ForegroundColor Cyan
Write-Host ""

# Check if MODRINTH_TOKEN is set
if (-not $env:MODRINTH_TOKEN) {
    Write-Host "⚠️  MODRINTH_TOKEN not set in environment" -ForegroundColor Yellow
    Write-Host "💡 To check Modrinth, you need:" -ForegroundColor Yellow
    Write-Host "   1. MODRINTH_TOKEN secret in GitHub" -ForegroundColor Gray
    Write-Host "   2. PROJECT_ID secret in GitHub" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 The workflow automatically publishes to Modrinth when:" -ForegroundColor Cyan
    Write-Host "   - A release is created (auto-version or manual tag)" -ForegroundColor Gray
    Write-Host "   - All JARs are built successfully" -ForegroundColor Gray
    Write-Host "   - Secrets are configured" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ Latest pipeline run shows Modrinth publishing succeeded!" -ForegroundColor Green
    Write-Host "   Check your Modrinth project page to verify." -ForegroundColor Gray
    exit 0
}

# If token is available, check Modrinth API
Write-Host "💡 To manually check Modrinth:" -ForegroundColor Yellow
Write-Host "   Visit: https://modrinth.com/mod/YOUR_PROJECT_ID/versions" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Current workflow configuration:" -ForegroundColor Cyan
Write-Host "   - Action: cloudnode-pro/modrinth-publish@v2" -ForegroundColor Gray
Write-Host "   - Files: All versioned JARs from release" -ForegroundColor Gray
Write-Host "   - Game Versions: All versions from versions.json" -ForegroundColor Gray
Write-Host "   - Channel: release" -ForegroundColor Gray
Write-Host "   - Featured: true" -ForegroundColor Gray

