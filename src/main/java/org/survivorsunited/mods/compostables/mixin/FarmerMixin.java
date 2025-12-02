package org.survivorsunited.mods.compostables.mixin;

import com.google.common.collect.ImmutableSet;
import net.minecraft.block.Block;
import net.minecraft.item.Item;
import net.minecraft.item.Items;
import net.minecraft.registry.entry.RegistryEntry;
import net.minecraft.sound.SoundEvent;
import net.minecraft.text.Text;
import net.minecraft.village.VillagerProfession;
import net.minecraft.world.poi.PointOfInterestType;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Mutable;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;

@Mixin(VillagerProfession.class)
public class FarmerMixin {
    @Shadow
    @Mutable
    private ImmutableSet<Item> gatherableItems;

    @Inject(method = "<init>", at = @At("RETURN"))
    private void modifyFarmerGatherables(Text name, Predicate<RegistryEntry<PointOfInterestType>> heldWorkstation, Predicate<RegistryEntry<PointOfInterestType>> acquirableWorkstation, ImmutableSet<Item> gatherableItems, ImmutableSet<Block> secondaryJobSites, SoundEvent workSound, CallbackInfo ci) {
        // Check if this is the farmer profession by checking the name
        if (name.getString().equals("Farmer")) {
            // Add compostable items to the farmer's gatherable items
            this.gatherableItems = ImmutableSet.<Item>builder()
                .addAll(gatherableItems)
                // Add portable compostable items
                .add(Items.DEAD_BUSH)
                .add(Items.BAMBOO)
                .add(Items.ROTTEN_FLESH)
                .add(Items.SPIDER_EYE)
                .add(Items.FERMENTED_SPIDER_EYE)
                .add(Items.POISONOUS_POTATO)
                .add(Items.MUSHROOM_STEW)
                .add(Items.BEETROOT_SOUP)
                .add(Items.RABBIT_STEW)
                .add(Items.SUSPICIOUS_STEW)
                .add(Items.CHORUS_FRUIT)
                .add(Items.POPPED_CHORUS_FRUIT)
                .add(Items.CHORUS_FLOWER)
                .add(Items.RABBIT_FOOT)
				.add(Items.EGG)
				// Blue and brown eggs were added in 1.21.5+
				// Use reflection to check if these items exist
				.addAll(getEggItemsIfAvailable())
                .add(Items.BEEF)
                .add(Items.PORKCHOP)
                .add(Items.CHICKEN)
                .add(Items.MUTTON)
                .add(Items.RABBIT)
                .add(Items.COD)
                .add(Items.SALMON)
                .add(Items.TROPICAL_FISH)
                .add(Items.PUFFERFISH)
                .add(Items.COOKED_BEEF)
                .add(Items.COOKED_PORKCHOP)
                .add(Items.COOKED_CHICKEN)
                .add(Items.COOKED_MUTTON)
                .add(Items.COOKED_RABBIT)
                .add(Items.COOKED_COD)
                .add(Items.COOKED_SALMON)
                // Dyes
                .add(Items.WHITE_DYE)
                .add(Items.ORANGE_DYE)
                .add(Items.MAGENTA_DYE)
                .add(Items.LIGHT_BLUE_DYE)
                .add(Items.YELLOW_DYE)
                .add(Items.LIME_DYE)
                .add(Items.PINK_DYE)
                .add(Items.GRAY_DYE)
                .add(Items.LIGHT_GRAY_DYE)
                .add(Items.CYAN_DYE)
                .add(Items.PURPLE_DYE)
                .add(Items.BLUE_DYE)
                .add(Items.BROWN_DYE)
                .add(Items.GREEN_DYE)
                .add(Items.RED_DYE)
                .add(Items.BLACK_DYE)
                .build();
        }
    }
    
    /**
     * Get blue and brown egg items if they exist in this Minecraft version.
     * These items were added in 1.21.5+, so we use reflection to check for them.
     */
    private ImmutableSet<Item> getEggItemsIfAvailable() {
        List<Item> eggItems = new ArrayList<>();
        addEggItemIfExists(eggItems, "BLUE_EGG");
        addEggItemIfExists(eggItems, "BROWN_EGG");
        return ImmutableSet.copyOf(eggItems);
    }
    
    /**
     * Add an egg item to the list if it exists in this Minecraft version.
     */
    private void addEggItemIfExists(List<Item> eggItems, String fieldName) {
        try {
            java.lang.reflect.Field field = Items.class.getField(fieldName);
            Item item = (Item) field.get(null);
            eggItems.add(item);
        } catch (NoSuchFieldException | IllegalAccessException e) {
            // Item doesn't exist in this version, skip it
        }
    }
}