# Minecraft Fabric Mod Build and Test Server Script
# Builds the mod and optionally starts a test server

param(
    [switch]$StartServer,
    [string]$MinecraftVersion = "1.21.5"
)

# Set the correct JDK 21 path
$jdkPath = "C:\data\apps\#dev\jdk\jdk-21.0.7"
$env:JAVA_HOME = $jdkPath
$env:Path = "$jdkPath\bin;" + $env:Path

Write-Host "JAVA_HOME set to $jdkPath" -ForegroundColor Green

# Minecraft Server Download Map
$MinecraftServerDownloadMap = @{
    "1.21.5" = "https://piston-data.mojang.com/v1/objects/6e64dcabba3c01a7271b4fa6bd898483b794c59b/server.jar"
    "1.21.6" = "https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar"
    "1.21.7" = "https://piston-data.mojang.com/v1/objects/05e4b48fbc01f0385adb74bcff9751d34552486c/server.jar"
    "1.21.8" = "https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"
    "1.21.9" = "https://piston-data.mojang.com/v1/objects/11e54c2081420a4d49db3007e66c80a22579ff2a/server.jar"
    "1.21.10" = "https://piston-data.mojang.com/v1/objects/95495a7f485eedd84ce928cef5e223b757d2f764/server.jar"
}

# Fabric Loader Download Map
$FabricLoaderDownloadMap = @{
    "1.21.5" = "https://meta.fabricmc.net/v2/versions/loader/1.21.5/0.16.14/1.0.3/server/jar"
    "1.21.6" = "https://meta.fabricmc.net/v2/versions/loader/1.21.6/0.16.14/1.0.3/server/jar"
    "1.21.7" = "https://meta.fabricmc.net/v2/versions/loader/1.21.7/0.17.3/1.1.0/server/jar"
    "1.21.8" = "https://meta.fabricmc.net/v2/versions/loader/1.21.8/0.17.3/1.1.0/server/jar"
    "1.21.9" = "https://meta.fabricmc.net/v2/versions/loader/1.21.9/0.17.3/1.1.0/server/jar"
    "1.21.10" = "https://meta.fabricmc.net/v2/versions/loader/1.21.10/0.17.3/1.1.0/server/jar"
}

# Fabric API Download Map
$FabricApiDownloadMap = @{
    "1.21.5" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/vNBWcMLP/fabric-api-0.127.1%2B1.21.5.jar"
    "1.21.6" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/F5TVHWcE/fabric-api-0.128.2%2B1.21.6.jar"
    "1.21.7" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/JntuF9Ul/fabric-api-0.129.0%2B1.21.7.jar"
    "1.21.8" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/g58ofrov/fabric-api-0.136.1%2B1.21.8.jar"
    "1.21.9" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/iHrvVvaM/fabric-api-0.134.0%2B1.21.9.jar"
    "1.21.10" = "https://cdn.modrinth.com/data/P7dR8mSH/versions/dQ3p80zK/fabric-api-0.138.3%2B1.21.10.jar"
}

# Build the mod
Write-Host "🔨 Building mod..." -ForegroundColor Cyan
./gradlew build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Start server if requested
if ($StartServer) {
    Write-Host "🚀 Starting test server..." -ForegroundColor Cyan
    
    # Create server directory
    $serverDir = "test-server"
    if (-not (Test-Path $serverDir)) {
        New-Item -ItemType Directory -Path $serverDir | Out-Null
        Write-Host "📁 Created server directory: $serverDir" -ForegroundColor Green
    }
    
    Set-Location $serverDir
    
    # Download Minecraft server if not exists
    $minecraftServerJar = "server.jar"
    if (-not (Test-Path $minecraftServerJar)) {
        $serverUrl = $MinecraftServerDownloadMap[$MinecraftVersion]
        if ($serverUrl) {
            Write-Host "📥 Downloading Minecraft server $MinecraftVersion..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $serverUrl -OutFile $minecraftServerJar
            Write-Host "✅ Minecraft server downloaded" -ForegroundColor Green
        } else {
            Write-Host "❌ Unknown Minecraft version: $MinecraftVersion" -ForegroundColor Red
            Set-Location ..
            exit 1
        }
    }
    
    # Download Fabric server launcher if not exists
    $fabricServerJar = "fabric-server-launch.jar"
    if (-not (Test-Path $fabricServerJar)) {
        $fabricUrl = $FabricLoaderDownloadMap[$MinecraftVersion]
        if ($fabricUrl) {
            Write-Host "📥 Downloading Fabric server launcher $MinecraftVersion..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $fabricUrl -OutFile $fabricServerJar
            Write-Host "✅ Fabric server launcher downloaded" -ForegroundColor Green
        } else {
            Write-Host "❌ Unknown Fabric version for Minecraft: $MinecraftVersion" -ForegroundColor Red
            Set-Location ..
            exit 1
        }
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
        $fabricApiUrl = $FabricApiDownloadMap[$MinecraftVersion]
        if ($fabricApiUrl) {
            Write-Host "📥 Downloading Fabric API for $MinecraftVersion..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $fabricApiUrl -OutFile "$modsDir/$fabricApiJar"
            Write-Host "✅ Fabric API downloaded" -ForegroundColor Green
        } else {
            Write-Host "❌ Unknown Fabric API version for Minecraft: $MinecraftVersion" -ForegroundColor Red
            Set-Location ..
            exit 1
        }
    } else {
        Write-Host "✅ Fabric API already exists in mods directory" -ForegroundColor Green
    }
    
    # Find and copy the built mod JAR
    $modJars = Get-ChildItem -Path "../build/libs" -Filter "*.jar" | Where-Object { $_.Name -notlike "*-sources.jar" }
    if ($modJars.Count -gt 0) {
        $modJar = $modJars[0]
        Copy-Item $modJar.FullName -Destination "$modsDir/$($modJar.Name)" -Force
        Write-Host "📦 Copied mod JAR: $($modJar.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ No mod JAR found in build/libs" -ForegroundColor Red
        Set-Location ..
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
        Set-Location ..
        Write-Host "`n🛑 Server stopped" -ForegroundColor Yellow
    }
} 