# Script to fix or delete a release with version mismatch
# Usage: .\scripts\fix-bad-release.ps1 [version] [action]
# Actions: delete, rebuild, check

Param(
    [string]$Version = "1.0.40",
    [ValidateSet("delete", "rebuild", "check")]
    [string]$Action = "check"
)

Write-Host "🔧 Fix Bad Release Tool" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Checking release $Version..." -ForegroundColor Yellow
$releaseJson = gh release view $Version --json assets,tagName,url 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Release $Version not found" -ForegroundColor Red
    exit 1
}

$release = $releaseJson | ConvertFrom-Json
$jarAssets = $release.assets | Where-Object { $_.name -like "*.jar" }

Write-Host "📦 Found $($jarAssets.Count) JAR files:" -ForegroundColor Cyan
$versionMismatch = $false
foreach ($jar in $jarAssets) {
    if ($jar.name -notmatch "-$Version-") {
        Write-Host "  ❌ $($jar.name) (VERSION MISMATCH!)" -ForegroundColor Red
        $versionMismatch = $true
    } else {
        Write-Host "  ✅ $($jar.name)" -ForegroundColor Green
    }
}

Write-Host ""

if ($versionMismatch) {
    Write-Host "⚠️  VERSION MISMATCH DETECTED!" -ForegroundColor Red
    Write-Host "   Release tag: $Version" -ForegroundColor Yellow
    Write-Host "   JAR files contain different version" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Action -eq "delete") {
        Write-Host "🗑️  Deleting release $Version..." -ForegroundColor Yellow
        gh release delete $Version --yes 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Release deleted" -ForegroundColor Green
            Write-Host ""
            Write-Host "💡 To recreate with correct version:" -ForegroundColor Cyan
            Write-Host "   .\release.ps1 -Version `"$Version`"" -ForegroundColor Gray
        } else {
            Write-Host "❌ Failed to delete release" -ForegroundColor Red
        }
    } elseif ($Action -eq "rebuild") {
        Write-Host "🔨 Rebuilding release $Version..." -ForegroundColor Yellow
        Write-Host "   This will delete and recreate the release" -ForegroundColor Gray
        gh release delete $Version --yes 2>&1
        Start-Sleep -Seconds 2
        .\release.ps1 -Version $Version
    } else {
        Write-Host "💡 Options to fix:" -ForegroundColor Yellow
        Write-Host "   1. Delete release: .\scripts\fix-bad-release.ps1 -Version `"$Version`" -Action delete" -ForegroundColor Gray
        Write-Host "   2. Rebuild release: .\scripts\fix-bad-release.ps1 -Version `"$Version`" -Action rebuild" -ForegroundColor Gray
        Write-Host "   3. Manual fix: Delete release on GitHub, then run .\release.ps1 -Version `"$Version`"" -ForegroundColor Gray
    }
} else {
    Write-Host "✅ All JAR files match release version $Version" -ForegroundColor Green
}

