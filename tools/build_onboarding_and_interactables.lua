--!strict
--[[
    build_onboarding_and_interactables.lua
    Builds:
    1. Physical ExpeditionStarterChest beside Central Beacon Campfire in Safe Haven
    2. Practice resource nodes around Safe Haven perimeter (driftwood, stone, herbs, water)
    3. HUD Action Buttons ([C] CRAFT, [Q] QUESTS) in StarterGui.TFF_HUD.MainContainer
    4. On-screen ObjectiveTracker HUD frame in StarterGui.TFF_HUD.MainContainer
    5. Enhanced CraftingModal instruction banner and dynamic card structure
    6. Enhanced QuestModal with QuestList ScrollingFrame
]]

local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

print("=== STARTING ONBOARDING & INTERACTABLES BUILD ===")

local tffWorld = Workspace:WaitForChild("TFF_World")
local interactables = tffWorld:WaitForChild("Interactables")
local resourceNodes = tffWorld:FindFirstChild("ResourceNodes")
if not resourceNodes then
    resourceNodes = Instance.new("Folder")
    resourceNodes.Name = "ResourceNodes"
    resourceNodes.Parent = tffWorld
end

-- ============================================================================
-- 1. BUILD EXPEDITION STARTER CHEST IN SAFE HAVEN
-- ============================================================================
local oldChest = interactables:FindFirstChild("ExpeditionStarterChest")
if oldChest then oldChest:Destroy() end

local chestModel = Instance.new("Model")
chestModel.Name = "ExpeditionStarterChest"

-- Main Body
local chestBase = Instance.new("Part")
chestBase.Name = "ChestBase"
chestBase.Size = Vector3.new(4.2, 2.2, 2.6)
chestBase.Position = Vector3.new(6, 1.2, -8)
chestBase.Anchored = true
chestBase.Material = Enum.Material.WoodPlanks
chestBase.Color = Color3.fromRGB(80, 50, 30)
chestBase.TopSurface = Enum.SurfaceType.Smooth
chestBase.BottomSurface = Enum.SurfaceType.Smooth
chestBase.Parent = chestModel

-- Chest Lid
local chestLid = Instance.new("Part")
chestLid.Name = "ChestLid"
chestLid.Size = Vector3.new(4.4, 0.8, 2.8)
chestLid.Position = Vector3.new(6, 2.5, -8)
chestLid.Anchored = true
chestLid.Material = Enum.Material.WoodPlanks
chestLid.Color = Color3.fromRGB(95, 60, 35)
chestLid.TopSurface = Enum.SurfaceType.Smooth
chestLid.BottomSurface = Enum.SurfaceType.Smooth
chestLid.Parent = chestModel

-- Iron / Gold Bands
for _, xOff in ipairs({ -1.5, 0, 1.5 }) do
    local band = Instance.new("Part")
    band.Name = "IronBand"
    band.Size = Vector3.new(0.3, 2.3, 2.7)
    band.Position = Vector3.new(6 + xOff, 1.25, -8)
    band.Anchored = true
    band.Material = Enum.Material.Metal
    band.Color = Color3.fromRGB(45, 45, 50)
    band.CanCollide = false
    band.Parent = chestModel
end

-- Golden Glowing Lock & Trim
local goldLock = Instance.new("Part")
goldLock.Name = "GoldLock"
goldLock.Size = Vector3.new(0.8, 0.8, 0.3)
goldLock.Position = Vector3.new(6, 2.0, -9.35)
goldLock.Anchored = true
goldLock.Material = Enum.Material.Neon
goldLock.Color = Color3.fromRGB(255, 205, 50)
goldLock.CanCollide = false
goldLock.Parent = chestModel

local chestGlow = Instance.new("PointLight")
chestGlow.Color = Color3.fromRGB(255, 215, 80)
chestGlow.Brightness = 2.0
chestGlow.Range = 14
chestGlow.Parent = goldLock

-- Billboard Nameplate
local bbg = Instance.new("BillboardGui")
bbg.Name = "StarterChestBillboard"
bbg.Size = UDim2.new(0, 240, 0, 50)
bbg.StudsOffset = Vector3.new(0, 3.2, 0)
bbg.AlwaysOnTop = true
bbg.Adornee = chestBase
bbg.Parent = chestModel

local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, 0, 0.55, 0)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "EXPEDITION STARTER CHEST"
nameLbl.TextColor3 = Color3.fromRGB(255, 225, 90)
nameLbl.TextStrokeTransparency = 0.2
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 15
nameLbl.Parent = bbg

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1, 0, 0.45, 0)
subLbl.Position = UDim2.new(0, 0, 0.55, 0)
subLbl.BackgroundTransparency = 1
subLbl.Text = "[Torch, Field Knife, Parka, Salves]"
subLbl.TextColor3 = Color3.fromRGB(220, 230, 240)
subLbl.TextStrokeTransparency = 0.4
subLbl.Font = Enum.Font.GothamMedium
subLbl.TextSize = 11
subLbl.Parent = bbg

-- Proximity Prompt
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "ProximityPrompt"
prompt.ActionText = "Claim Starter Supplies"
prompt.ObjectText = "Expedition Starter Chest"
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 14
prompt.RequiresLineOfSight = false
prompt.Parent = chestBase

chestModel.PrimaryPart = chestBase
chestModel.Parent = interactables
CollectionService:AddTag(chestBase, "TFF_Interactable")
print("-> Expedition Starter Chest created at (6, 1.2, -8).")

-- ============================================================================
-- 2. BUILD SAFE HAVEN PRACTICE RESOURCE NODES
-- ============================================================================
local practiceNodes = {
    -- 4 Driftwood Logs (wood)
    { name = "SafeHaven_Driftwood_1", itemId = "wood", pos = Vector3.new(18, 0.6, -18), size = Vector3.new(6, 1.2, 1.4), color = Color3.fromRGB(110, 75, 45), mat = Enum.Material.Wood, action = "Gather Timber" },
    { name = "SafeHaven_Driftwood_2", itemId = "wood", pos = Vector3.new(-18, 0.6, -16), size = Vector3.new(5.5, 1.2, 1.4), color = Color3.fromRGB(110, 75, 45), mat = Enum.Material.Wood, action = "Gather Timber" },
    { name = "SafeHaven_Driftwood_3", itemId = "wood", pos = Vector3.new(14, 0.6, 20), size = Vector3.new(5.0, 1.2, 1.4), color = Color3.fromRGB(110, 75, 45), mat = Enum.Material.Wood, action = "Gather Timber" },
    { name = "SafeHaven_Driftwood_4", itemId = "wood", pos = Vector3.new(-14, 0.6, 22), size = Vector3.new(5.2, 1.2, 1.4), color = Color3.fromRGB(110, 75, 45), mat = Enum.Material.Wood, action = "Gather Timber" },

    -- 4 River Stone Piles (stone)
    { name = "SafeHaven_Stones_1", itemId = "stone", pos = Vector3.new(-6, 0.5, 32), size = Vector3.new(3.5, 1.2, 3.2), color = Color3.fromRGB(120, 125, 130), mat = Enum.Material.Slate, action = "Collect Stones" },
    { name = "SafeHaven_Stones_2", itemId = "stone", pos = Vector3.new(8, 0.5, 30), size = Vector3.new(3.2, 1.1, 3.0), color = Color3.fromRGB(115, 120, 125), mat = Enum.Material.Slate, action = "Collect Stones" },
    { name = "SafeHaven_Stones_3", itemId = "stone", pos = Vector3.new(-24, 0.5, 5), size = Vector3.new(3.6, 1.3, 3.4), color = Color3.fromRGB(120, 125, 130), mat = Enum.Material.Slate, action = "Collect Stones" },
    { name = "SafeHaven_Stones_4", itemId = "stone", pos = Vector3.new(24, 0.5, 6), size = Vector3.new(3.4, 1.2, 3.1), color = Color3.fromRGB(125, 128, 132), mat = Enum.Material.Slate, action = "Collect Stones" },

    -- 4 Soothing Herb Patches (herb)
    { name = "SafeHaven_Herbs_1", itemId = "herb", pos = Vector3.new(-22, 0.6, -32), size = Vector3.new(2.8, 0.8, 2.8), color = Color3.fromRGB(70, 150, 75), mat = Enum.Material.Grass, action = "Harvest Moss & Herbs" },
    { name = "SafeHaven_Herbs_2", itemId = "herb", pos = Vector3.new(-28, 0.6, -18), size = Vector3.new(2.6, 0.8, 2.6), color = Color3.fromRGB(65, 145, 70), mat = Enum.Material.Grass, action = "Harvest Moss & Herbs" },
    { name = "SafeHaven_Herbs_3", itemId = "herb", pos = Vector3.new(20, 0.6, -30), size = Vector3.new(2.8, 0.8, 2.8), color = Color3.fromRGB(70, 150, 75), mat = Enum.Material.Grass, action = "Harvest Moss & Herbs" },
    { name = "SafeHaven_Herbs_4", itemId = "herb", pos = Vector3.new(26, 0.6, 16), size = Vector3.new(2.5, 0.8, 2.5), color = Color3.fromRGB(65, 145, 70), mat = Enum.Material.Grass, action = "Harvest Moss & Herbs" },

    -- 2 Spring Water Wells (water)
    { name = "SafeHaven_Water_1", itemId = "water", pos = Vector3.new(0, 0.3, 38), size = Vector3.new(4.5, 0.6, 4.5), color = Color3.fromRGB(70, 160, 220), mat = Enum.Material.Glass, action = "Draw Spring Water" },
    { name = "SafeHaven_Water_2", itemId = "water", pos = Vector3.new(-12, 0.3, 36), size = Vector3.new(4.0, 0.6, 4.0), color = Color3.fromRGB(70, 160, 220), mat = Enum.Material.Glass, action = "Draw Spring Water" },
}

for _, n in ipairs(practiceNodes) do
    local existing = resourceNodes:FindFirstChild(n.name)
    if existing then existing:Destroy() end

    local p = Instance.new("Part")
    p.Name = n.name
    p.Size = n.size
    p.Position = n.pos
    p.Anchored = true
    p.Material = n.mat
    p.Color = n.color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p:SetAttribute("NodeId", n.name)
    p:SetAttribute("ItemId", n.itemId)
    p:SetAttribute("InitialYield", 5)

    local pr = Instance.new("ProximityPrompt")
    pr.ActionText = n.action
    pr.ObjectText = n.name:gsub("SafeHaven_", "")
    pr.HoldDuration = 0.8
    pr.MaxActivationDistance = 10
    pr.RequiresLineOfSight = false
    pr.Parent = p

    CollectionService:AddTag(p, "TFF_ResourceNode")
    p.Parent = resourceNodes
end
print(string.format("-> Created %d Safe Haven practice resource nodes.", #practiceNodes))

-- ============================================================================
-- 3. UPGRADE STARTERGUI.TFF_HUD.MAINCONTAINER
-- ============================================================================
local hud = StarterGui:WaitForChild("TFF_HUD")
local main = hud:WaitForChild("MainContainer")

-- 3A. Add [Q] QUESTS and [C] CRAFT Buttons
local function ensureButton(btnName: string, text: string, xOffset: number, width: number): TextButton
    local btn = main:FindFirstChild(btnName) :: TextButton?
    if not btn then
        btn = Instance.new("TextButton")
        btn.Name = btnName
        btn.Parent = main
    end
    btn.Size = UDim2.new(0, width, 0, 38)
    btn.Position = UDim2.new(1, xOffset, 0, 15)
    btn.BackgroundColor3 = Color3.fromRGB(45, 52, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = true

    local corner = btn:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
    end

    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.2
        stroke.Color = Color3.fromRGB(80, 95, 115)
        stroke.Parent = btn
    end

    return btn
end

-- Top-right action bar layout:
-- Settings: {1, -55}, 38px wide
-- Map:      {1, -115}, 52px wide
-- Quests:   {1, -195}, 72px wide
-- Crafting: {1, -285}, 82px wide
local settingsBtn = main:FindFirstChild("SettingsButton")
if settingsBtn then
    settingsBtn.Position = UDim2.new(1, -55, 0, 15)
    settingsBtn.Size = UDim2.new(0, 38, 0, 38)
end

local mapBtn = main:FindFirstChild("MapButton") :: TextButton?
if mapBtn then
    mapBtn.Position = UDim2.new(1, -115, 0, 15)
    mapBtn.Size = UDim2.new(0, 52, 0, 38)
    mapBtn.Text = "[M] MAP"
    mapBtn.TextSize = 11
end

local questBtn = ensureButton("QuestButton", "[Q] QUESTS", -195, 72)
local craftBtn = ensureButton("CraftingButton", "[C] CRAFT", -285, 82)
print("-> Added HUD action bar buttons: [Q] QUESTS, [C] CRAFT.")

-- 3B. Add ObjectiveTracker HUD Frame at Top-Left
local oldTracker = main:FindFirstChild("ObjectiveTracker")
if oldTracker then oldTracker:Destroy() end

local trackerFrame = Instance.new("Frame")
trackerFrame.Name = "ObjectiveTracker"
trackerFrame.Size = UDim2.new(0, 340, 0, 80)
trackerFrame.Position = UDim2.new(0, 20, 0, 15)
trackerFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
trackerFrame.BackgroundTransparency = 0.25
trackerFrame.BorderSizePixel = 0

local trackerCorner = Instance.new("UICorner")
trackerCorner.CornerRadius = UDim.new(0, 8)
trackerCorner.Parent = trackerFrame

local trackerStroke = Instance.new("UIStroke")
trackerStroke.Thickness = 1.5
trackerStroke.Color = Color3.fromRGB(215, 175, 75) -- Gold accent
trackerStroke.Parent = trackerFrame

local trackerHeader = Instance.new("TextLabel")
trackerHeader.Name = "Header"
trackerHeader.Size = UDim2.new(1, -20, 0, 20)
trackerHeader.Position = UDim2.new(0, 12, 0, 6)
trackerHeader.BackgroundTransparency = 1
trackerHeader.Text = "ACTIVE OBJECTIVE"
trackerHeader.TextColor3 = Color3.fromRGB(255, 215, 80)
trackerHeader.TextXAlignment = Enum.TextXAlignment.Left
trackerHeader.Font = Enum.Font.GothamBold
trackerHeader.TextSize = 11
trackerHeader.Parent = trackerFrame

local trackerTitle = Instance.new("TextLabel")
trackerTitle.Name = "ObjectiveTitle"
trackerTitle.Size = UDim2.new(1, -20, 0, 22)
trackerTitle.Position = UDim2.new(0, 12, 0, 26)
trackerTitle.BackgroundTransparency = 1
trackerTitle.Text = "Equip for the Wilds"
trackerTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
trackerTitle.TextXAlignment = Enum.TextXAlignment.Left
trackerTitle.Font = Enum.Font.GothamBold
trackerTitle.TextSize = 14
trackerTitle.Parent = trackerFrame

local trackerDesc = Instance.new("TextLabel")
trackerDesc.Name = "ObjectiveDesc"
trackerDesc.Size = UDim2.new(1, -20, 0, 24)
trackerDesc.Position = UDim2.new(0, 12, 0, 48)
trackerDesc.BackgroundTransparency = 1
trackerDesc.Text = "• Claim Expedition Starter Chest by the beacon fire [C: Craft, Q: Quests]"
trackerDesc.TextColor3 = Color3.fromRGB(200, 210, 220)
trackerDesc.TextXAlignment = Enum.TextXAlignment.Left
trackerDesc.Font = Enum.Font.GothamMedium
trackerDesc.TextSize = 11
trackerDesc.TextWrapped = true
trackerDesc.Parent = trackerFrame

trackerFrame.Parent = main
print("-> Added ObjectiveTracker to StarterGui.TFF_HUD.MainContainer.")

-- 3C. Upgrade CraftingModal: Guide Header & Dynamic Recipe Display
local craftingModal = main:FindFirstChild("CraftingModal") :: Frame?
if craftingModal then
    craftingModal.Size = UDim2.new(0, 540, 0, 440)

    -- Instructions Guide Banner
    local guideBanner = craftingModal:FindFirstChild("CraftingGuideBanner") :: Frame?
    if not guideBanner then
        guideBanner = Instance.new("Frame")
        guideBanner.Name = "CraftingGuideBanner"
        guideBanner.Parent = craftingModal
    end
    guideBanner.Size = UDim2.new(1, -30, 0, 54)
    guideBanner.Position = UDim2.new(0, 15, 0, 44)
    guideBanner.BackgroundColor3 = Color3.fromRGB(30, 36, 46)
    guideBanner.BorderSizePixel = 0

    local gCorner = guideBanner:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    gCorner.CornerRadius = UDim.new(0, 6)
    gCorner.Parent = guideBanner

    local gStroke = guideBanner:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    gStroke.Color = Color3.fromRGB(60, 75, 95)
    gStroke.Thickness = 1.0
    gStroke.Parent = guideBanner

    local guideText = guideBanner:FindFirstChild("GuideText") :: TextLabel? or Instance.new("TextLabel")
    guideText.Name = "GuideText"
    guideText.Size = UDim2.new(1, -16, 1, -8)
    guideText.Position = UDim2.new(0, 8, 0, 4)
    guideText.BackgroundTransparency = 1
    guideText.Text = "HOW CRAFTING WORKS:\n• Basic gear (Torches, Salves, Arrows) can be crafted anywhere.\n• Advanced weapons and barricades require standing near a Workbench.\n• Live readiness: Green = Ready to craft | Red = Missing resources."
    guideText.TextColor3 = Color3.fromRGB(220, 230, 240)
    guideText.TextXAlignment = Enum.TextXAlignment.Left
    guideText.Font = Enum.Font.GothamMedium
    guideText.TextSize = 11
    guideText.Parent = guideBanner

    -- Position RecipeList right under GuideBanner
    local recipeList = craftingModal:FindFirstChild("RecipeList") :: ScrollingFrame?
    if recipeList then
        recipeList.Position = UDim2.new(0, 15, 0, 106)
        recipeList.Size = UDim2.new(1, -30, 1, -118)
    end
end
print("-> Enhanced CraftingModal with instructions banner.")

-- 3D. Upgrade QuestModal: Full Notice Board & Quest Cards
local questModal = main:FindFirstChild("QuestModal") :: Frame?
if questModal then
    questModal.Size = UDim2.new(0, 560, 0, 460)

    local titleLbl = questModal:FindFirstChildWhichIsA("TextLabel")
    if titleLbl then
        titleLbl.Text = "EXPEDITION NOTICE BOARD & QUEST LOG"
        titleLbl.Size = UDim2.new(1, -50, 0, 28)
        titleLbl.Position = UDim2.new(0, 18, 0, 10)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local subtitleLbl = questModal:FindFirstChild("Subtitle") :: TextLabel? or Instance.new("TextLabel")
    subtitleLbl.Name = "Subtitle"
    subtitleLbl.Size = UDim2.new(1, -50, 0, 18)
    subtitleLbl.Position = UDim2.new(0, 18, 0, 36)
    subtitleLbl.BackgroundTransparency = 1
    subtitleLbl.Text = "Active missions, valley milestones, and survival objectives."
    subtitleLbl.TextColor3 = Color3.fromRGB(180, 195, 210)
    subtitleLbl.Font = Enum.Font.GothamMedium
    subtitleLbl.TextSize = 11
    subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLbl.Parent = questModal

    -- Ensure QuestList ScrollingFrame exists
    local questList = questModal:FindFirstChild("QuestList") :: ScrollingFrame?
    if not questList then
        questList = Instance.new("ScrollingFrame")
        questList.Name = "QuestList"
        questList.Parent = questModal
    end
    questList.Position = UDim2.new(0, 16, 0, 60)
    questList.Size = UDim2.new(1, -32, 1, -72)
    questList.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    questList.BackgroundTransparency = 0.5
    questList.BorderSizePixel = 0
    questList.ScrollBarThickness = 6
    questList.CanvasSize = UDim2.new(0, 0, 0, 560)

    local qLayout = questList:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
    qLayout.Padding = UDim.new(0, 8)
    qLayout.SortOrder = Enum.SortOrder.LayoutOrder
    qLayout.Parent = questList
end
print("-> Enhanced QuestModal with QuestList ScrollingFrame.")

print("=== ONBOARDING & INTERACTABLES BUILD COMPLETED SUCCESSFULLY ===")
return "BUILD_SUCCESS"
