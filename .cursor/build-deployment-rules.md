# Build & Deployment Rules - Compostables Mod

## Build System
- Use Gradle with Fabric toolchain
- Configuration centralized in `gradle.properties`
- PowerShell scripts in `/scripts/` directory for automation
- Always test builds before deployment

## PowerShell Scripts
- `build.ps1` - Main build script with optional server start
- `scripts/start-server.ps1` - Advanced server management
- `scripts/update-modrinth.ps1` - Update Modrinth project description
- `scripts/generate-web-icons.ps1` - Generate documentation icons

## Documentation Deployment
- Docusaurus site in `/docs/` directory
- Deploys to GitHub Pages via GitHub Actions
- Build with `npm run build` in docs directory
- Auto-deployment on release tags

## Version Management
- Update version in `gradle.properties`
- Create git tags for releases
- GitHub Actions handles automated publishing
- Update changelogs and documentation

## Environment Variables
- `MODRINTH_TOKEN` - For Modrinth API access
- `PROJECT_ID` - Modrinth project identifier
- Set in GitHub repository secrets for CI/CD

## Testing Workflow
1. Build mod: `./build.ps1`
2. Test locally: `./build.ps1 -StartServer`
3. Verify documentation: `cd docs && npm run start`
4. Run full build: `./gradlew build`
5. Create release tag for deployment

## File Patterns to Ignore
- `/build/` - Gradle build output
- `/run/` - Development server files
- `/test-server/` - Test server instance
- `node_modules/` - NPM dependencies
- `.gradle/` - Gradle cache

## Release Process
1. Update version in gradle.properties
2. Update documentation with new features
3. Build and test thoroughly
4. Create git tag with version
5. GitHub Actions handles the rest