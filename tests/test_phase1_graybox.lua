--!strict
--[[
    test_phase1_graybox.lua
    Automated verification of Phase 1 Graybox World & Player Foundation requirements.
]]

local function runPhase1Tests()
    local Workspace = game:GetService("Workspace")
    local CollectionService = game:GetService("CollectionService")

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    assert(tffWorld ~= nil, "Workspace.TFF_World must exist")

    -- 1. Check Safe Haven
    local map = tffWorld:FindFirstChild("Map")
    assert(map ~= nil, "TFF_World.Map must exist")
    assert(map:FindFirstChild("SafeHavenGround") ~= nil, "SafeHavenGround must exist")
    assert(map:FindFirstChild("Plaza") ~= nil, "Plaza must exist")

    -- 2. Check Spawns (adequate for 8-12 players)
    local spawns = tffWorld:FindFirstChild("SpawnLocations")
    assert(spawns ~= nil, "TFF_World.SpawnLocations must exist")
    assert(#spawns:GetChildren() >= 6, "Must have at least 6 spawn points in plaza")

    -- 3. Check Safe Zone enforcement
    local safeZones = tffWorld:FindFirstChild("SafeZones")
    assert(safeZones ~= nil, "TFF_World.SafeZones must exist")
    local safeZonePart = safeZones:FindFirstChild("SafeHavenSafeZone")
    assert(safeZonePart ~= nil, "SafeHavenSafeZone must exist")
    assert(safeZonePart:GetAttribute("Radius") ~= nil, "Safe zone must have Radius attribute")

    -- 4. Check Whispering Woods
    assert(map:FindFirstChild("TrailToWhisperingWoods") ~= nil, "TrailToWhisperingWoods must exist")
    assert(map:FindFirstChild("WhisperingWoodsGround") ~= nil, "WhisperingWoodsGround must exist")
    assert(map:FindFirstChild("FallenLogCrossing") ~= nil, "FallenLogCrossing must exist")
    assert(map:FindFirstChild("Creek") ~= nil, "Creek must exist")
    assert(map:FindFirstChild("MushroomClearing") ~= nil, "MushroomClearing must exist")
    assert(map:FindFirstChild("AbandonedCampsite") ~= nil, "AbandonedCampsite must exist")
    assert(map:FindFirstChild("OldStoneBridge") ~= nil, "OldStoneBridge must exist")

    -- 5. Check Resource Nodes
    local resourceNodes = tffWorld:FindFirstChild("ResourceNodes")
    assert(resourceNodes ~= nil, "TFF_World.ResourceNodes must exist")
    local taggedNodes = CollectionService:GetTagged("TFF_ResourceNode")
    assert(#taggedNodes >= 10, "Must have at least 10 tagged resource nodes")

    -- 6. Check Interactables
    local interactables = tffWorld:FindFirstChild("Interactables")
    assert(interactables ~= nil, "TFF_World.Interactables must exist")
    assert(interactables:FindFirstChild("Workbench") ~= nil, "Workbench must exist")
    assert(interactables:FindFirstChild("SharedStorageChest") ~= nil, "SharedStorageChest must exist")
    assert(interactables:FindFirstChild("QuestBoard") ~= nil, "QuestBoard must exist")
    assert(interactables:FindFirstChild("LockedVillageGate") ~= nil, "LockedVillageGate must exist")

    print("[Phase 1 Tests] All Phase 1 Graybox & Player Foundation checks passed!")
    return true
end

return runPhase1Tests
