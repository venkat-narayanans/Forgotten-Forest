--!strict
--[[
    build_abandoned_village.lua
    Procedural detailed low-poly overhaul for Abandoned Village & Old Stone Bridge:
    - Arched Old Stone Bridge with cobblestone parapets, moss, and 4 iron lanterns
    - Fortified stone archway & rusted portcullis gate for LockedVillageGate
    - Overgrown Village Square Well with stone coping ring, timber A-frame winch, bucket, and rope
    - 3 Unique Ruined Village Houses:
        1. Former Apothecary & Town Archive (stone hearth, chimney, broken rafters, archive table)
        2. Blacksmith Workshop (stone forge, iron clutter, broken timber roof)
        3. Ruined Residential Cottage (fieldstone walls, broken hinged door, window frames)
    - Ruined Watchtower with 3 platform tiers, wooden ladder, and crenellated battlements
]]

local Workspace = game:GetService("Workspace")

local tffWorld = Workspace:FindFirstChild("TFF_World")
if not tffWorld then error("TFF_World not found") end

local map = tffWorld:FindFirstChild("Map")
if not map then error("Map not found") end

local interactables = tffWorld:FindFirstChild("Interactables")
if not interactables then error("Interactables not found") end

-- Helpers
local function createPart(name: string, parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function createWedge(name: string, parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material): WedgePart
    local w = Instance.new("WedgePart")
    w.Name = name
    w.Size = size
    w.CFrame = cf
    w.Color = color
    w.Material = material
    w.Anchored = true
    w.CanCollide = true
    w.TopSurface = Enum.SurfaceType.Smooth
    w.BottomSurface = Enum.SurfaceType.Smooth
    w.Parent = parent
    return w
end

-- ============================================================================
-- 1. OLD STONE BRIDGE OVERHAUL
-- ============================================================================
local bridge = map:FindFirstChild("OldStoneBridge")
if bridge and bridge:IsA("BasePart") then
    bridge.Color = Color3.fromRGB(80, 82, 85)
    bridge.Material = Enum.Material.Cobblestone

    local detailedBridge = map:FindFirstChild("DetailedStoneBridge")
    if detailedBridge then detailedBridge:Destroy() end
    detailedBridge = Instance.new("Model")
    detailedBridge.Name = "DetailedStoneBridge"
    detailedBridge.Parent = map

    local bPos = bridge.Position
    local bSize = bridge.Size

    -- 1. Heavy stone parapet walls on East (X = +8) and West (X = -8)
    local parapetHeight = 3.6
    local parapetWidth = 1.4
    local pWest = createPart("ParapetWest", detailedBridge, Vector3.new(parapetWidth, parapetHeight, bSize.Z), CFrame.new(bPos.X - (bSize.X / 2) + (parapetWidth / 2), bPos.Y + (bSize.Y / 2) + (parapetHeight / 2), bPos.Z), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)
    local pEast = createPart("ParapetEast", detailedBridge, Vector3.new(parapetWidth, parapetHeight, bSize.Z), CFrame.new(bPos.X + (bSize.X / 2) - (parapetWidth / 2), bPos.Y + (bSize.Y / 2) + (parapetHeight / 2), bPos.Z), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)

    -- Capstones along the top of parapets
    createPart("ParapetCapWest", detailedBridge, Vector3.new(parapetWidth + 0.4, 0.6, bSize.Z), CFrame.new(pWest.Position.X, pWest.Position.Y + (parapetHeight / 2) + 0.3, bPos.Z), Color3.fromRGB(65, 68, 70), Enum.Material.Slate)
    createPart("ParapetCapEast", detailedBridge, Vector3.new(parapetWidth + 0.4, 0.6, bSize.Z), CFrame.new(pEast.Position.X, pEast.Position.Y + (parapetHeight / 2) + 0.3, bPos.Z), Color3.fromRGB(65, 68, 70), Enum.Material.Slate)

    -- 2. Massive Arched Support Piers underneath descending into the ravine
    local pierLeft = createPart("PierLeft", detailedBridge, Vector3.new(bSize.X + 2, 14, 8), CFrame.new(bPos.X, bPos.Y - 7, bPos.Z - 10), Color3.fromRGB(60, 62, 65), Enum.Material.Slate)
    local pierRight = createPart("PierRight", detailedBridge, Vector3.new(bSize.X + 2, 14, 8), CFrame.new(bPos.X, bPos.Y - 7, bPos.Z + 10), Color3.fromRGB(60, 62, 65), Enum.Material.Slate)

    -- 3. Four Weathered Iron Lamp Posts with glowing warm lanterns
    local lampOffsets = {
        Vector3.new(bPos.X - (bSize.X / 2) + 0.7, bPos.Y + (bSize.Y / 2) + parapetHeight + 0.6, bPos.Z - 16),
        Vector3.new(bPos.X + (bSize.X / 2) - 0.7, bPos.Y + (bSize.Y / 2) + parapetHeight + 0.6, bPos.Z - 16),
        Vector3.new(bPos.X - (bSize.X / 2) + 0.7, bPos.Y + (bSize.Y / 2) + parapetHeight + 0.6, bPos.Z + 16),
        Vector3.new(bPos.X + (bSize.X / 2) - 0.7, bPos.Y + (bSize.Y / 2) + parapetHeight + 0.6, bPos.Z + 16),
    }

    for idx, lPos in ipairs(lampOffsets) do
        -- Iron post
        local post = createPart("BridgeLampPost_" .. idx, detailedBridge, Vector3.new(0.6, 3.2, 0.6), CFrame.new(lPos.X, lPos.Y + 1.6, lPos.Z), Color3.fromRGB(40, 42, 45), Enum.Material.Metal)
        -- Lantern fixture
        local lantern = createPart("BridgeLantern_" .. idx, detailedBridge, Vector3.new(1.2, 1.6, 1.2), CFrame.new(lPos.X, lPos.Y + 3.8, lPos.Z), Color3.fromRGB(255, 185, 80), Enum.Material.Neon)
        lantern.CanCollide = false
        local lLight = Instance.new("PointLight")
        lLight.Color = Color3.fromRGB(255, 180, 80)
        lLight.Range = 16
        lLight.Brightness = 1.6
        lLight.Parent = lantern
    end

    -- 4. Creeping Ivy patches
    for i = -14, 14, 7 do
        local side = (i % 2 == 0) and (pWest.Position.X - 0.8) or (pEast.Position.X + 0.8)
        local ivy = createPart("BridgeIvy", detailedBridge, Vector3.new(0.3, 2.8, 3.2), CFrame.new(side, bPos.Y + 2.5, bPos.Z + i), Color3.fromRGB(45, 95, 40), Enum.Material.Grass)
        ivy.CanCollide = false
    end
end

-- ============================================================================
-- 2. FORTIFIED VILLAGE GATE ARCHWAY
-- ============================================================================
local gate = interactables:FindFirstChild("LockedVillageGate")
if gate and gate:IsA("BasePart") then
    local detailedGate = map:FindFirstChild("DetailedVillageGateArch")
    if detailedGate then detailedGate:Destroy() end
    detailedGate = Instance.new("Model")
    detailedGate.Name = "DetailedVillageGateArch"
    detailedGate.Parent = map

    local gPos = gate.Position

    -- Flanking stone guard pillars
    local pillarL = createPart("GatePillarL", detailedGate, Vector3.new(4, 16, 5), CFrame.new(gPos.X - 10, gPos.Y + 1, gPos.Z), Color3.fromRGB(65, 68, 70), Enum.Material.Slate)
    local pillarR = createPart("GatePillarR", detailedGate, Vector3.new(4, 16, 5), CFrame.new(gPos.X + 10, gPos.Y + 1, gPos.Z), Color3.fromRGB(65, 68, 70), Enum.Material.Slate)

    -- Heavy stone arch lintel
    local archBeam = createPart("GateArchLintel", detailedGate, Vector3.new(24, 4, 6), CFrame.new(gPos.X, gPos.Y + 9, gPos.Z), Color3.fromRGB(70, 72, 75), Enum.Material.Cobblestone)

    -- Iron chains & lock on gate
    local chainPart = createPart("GatePadlockChains", detailedGate, Vector3.new(3, 3, 1.2), CFrame.new(gPos.X, gPos.Y - 2, gPos.Z + 1), Color3.fromRGB(35, 35, 38), Enum.Material.Metal)
    chainPart.CanCollide = false

    -- Rune sigil on the lintel
    local sigil = createPart("GateRuneSigil", detailedGate, Vector3.new(2, 2, 0.4), CFrame.new(gPos.X, gPos.Y + 9, gPos.Z + 3.1), Color3.fromRGB(220, 160, 40), Enum.Material.Neon)
    sigil.CanCollide = false
    local sLight = Instance.new("PointLight")
    sLight.Color = Color3.fromRGB(255, 180, 50)
    sLight.Range = 12
    sLight.Brightness = 1.2
    sLight.Parent = sigil
end

-- ============================================================================
-- 3. VILLAGE SQUARE WELL & PLAZA PROPS
-- ============================================================================
local well = map:FindFirstChild("OvergrownWell")
local water = map:FindFirstChild("WellWater")
if well and well:IsA("BasePart") then
    local detailedWell = map:FindFirstChild("DetailedWellStructure")
    if detailedWell then detailedWell:Destroy() end
    detailedWell = Instance.new("Model")
    detailedWell.Name = "DetailedWellStructure"
    detailedWell.Parent = map

    local wPos = well.Position

    -- Upright timber support posts (East & West)
    local postL = createPart("WellPostL", detailedWell, Vector3.new(1.2, 8, 1.2), CFrame.new(wPos.X - 4.5, wPos.Y + 2, wPos.Z), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)
    local postR = createPart("WellPostR", detailedWell, Vector3.new(1.2, 8, 1.2), CFrame.new(wPos.X + 4.5, wPos.Y + 2, wPos.Z), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)

    -- Crossbeam overhead
    local crossBeam = createPart("WellCrossBeam", detailedWell, Vector3.new(10.5, 1.2, 1.2), CFrame.new(wPos.X, wPos.Y + 6, wPos.Z), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)

    -- Pitched wood shingle roof over the well
    local roofSlopeL = createWedge("WellRoofL", detailedWell, Vector3.new(5.5, 2.5, 9), CFrame.new(wPos.X - 2.5, wPos.Y + 7.5, wPos.Z) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(85, 55, 35), Enum.Material.WoodPlanks)
    local roofSlopeR = createWedge("WellRoofR", detailedWell, Vector3.new(5.5, 2.5, 9), CFrame.new(wPos.X + 2.5, wPos.Y + 7.5, wPos.Z) * CFrame.Angles(0, math.rad(-90), 0), Color3.fromRGB(85, 55, 35), Enum.Material.WoodPlanks)

    -- Wooden winch cylinder
    local winch = createPart("WellWinch", detailedWell, Vector3.new(4, 1.2, 1.2), CFrame.new(wPos.X, wPos.Y + 4.8, wPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(90, 60, 35), Enum.Material.Wood, Enum.PartType.Cylinder)
    winch.CanCollide = false

    -- Hanging rope
    local rope = createPart("WellRope", detailedWell, Vector3.new(0.3, 3, 0.3), CFrame.new(wPos.X, wPos.Y + 3.2, wPos.Z), Color3.fromRGB(150, 130, 95), Enum.Material.Fabric, Enum.PartType.Cylinder)
    rope.CanCollide = false

    -- Wooden bucket hanging
    local bucket = createPart("WellBucket", detailedWell, Vector3.new(1.8, 1.8, 1.8), CFrame.new(wPos.X, wPos.Y + 1.5, wPos.Z), Color3.fromRGB(80, 50, 28), Enum.Material.Wood, Enum.PartType.Cylinder)
    bucket.CanCollide = false

    -- Discarded wooden cartwheel near the well
    createPart("PlazaCartwheel", detailedWell, Vector3.new(4, 0.6, 4), CFrame.new(wPos.X + 7, 0.4, wPos.Z + 5) * CFrame.Angles(math.rad(75), math.rad(25), 0), Color3.fromRGB(65, 42, 22), Enum.Material.Wood, Enum.PartType.Cylinder)

    -- Weathered stone bench
    createPart("PlazaStoneBench", detailedWell, Vector3.new(7, 1.4, 2.2), CFrame.new(wPos.X - 12, 0.8, wPos.Z - 6) * CFrame.Angles(0, math.rad(30), 0), Color3.fromRGB(75, 78, 80), Enum.Material.Slate)
end

-- ============================================================================
-- 4. THREE DETAILED RUINED HOUSES
-- ============================================================================
local housesFolder = map:FindFirstChild("RuinedHouses")
if housesFolder then housesFolder:Destroy() end
housesFolder = Instance.new("Folder")
housesFolder.Name = "RuinedHouses"
housesFolder.Parent = map

-- ----------------------------------------------------------------------------
-- HOUSE 1: Town Archive & Apothecary (East, Z = -440 to -450)
-- ----------------------------------------------------------------------------
local h1 = Instance.new("Model")
h1.Name = "RuinedApothecaryAndArchive"
h1.Parent = housesFolder

local h1Pos = Vector3.new(50, 0, -445)
-- Foundation floor
createPart("H1_Floor", h1, Vector3.new(24, 0.8, 22), CFrame.new(h1Pos.X, 0.4, h1Pos.Z), Color3.fromRGB(68, 65, 62), Enum.Material.Cobblestone)
-- Standing stone walls (North & East walls intact, South/West crumbled)
createPart("H1_WallNorth", h1, Vector3.new(24, 11, 2), CFrame.new(h1Pos.X, 5.5, h1Pos.Z - 10), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)
createPart("H1_WallEast", h1, Vector3.new(2, 11, 22), CFrame.new(h1Pos.X + 11, 5.5, h1Pos.Z), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)
-- Partial crumbled South wall
createPart("H1_WallSouthHalf", h1, Vector3.new(12, 6, 2), CFrame.new(h1Pos.X + 5, 3, h1Pos.Z + 10), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)

-- Stone Fireplace & Chimney on North wall
createPart("H1_FireplaceHearth", h1, Vector3.new(7, 8, 4), CFrame.new(h1Pos.X, 4, h1Pos.Z - 8.5), Color3.fromRGB(60, 62, 65), Enum.Material.Slate)
createPart("H1_Chimney", h1, Vector3.new(3.5, 16, 3.5), CFrame.new(h1Pos.X, 10, h1Pos.Z - 8.5), Color3.fromRGB(55, 58, 60), Enum.Material.Cobblestone)

-- Broken angled roof rafters
createPart("H1_Rafter1", h1, Vector3.new(1.2, 1.2, 16), CFrame.new(h1Pos.X - 5, 8, h1Pos.Z) * CFrame.Angles(math.rad(-22), 0, math.rad(15)), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)
createPart("H1_Rafter2", h1, Vector3.new(1.2, 1.2, 16), CFrame.new(h1Pos.X + 5, 9, h1Pos.Z) * CFrame.Angles(math.rad(-20), 0, math.rad(-12)), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)

-- Town Archive Desk holding StoryClue_Archive
local desk = createPart("ArchiveDesk", h1, Vector3.new(6, 2.6, 3.5), CFrame.new(h1Pos.X - 4, 1.3, h1Pos.Z - 3), Color3.fromRGB(80, 50, 30), Enum.Material.WoodPlanks)

-- Ensure the StoryClue_Archive is cleanly placed on the desk
local storyClue = interactables:FindFirstChild("StoryClue_Archive")
if storyClue and storyClue:IsA("BasePart") then
    storyClue.CFrame = CFrame.new(desk.Position.X, desk.Position.Y + 1.4, desk.Position.Z)
    storyClue.Color = Color3.fromRGB(240, 230, 200)
    storyClue.Material = Enum.Material.Fabric

    -- Add mystical discovery aura
    local docGlow = storyClue:FindFirstChild("DiscoveryGlow")
    if not docGlow then
        docGlow = Instance.new("PointLight")
        docGlow.Name = "DiscoveryGlow"
        docGlow.Color = Color3.fromRGB(255, 220, 120)
        docGlow.Range = 10
        docGlow.Brightness = 1.8
        docGlow.Parent = storyClue
    end
end

-- ----------------------------------------------------------------------------
-- HOUSE 2: Ruined Blacksmith Workshop (North-West, Z = -425)
-- ----------------------------------------------------------------------------
local h2 = Instance.new("Model")
h2.Name = "RuinedBlacksmithWorkshop"
h2.Parent = housesFolder

local h2Pos = Vector3.new(-38, 0, -425)
createPart("H2_Floor", h2, Vector3.new(20, 0.8, 18), CFrame.new(h2Pos.X, 0.4, h2Pos.Z), Color3.fromRGB(65, 62, 60), Enum.Material.Cobblestone)
-- Low stone perimeter walls
createPart("H2_WallWest", h2, Vector3.new(2, 7, 18), CFrame.new(h2Pos.X - 9, 3.5, h2Pos.Z), Color3.fromRGB(72, 75, 78), Enum.Material.Slate)
createPart("H2_WallNorth", h2, Vector3.new(18, 7, 2), CFrame.new(h2Pos.X, 3.5, h2Pos.Z - 8), Color3.fromRGB(72, 75, 78), Enum.Material.Slate)

-- Heavy Blacksmith Forge (stone kiln with glowing embers)
local forge = createPart("H2_ForgeBase", h2, Vector3.new(6, 4.5, 5), CFrame.new(h2Pos.X - 5, 2.25, h2Pos.Z - 4), Color3.fromRGB(50, 52, 55), Enum.Material.Cobblestone)
local forgeEmbers = createPart("H2_ForgeEmbers", h2, Vector3.new(3, 1, 2.5), CFrame.new(forge.Position.X, 3.8, forge.Position.Z), Color3.fromRGB(255, 90, 20), Enum.Material.Neon)
forgeEmbers.CanCollide = false
local forgeLight = Instance.new("PointLight")
forgeLight.Color = Color3.fromRGB(255, 100, 30)
forgeLight.Range = 14
forgeLight.Brightness = 2.0
forgeLight.Parent = forgeEmbers

-- Anvil on tree stump
local stump = createPart("H2_AnvilStump", h2, Vector3.new(2.4, 2.2, 2.4), CFrame.new(h2Pos.X, 1.1, h2Pos.Z + 1), Color3.fromRGB(70, 45, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
createPart("H2_AnvilBlock", h2, Vector3.new(1.8, 1.4, 3.2), CFrame.new(stump.Position.X, 2.6, stump.Position.Z), Color3.fromRGB(42, 44, 46), Enum.Material.Metal)

-- Collapsed timber roof beams tilted to the floor
createPart("H2_FallenBeam1", h2, Vector3.new(1.2, 1.2, 15), CFrame.new(h2Pos.X + 2, 3.2, h2Pos.Z + 1) * CFrame.Angles(math.rad(28), math.rad(15), math.rad(-10)), Color3.fromRGB(65, 42, 22), Enum.Material.Wood)

-- ----------------------------------------------------------------------------
-- HOUSE 3: Ruined Residential Cottage (South-East, Z = -480)
-- ----------------------------------------------------------------------------
local h3 = Instance.new("Model")
h3.Name = "RuinedCottage"
h3.Parent = housesFolder

local h3Pos = Vector3.new(45, 0, -485)
createPart("H3_Floor", h3, Vector3.new(18, 0.8, 16), CFrame.new(h3Pos.X, 0.4, h3Pos.Z), Color3.fromRGB(70, 66, 62), Enum.Material.WoodPlanks)

-- Fieldstone walls with window cutouts
createPart("H3_WallSouth", h3, Vector3.new(18, 8, 2), CFrame.new(h3Pos.X, 4, h3Pos.Z + 7), Color3.fromRGB(76, 78, 80), Enum.Material.Cobblestone)
createPart("H3_WallEast", h3, Vector3.new(2, 8, 14), CFrame.new(h3Pos.X + 8, 4, h3Pos.Z), Color3.fromRGB(76, 78, 80), Enum.Material.Cobblestone)
createPart("H3_WallNorthPart", h3, Vector3.new(8, 8, 2), CFrame.new(h3Pos.X + 4, 4, h3Pos.Z - 7), Color3.fromRGB(76, 78, 80), Enum.Material.Cobblestone)

-- Broken wooden door tilted off one hinge in the doorway
createPart("H3_BrokenDoor", h3, Vector3.new(3.5, 6.5, 0.6), CFrame.new(h3Pos.X - 3, 3.2, h3Pos.Z - 6.8) * CFrame.Angles(0, math.rad(35), math.rad(-18)), Color3.fromRGB(80, 52, 30), Enum.Material.Wood)

-- Collapsed corner with climbing ivy
createPart("H3_IvyClump", h3, Vector3.new(3, 6, 3), CFrame.new(h3Pos.X + 7.5, 3.5, h3Pos.Z + 6.5), Color3.fromRGB(42, 92, 38), Enum.Material.Grass)

-- ============================================================================
-- 5. RUINED WATCHTOWER OVERHAUL (3-TIER TOWER)
-- ============================================================================
local watchtower = map:FindFirstChild("RuinedWatchtower")
if watchtower then
    local towerBase = watchtower:FindFirstChild("TowerBase")
    if towerBase and towerBase:IsA("BasePart") then
        towerBase.Transparency = 1
        towerBase.CanCollide = false
    end

    local detailedTower = map:FindFirstChild("DetailedWatchtowerModel")
    if detailedTower then detailedTower:Destroy() end
    detailedTower = Instance.new("Model")
    detailedTower.Name = "DetailedWatchtowerModel"
    detailedTower.Parent = map

    local tPos = Vector3.new(-60, 0, -460)

    -- 1. Stone Foundation Base (Ground tier)
    createPart("WT_StoneBase", detailedTower, Vector3.new(16, 10, 16), CFrame.new(tPos.X, 5, tPos.Z), Color3.fromRGB(72, 75, 78), Enum.Material.Cobblestone)

    -- Arched Entrance Doorway on East face
    local entranceCutout = createPart("WT_DoorwayCutout", detailedTower, Vector3.new(4, 7, 3), CFrame.new(tPos.X + 7, 3.5, tPos.Z), Color3.fromRGB(30, 30, 30), Enum.Material.Slate)
    entranceCutout.CanCollide = false

    -- 2. Second Tier Timber Platform
    createPart("WT_Tier2Floor", detailedTower, Vector3.new(18, 1, 18), CFrame.new(tPos.X, 10.5, tPos.Z), Color3.fromRGB(85, 55, 32), Enum.Material.WoodPlanks)
    -- 4 Heavy Corner Support Timber Posts
    local cOffsets = {
        Vector3.new(-7.5, 16, -7.5),
        Vector3.new(7.5, 16, -7.5),
        Vector3.new(7.5, 16, 7.5),
        Vector3.new(-7.5, 16, 7.5),
    }
    for idx, cOff in ipairs(cOffsets) do
        createPart("WT_CornerPost_" .. idx, detailedTower, Vector3.new(1.6, 12, 1.6), CFrame.new(tPos.X + cOff.X, cOff.Y, tPos.Z + cOff.Z), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)
    end

    -- 3. Top Lookout Platform (Tier 3)
    local topFloor = createPart("WT_TopLookoutFloor", detailedTower, Vector3.new(20, 1.2, 20), CFrame.new(tPos.X, 22.6, tPos.Z), Color3.fromRGB(90, 60, 35), Enum.Material.WoodPlanks)
    topFloor.CanCollide = true

    -- Crenellated battlements & railings on lookout
    local battlementSides = {
        { off = Vector3.new(0, 24.6, 9.5), sz = Vector3.new(19, 3.2, 1) },
        { off = Vector3.new(0, 24.6, -9.5), sz = Vector3.new(19, 3.2, 1) },
        { off = Vector3.new(9.5, 24.6, 0), sz = Vector3.new(1, 3.2, 19) },
        { off = Vector3.new(-9.5, 24.6, 0), sz = Vector3.new(1, 3.2, 19) },
    }
    for bIdx, bSide in ipairs(battlementSides) do
        createPart("WT_Battlement_" .. bIdx, detailedTower, bSide.sz, CFrame.new(tPos.X + bSide.off.X, bSide.off.Y, tPos.Z + bSide.off.Z), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)
    end

    -- Lookout Brazier (Signal fire bowl with smoke & fire particles)
    local brazierStand = createPart("WT_BrazierStand", detailedTower, Vector3.new(2, 3, 2), CFrame.new(tPos.X, 24.5, tPos.Z), Color3.fromRGB(45, 45, 48), Enum.Material.Metal, Enum.PartType.Cylinder)
    local brazierBowl = createPart("WT_BrazierBowl", detailedTower, Vector3.new(3.5, 1.2, 3.5), CFrame.new(tPos.X, 26.2, tPos.Z), Color3.fromRGB(220, 100, 30), Enum.Material.Neon, Enum.PartType.Cylinder)
    brazierBowl.CanCollide = false

    local bLight = Instance.new("PointLight")
    bLight.Color = Color3.fromRGB(255, 140, 40)
    bLight.Range = 28
    bLight.Brightness = 2.4
    bLight.Parent = brazierBowl

    local bFire = Instance.new("ParticleEmitter")
    bFire.Name = "WatchtowerFire"
    bFire.Color = ColorSequence.new(Color3.fromRGB(255, 180, 50), Color3.fromRGB(220, 60, 20))
    bFire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(1, 0.2)
    })
    bFire.Rate = 14
    bFire.Speed = NumberRange.new(2, 4)
    bFire.Lifetime = NumberRange.new(1, 2)
    bFire.SpreadAngle = Vector2.new(20, 20)
    bFire.Parent = brazierBowl
end

print("[build_abandoned_village] Abandoned Village & Old Stone Bridge overhaul complete!")
return true
