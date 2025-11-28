# Build Documentation

This document explains how to build the Compostables mod, test it locally, and manage releases.

## Quick Start

### Prerequisites

- **Java 21** or higher
- **Gradle** (or use the included Gradle wrapper)
- **PowerShell** (for Windows build scripts)

### Basic Build Commands

**Windows (Recommended):**
```powershell
# Build the mod
.\build.ps1

# Build and start test server
.\build.ps1 -StartServer

# Build and start test server with specific Minecraft version
.\build.ps1 -StartServer -MinecraftVersion "1.21.8"
```

**Linux/Mac:**
```bash
# Build the mod
./gradlew build

# Clean and build
./gradlew clean build
```

### Build Output

Built JAR files are located in `build/libs/` with the naming format:
```
{jar_name}-{mod_version}.jar
```

Example: `su-compostables-1.0.10.jar`

## Build Configuration

### gradle.properties

All mod properties are centralized in `gradle.properties`:

- **Minecraft Version**: `minecraft_version=1.21.5`
- **Mod Version**: `mod_version=1.0.10`
- **Fabric Versions**: Loader, API, Loom versions
- **Mod Metadata**: Name, description, author, etc.

To build for a different Minecraft version, update `gradle.properties`:
```properties
minecraft_version=1.21.8
yarn_mappings=1.21.8+build.1
fabric_loader_version=0.17.3
fabric_version=0.134.0+1.21.8
```

### Supported Minecraft Versions

The `build.ps1` script supports testing with these Minecraft versions:
- **1.21.5** (default)
- **1.21.6**
- **1.21.7**
- **1.21.8**
- **1.21.9**
- **1.21.10**

The mod is built for the version specified in `gradle.properties`, but you can test it on any supported version using the `-MinecraftVersion` parameter.

## Build Scripts

### build.ps1 (Windows)

The `build.ps1` script provides a convenient way to build and test the mod locally.

**Features:**
- Builds the mod using Gradle
- Optionally starts a test server with the mod installed
- Automatically downloads required server files
- Sets up Java 21 environment
- Copies built mod to test server

**Usage:**
```powershell
# Build only
.\build.ps1

# Build and start test server (default: 1.21.5)
.\build.ps1 -StartServer

# Build and start test server with specific version
.\build.ps1 -StartServer -MinecraftVersion "1.21.8"
```

**What it does:**
1. Sets up Java 21 environment
2. Builds the mod using `./gradlew build`
3. If `-StartServer` is specified:
   - Creates `test-server` directory if needed
   - Downloads Minecraft server JAR for specified version
   - Downloads Fabric server launcher
   - Downloads Fabric API
   - Copies built mod to `test-server/mods/`
   - Starts the server

**Server Download Maps:**

The script includes download maps for:
- **Minecraft Server JARs**: All supported versions
- **Fabric Loader**: All supported versions
- **Fabric API**: All supported versions

These are defined in `build.ps1` and can be updated when new versions are released.

### scripts/start-server.ps1

Advanced server launcher script with features:
- Auto-detects Fabric server JAR
- Optimized JVM flags (8G-32G RAM)
- Automatic restart on crash
- Log monitoring

**Usage:**
```powershell
cd test-server
..\scripts\start-server.ps1
```

## Local Testing

### Testing the Mod

1. **Build the mod:**
   ```powershell
   .\build.ps1
   ```

2. **Start test server:**
   ```powershell
   .\build.ps1 -StartServer -MinecraftVersion "1.21.8"
   ```

3. **Check server logs:**
   ```powershell
   Get-Content test-server/logs/latest.log -Tail 50
   ```

4. **Verify mod loaded:**
   Look for these messages in the logs:
   ```
   [main/INFO]: Initializing Compostables mod!
   [main/INFO]: Compostables mod initialized! More organic items can now be composted.
   ```

### Testing Block Item Composting

The mod includes `ComposterBlockMixin` to allow block items (carpets, wool, etc.) to be composted. To test:

1. Start the test server
2. Connect with a Minecraft client
3. Place a composter
4. Try composting a carpet or wool block
5. Verify it composts instead of placing as a block

## CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/build.yml` workflow:

1. **Build Job**: Builds the mod on every push/PR
2. **Docs Job**: Builds and deploys documentation
3. **Auto-Version Job**: Auto-increments patch version on main branch
4. **Release Job**: Creates GitHub release and publishes to Modrinth

### Release Process

The release process is automated:

1. **Push to main** triggers the workflow
2. **Auto-version job** increments `mod_version` in `gradle.properties`
3. **Version bump commit** is created and pushed
4. **Git tag** is created (e.g., `1.0.11`)
5. **Release job** builds the mod and creates GitHub release
6. **Modrinth publish** uploads the JAR to Modrinth

**Manual Release:**
If you need to create a release manually:
```powershell
# Update mod_version in gradle.properties
# Commit and push
git tag -a "1.0.11" -m "Release 1.0.11"
git push origin main --tags
```

## Troubleshooting

### Build Fails with Java Version Error

**Error**: `Minecraft 1.21.5 requires Java 21 but Gradle is using 17`

**Solution:**
- Ensure Java 21 is installed
- Set `JAVA_HOME` to Java 21 path
- Use `build.ps1` which automatically sets Java 21

### Server Won't Start

**Error**: Server fails to start or crashes

**Solution:**
- Check `test-server/logs/latest.log` for errors
- Verify mod JAR is in `test-server/mods/`
- Ensure Fabric API is present
- Check that Minecraft version matches mod build version
- Verify Java 21 is being used (check server startup logs)

### Mixin Errors

**Error**: Mixin application failed

**Solution:**
- Check mixin configuration in `compostables.mixins.json`
- Verify mixin class signatures match target methods
- Check server logs for specific mixin errors
- Ensure Fabric Loader version is compatible

### Mod Not Loading

**Error**: Mod doesn't appear in loaded mods list

**Solution:**
- Verify mod JAR is in `test-server/mods/`
- Check mod ID matches in `fabric.mod.json`
- Ensure Fabric API is installed
- Check server logs for initialization errors

## Advanced Usage

### Building Without Test Server

```powershell
# Just build
.\build.ps1
```

### Using Gradle Directly

```bash
# Build
./gradlew build

# Clean build
./gradlew clean build

# Build without tests
./gradlew build -x test
```

### Custom Build Properties

You can override properties:
```bash
./gradlew build -Pmod_version=1.1.0
```

### Building for Different Versions

To build for a different Minecraft version:

1. Update `gradle.properties`:
   ```properties
   minecraft_version=1.21.8
   yarn_mappings=1.21.8+build.1
   fabric_loader_version=0.17.3
   fabric_version=0.134.0+1.21.8
   ```

2. Build:
   ```powershell
   .\build.ps1
   ```

3. Test:
   ```powershell
   .\build.ps1 -StartServer -MinecraftVersion "1.21.8"
   ```

## Project Structure

```
mods-compostables/
├── src/main/java/          # Java source code
│   └── org/survivorsunited/mods/compostables/
│       ├── Compostables.java           # Main mod class
│       └── mixin/
│           ├── ComposterBlockMixin.java  # Block item composting fix
│           └── FarmerMixin.java          # Villager compatibility
├── src/main/resources/     # Resources (mixins, fabric.mod.json)
├── build/libs/            # Built JAR files
├── test-server/           # Local test server (created by build.ps1)
├── build.ps1              # Windows build script
├── gradle.properties      # Build configuration
└── build.gradle           # Gradle build script
```

## Related Files

- **gradle.properties**: Build configuration and mod metadata
- **build.gradle**: Gradle build script
- **build.ps1**: Windows build and test server script
- **scripts/start-server.ps1**: Advanced server launcher
- **.github/workflows/build.yml**: CI/CD pipeline
- **src/main/resources/compostables.mixins.json**: Mixin configuration

## Version Management

### Current Version

The mod version is defined in `gradle.properties`:
```properties
mod_version=1.0.10
```

### Version Bumping

The CI/CD pipeline automatically increments the patch version on each push to main:
- `1.0.10` → `1.0.11` → `1.0.12` etc.

For major or minor version bumps, manually update `gradle.properties` and commit.

### Version History

Version changes are tracked in:
- Git tags (e.g., `1.0.10`)
- GitHub releases
- `gradle.properties` commit history
