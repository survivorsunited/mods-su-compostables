# Minecraft Fabric Mod - Compostables
# Main Cursor AI Rules

## Project Overview
This is a Minecraft Fabric mod that extends composting functionality by adding 100 new compostable items. The mod includes organic materials like meat, dyes, stews, carpets, wool, bones, and other processed organic materials.

## Key Project Structure
- `src/main/java/org/survivorsunited/mods/compostables/` - Main mod code
- `docs/` - Docusaurus documentation website 
- `scripts/` - PowerShell build and deployment scripts
- `gradle.properties` - Centralized mod configuration

## Development Guidelines

### Java Code (Fabric Mod)
- Follow existing code style and patterns
- Use proper Minecraft item names (e.g., "Block of Bamboo" not "Bamboo Block")
- All composting chances should match the values in Compostables.java:
  - 30% = 0.3f, 50% = 0.5f, 65% = 0.65f, 85% = 0.85f, 100% = 1.0f
- Register items using ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put()
- Always log the total count of registered items

### Documentation
- Use proper Minecraft item names consistently across all files
- Bold mod items in tables to distinguish from vanilla items
- Include image sprites and wiki links for all items in tables
- Follow the exact table format from reference/composter.md (5 columns: 30%, 50%, 65%, 85%, 100%)
- Update both intro.md and modrinth.md when making changes

### File Naming Conventions
- Use kebab-case for documentation files
- Follow Minecraft naming conventions for items and blocks
- All documentation should reference the correct item count (100 total mod items)

### Build and Deployment
- Use PowerShell scripts in /scripts/ directory
- Configuration is centralized in gradle.properties
- Documentation deploys to GitHub Pages via GitHub Actions

## Important Item Names
- "Block of Bamboo" (not "Bamboo Block")
- All carpet items: "Color Carpet" (e.g., "White Carpet")
- All wool items: "Color Wool" (e.g., "White Wool") 
- All dye items: "Color Dye" (e.g., "White Dye")

## Testing
- Build using `./build.ps1`
- Test server can be started with `./build.ps1 -StartServer`
- Always test composting functionality for new items

## Documentation Updates
When updating mod items, ensure consistency across:
- Compostables.java (source of truth for percentages)
- docs/docs/intro.md (main documentation)
- docs/docs/modrinth.md (Modrinth project description)
- README.md (if needed)