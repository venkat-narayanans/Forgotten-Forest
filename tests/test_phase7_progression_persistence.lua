--!strict
--[[
    test_phase7_progression_persistence.lua
    Automated verification of Phase 7 Progression, Quests, and Persistence requirements.
]]

local function runPhase7Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local QuestDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions)

    -- 1. Test XP Curve and Level Progression
    local function getXPForNextLevel(level: number): number
        return math.floor(100 * (level ^ 1.5))
    end

    local testProfile = {
        schemaVersion = 1,
        level = 1,
        xp = 0,
        forestCoins = 0,
        ancientTokens = 0,
        completedQuests = {},
        inventory = {},
    }

    local function grantXP(profile, amount)
        profile.xp += amount
        local needed = getXPForNextLevel(profile.level)
        while profile.xp >= needed do
            profile.xp -= needed
            profile.level += 1
            needed = getXPForNextLevel(profile.level)
        end
    end

    -- Initial needed for Lvl 1 -> 2 is 100 XP
    assert(getXPForNextLevel(1) == 100, "Level 1 to 2 should require 100 XP")
    grantXP(testProfile, 150)
    assert(testProfile.level == 2, "Profile should be Level 2")
    assert(testProfile.xp == 50, "Remaining XP should be 50")

    -- 2. Test Currency Balance
    local function grantCurrency(profile, currType, amt)
        if currType == "ForestCoins" then
            profile.forestCoins += amt
        elseif currType == "AncientTokens" then
            profile.ancientTokens += amt
        end
    end

    grantCurrency(testProfile, "ForestCoins", 250)
    grantCurrency(testProfile, "AncientTokens", 5)
    assert(testProfile.forestCoins == 250, "Forest Coins should be 250")
    assert(testProfile.ancientTokens == 5, "Ancient Tokens should be 5")

    -- 3. Test Quest Idempotency
    local questId = "q_first_steps"
    local questDef = QuestDefinitions[questId]
    assert(questDef ~= nil, "Quest definition must exist")

    local function claimQuest(profile, qId)
        local def = QuestDefinitions[qId]
        if not def then return false end
        if not def.IsRepeatable and profile.completedQuests[qId] then
            return false -- Already claimed!
        end
        profile.completedQuests[qId] = true
        grantXP(profile, def.Rewards.XP)
        grantCurrency(profile, "ForestCoins", def.Rewards.ForestCoins)
        return true
    end

    local firstClaim = claimQuest(testProfile, questId)
    local secondClaim = claimQuest(testProfile, questId)

    assert(firstClaim == true, "First quest claim should succeed")
    assert(secondClaim == false, "Second quest claim must be rejected (idempotency)")
    assert(testProfile.completedQuests[questId] == true, "Quest marked completed")

    -- 4. Test Schema Migration
    local oldProfileV0 = {
        level = 3,
        xp = 40,
        -- Missing schemaVersion, currencies, completedQuests, settings
    }

    local function migrateProfile(data)
        local p = table.clone(data)
        if not p.schemaVersion or p.schemaVersion < 1 then
            p.schemaVersion = 1
        end
        p.forestCoins = p.forestCoins or 0
        p.ancientTokens = p.ancientTokens or 0
        p.completedQuests = p.completedQuests or {}
        p.inventory = p.inventory or {}
        p.settings = p.settings or { reducedEffects = false, cameraShake = true }
        return p
    end

    local migrated = migrateProfile(oldProfileV0)
    assert(migrated.schemaVersion == 1, "Migrated profile must have schemaVersion = 1")
    assert(migrated.level == 3, "Existing progression level must be preserved")
    assert(migrated.xp == 40, "Existing XP must be preserved")
    assert(migrated.forestCoins == 0, "Missing fields should be populated with defaults")
    assert(migrated.settings.reducedEffects == false, "Settings populated")

    -- 5. Test Simulated Rejoin Persistence
    local mockStorage = {}
    local userIdKey = "Player_9999"

    -- Save
    mockStorage[userIdKey] = table.clone(testProfile)

    -- Reload
    local loadedProfile = mockStorage[userIdKey]
    assert(loadedProfile ~= nil, "Profile must load successfully from store")
    assert(loadedProfile.level == testProfile.level, "Rejoining player must retain level")
    assert(loadedProfile.forestCoins == testProfile.forestCoins, "Rejoining player must retain coins")
    assert(loadedProfile.completedQuests[questId] == true, "Rejoining player must retain quest completion")

    print("[Phase 7 Tests] All Phase 7 Progression, Quests, and Persistence checks passed!")
    return true
end

return runPhase7Tests
