package org.survivorsunited.mods.compostables;

import net.fabricmc.api.ModInitializer;
import net.minecraft.block.ComposterBlock;
import net.minecraft.item.Items;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Main mod class for Compostables
 * This mod extends the composting functionality by making more organic items compostable
 */
public class Compostables implements ModInitializer {
	public static final String MOD_ID = "compostables";
	public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

	@Override
	public void onInitialize() {
		LOGGER.info("Initializing Compostables mod!");
		
		// Register new compostable items
		registerCompostableItems();
		
		LOGGER.info("Compostables mod initialized! More organic items can now be composted.");
	}
	
	private void registerCompostableItems() {
		// 10% chance items (dried/minimal organic matter)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.DEAD_BUSH, 0.1f);
		
		// 20% chance items (low organic content)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.DIRT_PATH, 0.2f);
		
		// 30% chance items (basic soil/organic blocks + minimal organic content)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.GRASS_BLOCK, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ROOTED_DIRT, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUDDY_MANGROVE_ROOTS, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.TURTLE_EGG, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SNIFFER_EGG, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SCULK_VEIN, 0.3f);
		
		// 35% chance items (improved bamboo - composts well IRL)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BAMBOO, 0.35f);
		
		// 50% chance items (moderate organic content)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ROTTEN_FLESH, 0.5f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PODZOL, 0.5f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHORUS_FRUIT, 0.5f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHORUS_PLANT, 0.5f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.RABBIT_FOOT, 0.5f);
		
		// 65% chance items (rich organic matter + processed items)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SPIDER_EYE, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MYCELIUM, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CRIMSON_NYLIUM, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.WARPED_NYLIUM, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.POPPED_CHORUS_FRUIT, 0.65f); // Increased from 50% - processing adds value
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.EGG, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BEEF, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PORKCHOP, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHICKEN, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUTTON, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.RABBIT, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COD, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SALMON, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.TROPICAL_FISH, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PUFFERFISH, 0.65f);
		
		// 75% chance items (nutritious organic matter)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.POISONOUS_POTATO, 0.75f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUSHROOM_STEW, 0.75f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BEETROOT_SOUP, 0.75f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHORUS_FLOWER, 0.75f);
		
		// 85% chance items (processed/fermented/cooked organic matter)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.FERMENTED_SPIDER_EYE, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_BEEF, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_PORKCHOP, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_CHICKEN, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_MUTTON, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_RABBIT, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_COD, 0.85f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_SALMON, 0.85f);
		
		LOGGER.info("Registered {} new compostable items", 40);
	}
}