# Java Development Rules - Minecraft Fabric Mod

## Code Style
- Use proper indentation (tabs as shown in existing code)
- Follow existing naming conventions
- Add meaningful comments for complex logic
- Use proper Java logging with LOGGER.info()

## Minecraft Fabric Specific
- Always use Items.ITEM_NAME constants for item references
- Register compostable items in registerCompostableItems() method
- Use proper float values for composting chances (0.3f, 0.5f, 0.65f, 0.85f, 1.0f)
- Log the total count of registered items at the end

## Item Registration Pattern
```java
// Category comment
ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ITEM_NAME, percentage);
```

## Composting Percentages
- 30% (0.3f): Basic soil/organic blocks, minimal organic content
- 50% (0.5f): Moderate organic content, some processed items
- 65% (0.65f): Rich organic matter, processed foods
- 85% (0.85f): Nutritious organic matter, rare items  
- 100% (1.0f): Pure organic matter, meat, processed foods, dyes

## Error Handling
- Always check if items exist before registering
- Use proper exception handling for mod initialization
- Log errors appropriately with LOGGER.error()

## Testing
- Ensure all registered items can actually be composted in-game
- Test with farmer villagers for item pickup behavior
- Verify composting chances match expected percentages