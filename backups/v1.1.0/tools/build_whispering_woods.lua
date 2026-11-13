--!strict
--[[
    build_whispering_woods.lua
    Procedural detailed low-poly overhaul for Whispering Woods:
    - Tiered Fir/Pine trees, Broadleaf Oaks, and Silver Birch trees
    - Mossy hollow log crossing over the creek with shelf mushrooms
    - Glowing fairy-ring mushroom clearing with spore particles and luminescent caps
    - Abandoned expedition cart, spilled cargo, and weathered campsite props
    - Watcher's Bluff rocky scenic overlook with rope railings and ancient stone cairn
    - Ground scatter: wild ferns, grass tufts, river stones, and fireflies
]]

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local tffWorld = Workspace:FindFirstChild("TFF_World")
if not tffWorld then
    error("TFF_World not found in Workspace")
end

local map = tffWorld:FindFirstChild("Map")
if not map then
    error("Map folder not found in TFF_World")
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
    if shape then
        p.Shape = shape
    end
    p.Parent = parent
    return p
end

-- Helper: Create WedgePart
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
-- 1. CREEK & HOLLOW LOG ENHANCEMENT
-- ============================================================================
local creek = map:FindFirstChild("Creek")
if creek and creek:IsA("BasePart") then
    creek.Material = Enum.Material.Glass
    creek.Transparency = 0.35
    creek.Color = Color3.fromRGB(30, 95, 140)
    creek.Reflectance = 0.25
    creek.CanCollide = false
    
    -- Add creek bed underneath
    local creekBed = map:FindFirstChild("CreekBed")
    if not creekBed then
        creekBed = createPart("CreekBed", map, Vector3.new(creek.Size.X, 1, creek.Size.Z), creek.CFrame * CFrame.new(0, -0.6, 0), Color3.fromRGB(50, 45, 40), Enum.Material.Cobblestone)
    end
end

-- Detail the Fallen Log Crossing
local logCrossing = map:FindFirstChild("FallenLogCrossing")
if logCrossing and logCrossing:IsA("BasePart") then
    -- Make the base collision block invisible or semi-visible as support, build rich low poly log over it
    logCrossing.Transparency = 1
    logCrossing.CanCollide = true -- keep collision for player walking & tests

    local detailedLogModel = map:FindFirstChild("DetailedLogCrossing")
    if detailedLogModel then detailedLogModel:Destroy() end
    detailedLogModel = Instance.new("Model")
    detailedLogModel.Name = "DetailedLogCrossing"
    detailedLogModel.Parent = map

    local centerPos = logCrossing.Position
    -- Main arched log trunk (cylinder oriented along Z)
    local mainLog = createPart("MainLogTrunk", detailedLogModel, Vector3.new(28, 4.2, 4.2), CFrame.new(centerPos.X, centerPos.Y - 0.2, centerPos.Z) * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(75, 48, 28), Enum.Material.Wood, Enum.PartType.Cylinder)
    mainLog.CanCollide = false

    -- Hollow carved walking trough / bridge planking
    local walkway = createPart("LogWalkway", detailedLogModel, Vector3.new(4, 0.6, 26), CFrame.new(centerPos.X, centerPos.Y + 0.5, centerPos.Z), Color3.fromRGB(90, 60, 35), Enum.Material.WoodPlanks)
    walkway.CanCollide = true

    -- Moss patches along the log top and sides
    for i = -10, 10, 5 do
        local moss = createPart("MossPatch", detailedLogModel, Vector3.new(3.8, 0.3, 3.5), CFrame.new(centerPos.X + ((i % 2 == 0) and 0.5 or -0.5), centerPos.Y + 0.8, centerPos.Z + i), Color3.fromRGB(55, 110, 45), Enum.Material.Grass)
        moss.CanCollide = false
    end

    -- Shelf mushrooms sprouting from sides
    for i = -8, 8, 4 do
        local side = (i % 2 == 0) and 2.2 or -2.2
        local shelf = createPart("ShelfMushroom", detailedLogModel, Vector3.new(1.8, 0.3, 1.8), CFrame.new(centerPos.X + side, centerPos.Y + 0.2, centerPos.Z + i) * CFrame.Angles(math.rad((i % 2 == 0) and 15 or -15), 0, 0), Color3.fromRGB(190, 130, 80), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
        shelf.CanCollide = false
    end

    -- Fallen root clump on south bank
    local rootBase = createPart("RootBase", detailedLogModel, Vector3.new(7, 4, 5), CFrame.new(centerPos.X - 3, centerPos.Y + 0.5, centerPos.Z + 13) * CFrame.Angles(math.rad(10), math.rad(25), 0), Color3.fromRGB(60, 38, 22), Enum.Material.Wood)
    rootBase.CanCollide = true
end

-- ============================================================================
-- 2. GLOWING MUSHROOM CLEARING OVERHAUL
-- ============================================================================
local mushroomClearing = map:FindFirstChild("MushroomClearing")
if mushroomClearing then
    -- Keep existing test parts, upgrade appearance
    local giantCap = mushroomClearing:FindFirstChild("GiantMushroom")
    if giantCap and giantCap:IsA("BasePart") then
        giantCap.Color = Color3.fromRGB(150, 45, 200)
        giantCap.Material = Enum.Material.Neon
        
        -- Add soft mystical light to giant mushroom
        local light = giantCap:FindFirstChild("CapLight")
        if not light then
            light = Instance.new("PointLight")
            light.Name = "CapLight"
            light.Color = Color3.fromRGB(180, 80, 255)
            light.Range = 25
            light.Brightness = 2
            light.Parent = giantCap
        end

        -- Spore particles
        local spores = giantCap:FindFirstChild("Spores")
        if not spores then
            spores = Instance.new("ParticleEmitter")
            spores.Name = "Spores"
            spores.Color = ColorSequence.new(Color3.fromRGB(200, 120, 255), Color3.fromRGB(120, 200, 255))
            spores.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(1, 0.1)
            })
            spores.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.8, 0.4),
                NumberSequenceKeypoint.new(1, 1)
            })
            spores.Rate = 8
            spores.Speed = NumberRange.new(1, 3)
            spores.Lifetime = NumberRange.new(3, 6)
            spores.SpreadAngle = Vector2.new(45, 45)
            spores.Acceleration = Vector3.new(0, 0.5, 0)
            spores.Parent = giantCap
        end
    end

    local giantStem = mushroomClearing:FindFirstChild("GiantMushroomStem")
    if giantStem and giantStem:IsA("BasePart") then
        giantStem.Color = Color3.fromRGB(225, 215, 195)
        giantStem.Material = Enum.Material.SmoothPlastic
    end

    -- Clear old generated sub-clearing models if any
    local detailedRing = mushroomClearing:FindFirstChild("DetailedFairyRing")
    if detailedRing then detailedRing:Destroy() end
    detailedRing = Instance.new("Folder")
    detailedRing.Name = "DetailedFairyRing"
    detailedRing.Parent = mushroomClearing

    -- Build fairy ring of 12 glowing low-poly mushrooms in circle of radius 14
    local ringCenter = Vector3.new(-60, 0.5, -230)
    local colors = {
        Color3.fromRGB(0, 230, 255),  -- Cyan
        Color3.fromRGB(190, 80, 255), -- Purple
        Color3.fromRGB(255, 180, 40), -- Amber
        Color3.fromRGB(60, 255, 140)  -- Emerald
    }

    for i = 1, 12 do
        local angle = (i / 12) * math.pi * 2
        local r = 12 + ((i % 3) * 1.5)
        local posX = ringCenter.X + math.cos(angle) * r
        local posZ = ringCenter.Z + math.sin(angle) * r
        local stemHeight = 1.6 + ((i % 4) * 0.4)
        local col = colors[(i % #colors) + 1]

        -- Stem
        local stem = createPart("RingStem_" .. i, detailedRing, Vector3.new(0.5, stemHeight, 0.5), CFrame.new(posX, stemHeight / 2, posZ), Color3.fromRGB(230, 220, 205), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
        stem.CanCollide = false

        -- Cap (low-poly tiered cap)
        local capSize = 1.8 + ((i % 3) * 0.4)
        local cap = createPart("RingCap_" .. i, detailedRing, Vector3.new(capSize, 0.7, capSize), CFrame.new(posX, stemHeight + 0.3, posZ), col, Enum.Material.Neon, Enum.PartType.Cylinder)
        cap.CanCollide = false

        -- Cap light
        local pLight = Instance.new("PointLight")
        pLight.Color = col
        pLight.Range = 8
        pLight.Brightness = 1.2
        pLight.Parent = cap
    end
end

-- ============================================================================
-- 3. ABANDONED CAMPSITE OVERHAUL (EXPEDITION WAGON & GEAR)
-- ============================================================================
local campsite = map:FindFirstChild("AbandonedCampsite")
if campsite then
    local campCenter = Vector3.new(65, 0.5, -220)

    local detailedCamp = campsite:FindFirstChild("DetailedCampsiteProps")
    if detailedCamp then detailedCamp:Destroy() end
    detailedCamp = Instance.new("Model")
    detailedCamp.Name = "DetailedCampsiteProps"
    detailedCamp.Parent = campsite

    -- 1. Abandoned Expedition Wagon / Cart
    local cartPos = campCenter + Vector3.new(8, 0, -4)
    local cartCFrame = CFrame.new(cartPos) * CFrame.Angles(0, math.rad(25), math.rad(6)) -- slightly tilted

    -- Bed
    createPart("WagonBed", detailedCamp, Vector3.new(6, 0.8, 10), cartCFrame * CFrame.new(0, 1.6, 0), Color3.fromRGB(90, 58, 35), Enum.Material.WoodPlanks)
    -- Side rails
    createPart("WagonSideL", detailedCamp, Vector3.new(0.5, 1.8, 10), cartCFrame * CFrame.new(-3, 2.5, 0), Color3.fromRGB(80, 50, 30), Enum.Material.Wood)
    createPart("WagonSideR", detailedCamp, Vector3.new(0.5, 1.8, 10), cartCFrame * CFrame.new(3, 2.5, 0), Color3.fromRGB(80, 50, 30), Enum.Material.Wood)
    createPart("WagonBack", detailedCamp, Vector3.new(6, 1.8, 0.5), cartCFrame * CFrame.new(0, 2.5, -5), Color3.fromRGB(80, 50, 30), Enum.Material.Wood)
    -- Axle & tongue
    createPart("WagonTongue", detailedCamp, Vector3.new(0.8, 0.8, 6), cartCFrame * CFrame.new(0, 1.2, 7), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)

    -- Wheels (low poly cylinders)
    createPart("WagonWheelFL", detailedCamp, Vector3.new(3.2, 0.6, 3.2), cartCFrame * CFrame.new(-3.4, 1.2, 3.5) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
    createPart("WagonWheelFR", detailedCamp, Vector3.new(3.2, 0.6, 3.2), cartCFrame * CFrame.new(3.4, 1.2, 3.5) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
    createPart("WagonWheelBL", detailedCamp, Vector3.new(3.6, 0.6, 3.6), cartCFrame * CFrame.new(-3.4, 1.2, -3.5) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
    -- Broken detached rear-right wheel lying in the dirt
    createPart("BrokenWheel", detailedCamp, Vector3.new(3.6, 0.6, 3.6), CFrame.new(cartPos.X + 5, 0.4, cartPos.Z - 3) * CFrame.Angles(math.rad(78), math.rad(15), 0), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)

    -- Cargo in cart & spilled around
    createPart("SpilledCrate1", detailedCamp, Vector3.new(2.4, 2.4, 2.4), cartCFrame * CFrame.new(-1, 2.8, -1) * CFrame.Angles(0, math.rad(12), 0), Color3.fromRGB(115, 80, 50), Enum.Material.WoodPlanks)
    createPart("SpilledCrate2", detailedCamp, Vector3.new(2.2, 2.2, 2.2), cartCFrame * CFrame.new(1.2, 2.7, 1.5) * CFrame.Angles(0, math.rad(-18), 0), Color3.fromRGB(110, 75, 45), Enum.Material.WoodPlanks)
    createPart("FallenCrateGround", detailedCamp, Vector3.new(2.4, 2.4, 2.4), CFrame.new(cartPos.X - 5, 1.2, cartPos.Z + 1) * CFrame.Angles(math.rad(15), math.rad(35), math.rad(-10)), Color3.fromRGB(105, 72, 42), Enum.Material.WoodPlanks)

    -- Sacks
    createPart("GrainSack1", detailedCamp, Vector3.new(2.5, 1.4, 1.8), CFrame.new(cartPos.X - 4.5, 0.7, cartPos.Z - 2) * CFrame.Angles(0, math.rad(40), 0), Color3.fromRGB(160, 140, 110), Enum.Material.Fabric)
    createPart("GrainSack2", detailedCamp, Vector3.new(2.2, 1.2, 1.6), CFrame.new(cartPos.X - 4, 1.7, cartPos.Z - 2.2) * CFrame.Angles(0, math.rad(65), 0), Color3.fromRGB(150, 130, 100), Enum.Material.Fabric)

    -- Bedroll near tent
    createPart("WeatheredBedroll", detailedCamp, Vector3.new(3, 0.6, 6), CFrame.new(campCenter.X - 2, 0.4, campCenter.Z + 4) * CFrame.Angles(0, math.rad(20), 0), Color3.fromRGB(100, 90, 80), Enum.Material.Fabric)

    -- Unlit rusted iron lantern on barrel
    local barrel = createPart("CampBarrel", detailedCamp, Vector3.new(2.2, 3, 2.2), CFrame.new(campCenter.X - 6, 1.5, campCenter.Z - 2), Color3.fromRGB(85, 55, 30), Enum.Material.Wood, Enum.PartType.Cylinder)
    createPart("OldLantern", detailedCamp, Vector3.new(0.8, 1.2, 0.8), CFrame.new(barrel.Position.X, barrel.Position.Y + 2.1, barrel.Position.Z), Color3.fromRGB(45, 45, 45), Enum.Material.Metal)
end

-- ============================================================================
-- 4. WATCHER'S BLUFF SCENIC OVERLOOK OVERHAUL
-- ============================================================================
local overlook = map:FindFirstChild("WatcherOverlook")
if overlook and overlook:IsA("BasePart") then
    overlook.Color = Color3.fromRGB(65, 68, 65)
    overlook.Material = Enum.Material.Slate

    local detailedBluff = map:FindFirstChild("DetailedWatcherBluff")
    if detailedBluff then detailedBluff:Destroy() end
    detailedBluff = Instance.new("Model")
    detailedBluff.Name = "DetailedWatcherBluff"
    detailedBluff.Parent = map

    local bluffTop = overlook.Position + Vector3.new(0, overlook.Size.Y / 2, 0)

    -- 1. Rustic Timber Viewing Deck Platform
    local deck = createPart("DeckPlatform", detailedBluff, Vector3.new(18, 0.8, 18), CFrame.new(bluffTop.X, bluffTop.Y + 0.4, bluffTop.Z), Color3.fromRGB(85, 58, 35), Enum.Material.WoodPlanks)
    deck.CanCollide = true

    -- 2. Post-and-Rope Safety Railings around the cliff edge (3 exposed sides)
    local postCoords = {
        Vector3.new(deck.Position.X - 8, bluffTop.Y + 2, deck.Position.Z - 8),
        Vector3.new(deck.Position.X, bluffTop.Y + 2, deck.Position.Z - 8),
        Vector3.new(deck.Position.X + 8, bluffTop.Y + 2, deck.Position.Z - 8),
        Vector3.new(deck.Position.X + 8, bluffTop.Y + 2, deck.Position.Z),
        Vector3.new(deck.Position.X + 8, bluffTop.Y + 2, deck.Position.Z + 8),
        Vector3.new(deck.Position.X - 8, bluffTop.Y + 2, deck.Position.Z + 8),
        Vector3.new(deck.Position.X - 8, bluffTop.Y + 2, deck.Position.Z),
    }

    for idx, pPos in ipairs(postCoords) do
        createPart("RailingPost_" .. idx, detailedBluff, Vector3.new(0.8, 3.6, 0.8), CFrame.new(pPos), Color3.fromRGB(70, 45, 25), Enum.Material.Wood)
    end

    -- Horizontal timber guard rails connecting posts
    createPart("RailNorth", detailedBluff, Vector3.new(16, 0.4, 0.6), CFrame.new(deck.Position.X, bluffTop.Y + 3.2, deck.Position.Z - 8), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)
    createPart("RailEast", detailedBluff, Vector3.new(0.6, 0.4, 16), CFrame.new(deck.Position.X + 8, bluffTop.Y + 3.2, deck.Position.Z), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)
    createPart("RailWest", detailedBluff, Vector3.new(0.6, 0.4, 16), CFrame.new(deck.Position.X - 8, bluffTop.Y + 3.2, deck.Position.Z), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)

    -- 3. Ancient Stone Cairn (stacked stones with faint mystical aura)
    local cairnBase = Vector3.new(deck.Position.X - 4, bluffTop.Y + 0.8, deck.Position.Z + 4)
    createPart("CairnStone1", detailedBluff, Vector3.new(3.5, 1.2, 3.5), CFrame.new(cairnBase.X, cairnBase.Y + 0.6, cairnBase.Z), Color3.fromRGB(80, 80, 85), Enum.Material.Basalt)
    createPart("CairnStone2", detailedBluff, Vector3.new(2.6, 1.0, 2.6), CFrame.new(cairnBase.X, cairnBase.Y + 1.7, cairnBase.Z) * CFrame.Angles(0, math.rad(25), 0), Color3.fromRGB(75, 75, 80), Enum.Material.Basalt)
    createPart("CairnStone3", detailedBluff, Vector3.new(1.8, 0.8, 1.8), CFrame.new(cairnBase.X, cairnBase.Y + 2.6, cairnBase.Z) * CFrame.Angles(0, math.rad(-15), 0), Color3.fromRGB(70, 70, 75), Enum.Material.Basalt)
    local topRuneStone = createPart("CairnRuneStone", detailedBluff, Vector3.new(1.0, 1.6, 0.8), CFrame.new(cairnBase.X, cairnBase.Y + 3.8, cairnBase.Z) * CFrame.Angles(0, math.rad(45), math.rad(10)), Color3.fromRGB(60, 60, 65), Enum.Material.Slate)
    
    -- Inlaid glowing rune on top stone
    local runePart = createPart("RuneGlow", detailedBluff, Vector3.new(0.4, 0.8, 0.1), topRuneStone.CFrame * CFrame.new(0, 0, 0.41), Color3.fromRGB(0, 220, 255), Enum.Material.Neon)
    runePart.CanCollide = false
    local runeLight = Instance.new("PointLight")
    runeLight.Color = Color3.fromRGB(0, 200, 255)
    runeLight.Range = 10
    runeLight.Brightness = 1.5
    runeLight.Parent = runePart
end

-- ============================================================================
-- 5. RICH LOW-POLY FOREST TREES GENERATOR
-- ============================================================================
-- We replace or populate the Trees folder with high-quality stylized multi-part trees.
local treesFolder = map:FindFirstChild("Trees")
if not treesFolder then
    treesFolder = Instance.new("Folder")
    treesFolder.Name = "Trees"
    treesFolder.Parent = map
end

-- Clear old basic trees
treesFolder:ClearAllChildren()

-- Function to build a Low-Poly Pine/Fir Tree (Tiered Evergreen)
local function buildPineTree(parent: Instance, name: string, pos: Vector3, scale: number): Model
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent

    local s = scale or 1.0
    -- Trunk
    local trunkHeight = 16 * s
    local trunkRadius = 2.4 * s
    local trunk = createPart("Trunk", model, Vector3.new(trunkRadius, trunkHeight, trunkRadius), CFrame.new(pos.X, pos.Y + trunkHeight / 2, pos.Z), Color3.fromRGB(70, 45, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
    
    -- Tiered conical foliage layers (4 tiers)
    local tiers = {
        { y = 10 * s, w = 18 * s, h = 6 * s, col = Color3.fromRGB(28, 62, 35) },
        { y = 14 * s, w = 14 * s, h = 5 * s, col = Color3.fromRGB(34, 76, 42) },
        { y = 17 * s, w = 10 * s, h = 5 * s, col = Color3.fromRGB(42, 92, 50) },
        { y = 20 * s, w = 6 * s,  h = 5 * s, col = Color3.fromRGB(50, 108, 60) },
    }

    for idx, tier in ipairs(tiers) do
        -- Low-poly octagonal/block layered canopy
        local canopyA = createPart("Canopy_T" .. idx .. "A", model, Vector3.new(tier.w, tier.h, tier.w), CFrame.new(pos.X, pos.Y + tier.y, pos.Z) * CFrame.Angles(0, math.rad((idx * 30)), 0), tier.col, Enum.Material.Grass)
        canopyA.CanCollide = false
        local canopyB = createPart("Canopy_T" .. idx .. "B", model, Vector3.new(tier.w * 0.9, tier.h * 0.8, tier.w * 0.9), CFrame.new(pos.X, pos.Y + tier.y + 0.5, pos.Z) * CFrame.Angles(0, math.rad((idx * 30) + 45), 0), tier.col, Enum.Material.Grass)
        canopyB.CanCollide = false
    end

    -- Top cone peak
    local peak = createPart("CanopyPeak", model, Vector3.new(3 * s, 4 * s, 3 * s), CFrame.new(pos.X, pos.Y + (22 * s), pos.Z), Color3.fromRGB(55, 115, 65), Enum.Material.Grass)
    peak.CanCollide = false

    return model
end

-- Function to build a Broadleaf Ancient Oak Tree
local function buildOakTree(parent: Instance, name: string, pos: Vector3, scale: number): Model
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent

    local s = scale or 1.0
    -- Gnarled trunk
    local trunkHeight = 14 * s
    local trunkWidth = 3.2 * s
    local trunk = createPart("Trunk", model, Vector3.new(trunkWidth, trunkHeight, trunkWidth), CFrame.new(pos.X, pos.Y + trunkHeight / 2, pos.Z), Color3.fromRGB(80, 52, 30), Enum.Material.Wood)

    -- Root buttresses spreading out
    local rootDirs = {
        Vector3.new(2.5 * s, 0, 0),
        Vector3.new(-2.5 * s, 0, 0),
        Vector3.new(0, 0, 2.5 * s),
        Vector3.new(0, 0, -2.5 * s),
    }
    for rIdx, rOff in ipairs(rootDirs) do
        createPart("Root_" .. rIdx, model, Vector3.new(1.8 * s, 2.5 * s, 1.8 * s), CFrame.new(pos + rOff + Vector3.new(0, 1.2 * s, 0)), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)
    end

    -- Multi-clump cloud foliage
    local foliageClumps = {
        { off = Vector3.new(0, 15 * s, 0), sz = Vector3.new(15 * s, 9 * s, 15 * s), col = Color3.fromRGB(45, 95, 40) },
        { off = Vector3.new(5 * s, 13 * s, 3 * s), sz = Vector3.new(10 * s, 7 * s, 10 * s), col = Color3.fromRGB(52, 108, 48) },
        { off = Vector3.new(-4 * s, 13 * s, -4 * s), sz = Vector3.new(11 * s, 7 * s, 11 * s), col = Color3.fromRGB(38, 85, 35) },
        { off = Vector3.new(3 * s, 14 * s, -5 * s), sz = Vector3.new(9 * s, 7 * s, 9 * s), col = Color3.fromRGB(48, 102, 45) },
        { off = Vector3.new(-5 * s, 14 * s, 4 * s), sz = Vector3.new(10 * s, 7 * s, 10 * s), col = Color3.fromRGB(56, 115, 50) },
    }

    for fIdx, clump in ipairs(foliageClumps) do
        local cPart = createPart("CanopyClump_" .. fIdx, model, clump.sz, CFrame.new(pos + clump.off) * CFrame.Angles(0, math.rad(fIdx * 35), 0), clump.col, Enum.Material.Grass, Enum.PartType.Ball)
        cPart.CanCollide = false
    end

    return model
end

-- Function to build a Slender Silver/Mossy Birch Tree
local function buildBirchTree(parent: Instance, name: string, pos: Vector3, scale: number): Model
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent

    local s = scale or 1.0
    local trunkHeight = 18 * s
    local trunkRadius = 1.6 * s
    local trunk = createPart("Trunk", model, Vector3.new(trunkRadius, trunkHeight, trunkRadius), CFrame.new(pos.X, pos.Y + trunkHeight / 2, pos.Z), Color3.fromRGB(225, 222, 215), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)

    -- Dark bark markings (slight rings)
    for i = 3, 14, 3 do
        local ring = createPart("BarkMarking", model, Vector3.new(trunkRadius + 0.1, 0.4 * s, trunkRadius + 0.1), CFrame.new(pos.X, pos.Y + (i * s), pos.Z), Color3.fromRGB(45, 45, 45), Enum.Material.Slate, Enum.PartType.Cylinder)
        ring.CanCollide = false
    end

    -- High airy leaf clumps
    local clumps = {
        { off = Vector3.new(0, 17 * s, 0), sz = Vector3.new(8 * s, 8 * s, 8 * s), col = Color3.fromRGB(65, 135, 55) },
        { off = Vector3.new(2 * s, 15 * s, 1 * s), sz = Vector3.new(6 * s, 6 * s, 6 * s), col = Color3.fromRGB(75, 145, 60) },
        { off = Vector3.new(-2 * s, 14 * s, -1 * s), sz = Vector3.new(6 * s, 6 * s, 6 * s), col = Color3.fromRGB(58, 125, 50) },
    }
    for cIdx, c in ipairs(clumps) do
        local clump = createPart("BirchCanopy_" .. cIdx, model, c.sz, CFrame.new(pos + c.off), c.col, Enum.Material.Grass, Enum.PartType.Ball)
        clump.CanCollide = false
    end

    return model
end

-- Spawn a realistic distribution of 28 stylized trees across Whispering Woods
local treeCoords = {
    -- West forest area
    { type = "pine",  pos = Vector3.new(-35, 0, -195), s = 1.1 },
    { type = "oak",   pos = Vector3.new(-50, 0, -210), s = 1.0 },
    { type = "birch", pos = Vector3.new(-75, 0, -215), s = 0.95 },
    { type = "pine",  pos = Vector3.new(-90, 0, -235), s = 1.2 },
    { type = "oak",   pos = Vector3.new(-85, 0, -260), s = 1.05 },
    { type = "birch", pos = Vector3.new(-45, 0, -255), s = 1.0 },
    { type = "pine",  pos = Vector3.new(-65, 0, -270), s = 1.15 },
    { type = "pine",  pos = Vector3.new(-30, 0, -280), s = 1.0 },

    -- Central corridor & near creek
    { type = "birch", pos = Vector3.new(-15, 0, -165), s = 1.0 },
    { type = "oak",   pos = Vector3.new(20, 0, -160), s = 1.1 },
    { type = "pine",  pos = Vector3.new(-25, 0, -195), s = 1.05 },
    { type = "birch", pos = Vector3.new(22, 0, -195), s = 0.9 },
    { type = "pine",  pos = Vector3.new(-18, 0, -230), s = 1.1 },
    { type = "oak",   pos = Vector3.new(18, 0, -240), s = 1.15 },
    { type = "birch", pos = Vector3.new(-12, 0, -265), s = 1.0 },
    { type = "pine",  pos = Vector3.new(15, 0, -285), s = 1.2 },
    { type = "oak",   pos = Vector3.new(-20, 0, -310), s = 1.0 },
    { type = "birch", pos = Vector3.new(20, 0, -320), s = 1.05 },

    -- East forest area & campsite surrounds
    { type = "pine",  pos = Vector3.new(45, 0, -195), s = 1.1 },
    { type = "oak",   pos = Vector3.new(75, 0, -190), s = 1.0 },
    { type = "birch", pos = Vector3.new(85, 0, -210), s = 1.0 },
    { type = "pine",  pos = Vector3.new(50, 0, -245), s = 1.15 },
    { type = "oak",   pos = Vector3.new(78, 0, -240), s = 1.05 },
    { type = "birch", pos = Vector3.new(90, 0, -265), s = 0.95 },
    { type = "pine",  pos = Vector3.new(55, 0, -275), s = 1.2 },
    { type = "oak",   pos = Vector3.new(75, 0, -290), s = 1.1 },
    { type = "birch", pos = Vector3.new(40, 0, -305), s = 1.0 },
    { type = "pine",  pos = Vector3.new(65, 0, -320), s = 1.25 },
}

for i, t in ipairs(treeCoords) do
    local treeName = "Tree_" .. i
    if t.type == "pine" then
        buildPineTree(treesFolder, treeName, t.pos, t.s)
    elseif t.type == "oak" then
        buildOakTree(treesFolder, treeName, t.pos, t.s)
    elseif t.type == "birch" then
        buildBirchTree(treesFolder, treeName, t.pos, t.s)
    end
end

-- ============================================================================
-- 6. GROUND FOLIAGE, FERNS & FIREFLIES SCATTER
-- ============================================================================
local scatterFolder = map:FindFirstChild("ForestScatter")
if scatterFolder then scatterFolder:Destroy() end
scatterFolder = Instance.new("Folder")
scatterFolder.Name = "ForestScatter"
scatterFolder.Parent = map

-- Helper to make a low poly wild fern cluster
local function createFern(parent: Instance, name: string, pos: Vector3, scale: number)
    local s = scale or 1.0
    for i = 1, 5 do
        local angle = (i / 5) * math.pi * 2
        local f = createWedge(name .. "_Frond" .. i, parent, Vector3.new(0.4 * s, 1.4 * s, 2.5 * s), CFrame.new(pos) * CFrame.Angles(0, angle, 0) * CFrame.Angles(math.rad(-30), 0, 0) * CFrame.new(0, 0.6 * s, 1.2 * s), Color3.fromRGB(48, 120, 52), Enum.Material.Grass)
        f.CanCollide = false
    end
end

-- Scatter 20 fern clusters
for i = 1, 20 do
    local fx = ((i * 37) % 180) - 90
    local fz = -170 - ((i * 47) % 140)
    createFern(scatterFolder, "Fern_" .. i, Vector3.new(fx, 0.1, fz), 0.9 + ((i % 3) * 0.2))
end

-- Scatter riverbed stones along the creek banks
for i = -70, 70, 10 do
    local stoneSide = (i % 2 == 0) and -172 or -188
    local stone = createPart("RiverStone_" .. i, scatterFolder, Vector3.new(2.2, 0.8, 1.8), CFrame.new(i, 0.2, stoneSide) * CFrame.Angles(0, math.rad(i * 17), 0), Color3.fromRGB(85, 88, 85), Enum.Material.Pebble, Enum.PartType.Ball)
    stone.CanCollide = false
end

-- Fireflies floating in the dark woods
local fireflyEmitterHolder = createPart("FireflyNode", scatterFolder, Vector3.new(1, 1, 1), CFrame.new(0, 6, -240), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic)
fireflyEmitterHolder.Transparency = 1
fireflyEmitterHolder.CanCollide = false

local fireflies = Instance.new("ParticleEmitter")
fireflies.Name = "Fireflies"
fireflies.Color = ColorSequence.new(Color3.fromRGB(255, 235, 100), Color3.fromRGB(150, 255, 120))
fireflies.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.35),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 0.2)
})
fireflies.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.3, 0.1),
    NumberSequenceKeypoint.new(0.7, 0.1),
    NumberSequenceKeypoint.new(1, 1)
})
fireflies.Rate = 18
fireflies.Speed = NumberRange.new(0.8, 2.2)
fireflies.Lifetime = NumberRange.new(5, 10)
fireflies.SpreadAngle = Vector2.new(180, 180)
fireflies.Acceleration = Vector3.new(0, 0.1, 0)
fireflies.Parent = fireflyEmitterHolder

print("[build_whispering_woods] Whispering Woods low-poly overhaul completed successfully!")
return true
