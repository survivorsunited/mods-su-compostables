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

import java.util.function.Predicate;

@Mixin(VillagerProfession.class)
public class FarmerMixin {
    @Shadow
    @Mutable
    private ImmutableSet<Item> gatherableItems;

    @Inject(method = "<init>", at = @At("RETURN"))
    private void modifyFarmerGatherables(Text name, Predicate<RegistryEntry<PointOfInterestType>> heldWorkstation, Predicate<RegistryEntry<PointOfInterestType>> acquirableWorkstation, ImmutableSet<Item> gatherableItems, ImmutableSet<Block> secondaryJobSites, SoundEvent workSound, CallbackInfo ci) {
        // Check if this is the farmer profession by checking the name
        if (name.getString().equals("entity.minecraft.villager.farmer")) {
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
                .add(Items.CHORUS_FRUIT)
                .add(Items.POPPED_CHORUS_FRUIT)
                .add(Items.CHORUS_FLOWER)
                .add(Items.RABBIT_FOOT)
                .add(Items.EGG)
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
                .build();
        }
    }
}