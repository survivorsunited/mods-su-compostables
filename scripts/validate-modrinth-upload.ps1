# Validate that Modrinth upload will include all JAR files
# Usage: .\scripts\validate-modrinth-upload.ps1

Write-Host "🔍 Validating Modrinth Upload Configuration" -ForegroundColor Cyan
Write-Host ""

# Check versions.json
Write-Host "📋 Checking versions.json..." -ForegroundColor Yellow
$versionsJson = Get-Content versions.json | ConvertFrom-Json
$versions = $versionsJson.PSObject.Properties.Name | Sort-Object
$versionCount = $versions.Count

Write-Host "  Found $versionCount Minecraft versions:" -ForegroundColor Green
$versions | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
Write-Host ""

# Check workflow configuration
Write-Host "📋 Checking workflow configuration..." -ForegroundColor Yellow
$workflowContent = Get-Content .github/workflows/build.yml -Raw

# Check if Modrinth publishing is configured
if ($workflowContent -match "Publish to Modrinth") {
    Write-Host "  ✅ Modrinth publishing step found" -ForegroundColor Green
} else {
    Write-Host "  ❌ Modrinth publishing step not found!" -ForegroundColor Red
    exit 1
}

# Check if game versions are generated from versions.json
if ($workflowContent -match "jq -r 'keys") {
    Write-Host "  ✅ Game versions generated from versions.json" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Game versions may not be generated from versions.json" -ForegroundColor Yellow
}

# Check if all JARs are collected
if ($workflowContent -match "collect_jars") {
    Write-Host "  ✅ JAR collection step found" -ForegroundColor Green
} else {
    Write-Host "  ❌ JAR collection step not found!" -ForegroundColor Red
    exit 1
}

# Check if files parameter uses collected JARs
if ($workflowContent -match "files:.*collect_jars") {
    Write-Host "  ✅ Modrinth files parameter uses collected JARs" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Modrinth files parameter may not use collected JARs" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  Expected JARs: $versionCount (one per Minecraft version)" -ForegroundColor White
Write-Host "  Minecraft Versions: $($versions -join ', ')" -ForegroundColor White
Write-Host ""
Write-Host "✅ Validation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Ensure MODRINTH_TOKEN and PROJECT_ID secrets are set in GitHub" -ForegroundColor Gray
Write-Host "   2. Create a release (auto-version or manual tag)" -ForegroundColor Gray
Write-Host "   3. Verify all $versionCount JARs are uploaded to Modrinth" -ForegroundColor Gray

