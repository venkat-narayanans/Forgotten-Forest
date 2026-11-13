--!strict
--[[
    WeaponDefinitions.lua
    Data catalog for all weapons and offensive tools in The Forgotten Forest (v2.0).
    Directly reflects Master Game Specification Section 6.1.
]]

local Types = require(script.Parent.Parent.Types.Types)

local WeaponDefinitions: { [string]: Types.WeaponDefinition } = {
    field_knife = {
        WeaponId = "field_knife",
        DisplayName = "Field Knife",
        Role = "Fast starter defence",
        BaseDamage = 12,
        Range = 5.0,
        Cooldown = 0.55,
        StaminaCost = 8,
        IsRanged = false,
        EffectiveAgainst = "Stalker",
        Special = "Fast, low stagger, cannot harvest trees or ore",
    },
    wooden_spear = {
        WeaponId = "wooden_spear",
        DisplayName = "Wooden Spear",
        Role = "Reach and control",
        BaseDamage = 18,
        Range = 9.0,
        Cooldown = 1.0,
        StaminaCost = 14,
        IsRanged = false,
        EffectiveAgainst = "Stalker",
        Special = "Longer reach; can interrupt basic creature attack; slower recovery",
    },
    hatchet = {
        WeaponId = "hatchet",
        DisplayName = "Forged Hatchet",
        Role = "Tool and weapon",
        BaseDamage = 20,
        Range = 6.0,
        Cooldown = 1.1,
        StaminaCost = 12,
        IsRanged = false,
        EffectiveAgainst = "Wood",
        Special = "Bonus vs wooden obstacles; primary wood-harvesting tool",
    },
    keeper_blade = {
        WeaponId = "keeper_blade",
        DisplayName = "Keeper Blade",
        Role = "Advanced melee",
        BaseDamage = 28,
        Range = 6.5,
        Cooldown = 0.8,
        StaminaCost = 16,
        IsRanged = false,
        EffectiveAgainst = "Supernatural",
        Special = "Higher stagger vs supernatural entities; resonates near Keeper mechanisms",
    },
    hunting_bow = {
        WeaponId = "hunting_bow",
        DisplayName = "Hunting Bow",
        Role = "Quiet ranged",
        BaseDamage = 22,
        Range = 120.0,
        Cooldown = 1.3,
        StaminaCost = 18,
        IsRanged = true,
        EffectiveAgainst = "Ranged",
        Special = "Quiet ranged option; projectile travel and gravity drop; requires arrows",
        ProjectileSpeed = 95.0,
        GravityMultiplier = 0.45,
        AmmoItemId = "arrow",
    },
    flare_launcher = {
        WeaponId = "flare_launcher",
        DisplayName = "Flare Launcher",
        Role = "Utility defence",
        BaseDamage = 5,
        Range = 85.0,
        Cooldown = 3.0,
        StaminaCost = 10,
        IsRanged = true,
        EffectiveAgainst = "Darkness",
        Special = "Illuminates dark areas and briefly disrupts selected creatures; cannot permanently stun bosses",
        ProjectileSpeed = 70.0,
        GravityMultiplier = 0.35,
        AmmoItemId = "signal_flare",
    },
    pickaxe = {
        WeaponId = "pickaxe",
        DisplayName = "Iron Pickaxe",
        Role = "Mining tool and blunt weapon",
        BaseDamage = 15,
        Range = 5.5,
        Cooldown = 1.05,
        StaminaCost = 12,
        IsRanged = false,
        EffectiveAgainst = "Stone",
        Special = "Primary stone, metal, and crystal harvesting tool",
    },
}

return WeaponDefinitions
