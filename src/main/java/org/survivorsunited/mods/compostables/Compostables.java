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
		
		// 30% chance items (basic soil/organic blocks + minimal organic content + dyes)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.GRASS_BLOCK, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ROOTED_DIRT, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUDDY_MANGROVE_ROOTS, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.TURTLE_EGG, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SNIFFER_EGG, 0.3f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SCULK_VEIN, 0.3f);
		
		
		// 35% chance items (improved bamboo - composts well IRL)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BAMBOO, 0.35f);
		
		// 50% chance items (moderate organic content)
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
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BLUE_EGG, 0.65f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BROWN_EGG, 0.65f);
		
		// 75% chance items (nutritious organic matter)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.POISONOUS_POTATO, 0.75f);
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHORUS_FLOWER, 0.75f);
		
		// 100% chance items (pure organic matter - raw meat, processed/fermented foods, dyes)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BAMBOO_BLOCK, 1.0f); // 9 bamboo concentrated into 1 block
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ROTTEN_FLESH, 1.0f); // Pure organic meat (decomposed)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.FERMENTED_SPIDER_EYE, 1.0f); // Fermented = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUSHROOM_STEW, 1.0f); // Processed food from multiple ingredients
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BEETROOT_SOUP, 1.0f); // Processed food from multiple ingredients
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.RABBIT_STEW, 1.0f); // Processed food from multiple ingredients
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SUSPICIOUS_STEW, 1.0f); // Processed food from multiple ingredients
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BEEF, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PORKCHOP, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CHICKEN, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MUTTON, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.RABBIT, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COD, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.SALMON, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.TROPICAL_FISH, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PUFFERFISH, 1.0f); // Pure organic protein
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_BEEF, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_PORKCHOP, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_CHICKEN, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_MUTTON, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_RABBIT, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_COD, 1.0f); // Cooked = processed
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.COOKED_SALMON, 1.0f); // Cooked = processed
		
		// Dyes (processed/refined organic materials)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.WHITE_DYE, 1.0f); // From bonemeal or lily
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.ORANGE_DYE, 1.0f); // From orange tulip or red+yellow
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.MAGENTA_DYE, 1.0f); // From allium or crafted
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.LIGHT_BLUE_DYE, 1.0f); // From blue orchid or crafted
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.YELLOW_DYE, 1.0f); // From dandelion or sunflower
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.LIME_DYE, 1.0f); // From sea pickle or crafted
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PINK_DYE, 1.0f); // From pink tulip or crafted
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.GRAY_DYE, 1.0f); // From crafting
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.LIGHT_GRAY_DYE, 1.0f); // From azure bluet or crafted
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.CYAN_DYE, 1.0f); // From crafting
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.PURPLE_DYE, 1.0f); // From crafting
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BLUE_DYE, 1.0f); // From cornflower or lapis
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BROWN_DYE, 1.0f); // From cocoa beans
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.GREEN_DYE, 1.0f); // From cactus (smelted)
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.RED_DYE, 1.0f); // From poppy, rose bush, etc.
		ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.put(Items.BLACK_DYE, 1.0f); // From squid ink or wither rose
		
		LOGGER.info("Registered {} new compostable items", 62);
	}
}