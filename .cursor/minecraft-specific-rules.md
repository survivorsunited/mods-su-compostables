# Minecraft-Specific Rules - Compostables Mod

## Mod Development Guidelines

### Fabric Mod Structure
- Main class: `Compostables.java` implements `ModInitializer`
- Register items in `onInitialize()` method
- Use proper Fabric API patterns
- Follow Minecraft's item registration system

### Item Registration
- Use `ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put()`
- Register during mod initialization only
- Items must exist in the game before registration
- Always verify registration success

### Composting System
- Vanilla composting uses 7 levels (0-7)
- Each successful compost increases level by 1
- Full composter (level 7) produces bone meal
- Farmer villagers can use registered items

### Item Categories by Composting Chance

#### 30% (Basic organic blocks)
- Soil blocks, minimal organic content
- Examples: Dead Bush, Dirt Path, Grass Block

#### 50% (Moderate organic content) 
- Plant matter, some processed items
- Examples: Bamboo, Chorus Fruit, Podzol

#### 65% (Rich organic matter)
- Processed foods, rich organic materials
- Examples: Spider Eye, Eggs, Mycelium

#### 85% (Nutritious organic matter)
- High-value organic materials
- Examples: Poisonous Potato, Chorus Flower

#### 100% (Pure organic matter)
- Meat, processed foods, dyes, textiles
- Examples: All meat, fish, stews, dyes, carpets, wool

### Farmer Villager Compatibility
- Farmers pick up portable organic items only
- Cannot pick up blocks (must be manually composted)
- Will automatically use items if they're registered
- Check villager AI behavior for new items

### Testing Requirements
- Test all items in creative and survival mode
- Verify composting success rates match percentages
- Test farmer villager behavior
- Ensure no conflicts with other mods

### Version Compatibility
- Target Minecraft 1.21.5+
- Use Fabric Loader 0.16.14+
- Require Fabric API
- Test across different Minecraft versions