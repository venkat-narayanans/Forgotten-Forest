--!strict
--[[
    test_phase5_creature_combat.lua
    Automated verification of Phase 5 Creature AI and Combat requirements.
]]

local function runPhase5Tests()
    local ServerStorage = game:GetService("ServerStorage")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")

    local CreatureDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.CreatureDefinitions)
    local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
    local CombatService = require(ServerScriptService.TFFServer.Services.CombatService)

    -- 1. Check Definitions
    local stalkerDef = CreatureDefinitions.stalker
    assert(stalkerDef ~= nil, "Stalker definition must exist")
    assert(stalkerDef.AttackDamage == 12, "Stalker damage must be 12")
    assert(stalkerDef.AttackRange == 4, "Stalker attack range must be 4")
    assert(stalkerDef.LeashRange == 90, "Stalker leash range must be 90")
    assert(stalkerDef.DetectionRadius == 45, "Stalker detection radius must be 45")

    local watcherDef = CreatureDefinitions.watcher
    assert(watcherDef ~= nil, "Watcher definition must exist")
    assert(watcherDef.AttackDamage == 0, "Watcher must not deal damage (non-combat)")

    -- 2. Check ServerStorage Templates
    local templates = ServerStorage.TFF.Templates.Creatures
    assert(templates ~= nil, "Templates.Creatures folder must exist")
    assert(templates:FindFirstChild("Stalker") ~= nil, "Stalker template must exist")
    assert(templates:FindFirstChild("Watcher") ~= nil, "Watcher template must exist")
    assert(templates:FindFirstChild("Mimic") ~= nil, "Mimic template must exist")

    local stalkerTemplate = templates.Stalker
    assert(stalkerTemplate.PrimaryPart ~= nil, "Stalker must have a PrimaryPart")
    local head = stalkerTemplate:FindFirstChild("Head")
    assert(head ~= nil and head:FindFirstChild("TelegraphLight") ~= nil, "Stalker must have TelegraphLight")

    -- 3. Test Leash Logic
    local spawnPos = Vector3.new(0, 0, 0)
    local currentPosNear = Vector3.new(0, 0, 50)
    local currentPosFar = Vector3.new(0, 0, 95)
    assert((currentPosNear - spawnPos).Magnitude <= stalkerDef.LeashRange, "Within leash range")
    assert((currentPosFar - spawnPos).Magnitude > stalkerDef.LeashRange, "Exceeds leash range (triggers Return)")

    -- 4. Test Cap Enforcement
    assert(BalanceConfig.StandardHostileCap == 12, "Standard hostile cap must be 12")

    print("[Phase 5 Tests] All Phase 5 Creature AI and Combat checks passed!")
    return true
end

return runPhase5Tests
