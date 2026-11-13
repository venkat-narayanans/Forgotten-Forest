--!strict
--[[
    HUDController.lua
    Client controller for managing HUD updates, status bars, cycle phase,
    region banners, mobile touch sprint input, warmth/sanity meters,
    Interactive Valley Map (Key 'M'), Dialogue Modal, Floating Damage text,
    and Accessibility Settings modal.
    Fulfills Master Game Specification Sections 3.5, 4, 6.2, 8, 9.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local HUDController = {}
HUDController.__index = HUDController

local _player = Players.LocalPlayer
local _screenGui: ScreenGui? = nil
local _currentRegionName = "Safe Haven"
local _selectedSlot: number? = nil
local _cachedInventory: { [number]: { ItemId: string, Quantity: number } } = {}

-- Modals references
local _craftingModal: Frame? = nil
local _storageModal: Frame? = nil
local _questModal: Frame? = nil
local _loreModal: Frame? = nil
local _mapModal: Frame? = nil
local _dialogueModal: Frame? = nil
local _bossBar: Frame? = nil
local _hotbarContainer: Frame? = nil
local _regionBanner: TextLabel? = nil

-- Settings state
local _reducedEffects = false
local _cameraShake = true

local function formatTimer(seconds: number): string
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", mins, secs)
end

function HUDController.Init(_dependencies: { [string]: any })
    print("[HUDController] Initializing HUDController v2.0...")
end

function HUDController.Start()
    print("[HUDController] HUDController started.")

    local playerGui = _player:WaitForChild("PlayerGui")
    _screenGui = playerGui:WaitForChild("TFF_HUD") :: ScreenGui

    local mainContainer = _screenGui:WaitForChild("MainContainer") :: Frame
    local statusBars = mainContainer:WaitForChild("StatusBars") :: Frame
    local healthBg = statusBars:WaitForChild("HealthBackground") :: Frame
    local healthFill = healthBg:WaitForChild("Fill") :: Frame
    local healthLabel = healthBg:WaitForChild("HealthLabel") :: TextLabel

    local staminaBg = statusBars:WaitForChild("StaminaBackground") :: Frame
    local staminaFill = staminaBg:WaitForChild("Fill") :: Frame

    local warmthBg = statusBars:FindFirstChild("WarmthBackground") :: Frame?
    local warmthFill = warmthBg and warmthBg:FindFirstChild("Fill") :: Frame?
    local warmthLabel = warmthBg and warmthBg:FindFirstChild("Label") :: TextLabel?

    local sanityBg = statusBars:FindFirstChild("SanityBackground") :: Frame?
    local sanityFill = sanityBg and sanityBg:FindFirstChild("Fill") :: Frame?
    local sanityLabel = sanityBg and sanityBg:FindFirstChild("Label") :: TextLabel?

    local cycleIndicator = mainContainer:WaitForChild("CycleIndicator") :: Frame
    local phaseLabel = cycleIndicator:WaitForChild("PhaseLabel") :: TextLabel
    local timerLabel = cycleIndicator:WaitForChild("TimerLabel") :: TextLabel

    _regionBanner = mainContainer:WaitForChild("RegionBanner") :: TextLabel
    local mobileSprint = mainContainer:WaitForChild("MobileSprintButton") :: TextButton

    -- Settings Modal Wiring
    local settingsBtn = mainContainer:WaitForChild("SettingsButton") :: TextButton
    local settingsModal = mainContainer:WaitForChild("SettingsModal") :: Frame
    local redEffectsBtn = settingsModal:WaitForChild("ReducedEffectsToggle") :: TextButton
    local camShakeBtn = settingsModal:WaitForChild("CameraShakeToggle") :: TextButton
    local closeBtn = settingsModal:WaitForChild("CloseButton") :: TextButton

    settingsBtn.MouseButton1Click:Connect(function()
        settingsModal.Visible = not settingsModal.Visible
    end)

    closeBtn.MouseButton1Click:Connect(function()
        settingsModal.Visible = false
    end)

    redEffectsBtn.MouseButton1Click:Connect(function()
        _reducedEffects = not _reducedEffects
        redEffectsBtn.Text = "Reduced Visual Effects: " .. (_reducedEffects and "ON" or "OFF")
        redEffectsBtn.TextColor3 = _reducedEffects and Color3.fromRGB(120, 230, 150) or Color3.fromRGB(230, 230, 220)
    end)

    camShakeBtn.MouseButton1Click:Connect(function()
        _cameraShake = not _cameraShake
        camShakeBtn.Text = "Camera Shake: " .. (_cameraShake and "ON" or "OFF")
        camShakeBtn.TextColor3 = _cameraShake and Color3.fromRGB(120, 230, 150) or Color3.fromRGB(230, 230, 220)
    end)

    -- Gameplay Modals & Hotbar references
    _craftingModal = mainContainer:FindFirstChild("CraftingModal") :: Frame?
    _storageModal = mainContainer:FindFirstChild("StorageModal") :: Frame?
    _questModal = mainContainer:FindFirstChild("QuestModal") :: Frame?
    _loreModal = mainContainer:FindFirstChild("LoreModal") :: Frame?
    _mapModal = mainContainer:FindFirstChild("MapModal") :: Frame?
    _dialogueModal = mainContainer:FindFirstChild("DialogueModal") :: Frame?
    _bossBar = mainContainer:FindFirstChild("BossBar") :: Frame?
    _hotbarContainer = mainContainer:FindFirstChild("HotbarContainer") :: Frame?

    -- Modal Close Buttons
    local function hookModalClose(modal: Frame?)
        if not modal then return end
        local close = modal:FindFirstChild("CloseButton") :: TextButton?
        if close then
            close.MouseButton1Click:Connect(function()
                modal.Visible = false
            end)
        end
    end
    hookModalClose(_craftingModal)
    hookModalClose(_storageModal)
    hookModalClose(_questModal)
    hookModalClose(_loreModal)
    hookModalClose(_mapModal)
    hookModalClose(_dialogueModal)

    -- Map Button Wiring
    local mapBtn = mainContainer:FindFirstChild("MapButton") :: TextButton?
    if mapBtn then
        mapBtn.MouseButton1Click:Connect(function()
            HUDController.ToggleMapModal()
        end)
    end

    -- Wire up Crafting Buttons
    if _craftingModal then
        local recipeList = _craftingModal:FindFirstChild("RecipeList") :: ScrollingFrame?
        if recipeList then
            for _, card in ipairs(recipeList:GetChildren()) do
                if card:IsA("Frame") and card.Name:sub(1, 5) == "Card_" then
                    local recipeId = card.Name:sub(6)
                    local craftBtn = card:FindFirstChild("CraftButton") :: TextButton?
                    if craftBtn then
                        craftBtn.MouseButton1Click:Connect(function()
                            local craftRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestCraft)
                            if craftRemote then
                                craftRemote:FireServer(recipeId)
                            end
                        end)
                    end
                end
            end
        end
    end

    -- Wire up Hotbar Slots
    local function refreshHotbarUI()
        if not _hotbarContainer then return end
        local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
        for i = 1, 5 do
            local slotBtn = _hotbarContainer:FindFirstChild("Slot_" .. i) :: TextButton?
            if slotBtn then
                local itemData = _cachedInventory[i]
                local nameLabel = slotBtn:FindFirstChild("ItemName") :: TextLabel?
                local countLabel = slotBtn:FindFirstChild("ItemCount") :: TextLabel?
                local stroke = slotBtn:FindFirstChild("SelectionStroke") :: UIStroke?

                if itemData and itemData.Quantity > 0 then
                    local def = ItemDefinitions[itemData.ItemId]
                    if nameLabel then nameLabel.Text = def and def.DisplayName or itemData.ItemId end
                    if countLabel then countLabel.Text = tostring(itemData.Quantity) end
                else
                    if nameLabel then nameLabel.Text = "Empty" end
                    if countLabel then countLabel.Text = "" end
                end

                if stroke then
                    if _selectedSlot == i then
                        stroke.Color = Color3.fromRGB(255, 215, 80)
                        stroke.Thickness = 2.5
                    else
                        stroke.Color = Color3.fromRGB(60, 62, 68)
                        stroke.Thickness = 1.2
                    end
                end
            end
        end
    end

    if _hotbarContainer then
        for i = 1, 5 do
            local slotBtn = _hotbarContainer:FindFirstChild("Slot_" .. i) :: TextButton?
            if slotBtn then
                slotBtn.MouseButton1Click:Connect(function()
                    HUDController.SelectHotbarSlot(i)
                end)
            end
        end
    end

    -- Sync Profile & Inventory
    local syncProfileRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncProfileRemote then
        syncProfileRemote.OnClientEvent:Connect(function(profile: any)
            if profile and profile.inventory then
                _cachedInventory = profile.inventory
                refreshHotbarUI()
            end
        end)
    end

    -- Hook up Boss Health Sync
    local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
    if bossRemote then
        bossRemote.OnClientEvent:Connect(function(currentHp: number, maxHp: number, phaseName: string?)
            if _bossBar then
                if currentHp > 0 then
                    _bossBar.Visible = true
                    local hpFill = _bossBar:FindFirstChild("HpBackground") and _bossBar.HpBackground:FindFirstChild("HpFill") :: Frame?
                    if hpFill then
                        local ratio = math.clamp(currentHp / maxHp, 0, 1)
                        hpFill.Size = UDim2.new(ratio, 0, 1, 0)
                    end
                    local title = _bossBar:FindFirstChild("BossTitle") :: TextLabel?
                    if title and phaseName then
                        title.Text = "FOREST GUARDIAN — " .. string.upper(phaseName)
                    end
                else
                    _bossBar.Visible = false
                end
            end
        end)
    end

    -- Mobile sprint wiring
    if not UserInputService.TouchEnabled then
        mobileSprint.Visible = false
    else
        mobileSprint.Visible = true
        local isSprinting = false
        local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)

        mobileSprint.MouseButton1Down:Connect(function()
            isSprinting = not isSprinting
            mobileSprint.BackgroundTransparency = isSprinting and 0.1 or 0.3
            if sprintRemote then
                sprintRemote:FireServer(isSprinting)
            end
        end)
    end

    -- Hook up Stats sync
    local syncStatsRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncStats)
    if syncStatsRemote then
        syncStatsRemote.OnClientEvent:Connect(function(stats: Types.PlayerStats)
            local healthRatio = math.clamp(stats.Health / stats.MaxHealth, 0, 1)
            healthFill.Size = UDim2.new(healthRatio, 0, 1, 0)
            healthLabel.Text = string.format("HEALTH: %d/%d", math.ceil(stats.Health), math.ceil(stats.MaxHealth))

            local staminaRatio = math.clamp(stats.Stamina / stats.MaxStamina, 0, 1)
            staminaFill.Size = UDim2.new(staminaRatio, 0, 1, 0)

            if warmthFill and warmthLabel then
                local warmthRatio = math.clamp(stats.Warmth / stats.MaxWarmth, 0, 1)
                warmthFill.Size = UDim2.new(warmthRatio, 0, 1, 0)
                warmthLabel.Text = string.format("WARMTH: %d%%", math.ceil(warmthRatio * 100))
            end

            if sanityFill and sanityLabel then
                local sanityRatio = math.clamp(stats.Sanity / stats.MaxSanity, 0, 1)
                sanityFill.Size = UDim2.new(sanityRatio, 0, 1, 0)
                sanityLabel.Text = string.format("SANITY: %d%%", math.ceil(sanityRatio * 100))
            end
        end)
    end

    -- Hook up Cycle sync
    local syncCycleRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncTimeCycle)
    if syncCycleRemote then
        syncCycleRemote.OnClientEvent:Connect(function(phase: string, timeRemaining: number, _clockTime: number)
            phaseLabel.Text = string.upper(phase)
            timerLabel.Text = string.format("Time Remaining: %s", formatTimer(timeRemaining))
        end)
    end

    -- Hook up Downed state banner
    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote.OnClientEvent:Connect(function(userId: number, isDowned: boolean, duration: number)
            if userId == _player.UserId and _regionBanner then
                if isDowned then
                    _regionBanner.Text = "YOU ARE DOWNED! HOLD OUT FOR REVIVAL..."
                    _regionBanner.TextColor3 = Color3.fromRGB(255, 80, 80)
                else
                    _regionBanner.Text = _currentRegionName
                    _regionBanner.TextColor3 = Color3.fromRGB(235, 225, 205)
                end
            end
        end)
    end

    -- Hook Combat Hit Feedback (Floating Damage Numbers & Sparks)
    local hitRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.CombatHitFeedback)
    if hitRemote then
        hitRemote.OnClientEvent:Connect(function(hitPos: Vector3, damage: number, isCrit: boolean, hitType: string, targetName: string)
            HUDController.SpawnFloatingCombatText(hitPos, damage, isCrit, hitType)
        end)
    end

    -- Hook Dynamic Weather Notifications
    local weatherRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncWeather)
    if weatherRemote then
        weatherRemote.OnClientEvent:Connect(function(weatherName: string, warmthMult: number, fogDensity: number, desc: string)
            HUDController.ShowBannerNotification("WEATHER SHIFT: " .. string.upper(weatherName), desc)
        end)
    end

    -- Hook World Event Announcements
    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
    if eventRemote then
        eventRemote.OnClientEvent:Connect(function(title: string, desc: string, duration: number)
            HUDController.ShowBannerNotification("WORLD EVENT: " .. string.upper(title), desc)
        end)
    end

    -- Hook Dialogue & Clue Sync
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)
    if dialogRemote then
        dialogRemote.OnClientEvent:Connect(function(mode: string, data: any)
            HUDController.OpenDialogueModal(mode, data)
        end)
    end

    -- Region detection loop (Updated for 3,370 stud Grand Valley)
    task.spawn(function()
        while true do
            task.wait(1)
            local char = _player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
            if root then
                local pos = root.Position
                local detected = "Safe Haven"

                if pos.Z <= -2400 then
                    detected = "Ancient Grounds"
                elseif pos.Z <= -1800 then
                    detected = "Crystal Caverns"
                elseif pos.Z <= -1150 then
                    detected = "Abandoned Village"
                elseif pos.Z <= -250 then
                    detected = "Whispering Woods"
                else
                    detected = "Safe Haven"
                end

                if detected ~= _currentRegionName then
                    _currentRegionName = detected
                    if _regionBanner then
                        _regionBanner.Text = string.upper(detected)
                        _regionBanner.TextTransparency = 0
                        local tween = TweenService:Create(_regionBanner, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            TextTransparency = 0.2
                        })
                        tween:Play()
                    end
                end

                -- If Map Modal is open, update player marker
                if _mapModal and _mapModal.Visible then
                    HUDController.UpdateMapDisplay()
                end
            end
        end
    end)
end

function HUDController.IsReducedEffects(): boolean
    return _reducedEffects
end

function HUDController.IsCameraShakeEnabled(): boolean
    return _cameraShake
end

function HUDController.SelectHotbarSlot(slotIndex: number)
    local equipRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestEquipItem)
    if _selectedSlot == slotIndex then
        _selectedSlot = nil
        if equipRemote then
            equipRemote:FireServer(slotIndex)
        end
    else
        _selectedSlot = slotIndex
        if equipRemote then
            equipRemote:FireServer(slotIndex)
        end
    end

    if _hotbarContainer then
        for i = 1, 5 do
            local slotBtn = _hotbarContainer:FindFirstChild("Slot_" .. i) :: TextButton?
            local stroke = slotBtn and slotBtn:FindFirstChild("SelectionStroke") :: UIStroke?
            if stroke then
                if _selectedSlot == i then
                    stroke.Color = Color3.fromRGB(255, 215, 80)
                    stroke.Thickness = 2.5
                else
                    stroke.Color = Color3.fromRGB(60, 62, 68)
                    stroke.Thickness = 1.2
                end
            end
        end
    end
end

function HUDController.UseActiveItem()
    if _selectedSlot then
        local useRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestUseItem)
        if useRemote then
            useRemote:FireServer(_selectedSlot)
        end
    end
end

function HUDController.OpenModal(modalName: string)
    HUDController.CloseAllModals()
    if modalName == "Crafting" and _craftingModal then
        _craftingModal.Visible = true
    elseif modalName == "Storage" and _storageModal then
        _storageModal.Visible = true
    elseif modalName == "Quest" and _questModal then
        _questModal.Visible = true
    elseif modalName == "Lore" and _loreModal then
        _loreModal.Visible = true
    elseif modalName == "Map" and _mapModal then
        _mapModal.Visible = true
        HUDController.UpdateMapDisplay()
    end
end

function HUDController.ToggleMapModal()
    if _mapModal then
        local willBeVisible = not _mapModal.Visible
        HUDController.CloseAllModals()
        _mapModal.Visible = willBeVisible
        if willBeVisible then
            HUDController.UpdateMapDisplay()
        end
    end
end

function HUDController.UpdateMapDisplay()
    if not _mapModal or not _mapModal.Visible then return end
    local char = _player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end

    local pos = root.Position
    local canvas = _mapModal:FindFirstChild("MapCanvas") :: Frame?
    local marker = canvas and canvas:FindFirstChild("PlayerMarker") :: Frame?
    local sidebar = _mapModal:FindFirstChild("Sidebar") :: Frame?
    local coordLbl = sidebar and sidebar:FindFirstChild("CoordinatesLabel") :: TextLabel?

    if coordLbl then
        coordLbl.Text = string.format("POS: X: %d | Z: %d\nREGION: %s", math.floor(pos.X), math.floor(pos.Z), _currentRegionName)
    end

    if marker and canvas then
        -- Normalize coordinates into canvas [0, 1] range
        -- X bounds: -350 to +350 (span 700)
        -- Z bounds: +100 to -3150 (span 3250)
        local normX = math.clamp((pos.X + 350) / 700, 0.05, 0.95)
        local normY = math.clamp((100 - pos.Z) / 3250, 0.02, 0.98) -- +100 is bottom (Y=1.0), -3150 is top (Y=0.0)
        marker.Position = UDim2.new(normX, 0, 1.0 - normY, 0)
    end
end

function HUDController.OpenDialogueModal(mode: string, data: any)
    if not _dialogueModal then return end
    HUDController.CloseAllModals()
    _dialogueModal.Visible = true

    local nameLbl = _dialogueModal:FindFirstChild("NPCNameLabel") :: TextLabel?
    local textLbl = _dialogueModal:FindFirstChild("DialogueText") :: TextLabel?
    local topicCont = _dialogueModal:FindFirstChild("TopicContainer") :: Frame?

    if mode == "NPC" and data then
        if nameLbl then nameLbl.Text = string.format("%s — <%s>", data.DisplayName, data.Title) end
        if textLbl then textLbl.Text = data.Greeting end

        if topicCont then
            for _, c in ipairs(topicCont:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            local xOffset = 0
            if data.Topics then
                for _, topicData in pairs(data.Topics) do
                    local tBtn = Instance.new("TextButton")
                    tBtn.Size = UDim2.new(0, 190, 0, 36)
                    tBtn.Position = UDim2.new(0, xOffset, 0, 5)
                    tBtn.BackgroundColor3 = Color3.fromRGB(50, 65, 85)
                    tBtn.Text = topicData.prompt
                    tBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                    tBtn.Font = Enum.Font.GothamMedium
                    tBtn.TextSize = 11
                    local crn = Instance.new("UICorner")
                    crn.CornerRadius = UDim.new(0, 4)
                    crn.Parent = tBtn

                    tBtn.MouseButton1Click:Connect(function()
                        if textLbl then textLbl.Text = topicData.response end
                    end)
                    tBtn.Parent = topicCont
                    xOffset = xOffset + 200
                end
            end
        end
    elseif mode == "Clue" and data then
        if nameLbl then nameLbl.Text = string.format("[EXPEDITION RECORD] %s (%s)", data.Title, data.Region) end
        if textLbl then textLbl.Text = string.format("\"%s\"\n\n— %s", data.Body, data.Author) end
        if topicCont then
            for _, c in ipairs(topicCont:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
        end
    end
end

function HUDController.SpawnFloatingCombatText(pos: Vector3, damage: number, isCrit: boolean, hitType: string)
    if _reducedEffects and hitType == "miss" then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "FloatingDamage"
    bb.Size = UDim2.new(0, 140, 0, 44)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 0.2
    lbl.Parent = bb

    if hitType == "hit" then
        lbl.Text = tostring(damage) .. (isCrit and "!" or "")
        lbl.TextColor3 = isCrit and Color3.fromRGB(255, 120, 40) or Color3.fromRGB(255, 230, 80)
        lbl.TextSize = isCrit and 24 or 18
    elseif hitType == "blocked" then
        lbl.Text = "BLOCKED"
        lbl.TextColor3 = Color3.fromRGB(180, 190, 200)
        lbl.TextSize = 15
    elseif hitType == "resource" then
        lbl.Text = "+HARVEST"
        lbl.TextColor3 = Color3.fromRGB(120, 240, 140)
        lbl.TextSize = 16
    else
        lbl.Text = "MISS"
        lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
        lbl.TextSize = 14
    end

    local anchor = Instance.new("Part")
    anchor.Size = Vector3.new(0.5, 0.5, 0.5)
    anchor.CFrame = CFrame.new(pos)
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.Anchored = true
    bb.Adornee = anchor

    anchor.Parent = Workspace
    bb.Parent = Workspace

    local tween = TweenService:Create(bb, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        StudsOffset = Vector3.new(0, 5.0, 0)
    })
    local fadeTween = TweenService:Create(lbl, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    tween:Play()
    fadeTween:Play()

    task.delay(1.2, function()
        bb:Destroy()
        anchor:Destroy()
    end)
end

function HUDController.ShowBannerNotification(title: string, message: string)
    if _regionBanner then
        _regionBanner.Text = title .. "\n" .. message
        _regionBanner.TextColor3 = Color3.fromRGB(255, 230, 140)
        _regionBanner.TextTransparency = 0
        task.delay(6, function()
            if _regionBanner and _regionBanner.Text:find(title) then
                _regionBanner.Text = _currentRegionName
                _regionBanner.TextColor3 = Color3.fromRGB(235, 225, 205)
            end
        end)
    end
end

function HUDController.CloseAllModals()
    if _craftingModal then _craftingModal.Visible = false end
    if _storageModal then _storageModal.Visible = false end
    if _questModal then _questModal.Visible = false end
    if _loreModal then _loreModal.Visible = false end
    if _mapModal then _mapModal.Visible = false end
    if _dialogueModal then _dialogueModal.Visible = false end
end

return HUDController
