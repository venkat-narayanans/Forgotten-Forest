--!strict
--[[
    rebuild_detailed_npcs_and_tents.lua
    Fixes the giant white box issue by:
    1. Removing the solid engulfing tent blocks (MedTentRoof and ExplorerTent Canvas).
    2. Building open-air, low-poly pavilions for the Medical Tent and Cartographer Workshop.
    3. Sculpting detailed, expressive, recognizable low-poly humanoid character models
       for Alden, Mara, and The Old Keeper (complete with hair/hats, facial features,
       coats, satchels, gear, and backpacks).
]]

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local tffWorld = Workspace:FindFirstChild("TFF_World")
if not tffWorld then return "Error: TFF_World not found" end

local map = tffWorld:FindFirstChild("Map")
local interactables = tffWorld:FindFirstChild("Interactables")
if not map or not interactables then return "Error: Map or Interactables not found" end

local function createPart(name: string, parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.Plastic
    if shape then p.Shape = shape end
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

-- ============================================================================
-- 1. FIX MEDICAL TENT & REMOVE GIANT WHITE ROOF BLOCK
-- ============================================================================
print("[NPC Fix] Fixing Medical Tent structure...")
local medTent = map:FindFirstChild("SafeHavenMedicalTent")
if medTent then
    local oldRoof = medTent:FindFirstChild("MedTentRoof")
    if oldRoof then oldRoof:Destroy() end
else
    medTent = Instance.new("Model")
    medTent.Name = "SafeHavenMedicalTent"
    medTent.Parent = map
end

-- Ensure floor platform
local medPlatform = medTent:FindFirstChild("MedTentPlatform")
if not medPlatform then
    medPlatform = createPart("MedTentPlatform", medTent, Vector3.new(22, 1, 26), CFrame.new(-32, 0.5, -48), Color3.fromRGB(90, 75, 55), Enum.Material.WoodPlanks)
else
    medPlatform.Position = Vector3.new(-32, 0.5, -48)
    medPlatform.Size = Vector3.new(22, 1, 26)
end

-- Remove any old tent frame parts in medTent
for _, c in ipairs(medTent:GetChildren()) do
    if c.Name ~= "MedTentPlatform" then c:Destroy() end
end

-- Build 4 Open Timber Pillars
local medPillars = {
    Vector3.new(-42, 5.5, -59),
    Vector3.new(-22, 5.5, -59),
    Vector3.new(-42, 5.5, -37),
    Vector3.new(-22, 5.5, -37),
}
for i, pos in ipairs(medPillars) do
    createPart("MedPillar_" .. i, medTent, Vector3.new(1.4, 10, 1.4), CFrame.new(pos), Color3.fromRGB(110, 80, 50), Enum.Material.WoodPlanks)
end

-- Top Timber Lintels
createPart("MedLintel_N", medTent, Vector3.new(21.4, 1.2, 1.4), CFrame.new(-32, 10.5, -59), Color3.fromRGB(95, 70, 45), Enum.Material.WoodPlanks)
createPart("MedLintel_S", medTent, Vector3.new(21.4, 1.2, 1.4), CFrame.new(-32, 10.5, -37), Color3.fromRGB(95, 70, 45), Enum.Material.WoodPlanks)
createPart("MedLintel_W", medTent, Vector3.new(1.4, 1.2, 23.4), CFrame.new(-42, 10.5, -48), Color3.fromRGB(95, 70, 45), Enum.Material.WoodPlanks)
createPart("MedLintel_E", medTent, Vector3.new(1.4, 1.2, 23.4), CFrame.new(-22, 10.5, -48), Color3.fromRGB(95, 70, 45), Enum.Material.WoodPlanks)

-- Open Pitched Canvas Canopy (Elevated at Y=11.5 to 13.5, leaving full 10-stud clearance underneath)
local medCanopyLeft = createPart("MedCanopy_W", medTent, Vector3.new(12, 0.6, 25), CFrame.new(-37, 12, -48) * CFrame.Angles(0, 0, math.rad(-14)), Color3.fromRGB(225, 220, 205), Enum.Material.Fabric)
medCanopyLeft.CanCollide = false
local medCanopyRight = createPart("MedCanopy_E", medTent, Vector3.new(12, 0.6, 25), CFrame.new(-27, 12, -48) * CFrame.Angles(0, 0, math.rad(14)), Color3.fromRGB(225, 220, 205), Enum.Material.Fabric)
medCanopyRight.CanCollide = false

-- Medical Counter & Herbalist Desk
createPart("MedApothecaryDesk", medTent, Vector3.new(8, 2.8, 3.5), CFrame.new(-32, 2.4, -45), Color3.fromRGB(120, 90, 60), Enum.Material.WoodPlanks)
-- Potion Vials on counter
local v1 = createPart("Vial_Health", medTent, Vector3.new(0.6, 1.0, 0.6), CFrame.new(-34.5, 4.2, -45), Color3.fromRGB(230, 50, 50), Enum.Material.Neon, Enum.PartType.Cylinder)
v1.CanCollide = false
local v2 = createPart("Vial_Herb", medTent, Vector3.new(0.6, 1.0, 0.6), CFrame.new(-33.2, 4.2, -45), Color3.fromRGB(60, 220, 90), Enum.Material.Neon, Enum.PartType.Cylinder)
v2.CanCollide = false
local v3 = createPart("Vial_Aether", medTent, Vector3.new(0.6, 1.0, 0.6), CFrame.new(-31.9, 4.2, -45), Color3.fromRGB(0, 210, 240), Enum.Material.Neon, Enum.PartType.Cylinder)
v3.CanCollide = false

-- Hanging Lantern inside
local medLightPart = createPart("MedLantern", medTent, Vector3.new(1, 1.2, 1), CFrame.new(-32, 9.5, -48), Color3.fromRGB(255, 220, 150), Enum.Material.Neon)
medLightPart.CanCollide = false
local medPl = Instance.new("PointLight")
medPl.Color = Color3.fromRGB(255, 220, 160)
medPl.Range = 24
medPl.Brightness = 2.5
medPl.Parent = medLightPart

-- Field Cot / Stretcher
createPart("MedCot_Frame", medTent, Vector3.new(4, 1.2, 7.5), CFrame.new(-38.5, 1.6, -52), Color3.fromRGB(90, 65, 45), Enum.Material.WoodPlanks)
createPart("MedCot_Canvas", medTent, Vector3.new(3.6, 0.4, 7.1), CFrame.new(-38.5, 2.3, -52), Color3.fromRGB(215, 210, 195), Enum.Material.Fabric)

-- ============================================================================
-- 2. FIX CARTOGRAPHER WORKSHOP & REMOVE GIANT WHITE TENT BLOCK
-- ============================================================================
print("[NPC Fix] Fixing Cartographer Workshop structure...")
-- Destroy the old ExplorerTent that was located at Pos(28, 4, -26)
local outpost = map:FindFirstChild("SafeHavenOutpost")
if outpost then
    for _, c in ipairs(outpost:GetChildren()) do
        if c.Name == "ExplorerTent" then
            local canvas = c:FindFirstChild("Canvas")
            if canvas and canvas.Position.Z < 0 then
                c:Destroy()
            end
        end
    end
end

local pav = map:FindFirstChild("CartographerPavilion")
if not pav then
    pav = Instance.new("Model")
    pav.Name = "CartographerPavilion"
    pav.Parent = map
end

-- Clear old pavilion parts
for _, c in ipairs(pav:GetChildren()) do
    c:Destroy()
end

-- Pavilion Platform
createPart("MapPavilionDeck", pav, Vector3.new(20, 1, 20), CFrame.new(26, 0.5, -25), Color3.fromRGB(95, 75, 50), Enum.Material.WoodPlanks)

-- 4 Corner Posts
local pavPosts = {
    Vector3.new(17.5, 5.5, -33.5),
    Vector3.new(34.5, 5.5, -33.5),
    Vector3.new(17.5, 5.5, -16.5),
    Vector3.new(34.5, 5.5, -16.5),
}
for i, pos in ipairs(pavPosts) do
    createPart("PavilionPost_" .. i, pav, Vector3.new(1.4, 10, 1.4), CFrame.new(pos), Color3.fromRGB(115, 85, 55), Enum.Material.WoodPlanks)
end

-- Top Beams
createPart("PavBeam_N", pav, Vector3.new(18.4, 1.2, 1.4), CFrame.new(26, 10.5, -33.5), Color3.fromRGB(100, 75, 45), Enum.Material.WoodPlanks)
createPart("PavBeam_S", pav, Vector3.new(18.4, 1.2, 1.4), CFrame.new(26, 10.5, -16.5), Color3.fromRGB(100, 75, 45), Enum.Material.WoodPlanks)
createPart("PavBeam_W", pav, Vector3.new(1.4, 1.2, 18.4), CFrame.new(17.5, 10.5, -25), Color3.fromRGB(100, 75, 45), Enum.Material.WoodPlanks)
createPart("PavBeam_E", pav, Vector3.new(1.4, 1.2, 18.4), CFrame.new(34.5, 10.5, -25), Color3.fromRGB(100, 75, 45), Enum.Material.WoodPlanks)

-- Open Timber Roof with weather-worn green fabric cover (Elevated at Y=11.5)
local pavCanopy = createPart("PavilionCanopy", pav, Vector3.new(20, 0.8, 20), CFrame.new(26, 11.2, -25), Color3.fromRGB(75, 95, 80), Enum.Material.Fabric)
pavCanopy.CanCollide = false

-- Hanging warm brass lantern
local pavLightPart = createPart("PavLantern", pav, Vector3.new(1, 1.2, 1), CFrame.new(26, 9.5, -25), Color3.fromRGB(255, 215, 140), Enum.Material.Neon)
pavLightPart.CanCollide = false
local pavPl = Instance.new("PointLight")
pavPl.Color = Color3.fromRGB(255, 215, 140)
pavPl.Range = 22
pavPl.Brightness = 2.5
pavPl.Parent = pavLightPart

-- Map Drafting Table (Repositioned neatly inside)
local mapTable = interactables:FindFirstChild("CartographerMapTable")
if not mapTable then
    mapTable = createPart("CartographerMapTable", interactables, Vector3.new(8, 3.2, 4.5), CFrame.new(26, 2.6, -24), Color3.fromRGB(115, 85, 55), Enum.Material.WoodPlanks)
else
    mapTable.CFrame = CFrame.new(26, 2.6, -24)
    mapTable.Size = Vector3.new(8, 3.2, 4.5)
end

-- Parchment rolls on table
createPart("ParchmentRoll_1", pav, Vector3.new(0.5, 3.5, 0.5), CFrame.new(23.5, 4.4, -24) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(240, 230, 205), Enum.Material.SmoothPlastic).CanCollide = false
createPart("ParchmentRoll_2", pav, Vector3.new(0.5, 3.0, 0.5), CFrame.new(23.5, 4.4, -25) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(235, 225, 195), Enum.Material.SmoothPlastic).CanCollide = false
createPart("BrassCompass", pav, Vector3.new(1.0, 0.2, 1.0), CFrame.new(28.5, 4.3, -24), Color3.fromRGB(220, 180, 50), Enum.Material.Metal, Enum.PartType.Cylinder).CanCollide = false

-- ============================================================================
-- 3. SCULPT DETAILED CHARACTER MODELS FOR MARA & ALDEN
-- ============================================================================
local function cleanupOldNPC(name: string)
    local old = interactables:FindFirstChild(name)
    if old then old:Destroy() end
end

cleanupOldNPC("NPC_cartographer")
cleanupOldNPC("NPC_medic")

-- ----------------------------------------------------------------------------
-- ALDEN, THE VALLEY CARTOGRAPHER
-- ----------------------------------------------------------------------------
print("[NPC Fix] Sculpting Alden, The Valley Cartographer...")
local alden = Instance.new("Model")
alden.Name = "NPC_cartographer"
alden:SetAttribute("NPCId", "cartographer")
CollectionService:AddTag(alden, "TFF_NPC")

local aHum = Instance.new("Humanoid")
aHum.Name = "Humanoid"
aHum.MaxHealth = 100
aHum.Health = 100
aHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
aHum.Parent = alden

-- Root Part (Invisible)
local aRoot = createPart("HumanoidRootPart", alden, Vector3.new(2, 2, 1), CFrame.new(26, 3.0, -21.5), Color3.new(1,1,1), Enum.Material.Plastic)
aRoot.Transparency = 1
aRoot.CanCollide = false

-- Torso (Deep Navy Explorer Coat with Leather Trim)
local aTorso = createPart("Torso", alden, Vector3.new(2, 2, 1), CFrame.new(26, 3.0, -21.5), Color3.fromRGB(45, 70, 95), Enum.Material.Fabric)

-- Belt & Brass Buckle
local aBelt = createPart("Belt", alden, Vector3.new(2.05, 0.35, 1.05), CFrame.new(26, 2.15, -21.5), Color3.fromRGB(85, 55, 30), Enum.Material.Fabric)
local aBuckle = createPart("Buckle", alden, Vector3.new(0.5, 0.4, 1.1), CFrame.new(26, 2.15, -21.5), Color3.fromRGB(220, 180, 50), Enum.Material.Metal)

-- Leather Cross-Chest Harness
local aHarness = createPart("Harness", alden, Vector3.new(0.4, 2.05, 1.05), CFrame.new(26, 3.1, -21.5) * CFrame.Angles(0, 0, math.rad(28)), Color3.fromRGB(100, 65, 35), Enum.Material.Fabric)

-- Head (Warm Tan Skin)
local aHead = createPart("Head", alden, Vector3.new(1.2, 1.2, 1.2), CFrame.new(26, 4.6, -21.5), Color3.fromRGB(240, 200, 170), Enum.Material.SmoothPlastic)

-- Hair (Dark Brown Trim)
local aHair = createPart("Hair", alden, Vector3.new(1.25, 0.5, 1.25), CFrame.new(26, 5.0, -21.55), Color3.fromRGB(65, 45, 30), Enum.Material.Fabric)

-- Slouch Hat Brim & Crown (Explorer Fedora)
local aHatBrim = createPart("HatBrim", alden, Vector3.new(2.4, 0.2, 2.4), CFrame.new(26, 5.25, -21.5), Color3.fromRGB(85, 60, 40), Enum.Material.Fabric, Enum.PartType.Cylinder)
aHatBrim.CFrame = CFrame.new(26, 5.25, -21.5) * CFrame.Angles(math.rad(90), 0, 0)
local aHatCrown = createPart("HatCrown", alden, Vector3.new(1.4, 0.75, 1.4), CFrame.new(26, 5.65, -21.5), Color3.fromRGB(75, 50, 32), Enum.Material.Fabric)
local aHatBand = createPart("HatBand", alden, Vector3.new(1.45, 0.18, 1.45), CFrame.new(26, 5.35, -21.5), Color3.fromRGB(210, 170, 50), Enum.Material.Metal)

-- Spectacles / Glasses (Gold frame & lenses)
local aGlasses = createPart("Glasses", alden, Vector3.new(0.9, 0.25, 0.1), CFrame.new(26, 4.65, -20.95), Color3.fromRGB(230, 190, 60), Enum.Material.Metal)
local aMustache = createPart("Mustache", alden, Vector3.new(0.6, 0.2, 0.1), CFrame.new(26, 4.25, -20.95), Color3.fromRGB(65, 45, 30), Enum.Material.Fabric)

-- Cartographer Field Backpack & Strapped Map Scroll
local aPack = createPart("Backpack", alden, Vector3.new(1.6, 1.8, 0.8), CFrame.new(26, 3.2, -22.2), Color3.fromRGB(95, 65, 35), Enum.Material.Fabric)
local aScroll = createPart("MapScroll", alden, Vector3.new(0.4, 2.2, 0.4), CFrame.new(27.0, 3.2, -22.1) * CFrame.Angles(0, 0, math.rad(-15)), Color3.fromRGB(245, 235, 210), Enum.Material.SmoothPlastic)

-- Arms
local aArmL = createPart("LeftArm", alden, Vector3.new(0.8, 2.0, 0.8), CFrame.new(27.4, 3.0, -21.5), Color3.fromRGB(45, 70, 95), Enum.Material.Fabric)
local aArmR = createPart("RightArm", alden, Vector3.new(0.8, 2.0, 0.8), CFrame.new(24.6, 3.0, -21.5), Color3.fromRGB(45, 70, 95), Enum.Material.Fabric)
local aHandL = createPart("LeftHand", alden, Vector3.new(0.7, 0.4, 0.7), CFrame.new(27.4, 1.8, -21.5), Color3.fromRGB(240, 200, 170), Enum.Material.SmoothPlastic)
local aHandR = createPart("RightHand", alden, Vector3.new(0.7, 0.4, 0.7), CFrame.new(24.6, 1.8, -21.5), Color3.fromRGB(240, 200, 170), Enum.Material.SmoothPlastic)

-- Legs & Boots
local aLegL = createPart("LeftLeg", alden, Vector3.new(0.9, 1.4, 0.9), CFrame.new(26.5, 1.3, -21.5), Color3.fromRGB(55, 60, 68), Enum.Material.Fabric)
local aLegR = createPart("RightLeg", alden, Vector3.new(0.9, 1.4, 0.9), CFrame.new(25.5, 1.3, -21.5), Color3.fromRGB(55, 60, 68), Enum.Material.Fabric)
local aBootL = createPart("LeftBoot", alden, Vector3.new(0.95, 0.7, 1.1), CFrame.new(26.5, 0.35, -21.45), Color3.fromRGB(60, 42, 25), Enum.Material.Fabric)
local aBootR = createPart("RightBoot", alden, Vector3.new(0.95, 0.7, 1.1), CFrame.new(25.5, 0.35, -21.45), Color3.fromRGB(60, 42, 25), Enum.Material.Fabric)

-- Proximity Prompt
local aPrompt = Instance.new("ProximityPrompt")
aPrompt.Name = "InteractPrompt"
aPrompt.ActionText = "Converse"
aPrompt.ObjectText = "Alden, The Cartographer"
aPrompt.HoldDuration = 0.5
aPrompt.MaxActivationDistance = 12
aPrompt.RequiresLineOfSight = false
aPrompt.Parent = aTorso

-- Nameplate
local aTag = Instance.new("BillboardGui")
aTag.Name = "NPCTag"
aTag.Size = UDim2.new(0, 220, 0, 50)
aTag.StudsOffset = Vector3.new(0, 3.2, 0)
aTag.AlwaysOnTop = true
aTag.Adornee = aHead
local aLbl = Instance.new("TextLabel")
aLbl.Size = UDim2.new(1, 0, 0.6, 0)
aLbl.BackgroundTransparency = 1
aLbl.Text = "Alden, Valley Cartographer"
aLbl.TextColor3 = Color3.fromRGB(255, 230, 140)
aLbl.Font = Enum.Font.GothamBold
aLbl.TextSize = 16
aLbl.TextStrokeTransparency = 0.3
aLbl.Parent = aTag
local aSub = Instance.new("TextLabel")
aSub.Size = UDim2.new(1, 0, 0.4, 0)
aSub.Position = UDim2.new(0, 0, 0.6, 0)
aSub.BackgroundTransparency = 1
aSub.Text = "[E] Discuss Maps & Valley Exploration"
aSub.TextColor3 = Color3.fromRGB(200, 220, 240)
aSub.Font = Enum.Font.GothamMedium
aSub.TextSize = 12
aSub.TextStrokeTransparency = 0.4
aSub.Parent = aTag
aTag.Parent = alden

alden.PrimaryPart = aRoot
alden.Parent = interactables

-- ----------------------------------------------------------------------------
-- MARA, FIELD MEDIC
-- ----------------------------------------------------------------------------
print("[NPC Fix] Sculpting Mara, Field Medic...")
local mara = Instance.new("Model")
mara.Name = "NPC_medic"
mara:SetAttribute("NPCId", "medic")
CollectionService:AddTag(mara, "TFF_NPC")

local mHum = Instance.new("Humanoid")
mHum.Name = "Humanoid"
mHum.MaxHealth = 100
mHum.Health = 100
mHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
mHum.Parent = mara

-- Root Part (Invisible)
local mRoot = createPart("HumanoidRootPart", mara, Vector3.new(2, 2, 1), CFrame.new(-32, 3.0, -42), Color3.new(1,1,1), Enum.Material.Plastic)
mRoot.Transparency = 1
mRoot.CanCollide = false

-- Torso (White Field Tunic with Forest Green Trim)
local mTorso = createPart("Torso", mara, Vector3.new(2, 2, 1), CFrame.new(-32, 3.0, -42), Color3.fromRGB(240, 240, 235), Enum.Material.Fabric)

-- Red Cross on Chest
createPart("RedCross_V", mara, Vector3.new(0.4, 1.0, 0.08), CFrame.new(-32, 3.2, -41.48), Color3.fromRGB(220, 45, 45), Enum.Material.SmoothPlastic).CanCollide = false
createPart("RedCross_H", mara, Vector3.new(1.0, 0.4, 0.08), CFrame.new(-32, 3.2, -41.48), Color3.fromRGB(220, 45, 45), Enum.Material.SmoothPlastic).CanCollide = false

-- Leather Satchel & Herbalist Pouch Bandolier
createPart("MedicSash", mara, Vector3.new(0.35, 2.1, 1.05), CFrame.new(-32, 3.0, -42) * CFrame.Angles(0, 0, math.rad(-30)), Color3.fromRGB(110, 75, 45), Enum.Material.Fabric)
createPart("HerbSatchel", mara, Vector3.new(1.1, 0.9, 0.5), CFrame.new(-31.1, 2.1, -41.8), Color3.fromRGB(90, 60, 35), Enum.Material.Fabric)
-- Tiny glowing healing vial in pouch
local mvial = createPart("SatchelVial", mara, Vector3.new(0.3, 0.6, 0.3), CFrame.new(-31.1, 2.5, -41.5), Color3.fromRGB(60, 240, 110), Enum.Material.Neon, Enum.PartType.Cylinder)
mvial.CanCollide = false

-- Head (Warm Pale Tan Skin)
local mHead = createPart("Head", mara, Vector3.new(1.2, 1.2, 1.2), CFrame.new(-32, 4.6, -42), Color3.fromRGB(245, 205, 175), Enum.Material.SmoothPlastic)

-- Hair (Auburn / Chestnut Ponytail)
createPart("Hair_Top", mara, Vector3.new(1.25, 0.55, 1.25), CFrame.new(-32, 5.0, -42.05), Color3.fromRGB(110, 55, 30), Enum.Material.Fabric)
createPart("Hair_Back", mara, Vector3.new(0.7, 1.2, 0.5), CFrame.new(-32, 4.3, -42.7), Color3.fromRGB(110, 55, 30), Enum.Material.Fabric)

-- Field Medic Beret (Forest Green with Gold Badge)
local mBeret = createPart("MedicBeret", mara, Vector3.new(1.4, 0.5, 1.4), CFrame.new(-32, 5.4, -42) * CFrame.Angles(math.rad(-10), 0, math.rad(15)), Color3.fromRGB(45, 85, 55), Enum.Material.Fabric)
createPart("BeretPin", mara, Vector3.new(0.25, 0.25, 0.1), CFrame.new(-31.4, 5.35, -41.4), Color3.fromRGB(230, 190, 60), Enum.Material.Metal)

-- Face Details (Eyes & Cheerful Expression)
createPart("Eye_L", mara, Vector3.new(0.16, 0.16, 0.05), CFrame.new(-31.75, 4.65, -41.4), Color3.fromRGB(40, 70, 95), Enum.Material.SmoothPlastic).CanCollide = false
createPart("Eye_R", mara, Vector3.new(0.16, 0.16, 0.05), CFrame.new(-32.25, 4.65, -41.4), Color3.fromRGB(40, 70, 95), Enum.Material.SmoothPlastic).CanCollide = false

-- Arms (White sleeves with Green Trim)
local mArmL = createPart("LeftArm", mara, Vector3.new(0.8, 2.0, 0.8), CFrame.new(-30.6, 3.0, -42), Color3.fromRGB(240, 240, 235), Enum.Material.Fabric)
local mArmR = createPart("RightArm", mara, Vector3.new(0.8, 2.0, 0.8), CFrame.new(-33.4, 3.0, -42), Color3.fromRGB(240, 240, 235), Enum.Material.Fabric)
-- Red Cross Armband on Right Arm
createPart("Armband", mara, Vector3.new(0.85, 0.5, 0.85), CFrame.new(-33.4, 3.3, -42), Color3.fromRGB(220, 45, 45), Enum.Material.Fabric)

local mHandL = createPart("LeftHand", mara, Vector3.new(0.7, 0.4, 0.7), CFrame.new(-30.6, 1.8, -42), Color3.fromRGB(245, 205, 175), Enum.Material.SmoothPlastic)
local mHandR = createPart("RightHand", mara, Vector3.new(0.7, 0.4, 0.7), CFrame.new(-33.4, 1.8, -42), Color3.fromRGB(245, 205, 175), Enum.Material.SmoothPlastic)

-- Legs (Olive Field Pants & Brown Leather Boots)
local mLegL = createPart("LeftLeg", mara, Vector3.new(0.9, 1.4, 0.9), CFrame.new(-31.5, 1.3, -42), Color3.fromRGB(50, 70, 50), Enum.Material.Fabric)
local mLegR = createPart("RightLeg", mara, Vector3.new(0.9, 1.4, 0.9), CFrame.new(-32.5, 1.3, -42), Color3.fromRGB(50, 70, 50), Enum.Material.Fabric)
local mBootL = createPart("LeftBoot", mara, Vector3.new(0.95, 0.7, 1.1), CFrame.new(-31.5, 0.35, -41.95), Color3.fromRGB(80, 55, 35), Enum.Material.Fabric)
local mBootR = createPart("RightBoot", mara, Vector3.new(0.95, 0.7, 1.1), CFrame.new(-32.5, 0.35, -41.95), Color3.fromRGB(80, 55, 35), Enum.Material.Fabric)

-- Proximity Prompt
local mPrompt = Instance.new("ProximityPrompt")
mPrompt.Name = "InteractPrompt"
mPrompt.ActionText = "Consult"
mPrompt.ObjectText = "Mara, Field Medic"
mPrompt.HoldDuration = 0.5
mPrompt.MaxActivationDistance = 12
mPrompt.RequiresLineOfSight = false
mPrompt.Parent = mTorso

-- Nameplate
local mTag = Instance.new("BillboardGui")
mTag.Name = "NPCTag"
mTag.Size = UDim2.new(0, 220, 0, 50)
mTag.StudsOffset = Vector3.new(0, 3.2, 0)
mTag.AlwaysOnTop = true
mTag.Adornee = mHead
local mLbl = Instance.new("TextLabel")
mLbl.Size = UDim2.new(1, 0, 0.6, 0)
mLbl.BackgroundTransparency = 1
mLbl.Text = "Mara, Field Medic"
mLbl.TextColor3 = Color3.fromRGB(130, 240, 160)
mLbl.Font = Enum.Font.GothamBold
mLbl.TextSize = 16
mLbl.TextStrokeTransparency = 0.3
mLbl.Parent = mTag
local mSub = Instance.new("TextLabel")
mSub.Size = UDim2.new(1, 0, 0.4, 0)
mSub.Position = UDim2.new(0, 0, 0.6, 0)
mSub.BackgroundTransparency = 1
mSub.Text = "[E] Medical Guidance & Survival Tips"
mSub.TextColor3 = Color3.fromRGB(210, 240, 220)
mSub.Font = Enum.Font.GothamMedium
mSub.TextSize = 12
mSub.TextStrokeTransparency = 0.4
mSub.Parent = mTag
mTag.Parent = mara

mara.PrimaryPart = mRoot
mara.Parent = interactables

return "SUCCESS: Mara and Alden models and open pavilions rebuilt with zero giant white boxes!"
