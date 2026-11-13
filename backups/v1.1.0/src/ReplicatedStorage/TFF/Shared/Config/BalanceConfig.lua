--!strict
--[[
    BalanceConfig.lua
    Central gameplay balance starting values.
]]

local BalanceConfig = {
    -- Multiplayer settings
    MaxPlayers = 12,
    TargetMinimumPlayers = 8,

    -- Player baseline attributes
    MaxHealth = 100,
    MaxStamina = 100,
    MaxWarmth = 100,
    MaxSanity = 100,

    -- Inventory
    DefaultInventorySlots = 20,

    -- Interaction
    DefaultInteractionRange = 10, -- in studs

    -- Death & Revive
    DownedDuration = 30, -- in seconds
    ReviveDuration = 4,   -- in seconds
    ReviveHealthRestored = 35,
    DeathResourceLossPercent = 20, -- 20% of eligible carried resources

    -- Economy & Currencies
    Currencies = {
        ForestCoins = "forestCoins",
        AncientTokens = "ancientTokens",
    },

    -- NPC Caps
    StandardHostileCap = 12,
    MaxSimultaneousMajorEvents = 1,
}

return BalanceConfig
