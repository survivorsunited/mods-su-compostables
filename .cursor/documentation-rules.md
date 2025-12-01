# Documentation Rules - Compostables Mod

## General Principles
- Maintain consistency across all documentation files
- Use proper Minecraft item names (official wiki names)
- Bold all mod items to distinguish from vanilla items
- Keep item counts accurate (100 total mod items)

## Table Formatting
- Follow the exact 5-column format: 30%, 50%, 65%, 85%, 100%
- Use proper markdown table syntax
- Include image sprites and wiki links for all items
- Format: `[![](image-url)](wiki-link "Title")[Item Name](wiki-link "Title")`

## Item Name Standards
- "Block of Bamboo" (not "Bamboo Block")
- Use proper capitalization
- Follow official Minecraft wiki naming
- Be consistent across all files

## Files to Update Together
When making item changes, update:
1. `docs/docs/intro.md` - Main documentation
2. `docs/docs/modrinth.md` - Modrinth description  
3. `README.md` - If item counts change
4. Any reference tables

## Image Links
- Use minecraft.wiki image sprites
- Format: `https://minecraft.wiki/images/[Type]Sprite_[item-name].png?[hash]`
- Types: ItemSprite, BlockSprite, Invicon
- Always include alt text and titles

## Wiki Links
- Link to official Minecraft wiki pages
- Format: `https://minecraft.wiki/w/[Item_Name]`
- Use proper page names (spaces become underscores)
- Include title attributes for accessibility

## Markdown Best Practices
- Use proper heading hierarchy
- Include emoji icons for sections (🌱, ✨, 📦, etc.)
- Use code blocks for commands and file paths
- Keep line lengths reasonable for readability