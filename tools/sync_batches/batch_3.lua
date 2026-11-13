--!strict
-- Sync batch 3 of 4
local files = {
    { path = {"ServerScriptService", "TFFServer", "Services", "EventService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    EventService.lua
    Server-authoritative World Event Director.
    Coordinates dynamic valley events: Fog Surge, Strange Signal, Crystal Bloom, and Abandoned Caravan.
    Directly fulfills Master Game Specification Section 2.4 and Chapter objectives.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type WorldEvent = {
    Id: string,
    Title: string,
    Description: string,
    Duration: number,
    Start: () -> (),
    Cleanup: () -> (),
}

local EventService = {}
EventService.__index = EventService

local _weatherService: any = nil
local _rewardService: any = nil
local _worldService: any = nil

local _activeEvent: WorldEvent? = nil
local _eventCleanupTasks: { () -> () } = {}

function EventService.Init(dependencies: { [string]: any })
    print("[EventService] Initializing EventService v2.0...")
    _weatherService = dependencies.WeatherService
    _rewardService = dependencies.RewardService
    _worldService = dependencies.WorldService
end

function EventService.Start()
    print("[EventService] EventService started. Registering scheduled valley events.")

    -- Periodic world event scheduler (every 5 to 7 minutes)
    task.spawn(function()
        task.wait(120) -- initial grace period after server start
        local eventTypes = { "FogSurge", "StrangeSignal", "CrystalBloom", "AbandonedCaravan" }
        local eventIndex = 1

        while true do
            local eventName = eventTypes[eventIndex]
            EventService.TriggerEvent(eventName)

            eventIndex = (eventIndex % #eventTypes) + 1
            task.wait(320)
        end
    end)
end

function EventService.TriggerEvent(eventName: string)
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)

    -- 1. FOG SURGE EVENT
    if eventName == "FogSurge" then
        if _weatherService then
            _weatherService.TriggerFogSurge(90)
        end
        if eventRemote then
            eventRemote:FireAllClients(
                "FOG SURGE APPROACHING",
                "A dense freezing wall of supernatural mist rolls down the valley! Cold drain x2.5. Retreat to campfires!",
                90
            )
        end

    -- 2. STRANGE SIGNAL EVENT
    elseif eventName == "StrangeSignal" and interactables then
        local signalChest = Instance.new("Part")
        signalChest.Name = "Event_SignalCache"
        signalChest.Size = Vector3.new(4, 3, 3)
        signalChest.CFrame = CFrame.new(210, 16.5, -880)
        signalChest.Color = Color3.fromRGB(0, 240, 180)
        signalChest.Material = Enum.Material.Neon
        signalChest.Anchored = true
        signalChest.CanCollide = true

        local pLight = Instance.new("PointLight")
        pLight.Color = Color3.fromRGB(0, 240, 180)
        pLight.Range = 25
        pLight.Brightness = 3
        pLight.Parent = signalChest

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Salvage Anomalous Signal Cache"
        prompt.ObjectText = "Glowing Keeper Cache"
        prompt.HoldDuration = 1.5
        prompt.MaxActivationDistance = 9
        prompt.Parent = signalChest

        signalChest.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "strange_signal_cache", {
                    ancientTokens = 5,
                    forestCoins = 50,
                    items = { { ItemId = "crystal", Quantity = 2 }, { ItemId = "ancient_fragment", Quantity = 1 } }
                })
            end
            signalChest:Destroy()
        end)

        task.delay(180, function()
            if signalChest.Parent then signalChest:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "STRANGE SIGNAL DETECTED",
                "An anomalous emerald frequency is pinging from Watcher's Bluff in Whispering Woods!",
                180
            )
        end

    -- 3. CRYSTAL BLOOM EVENT
    elseif eventName == "CrystalBloom" then
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL GROTTO RESONANCE",
                "The subterranean veins in Crystal Caverns are pulsating with high energy! Mining yield increased!",
                120
            )
        end

    -- 4. ABANDONED CARAVAN EVENT
    elseif eventName == "AbandonedCaravan" and interactables then
        local crate = Instance.new("Part")
        crate.Name = "Event_CaravanCrate"
        crate.Size = Vector3.new(4, 3, 3)
        crate.CFrame = CFrame.new(15, 2, -440)
        crate.Color = Color3.fromRGB(115, 85, 55)
        crate.Material = Enum.Material.WoodPlanks
        crate.Anchored = true
        crate.CanCollide = true

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Scavenge Overturned Crate"
        prompt.ObjectText = "Expedition Supplies"
        prompt.HoldDuration = 1.0
        prompt.MaxActivationDistance = 9
        prompt.Parent = crate
        crate.Parent = interactables

        prompt.Triggered:Connect(function(player: Player)
            if _rewardService then
                _rewardService.GrantReward(player, "caravan_supplies", {
                    forestCoins = 25,
                    items = { { ItemId = "food", Quantity = 4 }, { ItemId = "cloth", Quantity = 3 }, { ItemId = "rope", Quantity = 2 } }
                })
            end
            crate:Destroy()
        end)

        task.delay(180, function()
            if crate.Parent then crate:Destroy() end
        end)

        if eventRemote then
            eventRemote:FireAllClients(
                "ABANDONED CARAVAN SIGHTED",
                "An overturned expedition crate was spotted near the Whispering Woods Creek Ravine!",
                180
            )
        end
    end
end

return EventService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "InventoryService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    InventoryService.lua
    Server-authoritative inventory and communal Safe Haven storage management.
    Ensures atomic transactions, stack integrity, and prevents duplication exploits.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local InventoryService = {}
InventoryService.__index = InventoryService

local _profileService: any = nil
local _survivalService: any = nil
local _sharedStorage: { [string]: number } = {}

local function syncProfileToClient(player: Player)
    local profile = _profileService.GetProfile(player)
    if not profile then return end
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function broadcastSharedStorage()
    local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
    if updateRemote then
        updateRemote:FireAllClients(_sharedStorage)
    end
end

function InventoryService.Init(dependencies: { [string]: any })
    print("[InventoryService] Initializing InventoryService...")
    _profileService = dependencies.ProfileService
    _survivalService = dependencies.SurvivalService

    -- Connect storage remotes
    local depositRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestDepositStorage)
    if depositRemote then
        depositRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryDepositToSharedStorage(player, itemId, quantity)
        end)
    end

    local withdrawRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestWithdrawStorage)
    if withdrawRemote then
        withdrawRemote.OnServerEvent:Connect(function(player: Player, itemId: string, quantity: number)
            InventoryService.TryWithdrawFromSharedStorage(player, itemId, quantity)
        end)
    end

    -- Connect tool equipping & consumption remotes
    local equipRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestEquipItem)
    if equipRemote then
        equipRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.EquipItem(player, slotIndex)
        end)
    end

    local useRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestUseItem)
    if useRemote then
        useRemote.OnServerEvent:Connect(function(player: Player, slotIndex: number)
            InventoryService.UseItem(player, slotIndex)
        end)
    end
end

function InventoryService.Start()
    print("[InventoryService] InventoryService started.")
    Players.PlayerAdded:Connect(function(player)
        local updateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SharedStorageUpdated)
        if updateRemote then
            updateRemote:FireClient(player, _sharedStorage)
        end
    end)
end

function InventoryService.GetItemCount(player: Player, itemId: string): number
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return 0 end

    local count = 0
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId then
            count += item.Quantity
        end
    end
    return count
end

function InventoryService.TryAddItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 or quantity > 999 then return false end
    local def = ItemDefinitions[itemId]
    if not def then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local maxSlots = BalanceConfig.DefaultInventorySlots
    local remainingToAdd = quantity

    -- First pass: fill existing stacks
    for _, item in ipairs(profile.inventory) do
        if item.ItemId == itemId and item.Quantity < def.StackLimit then
            local space = def.StackLimit - item.Quantity
            local toAdd = math.min(space, remainingToAdd)
            item.Quantity += toAdd
            remainingToAdd -= toAdd
            if remainingToAdd <= 0 then break end
        end
    end

    -- Second pass: add new slots if space permits
    while remainingToAdd > 0 do
        if #profile.inventory >= maxSlots then
            -- Inventory is full
            syncProfileToClient(player)
            return false
        end

        local toAdd = math.min(def.StackLimit, remainingToAdd)
        table.insert(profile.inventory, {
            ItemId = itemId,
            Quantity = toAdd,
        })
        remainingToAdd -= toAdd
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryRemoveItem(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local currentCount = InventoryService.GetItemCount(player, itemId)
    if currentCount < quantity then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    local remainingToRemove = quantity
    local index = #profile.inventory
    while index >= 1 and remainingToRemove > 0 do
        local item = profile.inventory[index]
        if item.ItemId == itemId then
            if item.Quantity <= remainingToRemove then
                remainingToRemove -= item.Quantity
                table.remove(profile.inventory, index)
            else
                item.Quantity -= remainingToRemove
                remainingToRemove = 0
            end
        end
        index -= 1
    end

    syncProfileToClient(player)
    return true
end

function InventoryService.TryDepositToSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    if not ItemDefinitions[itemId] then return false end

    if InventoryService.TryRemoveItem(player, itemId, quantity) then
        _sharedStorage[itemId] = (_sharedStorage[itemId] or 0) + quantity
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.TryWithdrawFromSharedStorage(player: Player, itemId: string, quantity: number): boolean
    if quantity <= 0 then return false end
    local available = _sharedStorage[itemId] or 0
    if available < quantity then return false end

    if InventoryService.TryAddItem(player, itemId, quantity) then
        _sharedStorage[itemId] -= quantity
        if _sharedStorage[itemId] <= 0 then
            _sharedStorage[itemId] = nil
        end
        broadcastSharedStorage()
        return true
    end
    return false
end

function InventoryService.EquipItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot then return false end

    local char = player.Character
    if not char then return false end

    -- Check if already holding this tool
    local currentTool = char:FindFirstChildWhichIsA("Tool")
    if currentTool and currentTool.Name == slot.ItemId then
        currentTool:Destroy()
        return true
    elseif currentTool then
        currentTool:Destroy()
    end

    -- Clone tool from ServerStorage.TFF.Templates.Tools
    local ServerStorage = game:GetService("ServerStorage")
    local tff = ServerStorage:FindFirstChild("TFF")
    local templates = tff and tff:FindFirstChild("Templates")
    local tools = templates and templates:FindFirstChild("Tools")
    local toolTemplate = tools and tools:FindFirstChild(slot.ItemId) :: Tool?
    if toolTemplate then
        local equippedTool = toolTemplate:Clone()
        equippedTool.Parent = char
        return true
    end
    return false
end

function InventoryService.UseItem(player: Player, slotIndex: number): boolean
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return false end
    local slot = profile.inventory[slotIndex]
    if not slot or slot.Quantity <= 0 then return false end

    if slot.ItemId == "healing_potion" and _survivalService then
        local healed = _survivalService.HealHealth(player, 40)
        if healed then
            InventoryService.TryRemoveItem(player, "healing_potion", 1)
            return true
        end
    end
    return false
end

function InventoryService.ApplyDeathResourcePenalty(player: Player): { [string]: number }
    local profile = _profileService.GetProfile(player)
    if not profile or not profile.inventory then return {} end

    local lostItems: { [string]: number } = {}

    for i = #profile.inventory, 1, -1 do
        local slot = profile.inventory[i]
        local def = ItemDefinitions[slot.ItemId]
        if def and not def.IsQuestProtected and def.Category == "Resource" then
            local toLose = math.floor(slot.Quantity * (BalanceConfig.DeathResourceLossPercent / 100))
            if toLose > 0 then
                slot.Quantity -= toLose
                lostItems[slot.ItemId] = (lostItems[slot.ItemId] or 0) + toLose
                if slot.Quantity <= 0 then
                    table.remove(profile.inventory, i)
                end
            end
        end
    end

    syncProfileToClient(player)
    return lostItems
end

return InventoryService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "PlayerService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    PlayerService.lua
    Manages player lifecycle, character spawning, profile synchronization, and safe disconnection.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local StoryDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.StoryDefinitions)
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local PlayerService = {}
PlayerService.__index = PlayerService

local _profileService: any = nil
local _worldService: any = nil
local _progressionService: any = nil

local function onPlayerAdded(player: Player)
    print(string.format("[PlayerService] Player joined: %s (%d)", player.Name, player.UserId))

    -- Enforce soft player limit if needed
    if #Players:GetPlayers() > BalanceConfig.MaxPlayers then
        player:Kick("Server capacity reached (Max 12 players). Please join another server.")
        return
    end

    local profile = _profileService.LoadProfile(player)

    -- Character spawning setup
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.WalkSpeed = 16

        -- Spawn inside Safe Haven spawn location if available
        local worldRoot = game.Workspace:FindFirstChild("TFF_World")
        if worldRoot then
            local spawnFolder = worldRoot:FindFirstChild("SpawnLocations")
            if spawnFolder and #spawnFolder:GetChildren() > 0 then
                local spawnPart = spawnFolder:GetChildren()[1] :: BasePart
                if spawnPart and spawnPart:IsA("BasePart") then
                    character:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
                end
            end
        end
    end)

    -- Sync initial profile to client
    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

local function onPlayerRemoving(player: Player)
    print(string.format("[PlayerService] Player leaving: %s (%d)", player.Name, player.UserId))
    _profileService.UnloadProfile(player)
end

function PlayerService.Init(dependencies: { [string]: any })
    print("[PlayerService] Initializing PlayerService...")
    _profileService = dependencies.ProfileService
    _worldService = dependencies.WorldService
    _progressionService = dependencies.ProgressionService
end

function PlayerService.Start()
    print("[PlayerService] PlayerService started.")
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    -- Hook up ProximityPrompts for NPCs and Story Clues
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)

    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        local parentInstance = prompt.Parent
        if not parentInstance then return end

        local model = parentInstance:FindFirstAncestorOfClass("Model")

        -- 1. NPC Interaction
        if model and CollectionService:HasTag(model, "TFF_NPC") then
            local npcId = model:GetAttribute("NPCId") or "cartographer"
            local data = StoryDefinitions.Dialogues[npcId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "NPC", data)
            end

        -- 2. Story Clue Interaction
        elseif parentInstance:IsA("BasePart") and CollectionService:HasTag(parentInstance, "TFF_StoryClue") then
            local clueId = parentInstance:GetAttribute("ClueId") or "safe_haven_orders"
            local data = StoryDefinitions.Clues[clueId]
            if data and dialogRemote then
                dialogRemote:FireClient(player, "Clue", data)
                if _progressionService then
                    _progressionService.AddExperience(player, 25)
                end
            end
        end
    end)
end

return PlayerService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "ProfileService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    ProfileService.lua
    Server-authoritative persistence provider for player profiles.
    Includes mock fallback for studio offline environments and safe migration logic.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("TFF"):WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("Types"))

local ProfileService = {}
ProfileService.__index = ProfileService

local SCHEMA_VERSION = 1
local DATA_STORE_NAME = "TFF_PlayerData_v1"

local _dataStore: GlobalDataStore? = nil
local _activeProfiles: { [number]: Types.PlayerProfile } = {}
local _mockStore: { [string]: Types.PlayerProfile } = {}
local _isMock = false

local function createDefaultProfile(): Types.PlayerProfile
    return {
        schemaVersion = SCHEMA_VERSION,
        level = 1,
        xp = 0,
        forestCoins = 0,
        ancientTokens = 0,
        inventory = {},
        equipment = {},
        unlockedRecipes = {
            torch = true,
            healing_potion = true,
            basic_tool = true,
        },
        completedQuests = {},
        activeQuests = {},
        achievements = {},
        discoveries = {},
        cosmetics = {},
        settings = {
            reducedEffects = false,
            cameraShake = true,
        },
        lastSaveUnix = os.time(),
    }
end

local function migrateProfile(data: any): Types.PlayerProfile
    if typeof(data) ~= "table" then
        return createDefaultProfile()
    end

    local profile = data :: Types.PlayerProfile
    if not profile.schemaVersion or profile.schemaVersion < 1 then
        profile.schemaVersion = 1
    end
    if not profile.inventory then profile.inventory = {} end
    if not profile.equipment then profile.equipment = {} end
    if not profile.unlockedRecipes then
        profile.unlockedRecipes = { torch = true, healing_potion = true, basic_tool = true }
    end
    if not profile.completedQuests then profile.completedQuests = {} end
    if not profile.activeQuests then profile.activeQuests = {} end
    if not profile.achievements then profile.achievements = {} end
    if not profile.discoveries then profile.discoveries = {} end
    if not profile.cosmetics then profile.cosmetics = {} end
    if not profile.settings then
        profile.settings = { reducedEffects = false, cameraShake = true }
    end
    profile.lastSaveUnix = os.time()

    return profile
end

function ProfileService.Init(_dependencies: { [string]: any })
    print("[ProfileService] Initializing ProfileService...")

    local success, store = pcall(function()
        return DataStoreService:GetDataStore(DATA_STORE_NAME)
    end)

    if success and store then
        _dataStore = store
        _isMock = false
        print("[ProfileService] Live DataStore connected.")
    else
        _isMock = true
        warn("[ProfileService] DataStoreService unavailable. Operating in safe MockDataStore mode.")
    end
end

function ProfileService.Start()
    print("[ProfileService] ProfileService started.")
end

function ProfileService.LoadProfile(player: Player): Types.PlayerProfile
    local userId = player.UserId
    local key = "Player_" .. tostring(userId)

    if _isMock or not _dataStore then
        local existing = _mockStore[key]
        if existing then
            _activeProfiles[userId] = existing
            return existing
        else
            local newProfile = createDefaultProfile()
            _mockStore[key] = newProfile
            _activeProfiles[userId] = newProfile
            return newProfile
        end
    end

    local success, result = pcall(function()
        return _dataStore:GetAsync(key)
    end)

    if success and result then
        local migrated = migrateProfile(result)
        _activeProfiles[userId] = migrated
        return migrated
    elseif success and result == nil then
        local newProfile = createDefaultProfile()
        _activeProfiles[userId] = newProfile
        return newProfile
    else
        warn(string.format("[ProfileService] Failed to load data for user %d: %s. Using safe temporary fallback.", userId, tostring(result)))
        local fallback = createDefaultProfile()
        _activeProfiles[userId] = fallback
        return fallback
    end
end

function ProfileService.GetProfile(player: Player): Types.PlayerProfile?
    return _activeProfiles[player.UserId]
end

function ProfileService.SaveProfile(player: Player): boolean
    local userId = player.UserId
    local profile = _activeProfiles[userId]
    if not profile then return false end

    profile.lastSaveUnix = os.time()
    local key = "Player_" .. tostring(userId)

    if _isMock or not _dataStore then
        _mockStore[key] = profile
        return true
    end

    local success, err = pcall(function()
        _dataStore:UpdateAsync(key, function(oldData)
            return profile
        end)
    end)

    if not success then
        warn(string.format("[ProfileService] Save failure for user %d: %s", userId, tostring(err)))
        return false
    end
    return true
end

function ProfileService.UnloadProfile(player: Player)
    ProfileService.SaveProfile(player)
    _activeProfiles[player.UserId] = nil
end

return ProfileService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "ProgressionService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    ProgressionService.lua
    Manages XP gain, level thresholds, and currency balances.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local ProgressionService = {}
ProgressionService.__index = ProgressionService

local _profileService: any = nil

local function getXPForNextLevel(currentLevel: number): number
    return math.floor(100 * (currentLevel ^ 1.5))
end

function ProgressionService.Init(dependencies: { [string]: any })
    print("[ProgressionService] Initializing ProgressionService...")
    _profileService = dependencies.ProfileService
end

function ProgressionService.Start()
    print("[ProgressionService] ProgressionService started.")
end

function ProgressionService.GrantXP(player: Player, amount: number, reason: string)
    if amount <= 0 then return end
    local profile = _profileService.GetProfile(player)
    if not profile then return end

    profile.xp += amount
    print(string.format("[ProgressionService] Granted %d XP to %s for: %s", amount, player.Name, reason))

    -- Check for level ups
    local needed = getXPForNextLevel(profile.level)
    while profile.xp >= needed do
        profile.xp -= needed
        profile.level += 1
        print(string.format("[ProgressionService] %s leveled up to Level %d!", player.Name, profile.level))
        needed = getXPForNextLevel(profile.level)
    end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

function ProgressionService.GrantCurrency(player: Player, currencyType: "ForestCoins" | "AncientTokens", amount: number)
    if amount <= 0 then return end
    local profile = _profileService.GetProfile(player)
    if not profile then return end

    if currencyType == "ForestCoins" then
        profile.forestCoins += amount
    elseif currencyType == "AncientTokens" then
        profile.ancientTokens += amount
    end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncRemote then
        syncRemote:FireClient(player, profile)
    end
end

return ProgressionService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "QuestService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    QuestService.lua
    Server-authoritative quest management and idempotent completion tracking.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local QuestService = {}
QuestService.__index = QuestService

local _profileService: any = nil
local _progressionService: any = nil
local _inventoryService: any = nil

function QuestService.Init(dependencies: { [string]: any })
    print("[QuestService] Initializing QuestService...")
    _profileService = dependencies.ProfileService
    _progressionService = dependencies.ProgressionService
    _inventoryService = dependencies.InventoryService

    local claimRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestClaimQuest)
    if claimRemote then
        claimRemote.OnServerEvent:Connect(function(player: Player, questId: string)
            QuestService.TryClaimQuestReward(player, questId)
        end)
    end
end

function QuestService.Start()
    print("[QuestService] QuestService started.")
end

function QuestService.TryClaimQuestReward(player: Player, questId: string): boolean
    local def = QuestDefinitions[questId]
    if not def then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    -- Check idempotency: cannot complete non-repeatable quest twice
    if not def.IsRepeatable and profile.completedQuests[questId] then
        return false
    end

    -- Mark completed
    profile.completedQuests[questId] = true

    -- Grant rewards
    if def.Rewards.XP > 0 then
        _progressionService.GrantXP(player, def.Rewards.XP, "Quest: " .. def.Title)
    end
    if def.Rewards.ForestCoins > 0 then
        _progressionService.GrantCurrency(player, "ForestCoins", def.Rewards.ForestCoins)
    end
    if def.Rewards.AncientTokens > 0 then
        _progressionService.GrantCurrency(player, "AncientTokens", def.Rewards.AncientTokens)
    end
    if def.Rewards.Items then
        for itemId, qty in pairs(def.Rewards.Items) do
            _inventoryService.TryAddItem(player, itemId, qty)
        end
    end

    local questUpdateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.QuestUpdated)
    if questUpdateRemote then
        questUpdateRemote:FireClient(player, profile.activeQuests, profile.completedQuests)
    end

    return true
end

return QuestService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "ResourceService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    ResourceService.lua
    Server-authoritative resource gathering and node lifecycle management.
    Prevents duplicate node harvest exploits, verifies distance, and manages respawn timers.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)

local ResourceService = {}
ResourceService.__index = ResourceService

local _inventoryService: any = nil
local _progressionService: any = nil
local _survivalService: any = nil
local _worldService: any = nil

type ActiveNode = {
    NodeId: string,
    ItemId: string,
    Part: BasePart?,
    RemainingYield: number,
    GatherDuration: number,
    RespawnDuration: number,
    Position: Vector3,
    IsAvailable: boolean,
}

local _registeredNodes: { [string]: ActiveNode } = {}

function ResourceService.Init(dependencies: { [string]: any })
    print("[ResourceService] Initializing ResourceService...")
    _inventoryService = dependencies.InventoryService
    _progressionService = dependencies.ProgressionService
    _survivalService = dependencies.SurvivalService
    _worldService = dependencies.WorldService

    -- Connect remote request for headless/scripted gather calls
    local gatherRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestGather)
    if gatherRemote then
        gatherRemote.OnServerEvent:Connect(function(player: Player, nodeId: string)
            ResourceService.TryGather(player, nodeId)
        end)
    end
end

function ResourceService.Start()
    print("[ResourceService] ResourceService started.")

    -- Register existing world resource nodes
    local worldRoot = game.Workspace:FindFirstChild("TFF_World")
    local nodesFolder = worldRoot and worldRoot:FindFirstChild("ResourceNodes")
    if nodesFolder then
        for _, part in ipairs(nodesFolder:GetChildren()) do
            if part:IsA("BasePart") and CollectionService:HasTag(part, "TFF_ResourceNode") then
                local nodeId = part:GetAttribute("NodeId") or part.Name
                local itemId = part:GetAttribute("ItemId") or "wood"
                local initialYield = part:GetAttribute("InitialYield") or 3
                ResourceService.RegisterNode(nodeId, itemId, initialYield, part.Position, 180, part)
            end
        end
    end

    -- Server-side proximity prompt handling
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        local parentPart = prompt.Parent :: BasePart?
        if parentPart and CollectionService:HasTag(parentPart, "TFF_ResourceNode") then
            local nodeId = parentPart:GetAttribute("NodeId") or parentPart.Name
            ResourceService.TryGather(player, nodeId)
        end
    end)
end

function ResourceService.RegisterNode(nodeId: string, itemId: string, initialYield: number, position: Vector3, respawnDuration: number, part: BasePart?)
    _registeredNodes[nodeId] = {
        NodeId = nodeId,
        ItemId = itemId,
        Part = part,
        RemainingYield = initialYield,
        GatherDuration = 1.5,
        RespawnDuration = respawnDuration or 180,
        Position = position,
        IsAvailable = true,
    }
end

function ResourceService.TryGather(player: Player, nodeId: string): boolean
    local node = _registeredNodes[nodeId]
    if not node or not node.IsAvailable or node.RemainingYield <= 0 then
        return false
    end

    local stats = _survivalService.GetStats(player)
    if not stats or stats.IsDowned then return false end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return false end

    local dist = (root.Position - node.Position).Magnitude
    if dist > BalanceConfig.DefaultInteractionRange + 2 then
        return false
    end

    -- Atomic reservation
    node.RemainingYield -= 1
    local isDepleted = (node.RemainingYield <= 0)
    if isDepleted then
        node.IsAvailable = false
        if node.Part then
            node.Part.Transparency = 0.8
            local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then prompt.Enabled = false end
        end

        task.delay(node.RespawnDuration, function()
            node.RemainingYield = 3
            node.IsAvailable = true
            if node.Part then
                node.Part.Transparency = 0
                local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then prompt.Enabled = true end
            end
        end)
    end

    -- Grant resource through InventoryService
    local added = _inventoryService.TryAddItem(player, node.ItemId, 1)
    if added then
        _progressionService.GrantXP(player, 5, "Gathering " .. node.ItemId)
        return true
    else
        -- If inventory is full, return node yield
        if isDepleted then
            node.RemainingYield = 1
            node.IsAvailable = true
            if node.Part then
                node.Part.Transparency = 0
                local prompt = node.Part:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then prompt.Enabled = true end
            end
        else
            node.RemainingYield += 1
        end
        return false
    end
end

function ResourceService.GetNodeState(nodeId: string): ActiveNode?
    return _registeredNodes[nodeId]
end

return ResourceService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "RewardService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    RewardService.lua
    Coordinates participation-based encounter and dawn cycle rewards.
    Guarantees reward idempotency and fair contribution attribution.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

local RewardService = {}
RewardService.__index = RewardService

local _progressionService: any = nil
local _inventoryService: any = nil

local _processedTransactions: { [string]: boolean } = {}

function RewardService.Init(dependencies: { [string]: any })
    print("[RewardService] Initializing RewardService...")
    _progressionService = dependencies.ProgressionService
    _inventoryService = dependencies.InventoryService
end

function RewardService.Start()
    print("[RewardService] RewardService started.")
end

function RewardService.GrantIdempotentReward(player: Player, transactionId: string, xp: number, coins: number, items: { [string]: number }?): boolean
    if _processedTransactions[transactionId] then
        warn(string.format("[RewardService] Duplicate reward transaction rejected: %s", transactionId))
        return false
    end

    _processedTransactions[transactionId] = true

    if xp > 0 then
        _progressionService.GrantXP(player, xp, "Reward: " .. transactionId)
    end
    if coins > 0 then
        _progressionService.GrantCurrency(player, "ForestCoins", coins)
    end
    if items then
        for itemId, qty in pairs(items) do
            _inventoryService.TryAddItem(player, itemId, qty)
        end
    end

    return true
end

return RewardService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "SurvivalService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    SurvivalService.lua
    Server-authoritative manager for player survival attributes:
    Health, Stamina, Warmth, Sanity, Downed state, Timed Revivals, and Idempotent Death Penalties.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage.TFF.Shared.Config.MovementConfig)
local SurvivalConfig = require(ReplicatedStorage.TFF.Shared.Config.SurvivalConfig)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local SurvivalService = {}
SurvivalService.__index = SurvivalService

local _worldService: any = nil
local _inventoryService: any = nil
local _weatherService: any = nil
local _playerStats: { [number]: Types.PlayerStats } = {}
local _lastSprintTime: { [number]: number } = {}
local _activeRevives: { [number]: { targetId: number, startTime: number } } = {}
local _isProcessingDeath: { [number]: boolean } = {}

local function createInitialStats(): Types.PlayerStats
    return {
        Health = SurvivalConfig.MaxHealth,
        MaxHealth = SurvivalConfig.MaxHealth,
        Stamina = SurvivalConfig.MaxStamina,
        MaxStamina = SurvivalConfig.MaxStamina,
        Warmth = SurvivalConfig.MaxWarmth,
        MaxWarmth = SurvivalConfig.MaxWarmth,
        Sanity = SurvivalConfig.MaxSanity,
        MaxSanity = SurvivalConfig.MaxSanity,
        IsSprinting = false,
        IsDowned = false,
        DownedTimer = 0,
    }
end

local function syncStatsToClient(player: Player)
    local stats = _playerStats[player.UserId]
    if not stats then return end

    local syncRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncStats)
    if syncRemote then
        syncRemote:FireClient(player, stats)
    end
end

function SurvivalService.Init(dependencies: { [string]: any })
    print("[SurvivalService] Initializing SurvivalService...")
    _worldService = dependencies.WorldService
    _inventoryService = dependencies.InventoryService
    _weatherService = dependencies.WeatherService

    local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)
    if sprintRemote then
        sprintRemote.OnServerEvent:Connect(function(player: Player, wantsSprint: boolean)
            SurvivalService.SetSprinting(player, wantsSprint == true)
        end)
    end

    local reviveRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestRevive)
    if reviveRemote then
        reviveRemote.OnServerEvent:Connect(function(player: Player, targetUserId: number)
            SurvivalService.StartRevive(player, targetUserId)
        end)
    end
end

function SurvivalService.Start()
    print("[SurvivalService] SurvivalService started.")

    Players.PlayerAdded:Connect(function(player)
        _playerStats[player.UserId] = createInitialStats()
        _lastSprintTime[player.UserId] = os.clock()
        _isProcessingDeath[player.UserId] = false

        player.CharacterAdded:Connect(function(char)
            local stats = _playerStats[player.UserId]
            if stats then
                stats.Health = stats.MaxHealth
                stats.Stamina = stats.MaxStamina
                stats.IsDowned = false
                stats.DownedTimer = 0
                _isProcessingDeath[player.UserId] = false
                syncStatsToClient(player)
            end
        end)

        syncStatsToClient(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        _playerStats[player.UserId] = nil
        _lastSprintTime[player.UserId] = nil
        _activeRevives[player.UserId] = nil
        _isProcessingDeath[player.UserId] = nil
    end)

    -- Simulation tick (0.5s)
    task.spawn(function()
        local dt = 0.5
        while true do
            task.wait(dt)
            local now = os.clock()

            -- 1. Check active timed revives (4-second duration)
            for reviverId, reviveData in pairs(_activeRevives) do
                local reviver = Players:GetPlayerByUserId(reviverId)
                local target = Players:GetPlayerByUserId(reviveData.targetId)
                local reviverChar = reviver and reviver.Character
                local targetChar = target and target.Character
                local reviverRoot = reviverChar and reviverChar:FindFirstChild("HumanoidRootPart") :: BasePart?
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

                if not reviver or not target or not reviverRoot or not targetRoot then
                    _activeRevives[reviverId] = nil
                else
                    local dist = (reviverRoot.Position - targetRoot.Position).Magnitude
                    if dist > BalanceConfig.DefaultInteractionRange + 2 then
                        -- Reviver moved too far -> cancel revive
                        _activeRevives[reviverId] = nil
                    elseif (now - reviveData.startTime) >= BalanceConfig.ReviveDuration then
                        -- Revive completed successfully!
                        _activeRevives[reviverId] = nil
                        SurvivalService.CompleteRevive(reviver, target)
                    end
                end
            end

            -- 2. Player Stats & Downed Timers
            for _, player in ipairs(Players:GetPlayers()) do
                local stats = _playerStats[player.UserId]
                local char = player.Character
                local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?

                if stats and humanoid and humanoid.Health > 0 then
                    if stats.IsDowned then
                        stats.DownedTimer -= dt
                        if stats.DownedTimer <= 0 then
                            SurvivalService.HandlePlayerDeath(player)
                        else
                            syncStatsToClient(player)
                        end
                    else
                        -- Stamina drain & recovery
                        if stats.IsSprinting then
                            stats.Stamina = math.max(0, stats.Stamina - (MovementConfig.SprintDrainRate * dt))
                            _lastSprintTime[player.UserId] = now
                            if stats.Stamina <= 0 then
                                SurvivalService.SetSprinting(player, false)
                            end
                        else
                            local idleDuration = now - (_lastSprintTime[player.UserId] or 0)
                            if idleDuration >= MovementConfig.RegenDelayAfterSprint then
                                stats.Stamina = math.min(stats.MaxStamina, stats.Stamina + (MovementConfig.StaminaRegenRate * dt))
                            end
                        end

                        -- Environmental Survival: Warmth & Sanity Dynamics
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                        local isSafe = rootPart and _worldService and _worldService.IsInsideSafeZone(rootPart.Position)
                        local weatherWarmthMult = _weatherService and _weatherService.GetWarmthMultiplier() or 1.0
                        local weatherSanityMult = _weatherService and _weatherService.GetSanityMultiplier() or 1.0

                        if isSafe then
                            -- Safe Haven Recovery
                            stats.Health = math.min(stats.MaxHealth, stats.Health + (SurvivalConfig.SafeHavenHealthRegen * dt))
                            stats.Warmth = math.min(stats.MaxWarmth, stats.Warmth + (SurvivalConfig.WarmthRecoveryNearFire * dt))
                            stats.Sanity = math.min(stats.MaxSanity, stats.Sanity + (SurvivalConfig.SafeHavenSanityRegen * dt))
                            humanoid.Health = stats.Health
                        else
                            -- Check if player is holding a torch or lantern
                            local tool = char:FindFirstChildWhichIsA("Tool")
                            local hasLight = tool and (tool.Name == "torch" or tool.Name == "advanced_lantern")

                            if hasLight then
                                stats.Warmth = math.min(stats.MaxWarmth, stats.Warmth + (2.0 * dt))
                            else
                                stats.Warmth = math.max(0, stats.Warmth - (SurvivalConfig.WarmthDecayColdZone * weatherWarmthMult * dt))
                            end

                            -- Hypothermia damage if freezing
                            if stats.Warmth <= 0 then
                                stats.Health = math.max(0, stats.Health - (2.5 * dt))
                                humanoid.Health = stats.Health
                                if stats.Health <= 0 then
                                    stats.IsDowned = true
                                    stats.DownedTimer = BalanceConfig.DownedDuration
                                    stats.IsSprinting = false
                                end
                            end

                            -- Sanity decay in deep wilderness
                            if rootPart and rootPart.Position.Z < -250 then
                                local sanityDrain = (hasLight and 0.3 or 1.0) * weatherSanityMult * dt
                                stats.Sanity = math.max(0, stats.Sanity - sanityDrain)
                            end
                        end

                        syncStatsToClient(player)
                    end
                end
            end
        end
    end)
end

function SurvivalService.DrainStamina(player: Player, amount: number): boolean
    local stats = _playerStats[player.UserId]
    if not stats or stats.IsDowned then return false end
    if stats.Stamina < amount then return false end
    stats.Stamina = math.max(0, stats.Stamina - amount)
    _lastSprintTime[player.UserId] = os.clock()
    syncStatsToClient(player)
    return true
end

function SurvivalService.SetSprinting(player: Player, isSprinting: boolean)
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return end

    if isSprinting then
        if stats.Stamina >= MovementConfig.MinStaminaToStartSprint then
            stats.IsSprinting = true
            humanoid.WalkSpeed = MovementConfig.SprintSpeed
        else
            stats.IsSprinting = false
            humanoid.WalkSpeed = MovementConfig.WalkSpeed
        end
    else
        stats.IsSprinting = false
        humanoid.WalkSpeed = MovementConfig.WalkSpeed
    end
    syncStatsToClient(player)
end

function SurvivalService.ApplyDamage(player: Player, amount: number)
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return end

    -- Taking damage interrupts any active revive being channeled by this player
    if _activeRevives[player.UserId] then
        _activeRevives[player.UserId] = nil
        print(string.format("[SurvivalService] Revive interrupted for %s due to taking damage", player.Name))
    end

    stats.Health = math.max(0, stats.Health - amount)
    humanoid.Health = stats.Health

    if stats.Health <= 0 then
        -- Enter Downed state
        stats.IsDowned = true
        stats.DownedTimer = BalanceConfig.DownedDuration
        stats.IsSprinting = false
        humanoid.WalkSpeed = MovementConfig.DownedWalkSpeed

        local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
        if downedRemote then
            downedRemote:FireAllClients(player.UserId, true, BalanceConfig.DownedDuration)
        end
    end
    syncStatsToClient(player)
end

function SurvivalService.HealHealth(player: Player, amount: number): boolean
    local stats = _playerStats[player.UserId]
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not stats or not humanoid or stats.IsDowned then return false end
    if stats.Health >= stats.MaxHealth then return false end

    stats.Health = math.min(stats.MaxHealth, stats.Health + amount)
    humanoid.Health = stats.Health
    syncStatsToClient(player)
    return true
end

function SurvivalService.StartRevive(reviver: Player, targetUserId: number): boolean
    local reviverStats = _playerStats[reviver.UserId]
    local targetStats = _playerStats[targetUserId]
    if not reviverStats or reviverStats.IsDowned then return false end
    if not targetStats or not targetStats.IsDowned then return false end

    local reviverChar = reviver.Character
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    local targetChar = targetPlayer and targetPlayer.Character
    local reviverRoot = reviverChar and reviverChar:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

    if not reviverRoot or not targetRoot then return false end

    local dist = (reviverRoot.Position - targetRoot.Position).Magnitude
    if dist > BalanceConfig.DefaultInteractionRange + 2 then
        return false
    end

    _activeRevives[reviver.UserId] = {
        targetId = targetUserId,
        startTime = os.clock(),
    }
    print(string.format("[SurvivalService] %s started reviving %s (4s channel)", reviver.Name, targetPlayer.Name))
    return true
end

function SurvivalService.CompleteRevive(reviver: Player, target: Player)
    local targetStats = _playerStats[target.UserId]
    if not targetStats or not targetStats.IsDowned then return end

    targetStats.IsDowned = false
    targetStats.DownedTimer = 0
    targetStats.Health = BalanceConfig.ReviveHealthRestored

    local targetChar = target.Character
    local targetHumanoid = targetChar and targetChar:FindFirstChild("Humanoid") :: Humanoid?
    if targetHumanoid then
        targetHumanoid.Health = targetStats.Health
        targetHumanoid.WalkSpeed = MovementConfig.WalkSpeed
    end

    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote:FireAllClients(target.UserId, false, 0)
    end
    syncStatsToClient(target)
    print(string.format("[SurvivalService] %s successfully revived %s! Restored %d Health.", reviver.Name, target.Name, BalanceConfig.ReviveHealthRestored))
end

function SurvivalService.HandlePlayerDeath(player: Player)
    local userId = player.UserId
    if _isProcessingDeath[userId] then
        -- Idempotency check: prevent duplicate death processing
        return
    end
    _isProcessingDeath[userId] = true

    print(string.format("[SurvivalService] Processing death for %s...", player.Name))

    -- 1. Deduct 20% of eligible carried resources
    local lostItems = {}
    if _inventoryService then
        lostItems = _inventoryService.ApplyDeathResourcePenalty(player)
    end

    -- Format summary message
    local summaryParts = {}
    for itemId, count in pairs(lostItems) do
        table.insert(summaryParts, string.format("%dx %s", count, itemId))
    end
    local lossSummary = #summaryParts > 0 and table.concat(summaryParts, ", ") or "None"

    local notifyRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.ShowNotification)
    if notifyRemote then
        notifyRemote:FireClient(player, "You have succumbed to the forest.", "Carried resources lost (20%): " .. lossSummary, "Warning")
    end

    -- 2. Respawn character at Safe Haven Plaza
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
        if humanoid then humanoid.Health = 0 end
    end

    local stats = _playerStats[userId]
    if stats then
        stats.IsDowned = false
        stats.DownedTimer = 0
        stats.Health = stats.MaxHealth
        stats.Stamina = stats.MaxStamina
    end

    local downedRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.DownedStateChanged)
    if downedRemote then
        downedRemote:FireAllClients(userId, false, 0)
    end

    task.delay(3, function()
        _isProcessingDeath[userId] = false
    end)
end

function SurvivalService.GetStats(player: Player): Types.PlayerStats?
    return _playerStats[player.UserId]
end

return SurvivalService
]=====] },
}

local synced = 0
for _, item in ipairs(files) do
    local current: Instance = game:GetService(item.path[1])
    for i = 2, #item.path - 1 do
        local seg = item.path[i]
        local child = current:FindFirstChild(seg)
        if not child then
            child = Instance.new("Folder")
            child.Name = seg
            child.Parent = current
        end
        current = child
    end
    local leaf = item.path[#item.path]
    local obj = current:FindFirstChild(leaf)
    if not obj or obj.ClassName ~= item.class then
        if obj then obj:Destroy() end
        obj = Instance.new(item.class)
        obj.Name = leaf
        obj.Parent = current
    end
    (obj :: any).Source = item.source
    synced = synced + 1
end
return string.format("BATCH 3 SUCCESS: Updated %d scripts.", synced)