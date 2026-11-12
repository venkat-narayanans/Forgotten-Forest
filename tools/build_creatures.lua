--!strict
--[[
    build_creatures.lua
    Procedural detailed low-poly sculpting for all 4 creature templates:
    1. The Stalker: Quadruped shadow predator with spine quills, clawed legs, angular jaw, and red ember eyes
    2. The Watcher: Slender hooded entity with bone mask, celestial third eye, and floating shroud
    3. The Mimic: Hinged fanged wooden chest with bronze banding, root legs, and fanged purple maw
    4. Forest Guardian Boss: 18-stud tall ancient treant golem with basalt pauldrons, root horns, and crystal heart
]]

local ServerStorage = game:GetService("ServerStorage")

local tffStorage = ServerStorage:FindFirstChild("TFF")
if not tffStorage then error("ServerStorage.TFF not found") end

local templates = tffStorage:FindFirstChild("Templates")
if not templates then error("ServerStorage.TFF.Templates not found") end

local creaturesFolder = templates:FindFirstChild("Creatures")
if not creaturesFolder then
    creaturesFolder = Instance.new("Folder")
    creaturesFolder.Name = "Creatures"
    creaturesFolder.Parent = templates
end

-- Helper: Create a Part
local function createPart(name: string, parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material
    p.Anchored = false
    p.CanCollide = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

-- Helper: Weld a Part to the Root
local function weldParts(part0: BasePart, part1: BasePart)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.Parent = part0
end

-- ============================================================================
-- 1. THE STALKER MODEL
-- ============================================================================
local oldStalker = creaturesFolder:FindFirstChild("Stalker")
if oldStalker then oldStalker:Destroy() end

local stalker = Instance.new("Model")
stalker.Name = "Stalker"
stalker.Parent = creaturesFolder

-- RootPart
local sRoot = Instance.new("Part")
sRoot.Name = "HumanoidRootPart"
sRoot.Size = Vector3.new(3, 4, 3)
sRoot.CFrame = CFrame.new(0, 2, 0)
sRoot.Transparency = 1
sRoot.CanCollide = true
sRoot.Anchored = false
sRoot.Parent = stalker
stalker.PrimaryPart = sRoot

-- Humanoid
local sHum = Instance.new("Humanoid")
sHum.MaxHealth = 100
sHum.Health = 100
sHum.WalkSpeed = 16
sHum.Parent = stalker

-- Sculpted Torso
local sTorso = createPart("Torso", stalker, Vector3.new(2.8, 2.4, 5.5), sRoot.CFrame * CFrame.Angles(math.rad(-10), 0, 0), Color3.fromRGB(32, 32, 38), Enum.Material.Slate)
weldParts(sRoot, sTorso)

-- Spine Quills
for i = -1.5, 1.5, 1.0 do
    local quill = createPart("SpineQuill", stalker, Vector3.new(0.5, 1.4, 0.8), sTorso.CFrame * CFrame.new(0, 1.6, i) * CFrame.Angles(math.rad(-25), 0, 0), Color3.fromRGB(20, 20, 25), Enum.Material.Basalt)
    weldParts(sRoot, quill)
end

-- 4 Quadruped Legs
local legConfigs = {
    { name = "FrontLegL", off = Vector3.new(-1.6, -1.0, 1.8) },
    { name = "FrontLegR", off = Vector3.new(1.6, -1.0, 1.8) },
    { name = "HindLegL",  off = Vector3.new(-1.6, -0.8, -1.8) },
    { name = "HindLegR",  off = Vector3.new(1.6, -0.8, -1.8) },
}
for _, lConf in ipairs(legConfigs) do
    local leg = createPart(lConf.name, stalker, Vector3.new(0.9, 2.8, 1.1), sTorso.CFrame * CFrame.new(lConf.off) * CFrame.Angles(math.rad(15), 0, 0), Color3.fromRGB(28, 28, 34), Enum.Material.Slate)
    weldParts(sRoot, leg)
    -- Claw paw
    local claw = createPart(lConf.name .. "_Claw", stalker, Vector3.new(1.1, 0.5, 1.5), leg.CFrame * CFrame.new(0, -1.3, 0.2), Color3.fromRGB(18, 18, 22), Enum.Material.Basalt)
    weldParts(sRoot, claw)
end

-- Sculpted Head
local sHead = createPart("Head", stalker, Vector3.new(2.2, 1.8, 2.8), sTorso.CFrame * CFrame.new(0, 0.8, 3.2) * CFrame.Angles(math.rad(12), 0, 0), Color3.fromRGB(35, 35, 42), Enum.Material.Slate)
weldParts(sRoot, sHead)

-- Predatory Red Ember Eyes (Neon)
local eyeL = createPart("EyeL", stalker, Vector3.new(0.3, 0.3, 0.6), sHead.CFrame * CFrame.new(-0.8, 0.3, 1.2), Color3.fromRGB(255, 30, 30), Enum.Material.Neon)
local eyeR = createPart("EyeR", stalker, Vector3.new(0.3, 0.3, 0.6), sHead.CFrame * CFrame.new(0.8, 0.3, 1.2), Color3.fromRGB(255, 30, 30), Enum.Material.Neon)
weldParts(sRoot, eyeL)
weldParts(sRoot, eyeR)

-- Telegraph Light for attack windup
local sTelegraph = Instance.new("PointLight")
sTelegraph.Name = "TelegraphLight"
sTelegraph.Color = Color3.fromRGB(255, 20, 20)
sTelegraph.Range = 12
sTelegraph.Brightness = 0 -- Activated during windup by CreatureService
sTelegraph.Parent = sHead

-- Tail
local sTail = createPart("Tail", stalker, Vector3.new(0.6, 0.6, 3.5), sTorso.CFrame * CFrame.new(0, 0.4, -3.2) * CFrame.Angles(math.rad(-25), 0, 0), Color3.fromRGB(26, 26, 32), Enum.Material.Slate)
weldParts(sRoot, sTail)

-- ============================================================================
-- 2. THE WATCHER MODEL
-- ============================================================================
local oldWatcher = creaturesFolder:FindFirstChild("Watcher")
if oldWatcher then oldWatcher:Destroy() end

local watcher = Instance.new("Model")
watcher.Name = "Watcher"
watcher.Parent = creaturesFolder

local wRoot = Instance.new("Part")
wRoot.Name = "HumanoidRootPart"
wRoot.Size = Vector3.new(2, 8, 2)
wRoot.CFrame = CFrame.new(0, 4, 0)
wRoot.Transparency = 1
wRoot.CanCollide = true
wRoot.Anchored = false
wRoot.Parent = watcher
watcher.PrimaryPart = wRoot

local wHum = Instance.new("Humanoid")
wHum.MaxHealth = 1
wHum.Health = 1
wHum.Parent = watcher

-- Draped shadowy robe body
local shroudLower = createPart("ShroudLower", watcher, Vector3.new(3.2, 5.5, 3.2), wRoot.CFrame * CFrame.new(0, -1.2, 0), Color3.fromRGB(15, 15, 20), Enum.Material.Fabric)
weldParts(wRoot, shroudLower)

local shroudUpper = createPart("ShroudUpper", watcher, Vector3.new(2.8, 3.5, 2.5), wRoot.CFrame * CFrame.new(0, 2.2, 0), Color3.fromRGB(20, 20, 26), Enum.Material.Fabric)
weldParts(wRoot, shroudUpper)

-- Elongated thin arms
local armL = createPart("ArmL", watcher, Vector3.new(0.6, 6.0, 0.6), wRoot.CFrame * CFrame.new(-1.8, 0.5, 0), Color3.fromRGB(15, 15, 20), Enum.Material.Fabric)
local armR = createPart("ArmR", watcher, Vector3.new(0.6, 6.0, 0.6), wRoot.CFrame * CFrame.new(1.8, 0.5, 0), Color3.fromRGB(15, 15, 20), Enum.Material.Fabric)
weldParts(wRoot, armL)
weldParts(wRoot, armR)

-- White Porcelain Mask
local mask = createPart("Mask", watcher, Vector3.new(1.4, 2.0, 0.6), wRoot.CFrame * CFrame.new(0, 3.8, 0.9), Color3.fromRGB(240, 238, 235), Enum.Material.SmoothPlastic)
weldParts(wRoot, mask)

-- Glowing Celestial Third Eye
local wEye = createPart("Eye", watcher, Vector3.new(0.5, 0.5, 0.5), mask.CFrame * CFrame.new(0, 0.3, 0.35), Color3.fromRGB(0, 235, 255), Enum.Material.Neon, Enum.PartType.Ball)
weldParts(wRoot, wEye)

local wEyeLight = Instance.new("PointLight")
wEyeLight.Color = Color3.fromRGB(0, 220, 255)
wEyeLight.Range = 16
wEyeLight.Brightness = 2.0
wEyeLight.Parent = wEye

-- ============================================================================
-- 3. THE MIMIC MODEL
-- ============================================================================
local oldMimic = creaturesFolder:FindFirstChild("Mimic")
if oldMimic then oldMimic:Destroy() end

local mimic = Instance.new("Model")
mimic.Name = "Mimic"
mimic.Parent = creaturesFolder

local mRoot = Instance.new("Part")
mRoot.Name = "HumanoidRootPart"
mRoot.Size = Vector3.new(3.5, 5, 3.5)
mRoot.CFrame = CFrame.new(0, 2.5, 0)
mRoot.Transparency = 1
mRoot.CanCollide = true
mRoot.Anchored = false
mRoot.Parent = mimic
mimic.PrimaryPart = mRoot

local mHum = Instance.new("Humanoid")
mHum.MaxHealth = 140
mHum.Health = 140
mHum.WalkSpeed = 12
mHum.Parent = mimic

-- Chest Base
local chestBase = createPart("ChestBase", mimic, Vector3.new(4.2, 2.4, 3.2), mRoot.CFrame * CFrame.new(0, 0, 0), Color3.fromRGB(85, 52, 28), Enum.Material.WoodPlanks)
weldParts(mRoot, chestBase)

-- Bronze banding trims
local bandL = createPart("ChestBandL", mimic, Vector3.new(4.3, 0.4, 3.3), chestBase.CFrame * CFrame.new(0, -0.6, 0), Color3.fromRGB(150, 110, 50), Enum.Material.Metal)
local bandU = createPart("ChestBandU", mimic, Vector3.new(4.3, 0.4, 3.3), chestBase.CFrame * CFrame.new(0, 0.8, 0), Color3.fromRGB(150, 110, 50), Enum.Material.Metal)
weldParts(mRoot, bandL)
weldParts(mRoot, bandU)

-- Hinged Lid (open at 35 degree angle)
local lid = createPart("ChestLid", mimic, Vector3.new(4.4, 1.2, 3.4), chestBase.CFrame * CFrame.new(0, 2.0, -0.6) * CFrame.Angles(math.rad(-35), 0, 0), Color3.fromRGB(75, 45, 22), Enum.Material.WoodPlanks)
weldParts(mRoot, lid)

-- Fanged Jaws & Glowing Purple Maw
local mawGlow = createPart("MawGlow", mimic, Vector3.new(3.6, 1.0, 2.4), chestBase.CFrame * CFrame.new(0, 1.2, 0), Color3.fromRGB(190, 45, 225), Enum.Material.Neon)
weldParts(mRoot, mawGlow)

local mawLight = Instance.new("PointLight")
mawLight.Color = Color3.fromRGB(180, 40, 220)
mawLight.Range = 12
mawLight.Brightness = 1.8
mawLight.Parent = mawGlow

-- Fanged Teeth
for i = -1.4, 1.4, 0.7 do
    local toothTop = createPart("ToothTop", mimic, Vector3.new(0.3, 0.8, 0.3), lid.CFrame * CFrame.new(i, -0.6, 1.2) * CFrame.Angles(math.rad(180), 0, 0), Color3.fromRGB(240, 235, 215), Enum.Material.SmoothPlastic)
    local toothBottom = createPart("ToothBottom", mimic, Vector3.new(0.3, 0.8, 0.3), chestBase.CFrame * CFrame.new(i, 1.4, 1.2), Color3.fromRGB(240, 235, 215), Enum.Material.SmoothPlastic)
    weldParts(mRoot, toothTop)
    weldParts(mRoot, toothBottom)
end

-- 4 Root Legs
local legOffsets = {
    Vector3.new(-1.8, -1.8, 1.2),
    Vector3.new(1.8, -1.8, 1.2),
    Vector3.new(-1.8, -1.8, -1.2),
    Vector3.new(1.8, -1.8, -1.2),
}
for idx, lOff in ipairs(legOffsets) do
    local rLeg = createPart("RootLeg_" .. idx, mimic, Vector3.new(0.8, 2.2, 0.8), chestBase.CFrame * CFrame.new(lOff) * CFrame.Angles(math.rad(idx <= 2 and 20 or -20), 0, 0), Color3.fromRGB(60, 38, 22), Enum.Material.Wood)
    weldParts(mRoot, rLeg)
end

-- ============================================================================
-- 4. FOREST GUARDIAN BOSS MODEL
-- ============================================================================
local oldBoss = creaturesFolder:FindFirstChild("ForestGuardian")
if oldBoss then oldBoss:Destroy() end

local boss = Instance.new("Model")
boss.Name = "ForestGuardian"
boss.Parent = creaturesFolder

local bRoot = Instance.new("Part")
bRoot.Name = "HumanoidRootPart"
bRoot.Size = Vector3.new(10, 16, 10)
bRoot.CFrame = CFrame.new(0, 8, 0)
bRoot.Transparency = 1
bRoot.CanCollide = true
bRoot.Anchored = false
bRoot.Parent = boss
boss.PrimaryPart = bRoot

local bHum = Instance.new("Humanoid")
bHum.MaxHealth = 2500
bHum.Health = 2500
bHum.WalkSpeed = 10
bHum.Parent = boss

-- Massive Ancient Bark Torso
local bTorso = createPart("Torso", boss, Vector3.new(9, 12, 7), bRoot.CFrame * CFrame.new(0, 1, 0), Color3.fromRGB(65, 45, 28), Enum.Material.Wood)
weldParts(bRoot, bTorso)

-- Mossy Basalt Shoulder Pauldrons
local pauldronL = createPart("PauldronL", boss, Vector3.new(5.5, 4.5, 6), bTorso.CFrame * CFrame.new(-6.2, 5.0, 0), Color3.fromRGB(55, 65, 55), Enum.Material.Slate)
local pauldronR = createPart("PauldronR", boss, Vector3.new(5.5, 4.5, 6), bTorso.CFrame * CFrame.new(6.2, 5.0, 0), Color3.fromRGB(55, 65, 55), Enum.Material.Slate)
weldParts(bRoot, pauldronL)
weldParts(bRoot, pauldronR)

-- Massive Fists & Arms
local armBL = createPart("ArmL", boss, Vector3.new(3.5, 10, 3.5), bTorso.CFrame * CFrame.new(-6.5, -1.0, 0), Color3.fromRGB(60, 40, 25), Enum.Material.Wood)
local armBR = createPart("ArmR", boss, Vector3.new(3.5, 10, 3.5), bTorso.CFrame * CFrame.new(6.5, -1.0, 0), Color3.fromRGB(60, 40, 25), Enum.Material.Wood)
weldParts(bRoot, armBL)
weldParts(bRoot, armBR)

local fistL = createPart("FistL", boss, Vector3.new(4.5, 4.5, 4.5), armBL.CFrame * CFrame.new(0, -5.5, 0), Color3.fromRGB(50, 52, 55), Enum.Material.Basalt)
local fistR = createPart("FistR", boss, Vector3.new(4.5, 4.5, 4.5), armBR.CFrame * CFrame.new(0, -5.5, 0), Color3.fromRGB(50, 52, 55), Enum.Material.Basalt)
weldParts(bRoot, fistL)
weldParts(bRoot, fistR)

-- Thick Pillar Legs
local bLegL = createPart("LegL", boss, Vector3.new(4, 9, 4), bTorso.CFrame * CFrame.new(-3, -8.5, 0), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
local bLegR = createPart("LegR", boss, Vector3.new(4, 9, 4), bTorso.CFrame * CFrame.new(3, -8.5, 0), Color3.fromRGB(60, 40, 25), Enum.Material.Wood, Enum.PartType.Cylinder)
weldParts(bRoot, bLegL)
weldParts(bRoot, bLegR)

-- Carved Head & Elder Mask
local bHead = createPart("Head", boss, Vector3.new(5.5, 5.5, 5.5), bTorso.CFrame * CFrame.new(0, 8.5, 0.5), Color3.fromRGB(75, 52, 32), Enum.Material.Wood)
weldParts(bRoot, bHead)

-- Branching Antler Root Horns
local hornL = createPart("HornL", boss, Vector3.new(1.8, 6.0, 1.8), bHead.CFrame * CFrame.new(-2.8, 4.2, 0) * CFrame.Angles(0, 0, math.rad(35)), Color3.fromRGB(50, 32, 20), Enum.Material.Wood)
local hornR = createPart("HornR", boss, Vector3.new(1.8, 6.0, 1.8), bHead.CFrame * CFrame.new(2.8, 4.2, 0) * CFrame.Angles(0, 0, math.rad(-35)), Color3.fromRGB(50, 32, 20), Enum.Material.Wood)
weldParts(bRoot, hornL)
weldParts(bRoot, hornR)

-- Glowing Emerald/Cyan Mask Eyes
local bEyeL = createPart("BossEyeL", boss, Vector3.new(1.0, 0.6, 0.4), bHead.CFrame * CFrame.new(-1.4, 0.6, 2.8), Color3.fromRGB(0, 255, 180), Enum.Material.Neon)
local bEyeR = createPart("BossEyeR", boss, Vector3.new(1.0, 0.6, 0.4), bHead.CFrame * CFrame.new(1.4, 0.6, 2.8), Color3.fromRGB(0, 255, 180), Enum.Material.Neon)
weldParts(bRoot, bEyeL)
weldParts(bRoot, bEyeR)

-- Glowing Crystal Heart Core in Chest
local bHeart = createPart("BossCrystalHeart", boss, Vector3.new(2.4, 3.2, 2.4), bTorso.CFrame * CFrame.new(0, 1.2, 3.4), Color3.fromRGB(0, 255, 210), Enum.Material.Neon, Enum.PartType.Ball)
weldParts(bRoot, bHeart)

local bHeartLight = Instance.new("PointLight")
bHeartLight.Color = Color3.fromRGB(0, 255, 210)
bHeartLight.Range = 25
bHeartLight.Brightness = 2.8
bHeartLight.Parent = bHeart

print("[build_creatures] All 4 sculpted creature models generated successfully!")
return true
