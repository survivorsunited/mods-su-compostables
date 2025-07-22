package org.survivorsunited.mods.compostables.mixin;

import com.google.common.collect.ImmutableSet;

import net.minecraft.item.Item;
import net.minecraft.item.Items;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.ModifyArgs;
import org.spongepowered.asm.mixin.injection.invoke.arg.Args;

@Mixin(net.minecraft.village.VillagerProfession.class)
public class FarmerMixin {
    @ModifyArgs(method = "<clinit>",
            at = @At(value = "INVOKE", target = "Lnet/minecraft/village/VillagerProfession;register(Ljava/lang/String;Lnet/minecraft/registry/RegistryKey;Lcom/google/common/collect/ImmutableSet;Lcom/google/common/collect/ImmutableSet;Lnet/minecraft/sound/SoundEvent;)Lnet/minecraft/village/VillagerProfession;"))
    private static void ModifyFarmerGatherables(Args args)
    {
        if(!args.get(0).equals("farmer"))
            return;

        ImmutableSet<Item> defItemSet = args.get(2);
        ImmutableSet<Item> newSet = ImmutableSet.<Item>builder()
                .addAll(defItemSet)
                // Portable items only (farmers can't carry blocks)
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

        args.set(2, newSet);
    }
}