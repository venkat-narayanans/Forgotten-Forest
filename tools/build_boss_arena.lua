--!strict
--[[
    build_boss_arena.lua
    Procedural detailed low-poly overhaul for the Forest Guardian Boss Arena:
    - Colossal Ancient Heartwood Tree towering 55 studs high with massive sweeping roots
    - Glowing cyan runic inlays, capital stones, and energy particles for 8 Ancient Pillars
    - Ornate stone altars with vertical glowing light pillars for the 3 Ancient Seals
    - Jagged slate boulder amphitheater boundary framing the 120-stud arena
    - Boss arena atmospheric mist and mystical twilight glow
]]

local Workspace = game:GetService("Workspace")

local tffWorld = Workspace:FindFirstChild("TFF_World")
if not tffWorld then error("TFF_World not found") end

local map = tffWorld:FindFirstChild("Map")
if not map then error("Map not found") end

local interactables = tffWorld:FindFirstChild("Interactables")
if not interactables then error("Interactables not found") end

local arenaFolder = map:FindFirstChild("BossArena")
if not arenaFolder then error("BossArena not found") end

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

-- ============================================================================
-- 1. DETAILED ANCIENT PILLARS OVERHAUL
-- ============================================================================
for i = 1, 8 do
    local pillar = arenaFolder:FindFirstChild("AncientPillar_" .. i)
    if pillar and pillar:IsA("BasePart") then
        pillar.Material = Enum.Material.Basalt
        pillar.Color = Color3.fromRGB(55, 58, 62)

        local pPos = pillar.Position
        local pSize = pillar.Size

        -- Base plinth
        local plinth = arenaFolder:FindFirstChild("PillarPlinth_" .. i)
        if plinth then plinth:Destroy() end
        plinth = createPart("PillarPlinth_" .. i, arenaFolder, Vector3.new(pSize.X + 3, 3, pSize.Z + 3), CFrame.new(pPos.X, 1.5, pPos.Z), Color3.fromRGB(65, 68, 72), Enum.Material.Cobblestone)

        -- Top capital stone
        local cap = arenaFolder:FindFirstChild("PillarCap_" .. i)
        if cap then cap:Destroy() end
        cap = createPart("PillarCap_" .. i, arenaFolder, Vector3.new(pSize.X + 2.5, 2.5, pSize.Z + 2.5), CFrame.new(pPos.X, pPos.Y + (pSize.Y / 2) + 1.25, pPos.Z), Color3.fromRGB(65, 68, 72), Enum.Material.Cobblestone)

        -- Inlaid glowing vertical rune strip (faces inward toward arena center 0, y, -620)
        local toCenter = (Vector3.new(0, pPos.Y, -620) - pPos).Unit
        local runeStrip = arenaFolder:FindFirstChild("PillarRuneStrip_" .. i)
        if runeStrip then runeStrip:Destroy() end
        runeStrip = createPart("PillarRuneStrip_" .. i, arenaFolder, Vector3.new(0.8, pSize.Y - 4, 0.3), CFrame.new(pPos + (toCenter * (pSize.X / 2 + 0.15)), pPos + (toCenter * 10)), Color3.fromRGB(0, 230, 255), Enum.Material.Neon)
        runeStrip.CanCollide = false

        -- Rune glow light
        local rLight = runeStrip:FindFirstChild("RuneLight")
        if not rLight then
            rLight = Instance.new("PointLight")
            rLight.Name = "RuneLight"
            rLight.Color = Color3.fromRGB(0, 210, 255)
            rLight.Range = 14
            rLight.Brightness = 1.4
            rLight.Parent = runeStrip
        end

        -- Energy motes
        local motes = runeStrip:FindFirstChild("EnergyMotes")
        if not motes then
            motes = Instance.new("ParticleEmitter")
            motes.Name = "EnergyMotes"
            motes.Color = ColorSequence.new(Color3.fromRGB(0, 230, 255), Color3.fromRGB(120, 255, 240))
            motes.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.4),
                NumberSequenceKeypoint.new(1, 0.1)
            })
            motes.Rate = 5
            motes.Speed = NumberRange.new(0.5, 1.5)
            motes.Lifetime = NumberRange.new(2, 4)
            motes.SpreadAngle = Vector2.new(30, 30)
            motes.Parent = runeStrip
        end
    end
end

-- ============================================================================
-- 2. ORNATE ANCIENT SEAL ALTARS
-- ============================================================================
for i = 1, 3 do
    local seal = interactables:FindFirstChild("AncientSeal_" .. i)
    if seal and seal:IsA("BasePart") then
        seal.Color = Color3.fromRGB(60, 65, 70)
        seal.Material = Enum.Material.Basalt

        local sPos = seal.Position

        -- Tiered stone plinth around seal
        local plinthName = "SealPlinth_" .. i
        local oldPlinth = map:FindFirstChild(plinthName)
        if oldPlinth then oldPlinth:Destroy() end
        local plinth = createPart(plinthName, map, Vector3.new(9, 1.2, 9), CFrame.new(sPos.X, 0.6, sPos.Z), Color3.fromRGB(75, 78, 82), Enum.Material.Cobblestone, Enum.PartType.Cylinder)

        -- Glowing core disk on top of seal
        local coreName = "SealCore_" .. i
        local oldCore = map:FindFirstChild(coreName)
        if oldCore then oldCore:Destroy() end
        local core = createPart(coreName, map, Vector3.new(3.8, 0.4, 3.8), CFrame.new(sPos.X, sPos.Y + (seal.Size.Y / 2) + 0.2, sPos.Z), Color3.fromRGB(0, 240, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
        core.CanCollide = false

        -- Vertical ethereal light beam rising from altar
        local beamName = "SealLightBeam_" .. i
        local oldBeam = map:FindFirstChild(beamName)
        if oldBeam then oldBeam:Destroy() end
        local beam = createPart(beamName, map, Vector3.new(2.4, 28, 2.4), CFrame.new(sPos.X, 15, sPos.Z), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
        beam.Transparency = 0.65
        beam.CanCollide = false

        local sLight = core:FindFirstChild("SealLight")
        if not sLight then
            sLight = Instance.new("PointLight")
            sLight.Name = "SealLight"
            sLight.Color = Color3.fromRGB(0, 220, 255)
            sLight.Range = 20
            sLight.Brightness = 2.5
            sLight.Parent = core
        end
    end
end

-- ============================================================================
-- 3. COLOSSAL ANCIENT HEARTWOOD TREE BACKDROP
-- ============================================================================
local ancientTreeModel = map:FindFirstChild("AncientHeartwoodTree")
if ancientTreeModel then ancientTreeModel:Destroy() end
ancientTreeModel = Instance.new("Model")
ancientTreeModel.Name = "AncientHeartwoodTree"
ancientTreeModel.Parent = map

local treeBasePos = Vector3.new(0, 0, -685)

-- Massive trunk
local mainTrunk = createPart("ElderTrunk", ancientTreeModel, Vector3.new(22, 50, 22), CFrame.new(treeBasePos.X, 25, treeBasePos.Z), Color3.fromRGB(55, 38, 25), Enum.Material.Wood, Enum.PartType.Cylinder)

-- Enormous Sweeping Roots wrapping into the arena perimeter
local rootConfigs = {
    { cf = CFrame.new(treeBasePos.X - 16, 4, treeBasePos.Z + 12) * CFrame.Angles(0, math.rad(-35), math.rad(15)), sz = Vector3.new(8, 8, 32) },
    { cf = CFrame.new(treeBasePos.X + 16, 4, treeBasePos.Z + 12) * CFrame.Angles(0, math.rad(35), math.rad(-15)), sz = Vector3.new(8, 8, 32) },
    { cf = CFrame.new(treeBasePos.X - 25, 2, treeBasePos.Z + 25) * CFrame.Angles(0, math.rad(-60), 0), sz = Vector3.new(6, 6, 26) },
    { cf = CFrame.new(treeBasePos.X + 25, 2, treeBasePos.Z + 25) * CFrame.Angles(0, math.rad(60), 0), sz = Vector3.new(6, 6, 26) },
}

for rIdx, rConf in ipairs(rootConfigs) do
    createPart("ElderRoot_" .. rIdx, ancientTreeModel, rConf.sz, rConf.cf, Color3.fromRGB(50, 34, 22), Enum.Material.Wood)
end

-- Hollow chest cavity with Pulsing Crystal Heart
local heartCavity = createPart("HeartCavity", ancientTreeModel, Vector3.new(6, 8, 4), CFrame.new(treeBasePos.X, 14, treeBasePos.Z + 10.5), Color3.fromRGB(20, 20, 20), Enum.Material.Slate)
heartCavity.CanCollide = false

local crystalHeart = createPart("ElderCrystalHeart", ancientTreeModel, Vector3.new(3, 4.5, 3), CFrame.new(treeBasePos.X, 14, treeBasePos.Z + 11), Color3.fromRGB(0, 255, 220), Enum.Material.Neon, Enum.PartType.Ball)
crystalHeart.CanCollide = false

local heartLight = Instance.new("PointLight")
heartLight.Name = "HeartLight"
heartLight.Color = Color3.fromRGB(0, 255, 220)
heartLight.Range = 35
heartLight.Brightness = 3.0
heartLight.Parent = crystalHeart

-- Sprawling canopy clumps high above
local canopyClumps = {
    { off = Vector3.new(0, 48, 0), sz = Vector3.new(45, 22, 45), col = Color3.fromRGB(22, 58, 38) },
    { off = Vector3.new(-18, 42, -10), sz = Vector3.new(32, 18, 32), col = Color3.fromRGB(28, 68, 44) },
    { off = Vector3.new(18, 42, -10), sz = Vector3.new(32, 18, 32), col = Color3.fromRGB(28, 68, 44) },
    { off = Vector3.new(0, 44, 16), sz = Vector3.new(36, 18, 30), col = Color3.fromRGB(34, 78, 50) },
}

for cIdx, c in ipairs(canopyClumps) do
    local foliage = createPart("ElderCanopy_" .. cIdx, ancientTreeModel, c.sz, CFrame.new(treeBasePos + c.off), c.col, Enum.Material.Grass, Enum.PartType.Ball)
    foliage.CanCollide = false
end

-- ============================================================================
-- 4. ARENA PERIMETER BOULDERS & MYSTICAL MIST
-- ============================================================================
local perimeterFolder = map:FindFirstChild("ArenaPerimeterProps")
if perimeterFolder then perimeterFolder:Destroy() end
perimeterFolder = Instance.new("Folder")
perimeterFolder.Name = "ArenaPerimeterProps"
perimeterFolder.Parent = map

-- Jagged slate boulders ringing the 120-stud arena boundary
for i = 1, 16 do
    local angle = (i / 16) * math.pi * 2
    local r = 58
    local bx = math.cos(angle) * r
    local bz = -620 + (math.sin(angle) * r)
    local bSize = Vector3.new(10 + ((i % 3) * 3), 8 + ((i % 4) * 2), 9 + ((i % 2) * 3))
    createPart("PerimeterBoulder_" .. i, perimeterFolder, bSize, CFrame.new(bx, 4, bz) * CFrame.Angles(math.rad(i * 12), math.rad(i * 25), math.rad(i * 7)), Color3.fromRGB(60, 62, 65), Enum.Material.Basalt)
end

-- Arena mist emitter
local mistNode = createPart("ArenaMistNode", perimeterFolder, Vector3.new(1, 1, 1), CFrame.new(0, 1, -620), Color3.fromRGB(0, 0, 0), Enum.Material.SmoothPlastic)
mistNode.Transparency = 1
mistNode.CanCollide = false

local mist = Instance.new("ParticleEmitter")
mist.Name = "ArenaMist"
mist.Color = ColorSequence.new(Color3.fromRGB(180, 220, 230), Color3.fromRGB(140, 180, 200))
mist.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 8),
    NumberSequenceKeypoint.new(0.5, 14),
    NumberSequenceKeypoint.new(1, 18)
})
mist.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.2, 0.75),
    NumberSequenceKeypoint.new(0.8, 0.75),
    NumberSequenceKeypoint.new(1, 1)
})
mist.Rate = 22
mist.Speed = NumberRange.new(1, 3)
mist.Lifetime = NumberRange.new(6, 12)
mist.SpreadAngle = Vector2.new(180, 180)
mist.Acceleration = Vector3.new(0, 0.1, 0)
mist.Parent = mistNode

print("[build_boss_arena] Forest Guardian Boss Arena overhaul complete!")
return true
