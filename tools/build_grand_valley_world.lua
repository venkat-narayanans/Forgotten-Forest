--!strict
--[[
    build_grand_valley_world.lua
    Master World Expansion for The Forgotten Forest (v2.0)
    Target Dimensions: ~700 studs (X) x 3,300 studs (Z) across the Grand Valley
    
    Regions:
    1. Safe Haven Hub (Z = 100 to -250, 350 x 350 studs)
    2. Whispering Woods (Z = -250 to -1150, 900 x 700 studs)
    3. Abandoned Village (Z = -1150 to -1800, 650 x 650 studs)
    4. Crystal Caverns (Z = -1800 to -2400, 600 x 600 studs)
    5. Ancient Grounds & Boss Arena (Z = -2400 to -3150, 700 x 700 studs)
]]

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local tffWorld = Workspace:FindFirstChild("TFF_World")
if not tffWorld then
    tffWorld = Instance.new("Folder")
    tffWorld.Name = "TFF_World"
    tffWorld.Parent = Workspace
end

local map = tffWorld:FindFirstChild("Map")
if not map then
    map = Instance.new("Folder")
    map.Name = "Map"
    map.Parent = tffWorld
end

local interactables = tffWorld:FindFirstChild("Interactables")
if not interactables then
    interactables = Instance.new("Folder")
    interactables.Name = "Interactables"
    interactables.Parent = tffWorld
end

local resourceFolder = tffWorld:FindFirstChild("ResourceNodes")
if not resourceFolder then
    resourceFolder = Instance.new("Folder")
    resourceFolder.Name = "ResourceNodes"
    resourceFolder.Parent = tffWorld
end

local zonesFolder = tffWorld:FindFirstChild("Zones")
if not zonesFolder then
    zonesFolder = Instance.new("Folder")
    zonesFolder.Name = "Zones"
    zonesFolder.Parent = tffWorld
end

-- Helper: Create anchored Part
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

-- Helper: Create Low Poly Tree
local function createTree(name: string, parent: Instance, pos: Vector3, scale: number, treeType: string)
    local treeModel = Instance.new("Model")
    treeModel.Name = name
    treeModel.Parent = parent

    scale = scale or 1.0
    local trunkH = (treeType == "Pine" and 22 or 16) * scale
    local trunkR = (treeType == "Pine" and 2.2 or 2.8) * scale
    local trunkColor = treeType == "Birch" and Color3.fromRGB(225, 222, 215) or Color3.fromRGB(80, 52, 30)
    local leafColor = treeType == "Pine" and Color3.fromRGB(32, 68, 38) or (treeType == "Birch" and Color3.fromRGB(95, 140, 50) or Color3.fromRGB(48, 92, 40))

    -- Trunk
    local trunk = createPart("Trunk", treeModel, Vector3.new(trunkR, trunkH, trunkR), CFrame.new(pos.X, pos.Y + trunkH / 2, pos.Z), trunkColor, Enum.Material.Wood, Enum.PartType.Cylinder)
    trunk.CanCollide = true

    if treeType == "Pine" then
        -- 3 tiered cone leaves
        for layer = 1, 3 do
            local layerH = 10 * scale
            local layerR = (14 - (layer * 3)) * scale
            local layerY = pos.Y + (trunkH * 0.5) + (layer * 5.5 * scale)
            local leaves = createPart("PineLayer_" .. layer, treeModel, Vector3.new(layerR, layerH, layerR), CFrame.new(pos.X, layerY, pos.Z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
            leaves.CanCollide = false
        end
    else
        -- Broadleaf / Birch foliage (cluster of balls)
        local topY = pos.Y + trunkH + (4 * scale)
        local mainCanopy = createPart("CanopyMain", treeModel, Vector3.new(16 * scale, 12 * scale, 16 * scale), CFrame.new(pos.X, topY, pos.Z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
        mainCanopy.CanCollide = false

        local subCanopy1 = createPart("CanopySub1", treeModel, Vector3.new(12 * scale, 9 * scale, 12 * scale), CFrame.new(pos.X + 4 * scale, topY - 2 * scale, pos.Z + 3 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
        subCanopy1.CanCollide = false

        local subCanopy2 = createPart("CanopySub2", treeModel, Vector3.new(11 * scale, 8 * scale, 11 * scale), CFrame.new(pos.X - 3 * scale, topY - 1 * scale, pos.Z - 4 * scale), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
        subCanopy2.CanCollide = false
    end

    -- Add harvestable wood node attribute on the trunk
    trunk:SetAttribute("ResourceType", "wood")
    trunk:SetAttribute("RemainingYield", 4)
    trunk:SetAttribute("MaxYield", 4)
    trunk:SetAttribute("EffectiveTool", "Hatchet")
    CollectionService:AddTag(trunk, "TFF_ResourceNode")

    return treeModel
end

-- Helper: Create Rock Boulder
local function createBoulder(name: string, parent: Instance, pos: Vector3, size: Vector3, rot: Vector3)
    local rock = createPart(name, parent, size, CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z)), Color3.fromRGB(90, 88, 85), Enum.Material.Slate)
    rock.CanCollide = true
    rock:SetAttribute("ResourceType", "stone")
    rock:SetAttribute("RemainingYield", 5)
    rock:SetAttribute("MaxYield", 5)
    rock:SetAttribute("EffectiveTool", "Pickaxe")
    CollectionService:AddTag(rock, "TFF_ResourceNode")
    return rock
end

print("[GrandValley] Step 1: Laying out Regional Terrains and Valley Floor...")

-- ============================================================================
-- 1. REGIONAL GROUND FOUNDATIONS
-- ============================================================================

-- Region 1: Safe Haven (350 x 350 studs, Z = 100 to -250)
local safeGround = map:FindFirstChild("SafeHavenGround")
if not safeGround then
    safeGround = createPart("SafeHavenGround", map, Vector3.new(350, 4, 350), CFrame.new(0, -2, -75), Color3.fromRGB(65, 95, 55), Enum.Material.Grass)
else
    safeGround.Size = Vector3.new(350, 4, 350)
    safeGround.CFrame = CFrame.new(0, -2, -75)
    safeGround.Material = Enum.Material.Grass
    safeGround.Color = Color3.fromRGB(65, 95, 55)
end

-- Region 2: Whispering Woods (700 x 900 studs, Z = -250 to -1150)
local woodsGround = map:FindFirstChild("WhisperingWoodsGround")
if not woodsGround then
    woodsGround = createPart("WhisperingWoodsGround", map, Vector3.new(700, 4, 900), CFrame.new(0, -2, -700), Color3.fromRGB(48, 82, 42), Enum.Material.Grass)
else
    woodsGround.Size = Vector3.new(700, 4, 900)
    woodsGround.CFrame = CFrame.new(0, -2, -700)
    woodsGround.Color = Color3.fromRGB(48, 82, 42)
    woodsGround.Material = Enum.Material.Grass
end

-- Region 3: Abandoned Village (650 x 650 studs, Z = -1150 to -1800)
local villageGround = map:FindFirstChild("AbandonedVillageGround")
if not villageGround then
    villageGround = createPart("AbandonedVillageGround", map, Vector3.new(650, 4, 650), CFrame.new(0, -2, -1475), Color3.fromRGB(72, 70, 68), Enum.Material.Cobblestone)
else
    villageGround.Size = Vector3.new(650, 4, 650)
    villageGround.CFrame = CFrame.new(0, -2, -1475)
    villageGround.Color = Color3.fromRGB(72, 70, 68)
    villageGround.Material = Enum.Material.Cobblestone
end

-- Region 4: Crystal Caverns (600 x 600 studs, Z = -1800 to -2400)
local cavernsGround = map:FindFirstChild("CrystalCavernsGround")
if not cavernsGround then
    cavernsGround = createPart("CrystalCavernsGround", map, Vector3.new(600, 4, 600), CFrame.new(0, -6, -2100), Color3.fromRGB(38, 40, 45), Enum.Material.Basalt)
else
    cavernsGround.Size = Vector3.new(600, 4, 600)
    cavernsGround.CFrame = CFrame.new(0, -6, -2100)
    cavernsGround.Color = Color3.fromRGB(38, 40, 45)
    cavernsGround.Material = Enum.Material.Basalt
end

-- Region 5: Ancient Grounds Plateau (700 x 750 studs, Z = -2400 to -3150)
local ancientGround = map:FindFirstChild("AncientGroundsPlateau")
if not ancientGround then
    ancientGround = createPart("AncientGroundsPlateau", map, Vector3.new(700, 6, 750), CFrame.new(0, 4, -2775), Color3.fromRGB(55, 58, 62), Enum.Material.Cobblestone)
else
    ancientGround.Size = Vector3.new(700, 6, 750)
    ancientGround.CFrame = CFrame.new(0, 4, -2775)
    ancientGround.Color = Color3.fromRGB(55, 58, 62)
    ancientGround.Material = Enum.Material.Cobblestone
end

print("[GrandValley] Step 2: Constructing Perimeter Valley Mountain Walls...")

-- ============================================================================
-- 2. VALLEY PERIMETER CLIFF WALLS (East & West, South Ridge, North Peaks)
-- ============================================================================

local cliffsFolder = map:FindFirstChild("ValleyCliffs")
if cliffsFolder then cliffsFolder:Destroy() end
cliffsFolder = Instance.new("Folder")
cliffsFolder.Name = "ValleyCliffs"
cliffsFolder.Parent = map

-- East Valley Mountain Wall (X = +340, Z = +100 to -3150)
for z = 100, -3150, -120 do
    local cliffH = 75 + math.abs(math.sin(z * 0.01)) * 40
    local cliffD = 130
    local cliffW = 80
    local c = createPart("EastCliff_" .. z, cliffsFolder, Vector3.new(cliffW, cliffH, cliffD), CFrame.new(350 + (cliffW/2), cliffH/2 - 2, z) * CFrame.Angles(0, math.rad(math.sin(z) * 12), 0), Color3.fromRGB(62, 60, 58), Enum.Material.Slate)
end

-- West Valley Mountain Wall (X = -340, Z = +100 to -3150)
for z = 100, -3150, -120 do
    local cliffH = 75 + math.abs(math.cos(z * 0.01)) * 40
    local cliffD = 130
    local cliffW = 80
    local c = createPart("WestCliff_" .. z, cliffsFolder, Vector3.new(cliffW, cliffH, cliffD), CFrame.new(-350 - (cliffW/2), cliffH/2 - 2, z) * CFrame.Angles(0, math.rad(math.cos(z) * 12), 0), Color3.fromRGB(62, 60, 58), Enum.Material.Slate)
end

-- South Ridge Wall behind Safe Haven (Z = +100)
for x = -350, 350, 90 do
    local ridgeH = 65
    createPart("SouthRidge_" .. x, cliffsFolder, Vector3.new(100, ridgeH, 60), CFrame.new(x, ridgeH/2 - 2, 115), Color3.fromRGB(68, 65, 62), Enum.Material.Slate)
end

-- North Valley Mountain Peaks behind Ancient Grounds (Z = -3150)
for x = -350, 350, 80 do
    local peakH = 130 + math.abs(math.sin(x * 0.05)) * 30
    createPart("NorthBasaltPeak_" .. x, cliffsFolder, Vector3.new(90, peakH, 90), CFrame.new(x, peakH/2 - 2, -3160) * CFrame.Angles(0, math.rad(x * 11), 0), Color3.fromRGB(42, 45, 48), Enum.Material.Basalt)
end

print("[GrandValley] Step 3: Upgrading Safe Haven Hub Structures...")

-- ============================================================================
-- 3. SAFE HAVEN HUB
-- ============================================================================

-- Camp Beacon Structure
local beaconModel = map:FindFirstChild("CampBeaconStructure")
if beaconModel then beaconModel:Destroy() end
beaconModel = Instance.new("Model")
beaconModel.Name = "CampBeaconStructure"
beaconModel.Parent = map

local beaconBase = createPart("BeaconStoneBase", beaconModel, Vector3.new(14, 3, 14), CFrame.new(0, 1.5, 0), Color3.fromRGB(75, 78, 80), Enum.Material.Cobblestone)
local beaconPillar = createPart("BeaconPillar", beaconModel, Vector3.new(4, 20, 4), CFrame.new(0, 11, 0), Color3.fromRGB(65, 68, 70), Enum.Material.Slate)
local beaconFlame = createPart("BeaconLightCore", beaconModel, Vector3.new(3.5, 3.5, 3.5), CFrame.new(0, 22, 0), Color3.fromRGB(255, 190, 60), Enum.Material.Neon, Enum.PartType.Ball)
beaconFlame.CanCollide = false

local beaconLight = Instance.new("PointLight")
beaconLight.Color = Color3.fromRGB(255, 185, 55)
beaconLight.Range = 55
beaconLight.Brightness = 3.5
beaconLight.Parent = beaconFlame

local beaconParticles = Instance.new("ParticleEmitter")
beaconParticles.Name = "BeaconEmbers"
beaconParticles.Color = ColorSequence.new(Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 100, 20))
beaconParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0.1)})
beaconParticles.Rate = 25
beaconParticles.Speed = NumberRange.new(3, 7)
beaconParticles.Lifetime = NumberRange.new(2, 4)
beaconParticles.SpreadAngle = Vector2.new(20, 20)
beaconParticles.Acceleration = Vector3.new(0, 2.5, 0)
beaconParticles.Parent = beaconFlame

-- Add proximity prompt or beacon interaction
beaconBase:SetAttribute("BeaconRepaired", true)
beaconBase:SetAttribute("BeaconFuel", 100)

-- Medical Tent & Station
local medTent = map:FindFirstChild("SafeHavenMedicalTent")
if medTent then medTent:Destroy() end
medTent = Instance.new("Model")
medTent.Name = "SafeHavenMedicalTent"
medTent.Parent = map

createPart("MedTentPlatform", medTent, Vector3.new(22, 1, 26), CFrame.new(-32, 0.5, -50), Color3.fromRGB(90, 75, 55), Enum.Material.WoodPlanks)
createPart("MedTentRoof", medTent, Vector3.new(24, 12, 28), CFrame.new(-32, 6.5, -50), Color3.fromRGB(215, 210, 195), Enum.Material.Fabric)

-- Cartographer Map Table & Pavilion
local mapPavilion = map:FindFirstChild("CartographerPavilion")
if mapPavilion then mapPavilion:Destroy() end
mapPavilion = Instance.new("Model")
mapPavilion.Name = "CartographerPavilion"
mapPavilion.Parent = map

createPart("MapPavilionDeck", mapPavilion, Vector3.new(20, 1, 20), CFrame.new(28, 0.5, -25), Color3.fromRGB(85, 70, 50), Enum.Material.WoodPlanks)
local mapTable = createPart("CartographerMapTable", interactables, Vector3.new(8, 3.2, 5), CFrame.new(28, 2.1, -25), Color3.fromRGB(115, 85, 55), Enum.Material.WoodPlanks)
local mapPrompt = Instance.new("ProximityPrompt")
mapPrompt.ActionText = "Inspect Valley Map"
mapPrompt.ObjectText = "Cartographer's Table"
mapPrompt.HoldDuration = 0.5
mapPrompt.MaxActivationDistance = 9
mapPrompt.Parent = mapTable

print("[GrandValley] Step 4: Constructing Whispering Woods Landmarks & Flora...")

-- ============================================================================
-- 4. WHISPERING WOODS (Z = -250 to -1150)
-- ============================================================================

-- Trail to Whispering Woods
local trail = map:FindFirstChild("TrailToWhisperingWoods")
if not trail then
    trail = createPart("TrailToWhisperingWoods", map, Vector3.new(20, 0.3, 200), CFrame.new(0, 0.15, -200), Color3.fromRGB(115, 95, 70), Enum.Material.Ground)
else
    trail.Size = Vector3.new(20, 0.3, 200)
    trail.CFrame = CFrame.new(0, 0.15, -200)
    trail.Material = Enum.Material.Ground
    trail.Color = Color3.fromRGB(115, 95, 70)
end

-- Creek Ravine (Running across Z = -450, 600 studs wide)
local creek = map:FindFirstChild("Creek")
if not creek then
    creek = createPart("Creek", map, Vector3.new(650, 1.2, 34), CFrame.new(0, -0.6, -450), Color3.fromRGB(35, 110, 155), Enum.Material.Glass)
else
    creek.Size = Vector3.new(650, 1.2, 34)
    creek.CFrame = CFrame.new(0, -0.6, -450)
    creek.Material = Enum.Material.Glass
    creek.Color = Color3.fromRGB(35, 110, 155)
end
creek.Transparency = 0.35
creek.Reflectance = 0.3
creek.CanCollide = false

local creekBed = map:FindFirstChild("CreekBed")
if not creekBed then
    creekBed = createPart("CreekBed", map, Vector3.new(650, 2, 36), CFrame.new(0, -1.8, -450), Color3.fromRGB(45, 42, 38), Enum.Material.Cobblestone)
else
    creekBed.Size = Vector3.new(650, 2, 36)
    creekBed.CFrame = CFrame.new(0, -1.8, -450)
    creekBed.Color = Color3.fromRGB(45, 42, 38)
    creekBed.Material = Enum.Material.Cobblestone
end

-- Fallen Log Crossing over Creek at X = 0, Z = -450
local logCrossing = map:FindFirstChild("FallenLogCrossing")
if logCrossing then
    logCrossing.Size = Vector3.new(8, 3, 40)
    logCrossing.CFrame = CFrame.new(0, 1.5, -450)
    logCrossing.CanCollide = true
end

-- Whispering Woods Landmark 1: The Split Oak (X = -120, Z = -650)
local splitOakModel = map:FindFirstChild("SplitOakLandmark")
if splitOakModel then splitOakModel:Destroy() end
splitOakModel = Instance.new("Model")
splitOakModel.Name = "SplitOakLandmark"
splitOakModel.Parent = map

local oakBase = createPart("OakBaseTrunk", splitOakModel, Vector3.new(12, 18, 12), CFrame.new(-120, 9, -650), Color3.fromRGB(75, 48, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
local trunkL = createPart("TrunkBranchL", splitOakModel, Vector3.new(7, 30, 7), CFrame.new(-126, 30, -650) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(70, 45, 22), Enum.Material.Wood, Enum.PartType.Cylinder)
local trunkR = createPart("TrunkBranchR", splitOakModel, Vector3.new(7, 30, 7), CFrame.new(-114, 30, -650) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(70, 45, 22), Enum.Material.Wood, Enum.PartType.Cylinder)
local oakCanopyL = createPart("OakCanopyL", splitOakModel, Vector3.new(34, 22, 34), CFrame.new(-135, 46, -650), Color3.fromRGB(42, 95, 38), Enum.Material.Grass, Enum.PartType.Ball)
local oakCanopyR = createPart("OakCanopyR", splitOakModel, Vector3.new(34, 22, 34), CFrame.new(-105, 46, -650), Color3.fromRGB(48, 105, 44), Enum.Material.Grass, Enum.PartType.Ball)
oakCanopyL.CanCollide = false
oakCanopyR.CanCollide = false

-- Whispering Woods Landmark 2: Silent Pond (X = 160, Z = -720)
local pondModel = map:FindFirstChild("SilentPondPOI")
if pondModel then pondModel:Destroy() end
pondModel = Instance.new("Model")
pondModel.Name = "SilentPondPOI"
pondModel.Parent = map

local pondWater = createPart("SilentPondWater", pondModel, Vector3.new(100, 0.8, 90), CFrame.new(160, -0.4, -720), Color3.fromRGB(28, 90, 125), Enum.Material.Glass, Enum.PartType.Cylinder)
pondWater.Transparency = 0.3
pondWater.Reflectance = 0.35
pondWater.CanCollide = false
local pondBank = createPart("SilentPondBank", pondModel, Vector3.new(115, 1.2, 105), CFrame.new(160, -1.0, -720), Color3.fromRGB(55, 52, 48), Enum.Material.Cobblestone, Enum.PartType.Cylinder)

-- Whispering Woods Landmark 3: Abandoned Campsite (X = -180, Z = -350)
local scoutCamp = map:FindFirstChild("AbandonedCampsite")
if not scoutCamp then
    scoutCamp = Instance.new("Folder")
    scoutCamp.Name = "AbandonedCampsite"
    scoutCamp.Parent = map
end
local scoutTent = createPart("ScoutLeanTo", scoutCamp, Vector3.new(14, 8, 12), CFrame.new(-180, 4, -350), Color3.fromRGB(110, 95, 75), Enum.Material.WoodPlanks)
local scoutFire = createPart("ColdCampfire", scoutCamp, Vector3.new(5, 1, 5), CFrame.new(-172, 0.5, -350), Color3.fromRGB(50, 48, 45), Enum.Material.Slate, Enum.PartType.Cylinder)

-- Whispering Woods Landmark 4: Fairy-Ring Mushroom Clearing (X = -80, Z = -950)
local mushroomClearing = map:FindFirstChild("MushroomClearing")
if not mushroomClearing then
    mushroomClearing = Instance.new("Folder")
    mushroomClearing.Name = "MushroomClearing"
    mushroomClearing.Parent = map
end
for i = 1, 8 do
    local angle = (i / 8) * math.pi * 2
    local mx = -80 + (math.cos(angle) * 22)
    local mz = -950 + (math.sin(angle) * 22)
    local mushStem = createPart("MushroomStem_" .. i, mushroomClearing, Vector3.new(1.2, 2.5, 1.2), CFrame.new(mx, 1.2, mz), Color3.fromRGB(225, 220, 205), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
    local mushCap = createPart("MushroomCap_" .. i, mushroomClearing, Vector3.new(3.2, 1.6, 3.2), CFrame.new(mx, 2.6, mz), Color3.fromRGB(40, 210, 180), Enum.Material.Neon, Enum.PartType.Ball)
    mushCap.CanCollide = false
    local mLight = Instance.new("PointLight")
    mLight.Color = Color3.fromRGB(40, 210, 180)
    mLight.Range = 12
    mLight.Brightness = 1.2
    mLight.Parent = mushCap
end

-- Whispering Woods Landmark 5: Watcher's Bluff Lookout (X = 210, Z = -880)
local bluff = map:FindFirstChild("DetailedWatcherBluff")
if bluff then
    bluff:PivotTo(CFrame.new(210, 15, -880))
end

-- Populate 140+ Trees and Rocks across the 900-stud Whispering Woods depth!
local treesFolder = map:FindFirstChild("Trees")
if not treesFolder then
    treesFolder = Instance.new("Folder")
    treesFolder.Name = "Trees"
    treesFolder.Parent = map
end

local scatterFolder = map:FindFirstChild("ForestScatter")
if not scatterFolder then
    scatterFolder = Instance.new("Folder")
    scatterFolder.Name = "ForestScatter"
    scatterFolder.Parent = map
end

-- Procedural Tree Grid across Whispering Woods (Z = -260 to -1140, X = -280 to 280)
local treeIndex = 0
for z = -260, -1140, -45 do
    for x = -280, 280, 55 do
        treeIndex = treeIndex + 1
        -- Add natural pseudo-random jitter
        local jx = x + math.sin(treeIndex * 7.3) * 16
        local jz = z + math.cos(treeIndex * 5.1) * 16

        -- Avoid placing trees directly on the trail or river
        local onTrail = math.abs(jx) < 18 and jz > -400
        local onRiver = math.abs(jz - (-450)) < 24
        local onPond = (Vector3.new(jx, 0, jz) - Vector3.new(160, 0, -720)).Magnitude < 55
        local onSplitOak = (Vector3.new(jx, 0, jz) - Vector3.new(-120, 0, -650)).Magnitude < 40

        if not onTrail and not onRiver and not onPond and not onSplitOak then
            local tType = (treeIndex % 3 == 0) and "Pine" or ((treeIndex % 3 == 1) and "Birch" or "Broadleaf")
            local tScale = 0.85 + (math.abs(math.sin(treeIndex * 1.7)) * 0.45)
            createTree("ForestTree_" .. treeIndex, treesFolder, Vector3.new(jx, 0, jz), tScale, tType)

            -- Scatter occasional boulders
            if treeIndex % 4 == 0 then
                createBoulder("ForestBoulder_" .. treeIndex, scatterFolder, Vector3.new(jx + 12, 1.5, jz + 10), Vector3.new(6, 4, 7), Vector3.new(10, treeIndex * 15, 12))
            end
        end
    end
end

print("[GrandValley] Step 5: Constructing Abandoned Village at Z = -1150 to -1800...")

-- ============================================================================
-- 5. ABANDONED VILLAGE (Z = -1150 to -1800)
-- ============================================================================

-- Old Stone Bridge crossing gorge at Z = -1150
local bridge = map:FindFirstChild("OldStoneBridge")
if not bridge then
    bridge = createPart("OldStoneBridge", map, Vector3.new(24, 4, 70), CFrame.new(0, 2, -1150), Color3.fromRGB(75, 72, 68), Enum.Material.Cobblestone)
else
    bridge.Size = Vector3.new(24, 4, 70)
    bridge.CFrame = CFrame.new(0, 2, -1150)
    bridge.Material = Enum.Material.Cobblestone
end

local detailedBridge = map:FindFirstChild("DetailedStoneBridge")
if detailedBridge then
    detailedBridge:PivotTo(CFrame.new(0, 2, -1150))
end

-- Fortified Village Gate at Z = -1190
local gate = interactables:FindFirstChild("LockedVillageGate")
if not gate then
    gate = createPart("LockedVillageGate", interactables, Vector3.new(22, 18, 2.5), CFrame.new(0, 9, -1190), Color3.fromRGB(80, 50, 30), Enum.Material.WoodPlanks)
else
    gate.CFrame = CFrame.new(0, 9, -1190)
    gate.Size = Vector3.new(22, 18, 2.5)
end

local gatePrompt = gate:FindFirstChild("ProximityPrompt")
if not gatePrompt then
    gatePrompt = Instance.new("ProximityPrompt")
    gatePrompt.ActionText = "Unlock Village Gate"
    gatePrompt.ObjectText = "Heavy Timber Gate"
    gatePrompt.HoldDuration = 1.0
    gatePrompt.MaxActivationDistance = 10
    gatePrompt.Parent = gate
end

local detailedGate = map:FindFirstChild("DetailedVillageGateArch")
if detailedGate then
    detailedGate:PivotTo(CFrame.new(0, 8, -1190))
end

-- Village Square & Overgrown Well at Z = -1475
local square = map:FindFirstChild("VillageSquare")
if not square then
    square = createPart("VillageSquare", map, Vector3.new(140, 0.4, 140), CFrame.new(0, 0.2, -1475), Color3.fromRGB(85, 82, 78), Enum.Material.Cobblestone)
else
    square.Size = Vector3.new(140, 0.4, 140)
    square.CFrame = CFrame.new(0, 0.2, -1475)
end

local well = map:FindFirstChild("OvergrownWell")
if not well then
    well = createPart("OvergrownWell", map, Vector3.new(10, 4, 10), CFrame.new(0, 2, -1475), Color3.fromRGB(70, 72, 75), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
else
    well.CFrame = CFrame.new(0, 2, -1475)
end

local detailedWell = map:FindFirstChild("DetailedWellStructure")
if detailedWell then
    detailedWell:PivotTo(CFrame.new(0, 2, -1475))
end

-- Village Clock Tower (48 studs tall at X = 70, Z = -1475)
local clockTowerModel = map:FindFirstChild("VillageClockTower")
if clockTowerModel then clockTowerModel:Destroy() end
clockTowerModel = Instance.new("Model")
clockTowerModel.Name = "VillageClockTower"
clockTowerModel.Parent = map

createPart("CT_Base", clockTowerModel, Vector3.new(18, 14, 18), CFrame.new(70, 7, -1475), Color3.fromRGB(68, 70, 72), Enum.Material.Cobblestone)
createPart("CT_Middle", clockTowerModel, Vector3.new(14, 24, 14), CFrame.new(70, 26, -1475), Color3.fromRGB(75, 78, 80), Enum.Material.Slate)
createPart("CT_ClockBelfry", clockTowerModel, Vector3.new(16, 12, 16), CFrame.new(70, 44, -1475), Color3.fromRGB(85, 55, 35), Enum.Material.WoodPlanks)
createPart("CT_PitchedRoof", clockTowerModel, Vector3.new(18, 10, 18), CFrame.new(70, 55, -1475), Color3.fromRGB(50, 40, 35), Enum.Material.Slate)
local clockFace = createPart("CT_ClockFace", clockTowerModel, Vector3.new(8, 8, 0.5), CFrame.new(70, 44, -1466.8), Color3.fromRGB(240, 235, 215), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
clockFace.CanCollide = false

-- Reposition or Create 5 Village Ruined Cottages, Town Archive, and Blacksmith Workshop
local villageBuildings = map:FindFirstChild("VillageBuildings")
if villageBuildings then villageBuildings:Destroy() end
villageBuildings = Instance.new("Folder")
villageBuildings.Name = "VillageBuildings"
villageBuildings.Parent = map

local buildingLayouts = {
    {name = "TownArchive", pos = Vector3.new(-65, 0, -1450), size = Vector3.new(28, 14, 24), color = Color3.fromRGB(75, 70, 65)},
    {name = "BlacksmithWorkshop", pos = Vector3.new(-60, 0, -1510), size = Vector3.new(26, 12, 22), color = Color3.fromRGB(65, 62, 60)},
    {name = "RuinedCottage_1", pos = Vector3.new(65, 0, -1410), size = Vector3.new(22, 10, 20), color = Color3.fromRGB(80, 75, 70)},
    {name = "RuinedCottage_2", pos = Vector3.new(60, 0, -1530), size = Vector3.new(24, 11, 20), color = Color3.fromRGB(78, 73, 68)},
    {name = "RuinedCottage_3", pos = Vector3.new(-70, 0, -1380), size = Vector3.new(20, 10, 18), color = Color3.fromRGB(75, 72, 68)},
    {name = "KeeperHallRuins", pos = Vector3.new(0, 0, -1620), size = Vector3.new(38, 16, 32), color = Color3.fromRGB(60, 62, 65)},
}

for _, b in ipairs(buildingLayouts) do
    local bModel = Instance.new("Model")
    bModel.Name = b.name
    bModel.Parent = villageBuildings

    -- Walls
    createPart("Floor", bModel, Vector3.new(b.size.X, 1, b.size.Z), CFrame.new(b.pos.X, 0.5, b.pos.Z), b.color, Enum.Material.Cobblestone)
    createPart("WallNorth", bModel, Vector3.new(b.size.X, b.size.Y, 1.5), CFrame.new(b.pos.X, b.size.Y / 2, b.pos.Z - b.size.Z / 2), b.color, Enum.Material.Cobblestone)
    createPart("WallSouth", bModel, Vector3.new(b.size.X, b.size.Y, 1.5), CFrame.new(b.pos.X, b.size.Y / 2, b.pos.Z + b.size.Z / 2), b.color, Enum.Material.Cobblestone)
    createPart("WallWest", bModel, Vector3.new(1.5, b.size.Y, b.size.Z), CFrame.new(b.pos.X - b.size.X / 2, b.size.Y / 2, b.pos.Z), b.color, Enum.Material.Cobblestone)
    createPart("WallEast", bModel, Vector3.new(1.5, b.size.Y, b.size.Z), CFrame.new(b.pos.X + b.size.X / 2, b.size.Y / 2, b.pos.Z), b.color, Enum.Material.Cobblestone)
    -- Partially collapsed roof
    createPart("RuinedRoof", bModel, Vector3.new(b.size.X + 2, 1.5, b.size.Z * 0.65), CFrame.new(b.pos.X, b.size.Y + 0.75, b.pos.Z - b.size.Z * 0.15) * CFrame.Angles(0, 0, math.rad(6)), Color3.fromRGB(60, 48, 38), Enum.Material.WoodPlanks)
end

-- Move StoryClue_Archive to the TownArchive building
local archiveClue = interactables:FindFirstChild("StoryClue_Archive")
if archiveClue then
    archiveClue.CFrame = CFrame.new(-65, 3, -1450)
else
    archiveClue = createPart("StoryClue_Archive", interactables, Vector3.new(2, 0.6, 2), CFrame.new(-65, 2, -1450), Color3.fromRGB(215, 205, 180), Enum.Material.SmoothPlastic)
    local cPrompt = Instance.new("ProximityPrompt")
    cPrompt.ActionText = "Read Keeper Record"
    cPrompt.ObjectText = "Village Archive Ledger"
    cPrompt.HoldDuration = 0.5
    cPrompt.MaxActivationDistance = 8
    cPrompt.Parent = archiveClue
end

print("[GrandValley] Step 6: Constructing Crystal Caverns at Z = -1800 to -2400...")

-- ============================================================================
-- 6. CRYSTAL CAVERNS (Z = -1800 to -2400)
-- ============================================================================

-- Mountain Gorge Gateway framing Cavern entrance at Z = -1810
local gorgeEntrance = map:FindFirstChild("CavernGorgeEntrance")
if gorgeEntrance then gorgeEntrance:Destroy() end
gorgeEntrance = Instance.new("Model")
gorgeEntrance.Name = "CavernGorgeEntrance"
gorgeEntrance.Parent = map

createPart("GorgePillarL", gorgeEntrance, Vector3.new(40, 70, 45), CFrame.new(-65, 33, -1815), Color3.fromRGB(48, 50, 55), Enum.Material.Basalt)
createPart("GorgePillarR", gorgeEntrance, Vector3.new(40, 70, 45), CFrame.new(65, 33, -1815), Color3.fromRGB(48, 50, 55), Enum.Material.Basalt)
createPart("GorgeArchLintel", gorgeEntrance, Vector3.new(110, 20, 40), CFrame.new(0, 68, -1815), Color3.fromRGB(42, 45, 50), Enum.Material.Basalt)

-- Cavern Roof / Enclosing Vault (Z = -1850 to -2350)
local cavernRoof = map:FindFirstChild("CavernVaultCeiling")
if cavernRoof then cavernRoof:Destroy() end
cavernRoof = Instance.new("Model")
cavernRoof.Name = "CavernVaultCeiling"
cavernRoof.Parent = map

for cz = -1860, -2340, -90 do
    local roofPart = createPart("CeilingVault_" .. cz, cavernRoof, Vector3.new(620, 16, 95), CFrame.new(0, 62, cz), Color3.fromRGB(32, 34, 38), Enum.Material.Basalt)
    -- Stalactites hanging from ceiling
    for sx = -200, 200, 90 do
        local sH = 18 + math.abs(math.sin(sx * 0.1)) * 12
        createPart("Stalactite_" .. sx .. "_" .. cz, cavernRoof, Vector3.new(4, sH, 4), CFrame.new(sx, 54 - sH/2, cz), Color3.fromRGB(45, 48, 52), Enum.Material.Basalt, Enum.PartType.Cylinder)
    end
end

-- Cavern Interior Props & Glowing Crystal Formations
local crystalGrotto = map:FindFirstChild("CrystalGrottoProps")
if crystalGrotto then crystalGrotto:Destroy() end
crystalGrotto = Instance.new("Folder")
crystalGrotto.Name = "CrystalGrottoProps"
crystalGrotto.Parent = map

local crystalColors = {
    Color3.fromRGB(0, 240, 255),   -- Glowing Cyan
    Color3.fromRGB(185, 65, 255),  -- Deep Amethyst
    Color3.fromRGB(45, 255, 155),  -- Emerald
}

for i = 1, 24 do
    local angle = (i / 24) * math.pi * 2
    local r = 120 + ((i % 5) * 28)
    local cx = math.cos(angle) * r
    local cz = -2100 + (math.sin(angle) * r)
    local col = crystalColors[(i % #crystalColors) + 1]
    local cHeight = 16 + ((i % 6) * 4)

    -- Giant Glowing Spire
    local cPart = createPart("GiantCrystal_" .. i, crystalGrotto, Vector3.new(4, cHeight, 4), CFrame.new(cx, cHeight / 2 - 6, cz) * CFrame.Angles(math.rad(i * 5), math.rad(i * 15), math.rad(i * 8)), col, Enum.Material.Neon)
    cPart.CanCollide = true

    local cLight = Instance.new("PointLight")
    cLight.Color = col
    cLight.Range = 32
    cLight.Brightness = 2.8
    cLight.Parent = cPart

    -- Associated Crystal Ore Resource Node for player harvesting
    local cNode = createPart("CrystalOreNode_" .. i, resourceFolder, Vector3.new(5, 3.5, 5), CFrame.new(cx + 4, -4, cz + 3), Color3.fromRGB(50, 55, 65), Enum.Material.Basalt)
    cNode:SetAttribute("ResourceType", "crystal")
    cNode:SetAttribute("RemainingYield", 6)
    cNode:SetAttribute("MaxYield", 6)
    cNode:SetAttribute("EffectiveTool", "Pickaxe")
    CollectionService:AddTag(cNode, "TFF_ResourceNode")
end

-- Cavern Trestle Bridge & Rail Line
local trestleBridge = createPart("CavernTrestleBridge", crystalGrotto, Vector3.new(22, 4, 220), CFrame.new(0, -2, -2100), Color3.fromRGB(75, 48, 28), Enum.Material.WoodPlanks)
createPart("MineTrackRailL", crystalGrotto, Vector3.new(0.6, 0.4, 220), CFrame.new(-6, 0.2, -2100), Color3.fromRGB(45, 45, 48), Enum.Material.Metal)
createPart("MineTrackRailR", crystalGrotto, Vector3.new(0.6, 0.4, 220), CFrame.new(6, 0.2, -2100), Color3.fromRGB(45, 45, 48), Enum.Material.Metal)

print("[GrandValley] Step 7: Constructing Ancient Grounds & Boss Arena at Z = -2400 to -3150...")

-- ============================================================================
-- 7. ANCIENT GROUNDS & BOSS ARENA (Z = -2400 to -3150)
-- ============================================================================

-- Reposition/Resize Boss Arena
local bossArena = map:FindFirstChild("BossArena")
if not bossArena then
    bossArena = Instance.new("Folder")
    bossArena.Name = "BossArena"
    bossArena.Parent = map
end

local arenaFloor = bossArena:FindFirstChild("ArenaFloor")
if not arenaFloor then
    arenaFloor = createPart("ArenaFloor", bossArena, Vector3.new(220, 2, 220), CFrame.new(0, 7.2, -2775), Color3.fromRGB(50, 52, 56), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
else
    arenaFloor.CFrame = CFrame.new(0, 7.2, -2775)
    arenaFloor.Size = Vector3.new(220, 2, 220)
end

-- 8 Massive Megalith Pillars forming the perimeter ritual circle
for i = 1, 8 do
    local angle = (i / 8) * math.pi * 2
    local px = math.cos(angle) * 98
    local pz = -2775 + (math.sin(angle) * 98)

    local pillar = bossArena:FindFirstChild("AncientPillar_" .. i)
    if not pillar then
        pillar = createPart("AncientPillar_" .. i, bossArena, Vector3.new(7, 32, 7), CFrame.new(px, 23, pz), Color3.fromRGB(65, 68, 72), Enum.Material.Basalt)
    else
        pillar.CFrame = CFrame.new(px, 23, pz)
        pillar.Size = Vector3.new(7, 32, 7)
    end

    local plinth = bossArena:FindFirstChild("PillarPlinth_" .. i)
    if not plinth then
        plinth = createPart("PillarPlinth_" .. i, bossArena, Vector3.new(11, 4, 11), CFrame.new(px, 9.2, pz), Color3.fromRGB(75, 78, 82), Enum.Material.Cobblestone)
    else
        plinth.CFrame = CFrame.new(px, 9.2, pz)
    end

    -- Glowing Runic Inscription on Pillar facing center
    local rune = bossArena:FindFirstChild("PillarRuneStrip_" .. i)
    local toCenter = (Vector3.new(0, 23, -2775) - Vector3.new(px, 23, pz)).Unit
    if not rune then
        rune = createPart("PillarRuneStrip_" .. i, bossArena, Vector3.new(2.5, 20, 0.4), CFrame.new(Vector3.new(px, 23, pz) + toCenter * 3.6, Vector3.new(0, 23, -2775)), Color3.fromRGB(0, 220, 200), Enum.Material.Neon)
        rune.CanCollide = false
    else
        rune.CFrame = CFrame.new(Vector3.new(px, 23, pz) + toCenter * 3.6, Vector3.new(0, 23, -2775))
    end
end

-- 5 Ancient Seals positioned across the Ritual Ground
local sealCoords = {
    Vector3.new(-65, 8.5, -2730),
    Vector3.new(65, 8.5, -2730),
    Vector3.new(-75, 8.5, -2820),
    Vector3.new(75, 8.5, -2820),
    Vector3.new(0, 8.5, -2845),
}

for i = 1, 5 do
    local s = interactables:FindFirstChild("AncientSeal_" .. i)
    if not s then
        s = createPart("AncientSeal_" .. i, interactables, Vector3.new(6, 2, 6), CFrame.new(sealCoords[i]), Color3.fromRGB(80, 85, 90), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
    else
        s.CFrame = CFrame.new(sealCoords[i])
        s.Size = Vector3.new(6, 2, 6)
    end

    s:SetAttribute("SealIndex", i)
    s:SetAttribute("Activated", false)

    local sPrompt = s:FindFirstChild("ProximityPrompt")
    if not sPrompt then
        sPrompt = Instance.new("ProximityPrompt")
        sPrompt.ActionText = "Channel Ancient Seal"
        sPrompt.ObjectText = "Runic Seal Stone " .. i
        sPrompt.HoldDuration = 2.0
        sPrompt.MaxActivationDistance = 9
        sPrompt.Parent = s
    end

    -- Seal Core Glowing Jewel
    local co = map:FindFirstChild("SealCore_" .. i)
    if not co then
        co = createPart("SealCore_" .. i, map, Vector3.new(2.2, 2.2, 2.2), CFrame.new(sealCoords[i].X, 10.2, sealCoords[i].Z), Color3.fromRGB(0, 240, 220), Enum.Material.Neon, Enum.PartType.Ball)
        co.CanCollide = false
    else
        co.CFrame = CFrame.new(sealCoords[i].X, 10.2, sealCoords[i].Z)
    end

    -- Light Beam
    local bm = map:FindFirstChild("SealLightBeam_" .. i)
    if not bm then
        bm = createPart("SealLightBeam_" .. i, map, Vector3.new(1.2, 38, 1.2), CFrame.new(sealCoords[i].X, 29, sealCoords[i].Z), Color3.fromRGB(0, 240, 220), Enum.Material.Neon, Enum.PartType.Cylinder)
        bm.Transparency = 0.5
        bm.CanCollide = false
    else
        bm.CFrame = CFrame.new(sealCoords[i].X, 29, sealCoords[i].Z)
    end
end

-- Reposition the Colossal Elder Heartwood Tree at the North Rim of Ancient Grounds (Z = -2920)
local elderTree = map:FindFirstChild("AncientHeartwoodTree")
if elderTree then
    elderTree:PivotTo(CFrame.new(0, 7.5, -2920))
end

-- Boss Crystal Heart inside Elder Tree core
local bossHeart = map:FindFirstChild("ForestGuardianCrystalHeart")
if bossHeart then bossHeart:Destroy() end
bossHeart = createPart("ForestGuardianCrystalHeart", map, Vector3.new(6, 9, 6), CFrame.new(0, 26, -2920), Color3.fromRGB(0, 255, 230), Enum.Material.Neon, Enum.PartType.Ball)
bossHeart.CanCollide = false

local heartLight = Instance.new("PointLight")
heartLight.Color = Color3.fromRGB(0, 255, 230)
heartLight.Range = 45
heartLight.Brightness = 4.0
heartLight.Parent = bossHeart

print("[GrandValley] Step 8: Configuring Region Discovery Zone Volumes...")

-- ============================================================================
-- 8. REGION DISCOVERY ZONE VOLUMES (for Map, UI, Weather, Audio)
-- ============================================================================

local zoneDefs = {
    {name = "SafeHavenZone", minZ = -250, maxZ = 120, minX = -250, maxX = 250, displayName = "Safe Haven"},
    {name = "WhisperingWoodsZone", minZ = -1150, maxZ = -250, minX = -350, maxX = 350, displayName = "Whispering Woods"},
    {name = "AbandonedVillageZone", minZ = -1800, maxZ = -1150, minX = -330, maxX = 330, displayName = "Abandoned Village"},
    {name = "CrystalCavernsZone", minZ = -2400, maxZ = -1800, minX = -300, maxX = 300, displayName = "Crystal Caverns"},
    {name = "AncientGroundsZone", minZ = -3150, maxZ = -2400, minX = -350, maxX = 350, displayName = "Ancient Grounds"},
}

for _, zd in ipairs(zoneDefs) do
    local zPart = zonesFolder:FindFirstChild(zd.name)
    local width = zd.maxX - zd.minX
    local depth = zd.maxZ - zd.minZ
    local centerX = (zd.minX + zd.maxX) / 2
    local centerZ = (zd.minZ + zd.maxZ) / 2

    if not zPart then
        zPart = Instance.new("Part")
        zPart.Name = zd.name
        zPart.Parent = zonesFolder
    end

    zPart.Size = Vector3.new(width, 100, depth)
    zPart.CFrame = CFrame.new(centerX, 45, centerZ)
    zPart.Transparency = 1
    zPart.CanCollide = false
    zPart.Anchored = true
    zPart:SetAttribute("RegionId", zd.name)
    zPart:SetAttribute("DisplayName", zd.displayName)
    CollectionService:AddTag(zPart, "TFF_RegionZone")
end

-- ============================================================================
-- 9. ANCHOR & VERIFICATION CHECK
-- ============================================================================

local unanchoredCount = 0
for _, d in ipairs(tffWorld:GetDescendants()) do
    if d:IsA("BasePart") and not d.Anchored then
        d.Anchored = true
        unanchoredCount = unanchoredCount + 1
    end
end

print(string.format("[GrandValley] BUILD SUCCESSFUL! Fixed %d unanchored parts. Total world Z-span: 3,270 studs (Z = +120 to -3150).", unanchoredCount))
return true
