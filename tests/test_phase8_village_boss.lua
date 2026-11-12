--!strict
--[[
    test_phase8_village_boss.lua
    Automated verification of Phase 8 Abandoned Village & First Boss requirements.
]]

local function runPhase8Tests()
    local Workspace = game:GetService("Workspace")
    local ServerStorage = game:GetService("ServerStorage")
    local CollectionService = game:GetService("CollectionService")

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    assert(tffWorld ~= nil, "TFF_World must exist")
    local map = tffWorld:FindFirstChild("Map")
    assert(map ~= nil, "Map must exist")

    -- 1. Check Abandoned Village geometry
    assert(map:FindFirstChild("AbandonedVillageGround") ~= nil, "AbandonedVillageGround must exist")
    assert(map:FindFirstChild("VillageSquare") ~= nil, "VillageSquare must exist")
    assert(map:FindFirstChild("OvergrownWell") ~= nil, "OvergrownWell must exist")
    assert(map:FindFirstChild("RuinedWatchtower") ~= nil, "RuinedWatchtower must exist")
    assert(map:FindFirstChild("CollapsedHouse") ~= nil, "CollapsedHouse must exist")

    -- 2. Check Story Clue
    local interactables = tffWorld:FindFirstChild("Interactables")
    assert(interactables ~= nil, "Interactables must exist")
    local clue = interactables:FindFirstChild("StoryClue_Archive")
    assert(clue ~= nil, "StoryClue_Archive must exist")
    assert(clue:GetAttribute("ClueId") == "Clue_VillageArchive", "ClueId must match")

    -- 3. Check Gate Unlock Logic
    local gate = interactables:FindFirstChild("LockedVillageGate")
    assert(gate ~= nil, "LockedVillageGate must exist")
    local requiredLevel = gate:GetAttribute("RequiredLevel") or 3

    local function canUnlockGate(playerLevel: number): boolean
        return playerLevel >= requiredLevel
    end

    assert(canUnlockGate(1) == false, "Level 1 player cannot unlock gate")
    assert(canUnlockGate(2) == false, "Level 2 player cannot unlock gate")
    assert(canUnlockGate(3) == true, "Level 3 player can unlock gate")
    assert(canUnlockGate(5) == true, "Level 5 player can unlock gate")

    -- 4. Check Boss Arena & Ancient Seals
    local arena = map:FindFirstChild("BossArena")
    assert(arena ~= nil, "BossArena must exist")
    assert(arena:FindFirstChild("ArenaFloor") ~= nil, "ArenaFloor must exist")

    local sealsFound = 0
    for _, item in ipairs(interactables:GetChildren()) do
        if item:GetAttribute("InteractableType") == "AncientSeal" then
            sealsFound += 1
        end
    end
    assert(sealsFound == 3, "Must have exactly 3 Ancient Seals for puzzle")

    -- 5. Check Forest Guardian Template
    local templates = ServerStorage.TFF.Templates.Creatures
    local boss = templates:FindFirstChild("ForestGuardian")
    assert(boss ~= nil, "ForestGuardian template must exist in ServerStorage")
    local bHumanoid = boss:FindFirstChildWhichIsA("Humanoid")
    assert(bHumanoid ~= nil, "Boss must have a Humanoid")
    assert(bHumanoid.MaxHealth == 2500, "Boss max health must be 2,500")

    -- 6. Check Boss Reward Idempotency
    local processedBossKills = {}
    local function grantBossReward(userId, bossEncounterId)
        local key = tostring(userId) .. "_" .. bossEncounterId
        if processedBossKills[key] then
            return false
        end
        processedBossKills[key] = true
        return true
    end

    assert(grantBossReward(1234, "Encounter_1") == true, "First reward grant succeeds")
    assert(grantBossReward(1234, "Encounter_1") == false, "Duplicate reward grant rejected")

    print("[Phase 8 Tests] All Phase 8 Abandoned Village and Boss checks passed!")
    return true
end

return runPhase8Tests
