# Validate Modrinth after a release to ensure all files are present
# Usage: .\scripts\validate-modrinth-after-release.ps1 [version] [project-id]
Param(
    [string]$Version = "",
    [string]$ProjectId = ""
)

Write-Host "🔍 Validating Modrinth Release" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($Version)) {
    # Get latest release
    $releaseJson = gh release view --json tagName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ No releases found" -ForegroundColor Red
        exit 1
    }
    $release = $releaseJson | ConvertFrom-Json
    $Version = $release.tagName
    Write-Host "📦 Using latest release: $Version" -ForegroundColor Yellow
}

Write-Host "📋 Checking GitHub Release..." -ForegroundColor Cyan
$releaseJson = gh release view $Version --json assets,tagName,url 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Release $Version not found" -ForegroundColor Red
    exit 1
}

$release = $releaseJson | ConvertFrom-Json
$jarAssets = $release.assets | Where-Object { $_.name -like "*.jar" }
$jarCount = $jarAssets.Count

Write-Host "  ✅ Found $jarCount JAR files in GitHub Release" -ForegroundColor Green
$jarAssets | ForEach-Object {
    Write-Host "    - $($_.name)" -ForegroundColor Gray
}

# Get expected count from versions.json
$versionsJson = Get-Content versions.json | ConvertFrom-Json
$expectedCount = ($versionsJson.PSObject.Properties.Name).Count

Write-Host ""
Write-Host "📊 Validation Summary:" -ForegroundColor Cyan
Write-Host "  Expected JARs: $expectedCount" -ForegroundColor White
Write-Host "  Found in Release: $jarCount" -ForegroundColor White

if ($jarCount -eq $expectedCount) {
    Write-Host "  ✅ All JARs present in GitHub Release!" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Mismatch: Expected $expectedCount but found $jarCount" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📦 Modrinth Validation:" -ForegroundColor Cyan

if ([string]::IsNullOrEmpty($ProjectId)) {
    Write-Host "  ⚠️  PROJECT_ID not provided" -ForegroundColor Yellow
    Write-Host "  💡 To validate Modrinth:" -ForegroundColor Yellow
    Write-Host "     1. Visit: https://modrinth.com/mod/YOUR_PROJECT_ID/versions" -ForegroundColor Gray
    Write-Host "     2. Check that version $Version exists" -ForegroundColor Gray
    Write-Host "     3. Verify all $expectedCount JARs are listed" -ForegroundColor Gray
    Write-Host "     4. Check that all game versions (1.21.1-1.21.10) are supported" -ForegroundColor Gray
} else {
    Write-Host "  🔍 Checking Modrinth API..." -ForegroundColor Yellow
    
    if (-not $env:MODRINTH_TOKEN) {
        Write-Host "  ⚠️  MODRINTH_TOKEN not set" -ForegroundColor Yellow
        Write-Host "  💡 Set MODRINTH_TOKEN environment variable to check via API" -ForegroundColor Gray
    } else {
        try {
            $headers = @{
                "Authorization" = $env:MODRINTH_TOKEN
            }
            
            $modrinthUrl = "https://api.modrinth.com/v2/project/$ProjectId/version"
            $response = Invoke-RestMethod -Uri $modrinthUrl -Headers $headers -Method Get
            
            $version = $response | Where-Object { $_.version_number -eq $Version } | Select-Object -First 1
            
            if ($version) {
                Write-Host "  ✅ Version $Version found on Modrinth" -ForegroundColor Green
                Write-Host "  📦 Files: $($version.files.Count)" -ForegroundColor White
                Write-Host "  🎮 Game Versions: $($version.game_versions.Count)" -ForegroundColor White
                
                if ($version.files.Count -eq $expectedCount) {
                    Write-Host "  ✅ All $expectedCount JARs uploaded to Modrinth!" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠️  Expected $expectedCount JARs but found $($version.files.Count)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "  ⚠️  Version $Version not found on Modrinth yet" -ForegroundColor Yellow
                Write-Host "  💡 The pipeline may still be running. Check again in a few minutes." -ForegroundColor Gray
            }
        } catch {
            Write-Host "  ❌ Error checking Modrinth: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "💡 Manual Check:" -ForegroundColor Yellow
Write-Host "   Visit: https://modrinth.com/mod/$ProjectId/versions" -ForegroundColor Cyan

