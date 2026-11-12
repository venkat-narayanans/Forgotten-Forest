--!strict
--[[
    test_phase0_foundation.lua
    Automated verification of Phase 0 Foundation requirements.
]]

local function runPhase0Tests()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local StarterPlayer = game:GetService("StarterPlayer")
    local Workspace = game:GetService("Workspace")

    local tff = ReplicatedStorage:FindFirstChild("TFF")
    assert(tff ~= nil, "ReplicatedStorage.TFF must exist")

    local shared = tff:FindFirstChild("Shared")
    assert(shared ~= nil, "ReplicatedStorage.TFF.Shared must exist")

    -- Test Configs
    local BalanceConfig = require(shared.Config.BalanceConfig)
    assert(BalanceConfig.MaxPlayers == 12, "BalanceConfig.MaxPlayers should be 12")
    assert(BalanceConfig.MaxHealth == 100, "BalanceConfig.MaxHealth should be 100")

    local MovementConfig = require(shared.Config.MovementConfig)
    assert(MovementConfig.WalkSpeed == 16, "MovementConfig.WalkSpeed should be 16")
    assert(MovementConfig.SprintSpeed == 22, "MovementConfig.SprintSpeed should be 22")

    local CycleConfig = require(shared.Config.CycleConfig)
    assert(#CycleConfig.PhaseOrder == 5, "CycleConfig should have 5 phases")

    -- Test Definitions
    local ItemDefinitions = require(shared.Definitions.ItemDefinitions)
    assert(ItemDefinitions.wood ~= nil, "ItemDefinitions.wood must exist")
    assert(ItemDefinitions.torch ~= nil, "ItemDefinitions.torch must exist")

    local RecipeDefinitions = require(shared.Definitions.RecipeDefinitions)
    assert(RecipeDefinitions.torch ~= nil, "RecipeDefinitions.torch must exist")

    -- Test Services
    local tffServer = ServerScriptService:FindFirstChild("TFFServer")
    assert(tffServer ~= nil, "ServerScriptService.TFFServer must exist")
    local services = tffServer:FindFirstChild("Services")
    assert(services ~= nil, "ServerScriptService.TFFServer.Services must exist")

    local requiredServices = {
        "WorldService", "ProfileService", "PlayerService", "TimeCycleService",
        "SurvivalService", "InventoryService", "CraftingService", "ProgressionService",
        "RewardService", "ResourceService", "QuestService", "CombatService",
        "CreatureService", "EventService"
    }

    for _, sName in ipairs(requiredServices) do
        local mod = services:FindFirstChild(sName)
        assert(mod ~= nil, "Service missing: " .. sName)
        local loaded = require(mod)
        assert(typeof(loaded.Init) == "function", sName .. " must have Init function")
        assert(typeof(loaded.Start) == "function", sName .. " must have Start function")
    end

    -- Test Workspace hierarchy
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    assert(tffWorld ~= nil, "Workspace.TFF_World must exist")

    print("[Phase 0 Tests] All Phase 0 Foundation verification checks passed successfully!")
    return true
end

return runPhase0Tests
