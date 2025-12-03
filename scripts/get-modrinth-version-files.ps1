# Get list of JAR files from Modrinth for a specific version
# Usage: .\scripts\get-modrinth-version-files.ps1 [version] [project-id]
Param(
    [string]$Version = "",
    [string]$ProjectId = ""
)

Write-Host "🔍 Fetching Modrinth Version Files" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrEmpty($Version)) {
    # Get latest release
    $releaseJson = gh release view --json tagName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $release = $releaseJson | ConvertFrom-Json
        $Version = $release.tagName
        Write-Host "📦 Using latest release: $Version" -ForegroundColor Yellow
    } else {
        Write-Host "❌ No releases found and no version specified" -ForegroundColor Red
        Write-Host "💡 Usage: .\scripts\get-modrinth-version-files.ps1 -Version '1.0.39' -ProjectId 'YOUR_PROJECT_ID'" -ForegroundColor Yellow
        exit 1
    }
}

if ([string]::IsNullOrEmpty($ProjectId)) {
    Write-Host "⚠️  PROJECT_ID not provided" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 To get PROJECT_ID:" -ForegroundColor Yellow
    Write-Host "   1. Visit your Modrinth project page" -ForegroundColor Gray
    Write-Host "   2. The PROJECT_ID is in the URL: https://modrinth.com/mod/PROJECT_ID" -ForegroundColor Gray
    Write-Host "   3. Or check GitHub secrets: PROJECT_ID" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Alternative: Check Modrinth website manually:" -ForegroundColor Cyan
    Write-Host "   https://modrinth.com/mod/YOUR_PROJECT_ID/versions" -ForegroundColor Gray
    exit 0
}

Write-Host "📦 Fetching version $Version from Modrinth project $ProjectId..." -ForegroundColor Cyan
Write-Host ""

# Try to get MODRINTH_TOKEN from environment or GitHub secrets
$token = $env:MODRINTH_TOKEN
if ([string]::IsNullOrEmpty($token)) {
    Write-Host "⚠️  MODRINTH_TOKEN not set in environment" -ForegroundColor Yellow
    Write-Host "💡 To use API:" -ForegroundColor Yellow
    Write-Host "   1. Get token from: https://modrinth.com/settings/api" -ForegroundColor Gray
    Write-Host "   2. Set: `$env:MODRINTH_TOKEN = 'your-token'" -ForegroundColor Gray
    Write-Host "   3. Or check GitHub secrets: MODRINTH_TOKEN" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Using public API (limited info)..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try public API (no auth required, but limited)
    try {
        # First get all versions to find the one we want
        $publicUrl = "https://api.modrinth.com/v2/project/$ProjectId/version"
        $jsonResponse = Invoke-WebRequest -Uri $publicUrl -Method Get -ErrorAction Stop
        $response = $jsonResponse.Content | ConvertFrom-Json
        
        $version = $response | Where-Object { $_.version_number -eq $Version } | Select-Object -First 1
        
        if ($version) {
            # Get detailed version info using version ID
            $versionId = $version.id
            $versionDetailUrl = "https://api.modrinth.com/v2/version/$versionId"
            try {
                $versionDetailJson = Invoke-WebRequest -Uri $versionDetailUrl -Method Get -ErrorAction Stop
                $versionDetail = $versionDetailJson.Content | ConvertFrom-Json
                $version = $versionDetail
            } catch {
                Write-Host "  ⚠️  Could not get detailed version info, using basic info" -ForegroundColor Yellow
            }
        }
        
        if ($version) {
            Write-Host "✅ Found version $Version on Modrinth" -ForegroundColor Green
            Write-Host ""
            
            # Convert to JSON and back to properly access nested arrays
            $versionJson = $version | ConvertTo-Json -Depth 10
            $versionObj = $versionJson | ConvertFrom-Json
            
            # Access files
            $files = @()
            if ($versionObj.files) {
                $files = $versionObj.files
            } elseif ($version.PSObject.Properties['files']) {
                $filesJson = $version.PSObject.Properties['files'].Value | ConvertTo-Json -Depth 10
                $files = $filesJson | ConvertFrom-Json
            }
            
            $fileCount = if ($files) { $files.Count } else { 0 }
            
            Write-Host "📦 Files ($fileCount):" -ForegroundColor Cyan
            if ($fileCount -gt 0) {
                foreach ($file in $files) {
                    $filename = $file.filename
                    $size = $file.size
                    $sizeMB = [math]::Round($size / 1MB, 2)
                    Write-Host "  ✅ $filename ($sizeMB MB)" -ForegroundColor Green
                }
            } else {
                Write-Host "  ⚠️  No files found in response" -ForegroundColor Yellow
                Write-Host "  💡 Try using authenticated API or check Modrinth website directly" -ForegroundColor Gray
            }
            
            Write-Host ""
            
            # Access game_versions
            $gameVersions = @()
            if ($versionObj.game_versions) {
                $gameVersions = $versionObj.game_versions
            } elseif ($version.PSObject.Properties['game_versions']) {
                $gvJson = $version.PSObject.Properties['game_versions'].Value | ConvertTo-Json -Depth 10
                $gameVersions = $gvJson | ConvertFrom-Json
            }
            
            $gameVersionCount = if ($gameVersions) { $gameVersions.Count } else { 0 }
            
            Write-Host "🎮 Game Versions ($gameVersionCount):" -ForegroundColor Cyan
            if ($gameVersionCount -gt 0) {
                $gameVersions | Sort-Object | ForEach-Object {
                    Write-Host "  - $_" -ForegroundColor Gray
                }
            } else {
                Write-Host "  ⚠️  No game versions found in response" -ForegroundColor Yellow
                Write-Host "  💡 Try using authenticated API or check Modrinth website directly" -ForegroundColor Gray
            }
            
            Write-Host ""
            Write-Host "📊 Summary:" -ForegroundColor Cyan
            Write-Host "  Version: $($version.version_number)" -ForegroundColor White
            Write-Host "  Status: $($version.status)" -ForegroundColor White
            Write-Host "  Channel: $($version.version_type)" -ForegroundColor White
            Write-Host "  Featured: $($version.featured)" -ForegroundColor White
            Write-Host "  Files: $fileCount" -ForegroundColor White
            Write-Host "  Game Versions: $gameVersionCount" -ForegroundColor White
            
            # Compare with expected
            $versionsJson = Get-Content versions.json | ConvertFrom-Json
            $expectedCount = ($versionsJson.PSObject.Properties.Name).Count
            
            Write-Host ""
            if ($version.files.Count -eq $expectedCount) {
                Write-Host "✅ All $expectedCount JARs found on Modrinth!" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Expected $expectedCount JARs but found $($version.files.Count)" -ForegroundColor Yellow
            }
            
            if ($version.game_versions.Count -eq $expectedCount) {
                Write-Host "✅ All $expectedCount game versions found!" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Expected $expectedCount game versions but found $($version.game_versions.Count)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ Version $Version not found on Modrinth" -ForegroundColor Red
            Write-Host ""
            Write-Host "📋 Available versions:" -ForegroundColor Yellow
            $response | Select-Object -First 5 | ForEach-Object {
                Write-Host "  - $($_.version_number)" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "❌ Error fetching from Modrinth API: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Try:" -ForegroundColor Yellow
        Write-Host "   1. Verify PROJECT_ID is correct" -ForegroundColor Gray
        Write-Host "   2. Check if version exists: https://modrinth.com/mod/$ProjectId/versions" -ForegroundColor Gray
        Write-Host "   3. Use authenticated API with MODRINTH_TOKEN for more details" -ForegroundColor Gray
    }
} else {
    # Use authenticated API
    Write-Host "🔐 Using authenticated API..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        $headers = @{
            "Authorization" = $token
        }
        
        $url = "https://api.modrinth.com/v2/project/$ProjectId/version"
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop
        
        $version = $response | Where-Object { $_.version_number -eq $Version } | Select-Object -First 1
        
        if ($version) {
            Write-Host "✅ Found version $Version on Modrinth" -ForegroundColor Green
            Write-Host ""
            Write-Host "📦 Files ($($version.files.Count)):" -ForegroundColor Cyan
            foreach ($file in $version.files) {
                $sizeMB = [math]::Round($file.size / 1MB, 2)
                $primary = if ($file.primary) { " [PRIMARY]" } else { "" }
                Write-Host "  ✅ $($file.filename) ($sizeMB MB)$primary" -ForegroundColor Green
            }
            Write-Host ""
            Write-Host "🎮 Game Versions ($($version.game_versions.Count)):" -ForegroundColor Cyan
            $version.game_versions | Sort-Object | ForEach-Object {
                Write-Host "  - $_" -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "📊 Full Details:" -ForegroundColor Cyan
            $version | ConvertTo-Json -Depth 10 | Write-Host
        } else {
            Write-Host "❌ Version $Version not found" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

