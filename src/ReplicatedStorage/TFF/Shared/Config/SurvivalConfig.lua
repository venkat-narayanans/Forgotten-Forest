--!strict
--[[
    SurvivalConfig.lua
    Configuration for Health, Stamina, Warmth, and Sanity survival dynamics.
]]

local SurvivalConfig = {
    MaxHealth = 100,
    MaxStamina = 100,
    MaxWarmth = 100,
    MaxSanity = 100,

    -- Sanity thresholds (atmospheric triggers)
    SanityThresholds = {
        SubtleWhispers = 70,
        Silhouettes = 45,
        Distortions = 20,
        Disorientation = 0,
    },

    -- Warmth
    WarmthDecayColdZone = 2.0,    -- points per second in cold environments
    WarmthRecoveryNearFire = 5.0,  -- points per second near active campfire

    -- Passive health recovery in Safe Haven
    SafeHavenHealthRegen = 2.0,   -- points per second
    SafeHavenSanityRegen = 3.0,   -- points per second
}

return SurvivalConfig
