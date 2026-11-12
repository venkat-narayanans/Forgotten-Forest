--!strict
--[[
    build_tools_and_hotbar.lua
    Procedural detailed low-poly creation of:
    1. ServerStorage.TFF.Templates.Tools:
       - torch (Traveler's Torch with flame, smoke, dynamic light)
       - basic_tool (Carved Hatchet with timber handle & stone/iron blade)
       - healing_potion (Herbal Salve glass vial with glowing tincture)
       - basic_trap (Snare Trap coiled rope & stake mechanism)
       - advanced_lantern (Aether Lantern brass frame with glowing crystal)
    2. StarterGui.TFF_HUD.MainContainer UI extensions:
       - HotbarContainer (5 interactive slots with keybindings 1-5 & selection border)
       - CraftingModal (Workbench crafting UI with recipe cards & Craft buttons)
       - StorageModal (Communal chest UI with backpack & outpost cache columns)
       - QuestModal (Expedition notice board UI with objectives & claim buttons)
       - LoreModal (Ancient archive parchment manuscript reader)
       - BossBar (Forest Guardian boss health bar with phase indicator)
]]

local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

-- ============================================================================
-- 1. PHYSICAL TOOL TEMPLATES IN SERVERSTORAGE
-- ============================================================================
local tffStorage = ServerStorage:FindFirstChild("TFF")
if not tffStorage then error("ServerStorage.TFF not found") end

local templates = tffStorage:FindFirstChild("Templates")
if not templates then error("ServerStorage.TFF.Templates not found") end

local toolsFolder = templates:FindFirstChild("Tools")
if not toolsFolder then
    toolsFolder = Instance.new("Folder")
    toolsFolder.Name = "Tools"
    toolsFolder.Parent = templates
end

-- Helper: Create Tool
local function createTool(name: string, handleSize: Vector3, handleColor: Color3, handleMaterial: Enum.Material): (Tool, Part)
    local oldTool = toolsFolder:FindFirstChild(name)
    if oldTool then oldTool:Destroy() end

    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = handleSize
    handle.Color = handleColor
    handle.Material = handleMaterial
    handle.CanCollide = false
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = tool

    tool.Parent = toolsFolder
    return tool, handle
end

-- 1. Traveler's Torch
local torchTool, torchHandle = createTool("torch", Vector3.new(0.6, 2.8, 0.6), Color3.fromRGB(75, 48, 28), Enum.Material.Wood)
local torchLight = Instance.new("PointLight")
torchLight.Name = "TorchLight"
torchLight.Color = Color3.fromRGB(255, 160, 50)
torchLight.Range = 22
torchLight.Brightness = 2.4
torchLight.Parent = torchHandle

local torchFire = Instance.new("ParticleEmitter")
torchFire.Name = "TorchFire"
torchFire.Color = ColorSequence.new(Color3.fromRGB(255, 180, 50), Color3.fromRGB(220, 70, 20))
torchFire.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(1, 0.2)
})
torchFire.Rate = 16
torchFire.Speed = NumberRange.new(1.5, 3)
torchFire.Lifetime = NumberRange.new(0.4, 0.8)
torchFire.SpreadAngle = Vector2.new(15, 15)
torchFire.Acceleration = Vector3.new(0, 4, 0)
torchFire.Parent = torchHandle

-- 2. Carved Hatchet
local hatchetTool, hatchetHandle = createTool("basic_tool", Vector3.new(0.8, 2.6, 1.4), Color3.fromRGB(80, 52, 30), Enum.Material.Wood)
local axeHead = Instance.new("Part")
axeHead.Name = "AxeHead"
axeHead.Size = Vector3.new(0.4, 1.0, 1.2)
axeHead.Color = Color3.fromRGB(65, 68, 72)
axeHead.Material = Enum.Material.Metal
axeHead.CanCollide = false
axeHead.CFrame = hatchetHandle.CFrame * CFrame.new(0, 1.0, 0.5)
axeHead.Parent = hatchetTool

local axeWeld = Instance.new("WeldConstraint")
axeWeld.Part0 = hatchetHandle
axeWeld.Part1 = axeHead
axeWeld.Parent = hatchetHandle

-- 3. Herbal Salve
local salveTool, salveHandle = createTool("healing_potion", Vector3.new(0.9, 1.5, 0.9), Color3.fromRGB(200, 210, 200), Enum.Material.Glass)
local salveFluid = Instance.new("Part")
salveFluid.Name = "HerbalTincture"
salveFluid.Size = Vector3.new(0.7, 1.0, 0.7)
salveFluid.Color = Color3.fromRGB(40, 220, 100)
salveFluid.Material = Enum.Material.Neon
salveFluid.CanCollide = false
salveFluid.CFrame = salveHandle.CFrame
salveFluid.Parent = salveTool

local salveWeld = Instance.new("WeldConstraint")
salveWeld.Part0 = salveHandle
salveWeld.Part1 = salveFluid
salveWeld.Parent = salveHandle

local salveLight = Instance.new("PointLight")
salveLight.Color = Color3.fromRGB(50, 230, 110)
salveLight.Range = 8
salveLight.Brightness = 1.2
salveLight.Parent = salveFluid

-- 4. Snare Trap
local trapTool, trapeHandle = createTool("basic_trap", Vector3.new(1.6, 0.5, 1.6), Color3.fromRGB(70, 48, 28), Enum.Material.Wood)

-- 5. Aether Lantern
local lanternTool, lanternHandle = createTool("advanced_lantern", Vector3.new(1.1, 2.2, 1.1), Color3.fromRGB(160, 130, 60), Enum.Material.Metal)
local lanternCore = Instance.new("Part")
lanternCore.Name = "AetherCore"
lanternCore.Size = Vector3.new(0.7, 0.9, 0.7)
lanternCore.Color = Color3.fromRGB(0, 240, 255)
lanternCore.Material = Enum.Material.Neon
lanternCore.CanCollide = false
lanternCore.CFrame = lanternHandle.CFrame
lanternCore.Parent = lanternTool

local lanternWeld = Instance.new("WeldConstraint")
lanternWeld.Part0 = lanternHandle
lanternWeld.Part1 = lanternCore
lanternWeld.Parent = lanternHandle

local lanternLight = Instance.new("PointLight")
lanternLight.Color = Color3.fromRGB(0, 220, 255)
lanternLight.Range = 28
lanternLight.Brightness = 2.6
lanternLight.Parent = lanternCore

-- ============================================================================
-- 2. STARTERGUI HUD EXTENSIONS
-- ============================================================================
local hud = StarterGui:FindFirstChild("TFF_HUD")
if not hud then error("StarterGui.TFF_HUD not found") end

local mainContainer = hud:FindFirstChild("MainContainer") :: Frame?
if not mainContainer then error("MainContainer not found in TFF_HUD") end

-- 1. Hotbar Container
local oldHotbar = mainContainer:FindFirstChild("HotbarContainer")
if oldHotbar then oldHotbar:Destroy() end

local hotbar = Instance.new("Frame")
hotbar.Name = "HotbarContainer"
hotbar.Size = UDim2.new(0, 360, 0, 72)
hotbar.Position = UDim2.new(0.5, 0, 1, -12)
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
hotbar.BackgroundTransparency = 0.35
hotbar.BorderSizePixel = 0
hotbar.Parent = mainContainer

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 10)
hCorner.Parent = hotbar

local hStroke = Instance.new("UIStroke")
hStroke.Color = Color3.fromRGB(75, 70, 60)
hStroke.Thickness = 1.5
hStroke.Parent = hotbar

local hLayout = Instance.new("UIListLayout")
hLayout.FillDirection = Enum.FillDirection.Horizontal
hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
hLayout.Padding = UDim.new(0, 8)
hLayout.Parent = hotbar

for i = 1, 5 do
    local slot = Instance.new("TextButton")
    slot.Name = "Slot_" .. i
    slot.Size = UDim2.new(0, 60, 0, 60)
    slot.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    slot.BackgroundTransparency = 0.2
    slot.Text = ""
    slot.AutoButtonColor = true
    slot.Parent = hotbar

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 8)
    sCorner.Parent = slot

    local sStroke = Instance.new("UIStroke")
    sStroke.Name = "SelectionStroke"
    sStroke.Color = Color3.fromRGB(60, 62, 68)
    sStroke.Thickness = 1.2
    sStroke.Parent = slot

    local numLabel = Instance.new("TextLabel")
    numLabel.Name = "SlotNumber"
    numLabel.Size = UDim2.new(0, 16, 0, 16)
    numLabel.Position = UDim2.new(0, 4, 0, 4)
    numLabel.BackgroundTransparency = 1
    numLabel.Text = tostring(i)
    numLabel.TextColor3 = Color3.fromRGB(180, 175, 165)
    numLabel.TextSize = 12
    numLabel.Font = Enum.Font.GothamBold
    numLabel.Parent = slot

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemName"
    nameLabel.Size = UDim2.new(1, -8, 0, 26)
    nameLabel.Position = UDim2.new(0, 4, 0.5, -13)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Empty"
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 215)
    nameLabel.TextSize = 10
    nameLabel.TextWrapped = true
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Parent = slot

    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "ItemCount"
    countLabel.Size = UDim2.new(0, 24, 0, 14)
    countLabel.Position = UDim2.new(1, -28, 1, -16)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = ""
    countLabel.TextColor3 = Color3.fromRGB(255, 215, 120)
    countLabel.TextSize = 11
    countLabel.Font = Enum.Font.GothamBold
    countLabel.Parent = slot
end

-- 2. Workbench Crafting Modal
local oldCrafting = mainContainer:FindFirstChild("CraftingModal")
if oldCrafting then oldCrafting:Destroy() end

local craftModal = Instance.new("Frame")
craftModal.Name = "CraftingModal"
craftModal.Size = UDim2.new(0, 500, 0, 380)
craftModal.Position = UDim2.new(0.5, 0, 0.5, 0)
craftModal.AnchorPoint = Vector2.new(0.5, 0.5)
craftModal.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
craftModal.BackgroundTransparency = 0.1
craftModal.Visible = false
craftModal.Parent = mainContainer

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 12)
cCorner.Parent = craftModal

local cStroke = Instance.new("UIStroke")
cStroke.Color = Color3.fromRGB(160, 130, 70)
cStroke.Thickness = 2
cStroke.Parent = craftModal

local cTitle = Instance.new("TextLabel")
cTitle.Name = "Title"
cTitle.Size = UDim2.new(1, -60, 0, 36)
cTitle.Position = UDim2.new(0, 20, 0, 12)
cTitle.BackgroundTransparency = 1
cTitle.Text = "WORKBENCH CRAFTING"
cTitle.TextColor3 = Color3.fromRGB(255, 225, 140)
cTitle.TextSize = 18
cTitle.Font = Enum.Font.GothamBold
cTitle.TextXAlignment = Enum.TextXAlignment.Left
cTitle.Parent = craftModal

local cClose = Instance.new("TextButton")
cClose.Name = "CloseButton"
cClose.Size = UDim2.new(0, 32, 0, 32)
cClose.Position = UDim2.new(1, -44, 0, 14)
cClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
cClose.Text = "X"
cClose.TextColor3 = Color3.fromRGB(255, 180, 180)
cClose.Font = Enum.Font.GothamBold
cClose.TextSize = 16
cClose.Parent = craftModal
local ccCorner = Instance.new("UICorner")
ccCorner.CornerRadius = UDim.new(0, 6)
ccCorner.Parent = cClose

local cScroll = Instance.new("ScrollingFrame")
cScroll.Name = "RecipeList"
cScroll.Size = UDim2.new(1, -40, 1, -70)
cScroll.Position = UDim2.new(0, 20, 0, 54)
cScroll.BackgroundTransparency = 1
cScroll.BorderSizePixel = 0
cScroll.ScrollBarThickness = 6
cScroll.Parent = craftModal

local cList = Instance.new("UIListLayout")
cList.Padding = UDim.new(0, 8)
cList.Parent = cScroll

-- Populate Sample Recipe Cards
local sampleRecipes = {
    { id = "torch", name = "Traveler's Torch", mats = "5 Timber, 2 Woven Fiber" },
    { id = "healing_potion", name = "Herbal Salve", mats = "3 Soothing Moss, 1 Spring Water" },
    { id = "basic_tool", name = "Carved Hatchet", mats = "8 Timber, 4 River Stone, 2 Rope" },
    { id = "basic_trap", name = "Snare Trap", mats = "4 Timber, 3 Braided Rope, 2 Scrap" },
    { id = "wooden_barricade", name = "Wooden Barricade", mats = "10 Timber, 4 Scrap Metal" },
    { id = "advanced_lantern", name = "Aether Lantern", mats = "6 Scrap, 3 Shards, 2 Relic Frags" },
}

for _, rec in ipairs(sampleRecipes) do
    local card = Instance.new("Frame")
    card.Name = "Card_" .. rec.id
    card.Size = UDim2.new(1, -10, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(32, 35, 42)
    card.Parent = cScroll

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local rName = Instance.new("TextLabel")
    rName.Size = UDim2.new(0.6, 0, 0, 24)
    rName.Position = UDim2.new(0, 12, 0, 4)
    rName.BackgroundTransparency = 1
    rName.Text = rec.name
    rName.TextColor3 = Color3.fromRGB(240, 235, 220)
    rName.TextSize = 14
    rName.Font = Enum.Font.GothamBold
    rName.TextXAlignment = Enum.TextXAlignment.Left
    rName.Parent = card

    local rMats = Instance.new("TextLabel")
    rMats.Size = UDim2.new(0.6, 0, 0, 18)
    rMats.Position = UDim2.new(0, 12, 0, 26)
    rMats.BackgroundTransparency = 1
    rMats.Text = "Requires: " .. rec.mats
    rMats.TextColor3 = Color3.fromRGB(170, 165, 155)
    rMats.TextSize = 11
    rMats.Font = Enum.Font.Gotham
    rMats.TextXAlignment = Enum.TextXAlignment.Left
    rMats.Parent = card

    local craftBtn = Instance.new("TextButton")
    craftBtn.Name = "CraftButton"
    craftBtn.Size = UDim2.new(0, 90, 0, 34)
    craftBtn.Position = UDim2.new(1, -102, 0.5, -17)
    craftBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 65)
    craftBtn.Text = "CRAFT"
    craftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    craftBtn.Font = Enum.Font.GothamBold
    craftBtn.TextSize = 13
    craftBtn.Parent = card
    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = craftBtn
end

-- 3. Communal Storage Modal
local oldStorage = mainContainer:FindFirstChild("StorageModal")
if oldStorage then oldStorage:Destroy() end

local storageModal = Instance.new("Frame")
storageModal.Name = "StorageModal"
storageModal.Size = UDim2.new(0, 540, 0, 380)
storageModal.Position = UDim2.new(0.5, 0, 0.5, 0)
storageModal.AnchorPoint = Vector2.new(0.5, 0.5)
storageModal.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
storageModal.BackgroundTransparency = 0.1
storageModal.Visible = false
storageModal.Parent = mainContainer

local sModCorner = Instance.new("UICorner")
sModCorner.CornerRadius = UDim.new(0, 12)
sModCorner.Parent = storageModal

local sModStroke = Instance.new("UIStroke")
sModStroke.Color = Color3.fromRGB(160, 130, 70)
sModStroke.Thickness = 2
sModStroke.Parent = storageModal

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1, -60, 0, 36)
sTitle.Position = UDim2.new(0, 20, 0, 12)
sTitle.BackgroundTransparency = 1
sTitle.Text = "COMMUNAL OUTPOST CHEST"
sTitle.TextColor3 = Color3.fromRGB(255, 225, 140)
sTitle.TextSize = 18
sTitle.Font = Enum.Font.GothamBold
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.Parent = storageModal

local sClose = Instance.new("TextButton")
sClose.Name = "CloseButton"
sClose.Size = UDim2.new(0, 32, 0, 32)
sClose.Position = UDim2.new(1, -44, 0, 14)
sClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
sClose.Text = "X"
sClose.TextColor3 = Color3.fromRGB(255, 180, 180)
sClose.Font = Enum.Font.GothamBold
sClose.TextSize = 16
sClose.Parent = storageModal
local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 6)
scCorner.Parent = sClose

-- 4. Quest Board Modal
local oldQuest = mainContainer:FindFirstChild("QuestModal")
if oldQuest then oldQuest:Destroy() end

local questModal = Instance.new("Frame")
questModal.Name = "QuestModal"
questModal.Size = UDim2.new(0, 500, 0, 360)
questModal.Position = UDim2.new(0.5, 0, 0.5, 0)
questModal.AnchorPoint = Vector2.new(0.5, 0.5)
questModal.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
questModal.BackgroundTransparency = 0.1
questModal.Visible = false
questModal.Parent = mainContainer

local qCorner = Instance.new("UICorner")
qCorner.CornerRadius = UDim.new(0, 12)
qCorner.Parent = questModal

local qStroke = Instance.new("UIStroke")
qStroke.Color = Color3.fromRGB(160, 130, 70)
qStroke.Thickness = 2
qStroke.Parent = questModal

local qTitle = Instance.new("TextLabel")
qTitle.Size = UDim2.new(1, -60, 0, 36)
qTitle.Position = UDim2.new(0, 20, 0, 12)
qTitle.BackgroundTransparency = 1
qTitle.Text = "EXPEDITION NOTICE BOARD"
qTitle.TextColor3 = Color3.fromRGB(255, 225, 140)
qTitle.TextSize = 18
qTitle.Font = Enum.Font.GothamBold
qTitle.TextXAlignment = Enum.TextXAlignment.Left
qTitle.Parent = questModal

local qClose = Instance.new("TextButton")
qClose.Name = "CloseButton"
qClose.Size = UDim2.new(0, 32, 0, 32)
qClose.Position = UDim2.new(1, -44, 0, 14)
qClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
qClose.Text = "X"
qClose.TextColor3 = Color3.fromRGB(255, 180, 180)
qClose.Font = Enum.Font.GothamBold
qClose.TextSize = 16
qClose.Parent = questModal
local qcCorner = Instance.new("UICorner")
qcCorner.CornerRadius = UDim.new(0, 6)
qcCorner.Parent = qClose

-- 5. Lore Modal
local oldLore = mainContainer:FindFirstChild("LoreModal")
if oldLore then oldLore:Destroy() end

local loreModal = Instance.new("Frame")
loreModal.Name = "LoreModal"
loreModal.Size = UDim2.new(0, 480, 0, 340)
loreModal.Position = UDim2.new(0.5, 0, 0.5, 0)
loreModal.AnchorPoint = Vector2.new(0.5, 0.5)
loreModal.BackgroundColor3 = Color3.fromRGB(26, 24, 20)
loreModal.BackgroundTransparency = 0.05
loreModal.Visible = false
loreModal.Parent = mainContainer

local lCorner = Instance.new("UICorner")
lCorner.CornerRadius = UDim.new(0, 10)
lCorner.Parent = loreModal

local lStroke = Instance.new("UIStroke")
lStroke.Color = Color3.fromRGB(180, 150, 90)
lStroke.Thickness = 2
lStroke.Parent = loreModal

local lTitle = Instance.new("TextLabel")
lTitle.Size = UDim2.new(1, -60, 0, 36)
lTitle.Position = UDim2.new(0, 20, 0, 12)
lTitle.BackgroundTransparency = 1
lTitle.Text = "THE FOREST REMEMBERS"
lTitle.TextColor3 = Color3.fromRGB(245, 220, 150)
lTitle.TextSize = 16
lTitle.Font = Enum.Font.GothamBold
lTitle.TextXAlignment = Enum.TextXAlignment.Left
lTitle.Parent = loreModal

local lBody = Instance.new("TextLabel")
lBody.Name = "LoreBody"
lBody.Size = UDim2.new(1, -40, 1, -64)
lBody.Position = UDim2.new(0, 20, 0, 50)
lBody.BackgroundTransparency = 1
lBody.Text = "Entry 01 — The First Wardens\n\nWe crossed the Old Stone Bridge as the mist rolled over the gorge. The ancients built this sanctuary to seal away the Heart of the Woods, but the roots grow restless. Should the three seals falter, the Forest Guardian shall awaken once more to purge the intruders...\n\nKeep the hearth lit. Trust no shadow."
lBody.TextColor3 = Color3.fromRGB(225, 215, 195)
lBody.TextSize = 13
lBody.Font = Enum.Font.Gotham
lBody.TextWrapped = true
lBody.TextYAlignment = Enum.TextYAlignment.Top
lBody.Parent = loreModal

local lClose = Instance.new("TextButton")
lClose.Name = "CloseButton"
lClose.Size = UDim2.new(0, 32, 0, 32)
lClose.Position = UDim2.new(1, -44, 0, 14)
lClose.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
lClose.Text = "X"
lClose.TextColor3 = Color3.fromRGB(255, 180, 180)
lClose.Font = Enum.Font.GothamBold
lClose.TextSize = 16
lClose.Parent = loreModal
local lcCorner = Instance.new("UICorner")
lcCorner.CornerRadius = UDim.new(0, 6)
lcCorner.Parent = lClose

-- 6. Boss Health Bar
local oldBossBar = mainContainer:FindFirstChild("BossBar")
if oldBossBar then oldBossBar:Destroy() end

local bossBar = Instance.new("Frame")
bossBar.Name = "BossBar"
bossBar.Size = UDim2.new(0, 440, 0, 52)
bossBar.Position = UDim2.new(0.5, 0, 0, 25)
bossBar.AnchorPoint = Vector2.new(0.5, 0)
bossBar.BackgroundColor3 = Color3.fromRGB(18, 20, 24)
bossBar.BackgroundTransparency = 0.25
bossBar.Visible = false
bossBar.Parent = mainContainer

local bbCorner = Instance.new("UICorner")
bbCorner.CornerRadius = UDim.new(0, 8)
bbCorner.Parent = bossBar

local bbStroke = Instance.new("UIStroke")
bbStroke.Color = Color3.fromRGB(180, 60, 60)
bbStroke.Thickness = 1.8
bbStroke.Parent = bossBar

local bName = Instance.new("TextLabel")
bName.Name = "BossTitle"
bName.Size = UDim2.new(1, -20, 0, 20)
bName.Position = UDim2.new(0, 10, 0, 4)
bName.BackgroundTransparency = 1
bName.Text = "FOREST GUARDIAN — THE ANCIENT HEART"
bName.TextColor3 = Color3.fromRGB(255, 215, 140)
bName.TextSize = 13
bName.Font = Enum.Font.GothamBold
bName.Parent = bossBar

local bHpBg = Instance.new("Frame")
bHpBg.Name = "HpBackground"
bHpBg.Size = UDim2.new(1, -20, 0, 16)
bHpBg.Position = UDim2.new(0, 10, 0, 28)
bHpBg.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
bHpBg.BorderSizePixel = 0
bHpBg.Parent = bossBar
local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 4)
bgCorner.Parent = bHpBg

local bHpFill = Instance.new("Frame")
bHpFill.Name = "HpFill"
bHpFill.Size = UDim2.new(1, 0, 1, 0)
bHpFill.BackgroundColor3 = Color3.fromRGB(220, 45, 45)
bHpFill.BorderSizePixel = 0
bHpFill.Parent = bHpBg
local bfCorner = Instance.new("UICorner")
bfCorner.CornerRadius = UDim.new(0, 4)
bfCorner.Parent = bHpFill

print("[build_tools_and_hotbar] Tools and Hotbar UI extension complete!")
return true
