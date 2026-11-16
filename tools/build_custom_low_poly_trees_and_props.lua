--!strict
--[[
    build_custom_low_poly_trees_and_props.lua
    Procedural low-poly tree variations and deployable physical tool templates.
    Implements The_Forgotten_Forest_Complete_Experience_Bible.md Sections 7, 10, and 14.
]]

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local function buildCustomTreesAndProps()
    print("==================================================")
    print("  BUILDING LOW-POLY TREE VARIATIONS & TEMPLATES   ")
    print("==================================================")

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return false end
    local map = tffWorld:FindFirstChild("Map")
    if not map then return false end

    local function createPart(name: string, size: Vector3, pos: Vector3, color: Color3, mat: Enum.Material, parent: Instance, canCollide: boolean?): Part
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Position = pos
        p.Color = color
        p.Material = mat
        p.Anchored = true
        p.CanCollide = if canCollide ~= nil then canCollide else true
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = parent
        return p
    end

    ------------------------------------------------------------------
    -- 1. SCATTERED TALL STRAIGHT PINES & ANCIENT OAKS IN MAP
    ------------------------------------------------------------------
    local treeFolder = map:FindFirstChild("Flora_ExperienceBible")
    if treeFolder then treeFolder:Destroy() end

    treeFolder = Instance.new("Folder")
    treeFolder.Name = "Flora_ExperienceBible"
    treeFolder.Parent = map

    -- 1.1 Tall Straight Pines along Whispering Woods trails
    local pinePositions = {
        Vector3.new(-25, 0, -320),
        Vector3.new(35, 0, -420),
        Vector3.new(-65, 0, -650),
        Vector3.new(45, 0, -720),
        Vector3.new(-20, 0, -880),
        Vector3.new(55, 0, -960),
    }

    for idx, pos in ipairs(pinePositions) do
        local pine = Instance.new("Model")
        pine.Name = "Tree_StraightPine_" .. idx
        pine.Parent = treeFolder

        -- Trunk
        local trunk = createPart("Trunk", Vector3.new(3.2, 42, 3.2), pos + Vector3.new(0, 21, 0), Color3.fromRGB(75, 55, 40), Enum.Material.Wood, pine)
        pine.PrimaryPart = trunk

        -- 4 Tiered Conical Foliage Layers
        local tiers = {
            { size = Vector3.new(16, 8, 16), yOffset = 18 },
            { size = Vector3.new(13, 8, 13), yOffset = 25 },
            { size = Vector3.new(10, 8, 10), yOffset = 32 },
            { size = Vector3.new(6, 8, 6), yOffset = 39 },
        }
        for tIdx, tier in ipairs(tiers) do
            createPart("FoliageTier_" .. tIdx, tier.size, pos + Vector3.new(0, tier.yOffset, 0), Color3.fromRGB(35, 75, 35), Enum.Material.Grass, pine, false)
        end
    end
    print("✔ [1/3] Tall Straight Pines Sculpted & Placed")

    -- 1.2 Broad Ancient Canopy Oaks
    local oakPositions = {
        Vector3.new(-55, 0, -360),
        Vector3.new(65, 0, -480),
        Vector3.new(-30, 0, -780),
        Vector3.new(20, 0, -1020),
    }
    for idx, pos in ipairs(oakPositions) do
        local oak = Instance.new("Model")
        oak.Name = "Tree_AncientOak_" .. idx
        oak.Parent = treeFolder

        local trunk = createPart("OakTrunk", Vector3.new(5.0, 32, 5.0), pos + Vector3.new(0, 16, 0), Color3.fromRGB(65, 48, 35), Enum.Material.Wood, oak)
        oak.PrimaryPart = trunk

        -- Broad sprawling foliage canopies
        createPart("Canopy_Center", Vector3.new(22, 12, 22), pos + Vector3.new(0, 30, 0), Color3.fromRGB(48, 90, 42), Enum.Material.Grass, oak, false)
        createPart("Canopy_North", Vector3.new(16, 9, 16), pos + Vector3.new(0, 28, -8), Color3.fromRGB(42, 82, 38), Enum.Material.Grass, oak, false)
        createPart("Canopy_South", Vector3.new(16, 9, 16), pos + Vector3.new(0, 28, 8), Color3.fromRGB(52, 95, 45), Enum.Material.Grass, oak, false)
        createPart("Canopy_West", Vector3.new(15, 9, 15), pos + Vector3.new(-8, 27, 0), Color3.fromRGB(45, 86, 40), Enum.Material.Grass, oak, false)
    end
    print("✔ [2/3] Broad Ancient Canopy Oaks Sculpted & Placed")

    -- 1.3 Traversable Hollow Log
    local hollowLog = Instance.new("Model")
    hollowLog.Name = "Prop_HollowLog_Crossing"
    hollowLog.Parent = treeFolder

    local logPos = Vector3.new(-15, -2, -378)
    local floorPart = createPart("LogFloor", Vector3.new(5.5, 1.0, 28), logPos + Vector3.new(0, 0.5, 0), Color3.fromRGB(70, 50, 35), Enum.Material.Wood, hollowLog)
    hollowLog.PrimaryPart = floorPart
    -- Walls and roof forming hollow tunnel
    createPart("LogWall_L", Vector3.new(1.0, 5.0, 28), logPos + Vector3.new(-2.6, 3.0, 0), Color3.fromRGB(65, 45, 30), Enum.Material.Wood, hollowLog)
    createPart("LogWall_R", Vector3.new(1.0, 5.0, 28), logPos + Vector3.new(2.6, 3.0, 0), Color3.fromRGB(65, 45, 30), Enum.Material.Wood, hollowLog)
    createPart("LogCeiling", Vector3.new(5.5, 1.0, 28), logPos + Vector3.new(0, 5.8, 0), Color3.fromRGB(60, 42, 28), Enum.Material.Wood, hollowLog)
    createPart("MossPatch", Vector3.new(5.8, 0.4, 26), logPos + Vector3.new(0, 6.3, 0), Color3.fromRGB(55, 95, 45), Enum.Material.Grass, hollowLog, false)

    ------------------------------------------------------------------
    -- 2. PHYSICAL TOOL TEMPLATES IN SERVERSTORAGE
    ------------------------------------------------------------------
    local tffStorage = ServerStorage:FindFirstChild("TFF")
    if not tffStorage then
        tffStorage = Instance.new("Folder")
        tffStorage.Name = "TFF"
        tffStorage.Parent = ServerStorage
    end

    local templates = tffStorage:FindFirstChild("Templates")
    if not templates then
        templates = Instance.new("Folder")
        templates.Name = "Templates"
        templates.Parent = tffStorage
    end

    local tools = templates:FindFirstChild("Tools")
    if not tools then
        tools = Instance.new("Folder")
        tools.Name = "Tools"
        tools.Parent = templates
    end

    -- 2.1 Advanced Lantern Template
    local existingAdvLantern = tools:FindFirstChild("advanced_lantern")
    if existingAdvLantern then existingAdvLantern:Destroy() end

    local advLantern = Instance.new("Tool")
    advLantern.Name = "advanced_lantern"
    advLantern.RequiresHandle = true
    advLantern.CanBeDropped = false

    local aHandle = Instance.new("Part")
    aHandle.Name = "Handle"
    aHandle.Size = Vector3.new(1.2, 2.0, 1.2)
    aHandle.Color = Color3.fromRGB(210, 170, 70)
    aHandle.Material = Enum.Material.Metal
    aHandle.CanCollide = false
    aHandle.Parent = advLantern

    local aCore = Instance.new("Part")
    aCore.Name = "CrystalCore"
    aCore.Size = Vector3.new(0.8, 1.2, 0.8)
    aCore.Color = Color3.fromRGB(100, 235, 255)
    aCore.Material = Enum.Material.Neon
    aCore.CanCollide = false
    aCore.Parent = advLantern

    local aLight = Instance.new("PointLight")
    aLight.Color = Color3.fromRGB(120, 240, 255)
    aLight.Range = 40
    aLight.Brightness = 3.0
    aLight.Parent = aCore

    local aWeld = Instance.new("WeldConstraint")
    aWeld.Part0 = aHandle
    aWeld.Part1 = aCore
    aWeld.Parent = aHandle
    advLantern.Parent = tools

    -- 2.2 Wooden Barricade Tool Template
    local existingBarricade = tools:FindFirstChild("wooden_barricade")
    if existingBarricade then existingBarricade:Destroy() end

    local barTool = Instance.new("Tool")
    barTool.Name = "wooden_barricade"
    barTool.RequiresHandle = true
    barTool.CanBeDropped = false

    local bHandle = Instance.new("Part")
    bHandle.Name = "Handle"
    bHandle.Size = Vector3.new(3.5, 2.5, 1.2)
    bHandle.Color = Color3.fromRGB(90, 65, 45)
    bHandle.Material = Enum.Material.WoodPlanks
    bHandle.CanCollide = false
    bHandle.Parent = barTool
    barTool.Parent = tools

    -- 2.3 Snare Trap Tool Template
    local existingTrap = tools:FindFirstChild("basic_trap")
    if existingTrap then existingTrap:Destroy() end

    local trapTool = Instance.new("Tool")
    trapTool.Name = "basic_trap"
    trapTool.RequiresHandle = true
    trapTool.CanBeDropped = false

    local trHandle = Instance.new("Part")
    trHandle.Name = "Handle"
    trHandle.Size = Vector3.new(2.2, 0.6, 2.2)
    trHandle.Color = Color3.fromRGB(75, 55, 35)
    trHandle.Material = Enum.Material.Wood
    trHandle.CanCollide = false
    trHandle.Parent = trapTool
    trapTool.Parent = tools

    print("✔ [3/3] Physical Tool Templates Created in ServerStorage")
    print("==================================================")
    print("  LOW-POLY TREE VARIATIONS & TEMPLATES COMPLETE!  ")
    print("==================================================")
    return true
end

return buildCustomTreesAndProps()
