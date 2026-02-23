# Build for all Minecraft versions in versions.json
$ErrorActionPreference = 'Stop'
$versionsJson = Get-Content -Raw versions.json | ConvertFrom-Json
# Sort versions numerically (1.21.1, 1.21.2, ... 1.21.11)
$mcVersions = $versionsJson.PSObject.Properties.Name | Sort-Object { [version]$_ }
$modVersion = (Get-Content gradle.properties | Select-String '^mod_version=').ToString().Split('=', 2)[1]
$modName = (Get-Content gradle.properties | Select-String '^jar_name=').ToString().Split('=', 2)[1]
$currentGradle = $null
# Use dir outside build/ so "gradlew clean" doesn't wipe collected JARs
$libsAll = "build-output"
if (Test-Path $libsAll) { Remove-Item $libsAll -Recurse -Force }
New-Item -ItemType Directory -Path $libsAll -Force | Out-Null

foreach ($mc in $mcVersions) {
    $c = $versionsJson.$mc
    $yarn = $c.yarn_mappings
    $loader = $c.loader_version
    $fabric = $c.fabric_version
    $loom = $c.loom_version
    $gradleVer = $c.gradle_version

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Building for Minecraft $mc" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Update Gradle wrapper if needed
    if ($currentGradle -ne $gradleVer) {
        $url = "https://services.gradle.org/distributions/gradle-$gradleVer-bin.zip"
        $escaped = $url -replace ':', '\:'
        (Get-Content gradle/wrapper/gradle-wrapper.properties) -replace 'distributionUrl=.*', "distributionUrl=$escaped" | Set-Content gradle/wrapper/gradle-wrapper.properties
        $currentGradle = $gradleVer
    }

    # Update gradle.properties
    $gp = Get-Content gradle.properties -Raw
    $gp = $gp -replace 'minecraft_version=.*', "minecraft_version=$mc"
    $gp = $gp -replace 'yarn_mappings=.*', "yarn_mappings=$yarn"
    $gp = $gp -replace 'fabric_loader_version=.*', "fabric_loader_version=$loader"
    $gp = $gp -replace 'fabric_version=.*', "fabric_version=$fabric"
    $gp = $gp -replace 'loom_version=.*', "loom_version=$loom"
    Set-Content gradle.properties -Value $gp -NoNewline

    # Clean and build (reuse build dir but clean between versions)
    & .\gradlew.bat clean build --no-daemon
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: Minecraft $mc" -ForegroundColor Red
        exit 1
    }

    # Copy versioned JAR to output dir (outside build/ so clean doesn't remove it)
    $origJar = Get-ChildItem -Path build/libs -Filter "$modName-$modVersion.jar" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch 'sources|dev' } | Select-Object -First 1
    if ($origJar) {
        $versionedName = "$modName-$modVersion-$mc.jar"
        Copy-Item $origJar.FullName -Destination (Join-Path $libsAll $versionedName)
        Write-Host "  -> $versionedName" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "All builds succeeded. JARs in $libsAll" -ForegroundColor Green
Get-ChildItem $libsAll -Filter "*.jar" | ForEach-Object { Write-Host "  $($_.Name)" }
