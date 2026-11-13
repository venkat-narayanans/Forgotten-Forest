--!strict
--[[
    Types.lua
    Core type definitions for The Forgotten Forest.
]]

export type TimePhase = "Morning" | "Afternoon" | "Sunset" | "Night" | "Dawn"

export type PlayerStats = {
    Health: number,
    MaxHealth: number,
    Stamina: number,
    MaxStamina: number,
    Warmth: number,
    MaxWarmth: number,
    Sanity: number,
    MaxSanity: number,
    IsSprinting: boolean,
    IsDowned: boolean,
    DownedTimer: number,
}

export type InventoryItem = {
    ItemId: string,
    Quantity: number,
    CustomData: { [string]: any }?,
}

export type ItemDefinition = {
    ItemId: string,
    DisplayName: string,
    Description: string,
    Category: "Resource" | "Consumable" | "Tool" | "Equipment" | "Structure" | "Quest",
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic",
    StackLimit: number,
    IsQuestProtected: boolean,
    IsTradeable: boolean,
    IconAsset: string?,
}

export type RecipeIngredient = {
    ItemId: string,
    Quantity: number,
}

export type RecipeDefinition = {
    RecipeId: string,
    DisplayName: string,
    Description: string,
    OutputItemId: string,
    OutputQuantity: number,
    Ingredients: { RecipeIngredient },
    StationRequired: string?,
    CraftDuration: number,
    UnlockLevel: number?,
}

export type PlayerProfile = {
    schemaVersion: number,
    level: number,
    xp: number,
    forestCoins: number,
    ancientTokens: number,
    inventory: { InventoryItem },
    equipment: { [string]: string },
    unlockedRecipes: { [string]: boolean },
    completedQuests: { [string]: boolean },
    activeQuests: { [string]: any },
    achievements: { [string]: boolean },
    discoveries: { [string]: boolean },
    cosmetics: { [string]: boolean },
    settings: {
        reducedEffects: boolean,
        cameraShake: boolean,
    },
    lastSaveUnix: number,
}

export type CreatureState =
    | "Dormant"
    | "Idle"
    | "Patrol"
    | "Investigate"
    | "Chase"
    | "Windup"
    | "Attack"
    | "Recover"
    | "Stagger"
    | "Return"
    | "Despawn"

export type WeaponDefinition = {
    WeaponId: string,
    DisplayName: string,
    Role: string,
    BaseDamage: number,
    Range: number,
    Cooldown: number,
    StaminaCost: number,
    IsRanged: boolean,
    EffectiveAgainst: string?,
    Special: string,
    ProjectileSpeed: number?,
    GravityMultiplier: number?,
    AmmoItemId: string?,
}

export type CreatureDefinition = {
    Id: string,
    DisplayName: string,
    MaxHealth: number,
    ChaseSpeed: number,
    PatrolSpeed: number,
    DetectionRadius: number,
    AttackRange: number,
    AttackDamage: number,
    AttackCooldown: number,
    WindupDuration: number,
    LeashRange: number,
    States: { CreatureState },
}

return {}
