package org.survivorsunited.mods.compostables.mixin;

import net.minecraft.block.BlockState;
import net.minecraft.block.ComposterBlock;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.BlockItem;
import net.minecraft.item.Item;
import net.minecraft.item.ItemStack;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Hand;
import net.minecraft.util.hit.BlockHitResult;
import net.minecraft.util.math.BlockPos;
import net.minecraft.world.World;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

/**
 * Mixin to allow block items to be composted instead of placed
 * This fixes the issue where block items (like carpets, wool, grass blocks, etc.)
 * cannot be placed into composters because Minecraft tries to place them as blocks
 * instead of composting them
 */
@Mixin(ComposterBlock.class)
public class ComposterBlockMixin {
	
	/**
	 * Intercepts the onUse method to allow block items to be composted
	 * When a player tries to use a block item on a composter, this mixin
	 * checks if the item is registered as compostable and manually
	 * triggers the composting logic, preventing block placement
	 */
	@Inject(
		method = "onUse",
		at = @At("HEAD"),
		cancellable = true
	)
	private void allowBlockItemComposting(
		BlockState state,
		World world,
		BlockPos pos,
		PlayerEntity player,
		Hand hand,
		BlockHitResult hit,
		CallbackInfoReturnable<ActionResult> cir
	) {
		ItemStack stack = player.getStackInHand(hand);
		Item item = stack.getItem();
		
		// Check if the item is a block item (can be placed as a block)
		// Block items include: carpets, wool, grass blocks, etc.
		if (item instanceof BlockItem) {
			// Check if the item is registered in the composter's compostable items map
			// Use getFloatOrDefault to avoid deprecated get() method
			float compostChance = ComposterBlock.ITEM_TO_LEVEL_INCREASE_CHANCE.getFloat(item);
			if (compostChance > 0.0f) {
				// The item is registered as compostable
				// Get the current composter level from the block state
				int currentLevel = state.get(ComposterBlock.LEVEL);
				
				// Check if the composter is not full (level < 7)
				if (currentLevel < 7) {
					// Check if the composting succeeds based on the chance
					if (world.getRandom().nextFloat() < compostChance) {
						// Successfully composted - increment the level
						BlockState newState = state.with(ComposterBlock.LEVEL, currentLevel + 1);
						world.setBlockState(pos, newState, 3);
						
						// Play the composting sound
						world.playSound(null, pos, newState.getSoundGroup().getPlaceSound(), 
							net.minecraft.sound.SoundCategory.BLOCKS, 1.0f, 1.0f);
						
						// Consume the item if not in creative mode
						if (!player.getAbilities().creativeMode) {
							stack.decrement(1);
						}
						
						// Check if the composter is now full and ready to produce bone meal
						if (newState.get(ComposterBlock.LEVEL) == 7) {
							// Schedule a block tick to process the composter
							world.scheduleBlockTick(pos, state.getBlock(), 20);
						}
						
						cir.setReturnValue(ActionResult.SUCCESS);
					} else {
						// Composting failed - item is not consumed in vanilla behavior
						// Play a fail sound to indicate the attempt
						world.playSound(null, pos, state.getSoundGroup().getPlaceSound(), 
							net.minecraft.sound.SoundCategory.BLOCKS, 0.3f, 0.5f);
						
						// Don't consume the item on failure (vanilla behavior)
						// Return SUCCESS to prevent block placement
						cir.setReturnValue(ActionResult.SUCCESS);
					}
				}
			}
		}
	}
}

