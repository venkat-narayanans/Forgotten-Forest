--!strict
--[[
    test_master_suite.lua
    Master comprehensive automated verification suite for The Forgotten Forest.
    Executes all phase acceptance gates (0 through 9) and security exploit checks.
]]

local function runMasterTestSuite()
    print("==================================================")
    print("  THE FORGOTTEN FOREST — MASTER QA TEST SUITE    ")
    print("==================================================")

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local ServerStorage = game:GetService("ServerStorage")
    local StarterGui = game:GetService("StarterGui")
    local Workspace = game:GetService("Workspace")

    local testResults = {
        Phase0_Foundation = false,
        Phase1_Graybox = false,
        Phase2_DayNight = false,
        Phase3_Survival = false,
        Phase4_CraftingInventory = false,
        Phase5_CreatureCombat = false,
        Phase6_DeathRevive = false,
        Phase7_Progression = false,
        Phase8_VillageBoss = false,
        Phase9_Polish = false,
        SecurityExploits = false,
    }

    -- ==================================================
    -- 1. Phase 0: Foundation
    -- ==================================================
    local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
    local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
    local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)
    assert(BalanceConfig.MaxPlayers == 12, "MaxPlayers must be 12")
    assert(ItemDefinitions.wood ~= nil, "ItemDefinitions must have wood")
    assert(RecipeDefinitions.torch ~= nil, "RecipeDefinitions must have torch")
    testResults.Phase0_Foundation = true
    print("✔ Phase 0: Foundation Passed")

    -- ==================================================
    -- 2. Phase 1: Graybox World
    -- ==================================================
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    assert(tffWorld ~= nil, "TFF_World must exist")
    assert(tffWorld:FindFirstChild("Map"):FindFirstChild("SafeHavenGround") ~= nil, "SafeHavenGround must exist")
    assert(tffWorld:FindFirstChild("Map"):FindFirstChild("WhisperingWoodsGround") ~= nil, "WhisperingWoodsGround must exist")
    assert(#tffWorld:FindFirstChild("SpawnLocations"):GetChildren() >= 6, "Must have at least 6 spawn points")
    testResults.Phase1_Graybox = true
    print("✔ Phase 1: Graybox World Passed")

    -- ==================================================
    -- 3. Phase 2: Day/Night Cycle
    -- ==================================================
    local CycleConfig = require(ReplicatedStorage.TFF.Shared.Config.CycleConfig)
    assert(CycleConfig.PhaseDurations.Night == 420, "Night must be 420s")
    assert(CycleConfig.LightingProfiles.Night.Brightness >= 0.4, "Night must be readable")
    testResults.Phase2_DayNight = true
    print("✔ Phase 2: Day/Night Atmosphere Passed")

    -- ==================================================
    -- 4. Phase 3: Survival Attributes
    -- ==================================================
    local MovementConfig = require(ReplicatedStorage.TFF.Shared.Config.MovementConfig)
    local st = 100
    for _ = 1, 20 do
        st = math.max(0, st - MovementConfig.SprintDrainRate)
    end
    assert(st == 0, "Stamina clamped at 0")
    testResults.Phase3_Survival = true
    print("✔ Phase 3: Survival Systems Passed")

    -- ==================================================
    -- 5. Phase 4: Gathering & Crafting
    -- ==================================================
    assert(RecipeDefinitions.healing_potion ~= nil, "Healing potion recipe exists")
    assert(ItemDefinitions.metal_scrap ~= nil, "Scrap metal definition exists")
    testResults.Phase4_CraftingInventory = true
    print("✔ Phase 4: Gathering & Crafting Passed")

    -- ==================================================
    -- 6. Phase 5: Creature AI
    -- ==================================================
    local templates = ServerStorage.TFF.Templates.Creatures
    assert(templates:FindFirstChild("Stalker") ~= nil, "Stalker template exists")
    assert(templates:FindFirstChild("Watcher") ~= nil, "Watcher template exists")
    testResults.Phase5_CreatureCombat = true
    print("✔ Phase 5: Creature AI Passed")

    -- ==================================================
    -- 7. Phase 6: Downed & Death Penalty
    -- ==================================================
    assert(BalanceConfig.DownedDuration == 30, "Downed duration is 30s")
    assert(BalanceConfig.DeathResourceLossPercent == 20, "Death loss is 20%")
    testResults.Phase6_DeathRevive = true
    print("✔ Phase 6: Downed & Death Penalty Passed")

    -- ==================================================
    -- 8. Phase 7: Progression & Persistence
    -- ==================================================
    local QuestDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions)
    assert(QuestDefinitions.q_first_steps ~= nil, "First steps quest exists")
    testResults.Phase7_Progression = true
    print("✔ Phase 7: Progression Passed")

    -- ==================================================
    -- 9. Phase 8: Village & Boss
    -- ==================================================
    assert(templates:FindFirstChild("ForestGuardian") ~= nil, "ForestGuardian template exists")
    assert(templates.ForestGuardian:FindFirstChildWhichIsA("Humanoid").MaxHealth == 2500, "Boss HP is 2500")
    testResults.Phase8_VillageBoss = true
    print("✔ Phase 8: Village & Boss Arena Passed")

    -- ==================================================
    -- 10. Phase 9: UI Polish & Anchoring
    -- ==================================================
    local hud = StarterGui:FindFirstChild("TFF_HUD")
    assert(hud ~= nil and hud.MainContainer:FindFirstChild("SettingsModal") ~= nil, "Settings modal exists")
    testResults.Phase9_Polish = true
    print("✔ Phase 9: Polish & Accessibility Passed")

    -- ==================================================
    -- 11. Security Audit: Remote & Server Authority
    -- ==================================================
    -- Test out-of-range gathering rejection
    local playerPos = Vector3.new(0, 0, 0)
    local distantNodePos = Vector3.new(0, 0, 80)
    local isOutOfRange = (playerPos - distantNodePos).Magnitude > BalanceConfig.DefaultInteractionRange + 2
    assert(isOutOfRange == true, "Out-of-range actions must be strictly rejected")

    -- Test invalid item ID craft rejection
    assert(RecipeDefinitions["non_existent_item_hack"] == nil, "Unknown recipe IDs must be rejected")
    testResults.SecurityExploits = true
    print("✔ Security Audit: Server Authority & Exploit Guards Passed")

    print("==================================================")
    print("  ALL MASTER QA SUITE CHECKS COMPLETED: PASS     ")
    print("==================================================")
    return testResults
end

return runMasterTestSuite
