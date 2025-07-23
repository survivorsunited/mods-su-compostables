# Compostables Mod

[![Modrinth](https://img.shields.io/modrinth/dt/su-compostables?label=Modrinth&logo=modrinth&color=00AF5C)](https://modrinth.com/mod/su-compostables)
[![GitHub](https://img.shields.io/github/license/survivorsunited/mods-su-compostables?label=License)](https://github.com/survivorsunited/mods-su-compostables/blob/main/LICENSE)
[![Minecraft Version](https://img.shields.io/badge/Minecraft-1.21.5+-brightgreen)](https://www.minecraft.net/)
[![Fabric](https://img.shields.io/badge/Fabric-0.16.14+-blue)](https://fabricmc.net/)

A Minecraft Fabric mod that extends composting functionality by making 62 additional organic items compostable, including meat, dyes, stews, and other processed organic materials.

## 📖 Documentation

Visit our **[Wiki](https://survivorsunited.github.io/mods-su-compostables/docs/intro)** for:
- Complete mod features and item list
- Installation guides
- Gameplay information

## 🚀 Quick Start

### Building from Source

```powershell
# Build only
.\build.ps1

# Build and start test server
.\build.ps1 -StartServer

# Build and start test server with specific version
.\build.ps1 -StartServer -MinecraftVersion "1.21.6"
```

### Requirements
- Java 21+
- Windows (PowerShell scripts provided)
- Gradle (included via wrapper)

## 🛠️ Development

### Project Structure
```
mods-compostables/
├── src/main/java/          # Java source code
├── src/main/resources/     # Resources (mixins, fabric.mod.json)
├── docs/                   # Documentation site (Docusaurus)
├── scripts/                # Utility scripts
├── gradle.properties       # Mod configuration
└── build.gradle           # Build configuration
```

### Configuration

All mod properties are centralized in `gradle.properties`:
- Minecraft/Fabric versions
- Mod metadata (name, version, etc.)
- Dependencies

### Scripts

- **build.ps1** - Build mod and optionally start test server
  - Sets up Java 21 environment
  - Downloads MC server & Fabric loader
  - Creates configured test environment
  
- **scripts/start-server.ps1** - Advanced server launcher
  - Auto-detects Fabric server JAR
  - Optimized JVM flags (8G-32G RAM)
  - Automatic restart on crash

- **scripts/generate-web-icons.ps1** - Web icon generator (all-in-one)
  - Usage: `.\scripts\generate-web-icons.ps1 [-Force] [-UseImageMagick]`
  - Automatically installs dependencies (Node.js or ImageMagick)
  - Uses Node.js by default, falls back to ImageMagick
  - Creates all web icon formats and manifests
  
- **scripts/generate-web-icons.js** - Web icon generator (Node.js only)
  - Direct Node.js implementation using sharp
  - Called by PowerShell script automatically

- **scripts/update-modrinth.ps1/.sh** - Update Modrinth project description
  - Usage: `.\scripts\update-modrinth.ps1 -ModrinthToken "token" -ProjectId "id"`
  - Or set environment variables: `MODRINTH_TOKEN`, `PROJECT_ID`
  - Updates project description from docs/MODRINTH.md

## 📦 CI/CD

GitHub Actions automatically:
- Builds mod on every push/PR
- Runs tests
- Creates releases with changelogs (on tags)
- Updates Modrinth project description (on release)
- Publishes to Modrinth (on tags)
- Deploys documentation to GitHub Pages (on release)

### Modrinth Setup

When creating a new mod:

1. Create project on [Modrinth](https://modrinth.com)
2. Get your API token from Modrinth settings (User Settings → API Tokens)
3. Get your project ID from the project URL (e.g., `su-compostables`)
4. Add repository secrets in GitHub (Settings → Secrets and variables → Actions):
   - `MODRINTH_TOKEN` - Your API token (without "Bearer " prefix)
   - `PROJECT_ID` - Your project ID/slug
5. Edit `docs/MODRINTH.md` for project description
6. Create a release (tag) to auto-update description and publish

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Guidelines
- Follow existing code style
- Update documentation for features
- Add unit tests where applicable
- Test on both client and server

## 📄 License

Licensed under Apache-2.0 - see [LICENSE](LICENSE) file.

## 🔗 Links

- [Modrinth](https://modrinth.com/mod/su-compostables)
- [GitHub Issues](https://github.com/survivorsunited/mods-su-compostables/issues)
- [Wiki Documentation](https://survivorsunited.github.io/mods-su-compostables/docs/intro)

---

*Made with ❤️ by [SurvivorsUnited](https://github.com/survivorsunited)*