---
sidebar_position: 4
---

# Technical Details

Information for server administrators and mod pack creators.

## Compatibility

### Minecraft Versions
- **Supported**: 1.21.5+
- **Tested**: 1.21.5, 1.21.6
- **Fabric Loader**: 0.16.14+
- **Fabric API**: Required

### Mod Compatibility
- Works with most Fabric mods
- No known conflicts with major mods
- Compatible with optimization mods (Sodium, Lithium, etc.)

## Performance

### Impact Analysis
- **Memory**: < 1MB additional
- **CPU**: Negligible (only during composting)
- **Network**: None (server-side only)

### Optimizations
- Efficient item registration
- No tick handlers or continuous processing
- Leverages vanilla composting system

## Configuration

Currently no configuration file - all values are hardcoded for consistency and balance.

### Future Configuration Options
- Toggle individual items
- Adjust composting chances
- Villager behavior settings

## Implementation Details

### Item Registration
Uses `ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE` map to register items:
```java
ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ROTTEN_FLESH, 0.5f);
```

### Villager Behavior
Mixin into `VillagerProfession` to add items to farmer gatherable list:
```java
@Mixin(net.minecraft.village.VillagerProfession.class)
public class FarmerMixin {
    // Adds new items to farmer's gatherable items
}
```

## For Mod Pack Creators

### Including Compostables
1. Add to your mod pack like any Fabric mod
2. No client-side installation needed
3. Works in multiplayer without client mods

### Balance Considerations
- Composting chances are balanced around vanilla rates
- Doesn't make bone meal too easy to obtain
- Preserves game progression

### Recipe Integration
- No new crafting recipes added
- Uses vanilla composter block
- Compatible with recipe mods

## Troubleshooting

### Common Issues

**Items not composting:**
- Verify mod is loaded (check logs)
- Ensure using composter block
- Check item is in supported list

**Villagers not collecting items:**
- Only farmers collect compostables
- Items must be dropped, not in containers
- Villagers need access to composters

**Server crashes:**
- Check Fabric API is installed
- Verify compatible Minecraft version
- Review crash logs for conflicts