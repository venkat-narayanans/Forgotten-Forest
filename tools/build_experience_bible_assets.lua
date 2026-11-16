--!strict
--[[
    build_experience_bible_assets.lua
    Procedural 3D Low-Poly Asset Generator for The Forgotten Forest.
    Constructs all signature narrative and environmental landmarks specified in
    The_Forgotten_Forest_Complete_Experience_Bible.md:
    1. Safe Haven Central Beacon (Multi-state stone & iron beacon with dark crystal core & amber light)
    2. Safe Haven 30-Stud Timber Watchtower & Mounted Brass Telescope
    3. Safe Haven Artisan Workshop (Anvil, forge, tool rack, quenching tub)
    4. Safe Haven Trader Stall (Market booth, shelves, ledger, jars)
    5. Whispering Woods Split Oak Landmark (46-stud lightning-split oak, half-dead/half-alive, Keeper rune)
    6. Creek Ravine Timber Trestle Bridge (40-stud sturdy crossing)
    7. Silent Pond Keeper Tri-Pillar Shrine (Circular dais, 3 triangular rune pillars)
    8. Abandoned Village 48-Stud Clock Tower (Stone tower, stopped clock mechanism)
    9. Abandoned Village Keeper Archive Vault (Arched portal, vault doors, Three Puzzle Lanterns)
    10. Abandoned Village Dry Fountain (Hexagonal basin, 5-Seal carved medallion)
    11. Abandoned Village Secret Well (Stone well rim, descending undercroft ladder)
    12. Custom Low-Poly Trees (Tall Straight Pines, Ancient Wide Oaks, Hollow Logs, Twisted Supernatural Trees)
]]

local Workspace = game:GetService("Workspace")

local function buildExperienceBibleAssets()
    print("==================================================")
    print("  BUILDING COMPLETE EXPERIENCE BIBLE 3D ASSETS   ")
    print("==================================================")

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
    -- 1. SAFE HAVEN CENTRAL BEACON
    ------------------------------------------------------------------
    local existingBeacon = interactables:FindFirstChild("SafeHaven_CentralBeacon")
    if existingBeacon then existingBeacon:Destroy() end

    local beaconModel = Instance.new("Model")
    beaconModel.Name = "SafeHaven_CentralBeacon"
    beaconModel:SetAttribute("State", "Damaged")
    beaconModel.Parent = interactables

    -- Stone pedestal
    local bBase = createPart("StoneBase", Vector3.new(10, 2, 10), Vector3.new(0, 1, -4), Color3.fromRGB(85, 85, 80), Enum.Material.Slate, beaconModel)
    beaconModel.PrimaryPart = bBase
    createPart("StoneStep", Vector3.new(7, 2, 7), Vector3.new(0, 3, -4), Color3.fromRGB(95, 95, 90), Enum.Material.Slate, beaconModel)

    -- Iron brackets and cage
    for i = 1, 4 do
        local angle = (i - 1) * math.pi / 2 + math.pi / 4
        local bx = math.cos(angle) * 3.2
        local bz = -4 + math.sin(angle) * 3.2
        createPart("IronPillar_" .. i, Vector3.new(0.8, 8, 0.8), Vector3.new(bx, 8, bz), Color3.fromRGB(35, 35, 38), Enum.Material.Metal, beaconModel)
    end
    createPart("IronCap", Vector3.new(6.5, 1, 6.5), Vector3.new(0, 12, -4), Color3.fromRGB(40, 40, 42), Enum.Material.Metal, beaconModel)

    -- Central Beacon Core (dark crystal initially)
    local bCore = createPart("BeaconCore", Vector3.new(2.8, 5, 2.8), Vector3.new(0, 7.5, -4), Color3.fromRGB(220, 140, 40), Enum.Material.Neon, beaconModel, false)
    local bLight = Instance.new("PointLight")
    bLight.Name = "BeaconLight"
    bLight.Color = Color3.fromRGB(255, 190, 80)
    bLight.Range = 45
    bLight.Brightness = 2.5
    bLight.Parent = bCore

    -- Prompt and Billboard
    local bPrompt = Instance.new("ProximityPrompt")
    bPrompt.Name = "BeaconPrompt"
    bPrompt.ActionText = "Repair Beacon (4 Wood, 2 Stone)"
    bPrompt.ObjectText = "Safe Haven Central Beacon"
    bPrompt.HoldDuration = 1.0
    bPrompt.MaxActivationDistance = 14
    bPrompt.Parent = bBase

    local bGui = Instance.new("BillboardGui")
    bGui.Name = "BeaconNameplate"
    bGui.Size = UDim2.new(0, 260, 0, 45)
    bGui.StudsOffset = Vector3.new(0, 7, 0)
    bGui.AlwaysOnTop = true
    bGui.Parent = bBase

    local bLabel = Instance.new("TextLabel")
    bLabel.Size = UDim2.new(1, 0, 1, 0)
    bLabel.BackgroundTransparency = 1
    bLabel.Text = "CENTRAL BEACON\n[Safe Haven Light Anchor]"
    bLabel.TextColor3 = Color3.fromRGB(255, 215, 120)
    bLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
    bLabel.TextStrokeTransparency = 0.2
    bLabel.Font = Enum.Font.GothamBold
    bLabel.TextSize = 13
    bLabel.Parent = bGui

    print("✔ [1/11] Safe Haven Central Beacon Created")

    ------------------------------------------------------------------
    -- 2. SAFE HAVEN 30-STUD TIMBER WATCHTOWER & TELESCOPE
    ------------------------------------------------------------------
    local existingTower = interactables:FindFirstChild("SafeHaven_Watchtower")
    if existingTower then existingTower:Destroy() end

    local towerModel = Instance.new("Model")
    towerModel.Name = "SafeHaven_Watchtower"
    towerModel.Parent = interactables

    local twBasePos = Vector3.new(38, 0, -55)
    local tBase = createPart("TowerGroundPad", Vector3.new(18, 1, 18), twBasePos + Vector3.new(0, 0.5, 0), Color3.fromRGB(70, 60, 50), Enum.Material.WoodPlanks, towerModel)
    towerModel.PrimaryPart = tBase

    -- 4 Heavy corner posts
    local postOffsets = {
        Vector3.new(-7, 15, -7),
        Vector3.new(7, 15, -7),
        Vector3.new(-7, 15, 7),
        Vector3.new(7, 15, 7),
    }
    for i, offset in ipairs(postOffsets) do
        createPart("TowerPost_" .. i, Vector3.new(1.8, 30, 1.8), twBasePos + offset, Color3.fromRGB(90, 65, 45), Enum.Material.Wood, towerModel)
    end

    -- Cross bracing
    createPart("CrossBrace_1", Vector3.new(14, 0.8, 0.8), twBasePos + Vector3.new(0, 12, -7), Color3.fromRGB(80, 55, 38), Enum.Material.Wood, towerModel)
    createPart("CrossBrace_2", Vector3.new(14, 0.8, 0.8), twBasePos + Vector3.new(0, 12, 7), Color3.fromRGB(80, 55, 38), Enum.Material.Wood, towerModel)
    createPart("CrossBrace_3", Vector3.new(0.8, 0.8, 14), twBasePos + Vector3.new(-7, 12, 0), Color3.fromRGB(80, 55, 38), Enum.Material.Wood, towerModel)
    createPart("CrossBrace_4", Vector3.new(0.8, 0.8, 14), twBasePos + Vector3.new(7, 12, 0), Color3.fromRGB(80, 55, 38), Enum.Material.Wood, towerModel)

    -- Upper Deck (Y = 22)
    local deckPos = twBasePos + Vector3.new(0, 22, 0)
    createPart("ObservationDeck", Vector3.new(16, 1.2, 16), deckPos, Color3.fromRGB(110, 80, 55), Enum.Material.WoodPlanks, towerModel)

    -- Deck Railings
    createPart("DeckRail_N", Vector3.new(15, 3, 0.6), deckPos + Vector3.new(0, 2, -7.5), Color3.fromRGB(85, 60, 40), Enum.Material.Wood, towerModel)
    createPart("DeckRail_S", Vector3.new(15, 3, 0.6), deckPos + Vector3.new(0, 2, 7.5), Color3.fromRGB(85, 60, 40), Enum.Material.Wood, towerModel)
    createPart("DeckRail_E", Vector3.new(0.6, 3, 15), deckPos + Vector3.new(7.5, 2, 0), Color3.fromRGB(85, 60, 40), Enum.Material.Wood, towerModel)
    createPart("DeckRail_W", Vector3.new(0.6, 3, 10), deckPos + Vector3.new(-7.5, 2, 2.5), Color3.fromRGB(85, 60, 40), Enum.Material.Wood, towerModel)

    -- Canopy Roof (Y = 30)
    createPart("CanopyRoof", Vector3.new(18, 1.5, 18), twBasePos + Vector3.new(0, 30, 0), Color3.fromRGB(60, 50, 40), Enum.Material.Wood, towerModel)

    -- Climbable stairs (series of ascending stepped platforms)
    for step = 1, 14 do
        local stepY = (step / 14) * 21
        local stepZ = twBasePos.Z + 7 - (step * 0.9)
        local stepX = twBasePos.X - 6
        createPart("StairStep_" .. step, Vector3.new(4, 0.8, 1.5), Vector3.new(stepX, stepY, stepZ), Color3.fromRGB(100, 75, 50), Enum.Material.WoodPlanks, towerModel)
    end

    -- Mounted Brass Telescope
    local telePedestal = createPart("TelescopePedestal", Vector3.new(1.2, 3.5, 1.2), deckPos + Vector3.new(0, 2.2, -5.5), Color3.fromRGB(120, 95, 60), Enum.Material.Wood, towerModel)
    local teleBarrel = createPart("Prop_BrassTelescope", Vector3.new(0.8, 0.8, 3.8), deckPos + Vector3.new(0, 4.2, -5.5), Color3.fromRGB(205, 165, 65), Enum.Material.Metal, towerModel, false)
    teleBarrel.Orientation = Vector3.new(-12, 0, 0)

    local telePrompt = Instance.new("ProximityPrompt")
    telePrompt.Name = "TelescopePrompt"
    telePrompt.ActionText = "Survey Valley Landmarks"
    telePrompt.ObjectText = "Brass Telescope"
    telePrompt.HoldDuration = 0.5
    telePrompt.MaxActivationDistance = 9
    telePrompt.Parent = teleBarrel

    print("✔ [2/11] Safe Haven 30-Stud Watchtower & Telescope Created")

    ------------------------------------------------------------------
    -- 3. SAFE HAVEN ARTISAN WORKSHOP (Anvil, Forge & Tool Racks)
    ------------------------------------------------------------------
    local existingShop = interactables:FindFirstChild("SafeHaven_ArtisanWorkshop")
    if existingShop then existingShop:Destroy() end

    local shopModel = Instance.new("Model")
    shopModel.Name = "SafeHaven_ArtisanWorkshop"
    shopModel.Parent = interactables

    local shopPos = Vector3.new(-22, 0, 18)
    local sPad = createPart("WorkshopFloor", Vector3.new(14, 0.8, 12), shopPos + Vector3.new(0, 0.4, 0), Color3.fromRGB(80, 80, 75), Enum.Material.Cobblestone, shopModel)
    shopModel.PrimaryPart = sPad

    -- Stone Forge & Glowing Coals
    createPart("StoneForge", Vector3.new(5, 4, 3.5), shopPos + Vector3.new(-3.5, 2, -3.5), Color3.fromRGB(60, 60, 60), Enum.Material.Slate, shopModel)
    local coals = createPart("ForgeCoals", Vector3.new(3.5, 0.6, 2.2), shopPos + Vector3.new(-3.5, 3.8, -3.5), Color3.fromRGB(255, 90, 20), Enum.Material.Neon, shopModel, false)
    local fLight = Instance.new("PointLight")
    fLight.Color = Color3.fromRGB(255, 120, 30)
    fLight.Range = 14
    fLight.Brightness = 2.0
    fLight.Parent = coals

    -- Heavy Cast Iron Anvil
    createPart("AnvilBase", Vector3.new(2.4, 1.2, 2.4), shopPos + Vector3.new(2, 0.8, 0), Color3.fromRGB(45, 45, 50), Enum.Material.Metal, shopModel)
    createPart("AnvilBody", Vector3.new(1.8, 1.0, 3.8), shopPos + Vector3.new(2, 2.0, 0), Color3.fromRGB(35, 35, 40), Enum.Material.Metal, shopModel)

    -- Quenching Tub
    createPart("QuenchTub", Vector3.new(3.0, 2.2, 2.4), shopPos + Vector3.new(3.5, 1.1, -3.5), Color3.fromRGB(85, 60, 40), Enum.Material.Wood, shopModel)
    createPart("QuenchWater", Vector3.new(2.6, 0.4, 2.0), shopPos + Vector3.new(3.5, 2.0, -3.5), Color3.fromRGB(50, 120, 180), Enum.Material.Glass, shopModel, false)

    -- Tool Rack
    createPart("ToolRack", Vector3.new(4.5, 5.0, 0.6), shopPos + Vector3.new(-3.5, 2.5, 4.5), Color3.fromRGB(90, 70, 50), Enum.Material.Wood, shopModel)

    print("✔ [3/11] Safe Haven Artisan Workshop Created")

    ------------------------------------------------------------------
    -- 4. SAFE HAVEN TRADER STALL
    ------------------------------------------------------------------
    local existingStall = interactables:FindFirstChild("SafeHaven_TraderStall")
    if existingStall then existingStall:Destroy() end

    local stallModel = Instance.new("Model")
    stallModel.Name = "SafeHaven_TraderStall"
    stallModel.Parent = interactables

    local stallPos = Vector3.new(32, 0, 12)
    local stPad = createPart("StallPlatform", Vector3.new(12, 0.8, 10), stallPos + Vector3.new(0, 0.4, 0), Color3.fromRGB(95, 75, 55), Enum.Material.WoodPlanks, stallModel)
    stallModel.PrimaryPart = stPad

    -- Countertop
    createPart("TraderCounter", Vector3.new(10, 2.8, 2), stallPos + Vector3.new(0, 1.6, -1.5), Color3.fromRGB(110, 85, 60), Enum.Material.WoodPlanks, stallModel)
    -- Shelves & Goods
    createPart("ShelvingUnit", Vector3.new(9, 6.5, 1.5), stallPos + Vector3.new(0, 3.5, 3.5), Color3.fromRGB(85, 65, 45), Enum.Material.Wood, stallModel)
    createPart("ClothBundle", Vector3.new(2.5, 1.2, 1.2), stallPos + Vector3.new(-2.5, 3.8, 3.5), Color3.fromRGB(160, 140, 100), Enum.Material.Fabric, stallModel)
    createPart("StoragePot", Vector3.new(1.4, 1.6, 1.4), stallPos + Vector3.new(2.2, 4.0, 3.5), Color3.fromRGB(150, 90, 60), Enum.Material.Slate, stallModel)

    -- Striped Awning
    createPart("AwningRoof", Vector3.new(12, 0.6, 10), stallPos + Vector3.new(0, 8.5, 0), Color3.fromRGB(180, 50, 45), Enum.Material.Fabric, stallModel)

    print("✔ [4/11] Safe Haven Trader Stall Created")

    ------------------------------------------------------------------
    -- 5. WHISPERING WOODS SPLIT OAK LANDMARK
    ------------------------------------------------------------------
    local existingSplitOak = interactables:FindFirstChild("Tree_SplitOak_Landmark")
    if existingSplitOak then existingSplitOak:Destroy() end

    local oakModel = Instance.new("Model")
    oakModel.Name = "Tree_SplitOak_Landmark"
    oakModel.Parent = interactables

    local oakPos = Vector3.new(-45, 0, -520)
    local oBase = createPart("SplitOakBase", Vector3.new(12, 2, 12), oakPos + Vector3.new(0, 1, 0), Color3.fromRGB(55, 40, 30), Enum.Material.Wood, oakModel)
    oakModel.PrimaryPart = oBase

    -- Dead Half (Charred Blackened Timber, Left)
    local deadTrunk = createPart("DeadTrunk", Vector3.new(4.5, 38, 4.5), oakPos + Vector3.new(-3, 19, 0), Color3.fromRGB(30, 28, 28), Enum.Material.Wood, oakModel)
    deadTrunk.Orientation = Vector3.new(0, 0, 7)
    createPart("DeadBranch_1", Vector3.new(2, 12, 2), oakPos + Vector3.new(-6, 32, 2), Color3.fromRGB(28, 25, 25), Enum.Material.Wood, oakModel)
    createPart("DeadBranch_2", Vector3.new(2, 10, 2), oakPos + Vector3.new(-4, 34, -3), Color3.fromRGB(28, 25, 25), Enum.Material.Wood, oakModel)

    -- Living Half (Lush Green Mossy Timber, Right)
    local livingTrunk = createPart("LivingTrunk", Vector3.new(4.8, 42, 4.8), oakPos + Vector3.new(3, 21, 0), Color3.fromRGB(75, 55, 38), Enum.Material.Wood, oakModel)
    livingTrunk.Orientation = Vector3.new(0, 0, -5)
    -- Living leaf clusters
    createPart("LivingCanopy_1", Vector3.new(14, 10, 14), oakPos + Vector3.new(6, 40, 0), Color3.fromRGB(45, 85, 40), Enum.Material.Grass, oakModel, false)
    createPart("LivingCanopy_2", Vector3.new(11, 8, 11), oakPos + Vector3.new(8, 46, -2), Color3.fromRGB(50, 95, 45), Enum.Material.Grass, oakModel, false)

    -- Glowing Heartroot Sap Veins
    local sapVein = createPart("HeartrootSapVein", Vector3.new(1.2, 16, 1.2), oakPos + Vector3.new(2.5, 10, 2), Color3.fromRGB(80, 230, 255), Enum.Material.Neon, oakModel, false)
    local sapLight = Instance.new("PointLight")
    sapLight.Color = Color3.fromRGB(80, 230, 255)
    sapLight.Range = 16
    sapLight.Brightness = 1.8
    sapLight.Parent = sapVein

    -- Carved Keeper Inscription & Supply Cache in the central cleft
    local cleftCache = createPart("SplitOak_Cache", Vector3.new(2.4, 2.0, 2.4), oakPos + Vector3.new(0, 2.5, 0), Color3.fromRGB(60, 50, 40), Enum.Material.Wood, oakModel)
    local cachePrompt = Instance.new("ProximityPrompt")
    cachePrompt.Name = "CachePrompt"
    cachePrompt.ActionText = "Inspect Split Oak Inscription"
    cachePrompt.ObjectText = "Split Oak Landmark"
    cachePrompt.HoldDuration = 0.5
    cachePrompt.Parent = cleftCache

    print("✔ [5/11] Whispering Woods Split Oak Landmark Created")

    ------------------------------------------------------------------
    -- 6. CREEK RAVINE TIMBER TRESTLE BRIDGE
    ------------------------------------------------------------------
    local existingBridge = interactables:FindFirstChild("Bridge_Ravine_Timber")
    if existingBridge then existingBridge:Destroy() end

    local bridgeModel = Instance.new("Model")
    bridgeModel.Name = "Bridge_Ravine_Timber"
    bridgeModel.Parent = interactables

    local brPos = Vector3.new(12, -4, -380)
    -- Stone Abutments on both banks
    createPart("SouthAbutment", Vector3.new(14, 8, 6), brPos + Vector3.new(0, 0, 18), Color3.fromRGB(80, 80, 75), Enum.Material.Slate, bridgeModel)
    createPart("NorthAbutment", Vector3.new(14, 8, 6), brPos + Vector3.new(0, 0, -18), Color3.fromRGB(80, 80, 75), Enum.Material.Slate, bridgeModel)

    -- Sturdy Timber Bridge Deck
    local brDeck = createPart("BridgeDeck", Vector3.new(8, 1.2, 36), brPos + Vector3.new(0, 4, 0), Color3.fromRGB(95, 70, 45), Enum.Material.WoodPlanks, bridgeModel)
    bridgeModel.PrimaryPart = brDeck

    -- Guide Railings
    createPart("GuideRail_L", Vector3.new(0.8, 3.0, 36), brPos + Vector3.new(-3.6, 5.5, 0), Color3.fromRGB(80, 55, 35), Enum.Material.Wood, bridgeModel)
    createPart("GuideRail_R", Vector3.new(0.8, 3.0, 36), brPos + Vector3.new(3.6, 5.5, 0), Color3.fromRGB(80, 55, 35), Enum.Material.Wood, bridgeModel)

    print("✔ [6/11] Creek Ravine Timber Trestle Bridge Created")

    ------------------------------------------------------------------
    -- 7. SILENT POND KEEPER TRI-PILLAR SHRINE
    ------------------------------------------------------------------
    local existingShrine = interactables:FindFirstChild("Shrine_KeeperTriPillar")
    if existingShrine then existingShrine:Destroy() end

    local shrineModel = Instance.new("Model")
    shrineModel.Name = "Shrine_KeeperTriPillar"
    shrineModel.Parent = interactables

    local shrinePos = Vector3.new(85, 0, -780)
    local sDais = createPart("StoneDais", Vector3.new(22, 1.5, 22), shrinePos + Vector3.new(0, 0.75, 0), Color3.fromRGB(90, 90, 85), Enum.Material.Slate, shrineModel)
    shrineModel.PrimaryPart = sDais

    -- 3 Triangular Megalith Rune Pillars
    local pillarNames = { "Root", "Veil", "Echo" }
    for i = 1, 3 do
        local rad = (i - 1) * (2 * math.pi / 3)
        local px = math.cos(rad) * 7.5
        local pz = math.sin(rad) * 7.5
        local pillar = createPart("Megalith_" .. pillarNames[i], Vector3.new(2.5, 12, 2.5), shrinePos + Vector3.new(px, 6.5, pz), Color3.fromRGB(70, 70, 75), Enum.Material.Slate, shrineModel)
        -- Glowing rune inscription
        createPart("RuneGlyph_" .. pillarNames[i], Vector3.new(1.2, 3, 0.4), shrinePos + Vector3.new(px * 0.85, 6.5, pz * 0.85), Color3.fromRGB(100, 220, 255), Enum.Material.Neon, shrineModel, false)
    end

    -- Central Runic Basin
    local basin = createPart("RunicBasin", Vector3.new(4, 1.8, 4), shrinePos + Vector3.new(0, 1.6, 0), Color3.fromRGB(50, 50, 55), Enum.Material.Slate, shrineModel)
    local shrinePrompt = Instance.new("ProximityPrompt")
    shrinePrompt.Name = "ShrinePrompt"
    shrinePrompt.ActionText = "Attune to Keeper Shrine"
    shrinePrompt.ObjectText = "Keeper Tri-Pillar Shrine"
    shrinePrompt.HoldDuration = 1.0
    shrinePrompt.Parent = basin

    print("✔ [7/11] Silent Pond Keeper Tri-Pillar Shrine Created")

    ------------------------------------------------------------------
    -- 8. ABANDONED VILLAGE 48-STUD CLOCK TOWER
    ------------------------------------------------------------------
    local existingClock = interactables:FindFirstChild("Village_ClockTower_48")
    if existingClock then existingClock:Destroy() end

    local clockModel = Instance.new("Model")
    clockModel.Name = "Village_ClockTower_48"
    clockModel.Parent = interactables

    local clockPos = Vector3.new(65, 0, -1450)
    -- Stone Tower Base (Height 48 studs)
    local cBase = createPart("ClockTowerBase", Vector3.new(18, 48, 18), clockPos + Vector3.new(0, 24, 0), Color3.fromRGB(80, 80, 80), Enum.Material.Cobblestone, clockModel)
    clockModel.PrimaryPart = cBase

    -- Belfry & Roof
    createPart("BelfryArch", Vector3.new(16, 8, 16), clockPos + Vector3.new(0, 52, 0), Color3.fromRGB(70, 70, 70), Enum.Material.Slate, clockModel)
    createPart("PitchedSpire", Vector3.new(18, 14, 18), clockPos + Vector3.new(0, 63, 0), Color3.fromRGB(50, 55, 60), Enum.Material.Slate, clockModel)

    -- Clock Face (Stopped at midnight)
    local cFace = createPart("ClockFace", Vector3.new(8, 8, 0.6), clockPos + Vector3.new(0, 42, -9.3), Color3.fromRGB(240, 230, 200), Enum.Material.SmoothPlastic, clockModel)
    createPart("ClockHands", Vector3.new(0.6, 3.6, 0.4), clockPos + Vector3.new(0, 43, -9.7), Color3.fromRGB(30, 30, 30), Enum.Material.Metal, clockModel)

    -- Undercroft Gear Mechanism
    local gearBox = createPart("ClockMechanism", Vector3.new(4, 3, 2), clockPos + Vector3.new(0, 2.5, -9.2), Color3.fromRGB(150, 120, 60), Enum.Material.Metal, clockModel)
    local clockPrompt = Instance.new("ProximityPrompt")
    clockPrompt.Name = "ClockPrompt"
    clockPrompt.ActionText = "Inspect Stopped Clock Mechanism"
    clockPrompt.ObjectText = "Village Clock Tower"
    clockPrompt.HoldDuration = 1.0
    clockPrompt.Parent = gearBox

    print("✔ [8/11] Abandoned Village 48-Stud Clock Tower Created")

    ------------------------------------------------------------------
    -- 9. ABANDONED VILLAGE KEEPER ARCHIVE VAULT & THREE LANTERNS
    ------------------------------------------------------------------
    local existingArchive = interactables:FindFirstChild("Village_KeeperArchive")
    if existingArchive then existingArchive:Destroy() end

    local archiveModel = Instance.new("Model")
    archiveModel.Name = "Village_KeeperArchive"
    archiveModel.Parent = interactables

    local archPos = Vector3.new(-35, 0, -1620)
    -- Carved stone archway
    local aFrameL = createPart("ArchFrameL", Vector3.new(4, 18, 6), archPos + Vector3.new(-9, 9, 0), Color3.fromRGB(75, 75, 80), Enum.Material.Slate, archiveModel)
    archiveModel.PrimaryPart = aFrameL
    createPart("ArchFrameR", Vector3.new(4, 18, 6), archPos + Vector3.new(9, 9, 0), Color3.fromRGB(75, 75, 80), Enum.Material.Slate, archiveModel)
    createPart("ArchLintel", Vector3.new(22, 5, 6), archPos + Vector3.new(0, 20.5, 0), Color3.fromRGB(80, 80, 85), Enum.Material.Slate, archiveModel)

    -- Heavy Iron Vault Door
    local vaultDoor = createPart("VaultDoor", Vector3.new(14, 16, 2), archPos + Vector3.new(0, 8, 0), Color3.fromRGB(45, 45, 50), Enum.Material.Metal, archiveModel)

    -- Three Puzzle Lanterns: Root, Ember, Echo
    local lanternDefs = {
        { name = "ArchiveLantern_Root", label = "Root Rune", offset = Vector3.new(-12, 4, 3) },
        { name = "ArchiveLantern_Ember", label = "Ember Rune", offset = Vector3.new(0, 24, 3) },
        { name = "ArchiveLantern_Echo", label = "Echo Rune", offset = Vector3.new(12, 4, 3) },
    }
    for _, lDef in ipairs(lanternDefs) do
        local lPlinth = createPart(lDef.name .. "_Plinth", Vector3.new(1.8, 4, 1.8), archPos + lDef.offset, Color3.fromRGB(60, 60, 65), Enum.Material.Slate, archiveModel)
        local lFlame = createPart("LanternFlame", Vector3.new(1, 1.2, 1), archPos + lDef.offset + Vector3.new(0, 2.5, 0), Color3.fromRGB(60, 60, 60), Enum.Material.Glass, lPlinth, false)
        local lPrompt = Instance.new("ProximityPrompt")
        lPrompt.Name = "LanternPrompt"
        lPrompt.ActionText = "Light " .. lDef.label
        lPrompt.ObjectText = "Keeper Archive Ward"
        lPrompt.HoldDuration = 0.5
        lPrompt.Parent = lPlinth
    end

    print("✔ [9/11] Abandoned Village Keeper Archive & Three Lanterns Created")

    ------------------------------------------------------------------
    -- 10. ABANDONED VILLAGE DRY FOUNTAIN
    ------------------------------------------------------------------
    local existingFountain = interactables:FindFirstChild("Village_DryFountain")
    if existingFountain then existingFountain:Destroy() end

    local fountainModel = Instance.new("Model")
    fountainModel.Name = "Village_DryFountain"
    fountainModel.Parent = interactables

    local fPos = Vector3.new(20, 0, -1380)
    local fBasin = createPart("FountainBasin", Vector3.new(16, 1.8, 16), fPos + Vector3.new(0, 0.9, 0), Color3.fromRGB(85, 85, 80), Enum.Material.Cobblestone, fountainModel)
    fountainModel.PrimaryPart = fBasin

    -- Central carved medallion with 5 Seals
    local medallion = createPart("FiveSealMedallion", Vector3.new(6, 1.0, 6), fPos + Vector3.new(0, 1.8, 0), Color3.fromRGB(65, 65, 70), Enum.Material.Slate, fountainModel)
    local mPrompt = Instance.new("ProximityPrompt")
    mPrompt.Name = "FountainPrompt"
    mPrompt.ActionText = "Inspect Five-Seal Emblem"
    mPrompt.ObjectText = "Dry Village Fountain"
    mPrompt.HoldDuration = 0.5
    mPrompt.Parent = medallion

    print("✔ [10/11] Abandoned Village Dry Fountain Created")

    ------------------------------------------------------------------
    -- 11. ABANDONED VILLAGE SECRET WELL
    ------------------------------------------------------------------
    local existingWell = interactables:FindFirstChild("Village_SecretWell")
    if existingWell then existingWell:Destroy() end

    local wellModel = Instance.new("Model")
    wellModel.Name = "Village_SecretWell"
    wellModel.Parent = interactables

    local wellPos = Vector3.new(-18, 0, -1340)
    local wRim = createPart("WellRim", Vector3.new(6, 3, 6), wellPos + Vector3.new(0, 1.5, 0), Color3.fromRGB(80, 80, 80), Enum.Material.Cobblestone, wellModel)
    wellModel.PrimaryPart = wRim

    -- Timber gallows and windlass
    createPart("WellPostL", Vector3.new(0.6, 6, 0.6), wellPos + Vector3.new(-2.6, 4.5, 0), Color3.fromRGB(90, 65, 45), Enum.Material.Wood, wellModel)
    createPart("WellPostR", Vector3.new(0.6, 6, 0.6), wellPos + Vector3.new(2.6, 4.5, 0), Color3.fromRGB(90, 65, 45), Enum.Material.Wood, wellModel)
    createPart("WellRoof", Vector3.new(7, 1.2, 7), wellPos + Vector3.new(0, 7.8, 0), Color3.fromRGB(60, 50, 40), Enum.Material.Wood, wellModel)

    local wellPrompt = Instance.new("ProximityPrompt")
    wellPrompt.Name = "WellPrompt"
    wellPrompt.ActionText = "Climb Down Secret Well"
    wellPrompt.ObjectText = "Overgrown Well"
    wellPrompt.HoldDuration = 0.5
    wellPrompt.Parent = wRim

    print("✔ [11/11] Abandoned Village Secret Well Created")

    print("==================================================")
    print("  ALL 11 EXPERIENCE BIBLE ASSETS BUILT!           ")
    print("==================================================")
    return true
end

return buildExperienceBibleAssets()
