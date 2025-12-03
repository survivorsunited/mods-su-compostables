# Simple script to get Modrinth version files - outputs raw JSON for inspection
# Usage: .\scripts\get-modrinth-files-simple.ps1 [version] [project-id]

Param(
    [string]$Version = "1.0.39",
    [string]$ProjectId = "su-compostables"
)

Write-Host "🔍 Fetching Modrinth Version Files (Raw JSON)" -ForegroundColor Cyan
Write-Host ""

# Get version by ID (we know it from pipeline logs)
$versionId = "Jt6kWNzG"
$url = "https://api.modrinth.com/v2/version/$versionId"

Write-Host "📦 Fetching version details from Modrinth API..." -ForegroundColor Yellow
Write-Host "  URL: $url" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
    
    Write-Host "✅ Version Found: $($response.version_number)" -ForegroundColor Green
    Write-Host ""
    
    # Output full JSON for inspection
    Write-Host "📋 Full Version JSON:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    Write-Host ""
    
    # Try to extract files
    if ($response.files) {
        Write-Host "📦 Files Found:" -ForegroundColor Green
        $response.files | ForEach-Object {
            $sizeMB = [math]::Round($_.size / 1MB, 2)
            Write-Host "  ✅ $($_.filename) ($sizeMB MB)" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Files array not found in response" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    # Try to extract game versions
    if ($response.game_versions) {
        Write-Host "🎮 Game Versions Found:" -ForegroundColor Green
        $response.game_versions | Sort-Object | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "⚠️  Game versions array not found in response" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "💡 Alternative: Check Modrinth website directly:" -ForegroundColor Yellow
    Write-Host "   https://modrinth.com/mod/$ProjectId/version/$Version" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Try:" -ForegroundColor Yellow
    Write-Host "   1. Check Modrinth website: https://modrinth.com/mod/$ProjectId/versions" -ForegroundColor Gray
    Write-Host "   2. Use authenticated API with MODRINTH_TOKEN" -ForegroundColor Gray
}

