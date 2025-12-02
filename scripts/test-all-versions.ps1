# Test script to build and test the mod for each Minecraft version
# Usage: .\scripts\test-all-versions.ps1 [version] (if version specified, only test that one)

Param(
    [string]$Version = ""
)

# Set the correct JDK 21 path
$jdkPath = "C:\data\apps\#dev\jdk\jdk-21.0.7"
$env:JAVA_HOME = $jdkPath
$env:Path = "$jdkPath\bin;" + $env:Path

Write-Host "🧪 Testing Mod for All Minecraft Versions" -ForegroundColor Cyan
Write-Host ""

# Get versions from versions.json
$versionsJson = Get-Content versions.json | ConvertFrom-Json
$versions = $versionsJson.PSObject.Properties.Name | Sort-Object

if ($Version) {
    if ($versions -contains $Version) {
        $versions = @($Version)
        Write-Host "🎯 Testing single version: $Version" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Version $Version not found in versions.json" -ForegroundColor Red
        Write-Host "Available versions: $($versions -join ', ')" -ForegroundColor Yellow
        exit 1
    }
}

$results = @()

foreach ($mcVersion in $versions) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🧪 Testing Minecraft $mcVersion" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $testResult = @{
        Version = $mcVersion
        BuildSuccess = $false
        ServerStartSuccess = $false
        Error = ""
    }
    
    try {
        # Step 1: Update gradle.properties for this version
        Write-Host "📝 Updating gradle.properties for $mcVersion..." -ForegroundColor Yellow
        $config = $versionsJson.$mcVersion
        
        $gradleProps = Get-Content gradle.properties -Raw
        $gradleProps = $gradleProps -replace "minecraft_version=.*", "minecraft_version=$mcVersion"
        $gradleProps = $gradleProps -replace "yarn_mappings=.*", "yarn_mappings=$($config.yarn_mappings)"
        $gradleProps = $gradleProps -replace "fabric_loader_version=.*", "fabric_loader_version=$($config.loader_version)"
        $gradleProps = $gradleProps -replace "fabric_version=.*", "fabric_version=$($config.fabric_version)"
        $gradleProps = $gradleProps -replace "loom_version=.*", "loom_version=$($config.loom_version)"
        Set-Content gradle.properties -Value $gradleProps -NoNewline
        
        # Step 2: Update Gradle wrapper
        Write-Host "📦 Updating Gradle wrapper to $($config.gradle_version)..." -ForegroundColor Yellow
        ./gradlew wrapper --gradle-version $config.gradle_version
        
        # Step 3: Clean and build
        Write-Host "🔨 Building mod for $mcVersion..." -ForegroundColor Yellow
        ./gradlew clean build --no-daemon
        
        if ($LASTEXITCODE -eq 0) {
            $testResult.BuildSuccess = $true
            Write-Host "✅ Build successful!" -ForegroundColor Green
            
            # Step 4: Start server and test
            Write-Host "🚀 Starting test server for $mcVersion..." -ForegroundColor Yellow
            
            # Create version-specific test server directory
            $testServerDir = "test-server-$mcVersion"
            if (Test-Path $testServerDir) {
                Remove-Item -Recurse -Force $testServerDir
            }
            New-Item -ItemType Directory -Path $testServerDir | Out-Null
            
            # Copy mod to test server
            $modJar = Get-ChildItem build/libs -Filter "su-compostables-*.jar" | Where-Object { $_.Name -notlike "*sources*" -and $_.Name -notlike "*dev*" } | Select-Object -First 1
            
            if ($modJar) {
                New-Item -ItemType Directory -Path "$testServerDir/mods" -Force | Out-Null
                Copy-Item $modJar.FullName "$testServerDir/mods/"
                Write-Host "📦 Copied mod: $($modJar.Name)" -ForegroundColor Green
                
                # Change to test server directory and start server
                Push-Location $testServerDir
                
                # Download server files if needed
                $serverUrl = (Get-Content ../build.ps1 -Raw | Select-String -Pattern "\"$mcVersion\"\s*=\s*`"([^`"]+)`"").Matches.Groups[1].Value
                if ($serverUrl) {
                    if (-not (Test-Path "server.jar")) {
                        Write-Host "📥 Downloading Minecraft server..." -ForegroundColor Yellow
                        Invoke-WebRequest -Uri $serverUrl -OutFile "server.jar"
                    }
                    
                    # Download Fabric loader
                    $loaderUrl = (Get-Content ../build.ps1 -Raw | Select-String -Pattern "FabricLoaderDownloadMap.*?`"$mcVersion`"\s*=\s*`"([^`"]+)`"" -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -First 1
                    if ($loaderUrl) {
                        if (-not (Test-Path "fabric-server-launch.jar")) {
                            Write-Host "📥 Downloading Fabric loader..." -ForegroundColor Yellow
                            Invoke-WebRequest -Uri $loaderUrl -OutFile "fabric-server-launch.jar"
                        }
                    }
                    
                    # Start server in background
                    Write-Host "🔄 Starting server (will check logs in 30 seconds)..." -ForegroundColor Yellow
                    $serverProcess = Start-Process -FilePath "java" -ArgumentList @("-Xmx2G", "-Xms2G", "-jar", "fabric-server-launch.jar", "nogui") -PassThru -NoNewWindow -RedirectStandardOutput "server.log" -RedirectStandardError "server-error.log"
                    
                    Start-Sleep -Seconds 30
                    
                    # Check if server started
                    if (Get-Content server.log -ErrorAction SilentlyContinue | Select-String -Pattern "Done" -Quiet) {
                        $testResult.ServerStartSuccess = $true
                        Write-Host "✅ Server started successfully!" -ForegroundColor Green
                        
                        # Check if mod loaded
                        $modLoaded = Get-Content server.log -ErrorAction SilentlyContinue | Select-String -Pattern "compostables" -CaseSensitive:$false -Quiet
                        if ($modLoaded) {
                            Write-Host "✅ Mod loaded successfully!" -ForegroundColor Green
                        } else {
                            Write-Host "⚠️  Mod may not have loaded (check logs)" -ForegroundColor Yellow
                        }
                    } else {
                        $testResult.Error = "Server did not start within 30 seconds"
                        Write-Host "❌ Server did not start" -ForegroundColor Red
                    }
                    
                    # Stop server
                    if (-not $serverProcess.HasExited) {
                        $serverProcess.Kill()
                        Start-Sleep -Seconds 2
                    }
                } else {
                    $testResult.Error = "Could not find server URL for $mcVersion"
                    Write-Host "❌ Could not find server URL" -ForegroundColor Red
                }
                
                Pop-Location
            } else {
                $testResult.Error = "Could not find built mod JAR"
                Write-Host "❌ Could not find built mod JAR" -ForegroundColor Red
            }
        } else {
            $testResult.Error = "Build failed"
            Write-Host "❌ Build failed!" -ForegroundColor Red
        }
    } catch {
        $testResult.Error = $_.Exception.Message
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $results += $testResult
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 Test Results Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

foreach ($result in $results) {
    $status = if ($result.BuildSuccess -and $result.ServerStartSuccess) { "✅ PASS" } elseif ($result.BuildSuccess) { "⚠️  BUILD OK" } else { "❌ FAIL" }
    Write-Host "$status - $($result.Version)" -ForegroundColor $(if ($result.BuildSuccess -and $result.ServerStartSuccess) { "Green" } elseif ($result.BuildSuccess) { "Yellow" } else { "Red" })
    if ($result.Error) {
        Write-Host "   Error: $($result.Error)" -ForegroundColor Red
    }
}

$passed = ($results | Where-Object { $_.BuildSuccess -and $_.ServerStartSuccess }).Count
$total = $results.Count

Write-Host ""
Write-Host "Results: $passed/$total versions passed all tests" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })

