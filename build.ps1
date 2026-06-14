# Minecraft Fabric Mod Build and Test Server Script
# Builds the mod and optionally starts a test server

param(
    [switch]$StartServer,
    [string]$MinecraftVersion = "1.21.11"
)

# Set the correct JDK 21 path
$jdkPath = "C:\data\apps\#dev\jdk\jdk-21.0.7"
$env:JAVA_HOME = $jdkPath
$env:Path = "$jdkPath\bin;" + $env:Path

Write-Host "JAVA_HOME set to $jdkPath" -ForegroundColor Green

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionsConfig = Get-Content -Raw (Join-Path $repoRoot "versions.json") | ConvertFrom-Json
$supportedVersions = $versionsConfig.PSObject.Properties.Name | Sort-Object { [version]$_ }

if ($MinecraftVersion -notin $supportedVersions) {
    Write-Host "❌ Unsupported Minecraft version: $MinecraftVersion" -ForegroundColor Red
    Write-Host "Supported versions: $($supportedVersions -join ', ')" -ForegroundColor Yellow
    exit 1
}

$versionConfig = $versionsConfig.$MinecraftVersion

function Set-BuildConfiguration {
    param(
        [string]$Version,
        [psobject]$Config
    )

    $wrapperPath = Join-Path $repoRoot "gradle/wrapper/gradle-wrapper.properties"
    $wrapperUrl = "https://services.gradle.org/distributions/gradle-$($Config.gradle_version)-bin.zip" -replace ':', '\:'
    (Get-Content $wrapperPath) -replace 'distributionUrl=.*', "distributionUrl=$wrapperUrl" | Set-Content $wrapperPath

    $gradlePropertiesPath = Join-Path $repoRoot "gradle.properties"
    $gradleProperties = Get-Content $gradlePropertiesPath -Raw
    $gradleProperties = $gradleProperties -replace 'minecraft_version=.*', "minecraft_version=$Version"
    $gradleProperties = $gradleProperties -replace 'yarn_mappings=.*', "yarn_mappings=$($Config.yarn_mappings)"
    $gradleProperties = $gradleProperties -replace 'fabric_loader_version=.*', "fabric_loader_version=$($Config.loader_version)"
    $gradleProperties = $gradleProperties -replace 'fabric_version=.*', "fabric_version=$($Config.fabric_version)"
    $gradleProperties = $gradleProperties -replace 'loom_version=.*', "loom_version=$($Config.loom_version)"
    Set-Content $gradlePropertiesPath -Value $gradleProperties -NoNewline
}

function Get-MinecraftServerUrl {
    param([string]$Version)

    $manifest = Invoke-RestMethod -Uri "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
    $versionInfo = $manifest.versions | Where-Object { $_.id -eq $Version } | Select-Object -First 1

    if (-not $versionInfo) {
        throw "Unable to find Minecraft server metadata for version $Version"
    }

    $versionManifest = Invoke-RestMethod -Uri $versionInfo.url
    return $versionManifest.downloads.server.url
}

function Get-FabricInstallerVersion {
    $installers = Invoke-RestMethod -Uri "https://meta.fabricmc.net/v2/versions/installer"
    $stableInstaller = $installers | Where-Object { $_.stable } | Select-Object -First 1

    if ($stableInstaller) {
        return $stableInstaller.version
    }

    return ($installers | Select-Object -First 1).version
}

function Get-FabricLoaderUrl {
    param(
        [string]$Version,
        [string]$LoaderVersion
    )

    $installerVersion = Get-FabricInstallerVersion
    return "https://meta.fabricmc.net/v2/versions/loader/$Version/$LoaderVersion/$installerVersion/server/jar"
}

function Get-FabricApiUrl {
    param([string]$FabricApiVersion)

    return "https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/$FabricApiVersion/fabric-api-$FabricApiVersion.jar"
}

Set-BuildConfiguration -Version $MinecraftVersion -Config $versionConfig

# Build the mod
Write-Host "🔨 Building mod..." -ForegroundColor Cyan
Push-Location $repoRoot
./gradlew build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Pop-Location

# Start server if requested
if ($StartServer) {
    Write-Host "🚀 Starting test server..." -ForegroundColor Cyan
    
    # Create server directory
    $serverDir = Join-Path $repoRoot "test-server"
    if (-not (Test-Path $serverDir)) {
        New-Item -ItemType Directory -Path $serverDir | Out-Null
        Write-Host "📁 Created server directory: $serverDir" -ForegroundColor Green
    }
    
    Push-Location $serverDir
    
    # Download Minecraft server if not exists
    $minecraftServerJar = "server.jar"
    if (-not (Test-Path $minecraftServerJar)) {
        $serverUrl = Get-MinecraftServerUrl -Version $MinecraftVersion
        Write-Host "📥 Downloading Minecraft server $MinecraftVersion..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $serverUrl -OutFile $minecraftServerJar
        Write-Host "✅ Minecraft server downloaded" -ForegroundColor Green
    }
    
    # Download Fabric server launcher if not exists
    $fabricServerJar = "fabric-server-launch.jar"
    if (-not (Test-Path $fabricServerJar)) {
        $fabricUrl = Get-FabricLoaderUrl -Version $MinecraftVersion -LoaderVersion $versionConfig.loader_version
        Write-Host "📥 Downloading Fabric server launcher $MinecraftVersion..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $fabricUrl -OutFile $fabricServerJar
        Write-Host "✅ Fabric server launcher downloaded" -ForegroundColor Green
    }
    
    # Create mods directory and copy built mod
    $modsDir = "mods"
    if (-not (Test-Path $modsDir)) {
        New-Item -ItemType Directory -Path $modsDir | Out-Null
        Write-Host "📁 Created mods directory: $modsDir" -ForegroundColor Green
    }

    # Download Fabric API if not exists
    $fabricApiJar = "fabric-api.jar"
    if (-not (Test-Path "$modsDir/$fabricApiJar")) {
        $fabricApiUrl = Get-FabricApiUrl -FabricApiVersion $versionConfig.fabric_version
        Write-Host "📥 Downloading Fabric API for $MinecraftVersion..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $fabricApiUrl -OutFile "$modsDir/$fabricApiJar"
        Write-Host "✅ Fabric API downloaded" -ForegroundColor Green
    } else {
        Write-Host "✅ Fabric API already exists in mods directory" -ForegroundColor Green
    }
    
    # Find and copy the built mod JAR
    $modJars = Get-ChildItem -Path (Join-Path $repoRoot "build/libs") -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" }
    if ($modJars.Count -gt 0) {
        $modJar = $modJars[0]
        Copy-Item $modJar.FullName -Destination "$modsDir/$($modJar.Name)" -Force
        Write-Host "📦 Copied mod JAR: $($modJar.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ No mod JAR found in build/libs" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    # Accept EULA if not exists
    if (-not (Test-Path "eula.txt")) {
        "eula=true" | Out-File -FilePath "eula.txt" -Encoding utf8
        Write-Host "✅ Accepted EULA" -ForegroundColor Green
    }
    
    # Create server properties with basic config
    if (-not (Test-Path "server.properties")) {
        @"
server-port=25565
gamemode=creative
difficulty=easy
spawn-protection=0
online-mode=false
enable-command-block=true
"@ | Out-File -FilePath "server.properties" -Encoding utf8
        Write-Host "✅ Created server.properties" -ForegroundColor Green
    }
    
    # Start the server
    Write-Host "🚀 Starting Fabric server..." -ForegroundColor Green
    Write-Host "Server will automatically stop after successful startup" -ForegroundColor Yellow
    
    $javaOpts = @(
        "-Xms2G"
        "-Xmx4G"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "--enable-native-access=ALL-UNNAMED"
    )
    
    $logFile = "server.log"
    $javaCmd = "java " + ($javaOpts -join " ") + " -jar `"$fabricServerJar`" nogui"
    
    try {
        # Start server in background and tee output to log file
        $job = Start-Job -ScriptBlock {
            param($cmd, $log)
            Invoke-Expression "$cmd 2>&1 | Tee-Object -FilePath `"$log`""
        } -ArgumentList $javaCmd, $logFile
        
        Write-Host "📄 Monitoring server log: $logFile" -ForegroundColor Cyan
        
        # Monitor log file for startup completion and show output
        $timeout = 120 # 2 minutes
        $elapsed = 0
        $serverStarted = $false
        $lastLineCount = 0
        
        while ($elapsed -lt $timeout -and !$serverStarted) {
            Start-Sleep -Seconds 1
            $elapsed++
            
            if (Test-Path $logFile) {
                try {
                    # Read all lines and show only new ones
                    $allLines = Get-Content $logFile -ErrorAction SilentlyContinue
                    if ($allLines -and $allLines.Count -gt $lastLineCount) {
                        # Show new lines
                        for ($i = $lastLineCount; $i -lt $allLines.Count; $i++) {
                            Write-Host $allLines[$i]
                            
                            # Check this line for completion
                            if ($allLines[$i] -match "Done \(\d+\.\d+s\)! For help, type") {
                                Write-Host "✅ Server started successfully! Stopping server..." -ForegroundColor Green
                                $serverStarted = $true
                                
                                # Force stop the job
                                Stop-Job $job -PassThru | Remove-Job
                                break
                            }
                        }
                        $lastLineCount = $allLines.Count
                    }
                } catch {
                    # File might be locked, just wait and try again
                    Start-Sleep -Milliseconds 100
                }
            } else {
                # Show progress when no log file yet
                if ($elapsed % 5 -eq 0) {
                    Write-Host "⏱️ Waiting for server to start logging... ($elapsed/$timeout seconds)" -ForegroundColor Yellow
                }
            }
        }
        
        if (!$serverStarted) {
            Write-Host "⚠️ Server startup timeout reached, stopping..." -ForegroundColor Yellow
            Stop-Job $job -PassThru | Remove-Job
        }
        
        # Display last few lines of log
        if (Test-Path $logFile) {
            Write-Host "`n📋 Last few log lines:" -ForegroundColor Cyan
            Get-Content $logFile -Tail 3
        }
        
    } finally {
        # Clean up
        if ($job) {
            Stop-Job $job -ErrorAction SilentlyContinue
            Remove-Job $job -ErrorAction SilentlyContinue
        }
        Remove-Item "stop_command.txt" -ErrorAction SilentlyContinue
        Pop-Location
        Write-Host "`n🛑 Server stopped" -ForegroundColor Yellow
    }
} 