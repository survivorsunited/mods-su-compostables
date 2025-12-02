# Find correct Fabric API version for a Minecraft version
# Usage: .\scripts\find-fabric-api-version.ps1 [mc-version]
Param(
    [Parameter(Mandatory=$true)]
    [string]$MinecraftVersion
)

Write-Host "🔍 Finding Fabric API version for Minecraft $MinecraftVersion..." -ForegroundColor Cyan

# Try Modrinth API
Write-Host ""
Write-Host "📦 Checking Modrinth API..." -ForegroundColor Yellow
$modrinthUrl = "https://api.modrinth.com/v2/project/fabric-api/version?game_versions=[`"$MinecraftVersion`"]&featured=true"
$response = Invoke-RestMethod -Uri $modrinthUrl -Method Get -ErrorAction SilentlyContinue

if ($response -and $response.Count -gt 0) {
    $version = $response[0]
    Write-Host "✅ Found on Modrinth:" -ForegroundColor Green
    Write-Host "  Version: $($version.version_number)" -ForegroundColor White
    Write-Host "  ID: $($version.id)" -ForegroundColor Gray
    Write-Host "  Published: $($version.date_published)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Use this version in versions.json:" -ForegroundColor Yellow
    Write-Host "  `"fabric_version`": `"$($version.version_number)`"" -ForegroundColor Cyan
    exit 0
}

# Try Fabric Maven (fallback)
Write-Host "📦 Checking Fabric Maven..." -ForegroundColor Yellow
$mavenUrl = "https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/maven-metadata.xml"
try {
    $mavenXml = Invoke-RestMethod -Uri $mavenUrl -Method Get
    Write-Host "  Maven metadata retrieved" -ForegroundColor Gray
    
    # Parse versions (this is a simplified approach)
    # The actual version format is like "0.124.0+1.21.1"
    Write-Host ""
    Write-Host "⚠️  Could not find exact version automatically" -ForegroundColor Yellow
    Write-Host "💡 Try checking:" -ForegroundColor Yellow
    Write-Host "   https://modrinth.com/mod/fabric-api/versions?g=$MinecraftVersion" -ForegroundColor Cyan
    Write-Host "   https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/" -ForegroundColor Cyan
} catch {
    Write-Host "  ❌ Could not access Maven" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 Manual check:" -ForegroundColor Yellow
Write-Host "   Visit: https://modrinth.com/mod/fabric-api/versions?g=$MinecraftVersion" -ForegroundColor Cyan

