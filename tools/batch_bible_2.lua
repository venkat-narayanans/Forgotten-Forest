--!strict
local files = {
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "QuestDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    QuestDefinitions.lua
    Data-driven definitions for initial discovery, survival, and mystery quests.
]]

export type QuestObjective = {
    Type: string,
    Target: string,
    RequiredCount: number,
    Description: string,
}

export type QuestDefinition = {
    QuestId: string,
    Title: string,
    Description: string,
    Category: "Exploration" | "Survival" | "Mystery" | "Group",
    Prerequisites: { string },
    Objectives: { QuestObjective },
    Rewards: {
        XP: number,
        ForestCoins: number,
        AncientTokens: number,
        Items: { [string]: number }?,
    },
    IsRepeatable: boolean,
}

local QuestDefinitions: { [string]: QuestDefinition } = {
    q_starter_kit = {
        QuestId = "q_starter_kit",
        Title = "Equip for the Wilds",
        Description = "Claim your survival kit from the Expedition Starter Chest beside the Safe Haven beacon fire. Equip your torch and field knife to prepare for the outer valley.",
        Category = "Survival",
        Prerequisites = {},
        Objectives = {
            {
                Type = "Interact",
                Target = "ExpeditionStarterChest",
                RequiredCount = 1,
                Description = "Claim Expedition Starter Supplies by Beacon Fire",
            },
            {
                Type = "EquipItem",
                Target = "torch",
                RequiredCount = 1,
                Description = "Equip Traveler's Torch (Press 1 or Click Hotbar)",
            },
        },
        Rewards = {
            XP = 100,
            ForestCoins = 50,
            AncientTokens = 0,
        },
        IsRepeatable = false,
    },
    q_first_steps = {
        QuestId = "q_first_steps",
        Title = "First Steps into the Unknown",
        Description = "Explore the immediate perimeter outside the Safe Haven boundary.",
        Category = "Exploration",
        Prerequisites = { "q_starter_kit" },
        Objectives = {
            {
                Type = "DiscoverLocation",
                Target = "WhisperingWoodsEdge",
                RequiredCount = 1,
                Description = "Reach the edge of Whispering Woods",
            },
        },
        Rewards = {
            XP = 50,
            ForestCoins = 25,
            AncientTokens = 0,
        },
        IsRepeatable = false,
    },
    q_prepare_for_night = {
        QuestId = "q_prepare_for_night",
        Title = "Preparing for Sunset",
        Description = "Gather wood and fiber to craft your first torch before darkness falls.",
        Category = "Survival",
        Prerequisites = { "q_first_steps" },
        Objectives = {
            {
                Type = "CollectItem",
                Target = "wood",
                RequiredCount = 2,
                Description = "Gather 2 Forest Timber",
            },
            {
                Type = "CraftItem",
                Target = "torch",
                RequiredCount = 1,
                Description = "Craft 1 Traveler's Torch",
            },
        },
        Rewards = {
            XP = 100,
            ForestCoins = 50,
            AncientTokens = 0,
        },
        IsRepeatable = false,
    },
    q_repair_beacon = {
        QuestId = "q_repair_beacon",
        Title = "A Light in the Valley",
        Description = "Gather 4 Forest Timber and 2 River Stones, then repair and ignite the Safe Haven Central Beacon to establish camp perimeter security.",
        Category = "Survival",
        Prerequisites = { "q_starter_kit" },
        Objectives = {
            {
                Type = "CollectItem",
                Target = "wood",
                RequiredCount = 4,
                Description = "Gather 4 Forest Timber",
            },
            {
                Type = "CollectItem",
                Target = "stone",
                RequiredCount = 2,
                Description = "Gather 2 River Stone",
            },
            {
                Type = "Interact",
                Target = "SafeHaven_CentralBeacon",
                RequiredCount = 1,
                Description = "Repair and Ignite the Central Beacon",
            },
        },
        Rewards = {
            XP = 150,
            ForestCoins = 100,
            AncientTokens = 1,
        },
        IsRepeatable = false,
    },
    q_archive_puzzle = {
        QuestId = "q_archive_puzzle",
        Title = "The Sealed Archive",
        Description = "In the Abandoned Village, light the three Keeper Lanterns in the sacred sequence (Root, Ember, Echo) to unlock the Keeper Archive.",
        Category = "Mystery",
        Prerequisites = { "q_investigate_village" },
        Objectives = {
            {
                Type = "Interact",
                Target = "ArchivePuzzle",
                RequiredCount = 1,
                Description = "Solve the Three Lantern Archive Puzzle",
            },
            {
                Type = "CollectClue",
                Target = "mira_vale_record",
                RequiredCount = 1,
                Description = "Recover Mira Vale's Final Record",
            },
        },
        Rewards = {
            XP = 300,
            ForestCoins = 150,
            AncientTokens = 3,
        },
        IsRepeatable = false,
    },
    q_whispering_woods = {
        QuestId = "q_whispering_woods",
        Title = "The Ravine Crossing",
        Description = "Cross the fallen timber bridge across Creek Ravine and discover the ancient Split Oak landmark.",
        Category = "Exploration",
        Prerequisites = { "q_first_steps" },
        Objectives = {
            {
                Type = "DiscoverLocation",
                Target = "Split Oak Landmark",
                RequiredCount = 1,
                Description = "Discover the Split Oak Landmark",
            },
        },
        Rewards = {
            XP = 150,
            ForestCoins = 75,
            AncientTokens = 1,
        },
        IsRepeatable = false,
    },
    q_helping_hand = {
        QuestId = "q_helping_hand",
        Title = "Comrades in the Mist",
        Description = "Revive a fallen explorer who was downed in the wilderness.",
        Category = "Survival",
        Prerequisites = {},
        Objectives = {
            {
                Type = "RevivePlayer",
                Target = "AnyPlayer",
                RequiredCount = 1,
                Description = "Successfully revive 1 teammate",
            },
        },
        Rewards = {
            XP = 150,
            ForestCoins = 75,
            AncientTokens = 1,
        },
        IsRepeatable = true,
    },
    q_investigate_village = {
        QuestId = "q_investigate_village",
        Title = "Echoes of the Past",
        Description = "Cross the Old Stone Bridge and investigate the Abandoned Village square.",
        Category = "Mystery",
        Prerequisites = { "q_prepare_for_night" },
        Objectives = {
            {
                Type = "DiscoverLocation",
                Target = "AbandonedVillageSquare",
                RequiredCount = 1,
                Description = "Discover the Abandoned Village square",
            },
        },
        Rewards = {
            XP = 200,
            ForestCoins = 100,
            AncientTokens = 2,
        },
        IsRepeatable = false,
    },
    q_ancient_seals = {
        QuestId = "q_ancient_seals",
        Title = "Shatter the Corrupted Ward",
        Description = "Venture to Ancient Grounds and channel all 5 Megalith Seals to expose the Forest Guardian.",
        Category = "Mystery",
        Prerequisites = { "q_investigate_village" },
        Objectives = {
            {
                Type = "Interact",
                Target = "AncientSeal",
                RequiredCount = 5,
                Description = "Channel 5 Ancient Megalith Seals",
            },
        },
        Rewards = {
            XP = 500,
            ForestCoins = 250,
            AncientTokens = 5,
        },
        IsRepeatable = false,
    },
}

return QuestDefinitions
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "WorldInteractionService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    WorldInteractionService.lua
    Server-authoritative controller for narrative and landmark world interactions in The Forgotten Forest:
    1. Safe Haven Central Beacon (Repair with 4 wood, 2 stone -> Active state with amber aura)
    2. Abandoned Village Three Lantern Archive Puzzle (Root -> Ember -> Echo -> Unlocks Archive Vault)
    3. Village Clock Tower Gear Restoration (Requires clock_gear -> Chime sound & progress)
    4. Watchtower Telescope (Discovers distant valley landmarks on Survey Map)
    Implements The_Forgotten_Forest_Complete_Experience_Bible.md Sections 4.1, 4.3, 9, and 12.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local WorldInteractionService = {}
WorldInteractionService.__index = WorldInteractionService

local _inventoryService: any = nil
local _questService: any = nil
local _progressionService: any = nil
local _initialized = false

-- State tracking
local _beaconRepaired = false
local _archiveLanternSequence: { string } = {}
local _archiveUnlocked = false
local _clockTowerRepaired = false

local CANONICAL_LANTERN_ORDER = { "Root", "Ember", "Echo" }

function WorldInteractionService.Init(dependencies: { [string]: any })
    print("[WorldInteractionService] Initializing world interaction and puzzle director...")
    _inventoryService = dependencies["InventoryService"]
    _questService = dependencies["QuestService"]
    _progressionService = dependencies["ProgressionService"]
    _initialized = true
end

function WorldInteractionService.Start()
    print("[WorldInteractionService] Starting listeners on world landmarks...")
    task.defer(function()
        task.wait(1.0)
        WorldInteractionService.SetupBeaconInteraction()
        WorldInteractionService.SetupArchivePuzzle()
        WorldInteractionService.SetupClockTowerInteraction()
        WorldInteractionService.SetupTelescopeInteraction()
    end)
end

----------------------------------------------------------------------
-- 1. Safe Haven Central Beacon
----------------------------------------------------------------------
function WorldInteractionService.SetupBeaconInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local beacon = interactables:FindFirstChild("SafeHaven_CentralBeacon")
    if not beacon then return end

    local prompt = beacon:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        WorldInteractionService.OnBeaconInteracted(player, beacon, prompt)
    end)
end

function WorldInteractionService.OnBeaconInteracted(player: Player, beacon: Instance, prompt: ProximityPrompt)
    if _beaconRepaired then
        -- Already active: warm yourself
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 15)
            end
        end
        return
    end

    -- Check ingredients: 4 wood, 2 stone
    if not _inventoryService then return end
    local woodCount = _inventoryService.GetItemCount(player, "wood")
    local stoneCount = _inventoryService.GetItemCount(player, "stone")

    if woodCount >= 4 and stoneCount >= 2 then
        -- Remove ingredients
        _inventoryService.RemoveItem(player, "wood", 4)
        _inventoryService.RemoveItem(player, "stone", 2)

        _beaconRepaired = true
        beacon:SetAttribute("State", "Active")
        prompt.ActionText = "Warm Yourself by Beacon"
        prompt.HoldDuration = 0.5

        -- Ignite Beacon Core visually
        local core = beacon:FindFirstChild("BeaconCore", true) :: BasePart?
        if core then
            core.Material = Enum.Material.Neon
            core.Color = Color3.fromRGB(255, 180, 50)
            local light = core:FindFirstChildOfClass("PointLight")
            if not light then
                light = Instance.new("PointLight")
                light.Parent = core
            end
            light.Color = Color3.fromRGB(255, 190, 80)
            light.Range = 60
            light.Brightness = 3.5
        end

        -- Award player
        if _progressionService then
            _progressionService.AwardXP(player, 150)
        end
        if _questService then
            _questService.OnCustomEvent(player, "Interact", "SafeHaven_CentralBeacon")
        end

        print(string.format("[WorldInteractionService] Player %s repaired Safe Haven Central Beacon! Camp perimeter fortified.", player.Name))
    else
        -- Notify player of requirements
        print(string.format("[WorldInteractionService] %s needs 4 wood, 2 stone to repair the Beacon (Has: %d wood, %d stone)", player.Name, woodCount, stoneCount))
    end
end

----------------------------------------------------------------------
-- 2. Abandoned Village Three Lantern Archive Puzzle
----------------------------------------------------------------------
function WorldInteractionService.SetupArchivePuzzle()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local archive = interactables:FindFirstChild("Village_KeeperArchive")
    if not archive then return end

    for _, lanternName in ipairs({ "ArchiveLantern_Root", "ArchiveLantern_Ember", "ArchiveLantern_Echo" }) do
        local lantern = archive:FindFirstChild(lanternName, true)
        if lantern then
            local prompt = lantern:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local runeType = string.gsub(lanternName, "ArchiveLantern_", "")
                prompt.Triggered:Connect(function(player: Player)
                    WorldInteractionService.OnLanternTriggered(player, lantern, runeType, archive)
                end)
            end
        end
    end
end

function WorldInteractionService.OnLanternTriggered(player: Player, lantern: Instance, runeType: string, archive: Instance)
    if _archiveUnlocked then return end

    -- Light up this lantern
    local flame = lantern:FindFirstChild("LanternFlame", true) :: BasePart?
    if flame then
        flame.Material = Enum.Material.Neon
        flame.Color = Color3.fromRGB(80, 220, 255)
    end

    table.insert(_archiveLanternSequence, runeType)
    local stepIndex = #_archiveLanternSequence

    -- Check if step is correct
    if CANONICAL_LANTERN_ORDER[stepIndex] == runeType then
        print(string.format("[ArchivePuzzle] Correct step %d: %s by %s", stepIndex, runeType, player.Name))
        if stepIndex == #CANONICAL_LANTERN_ORDER then
            -- Puzzle Solved!
            _archiveUnlocked = true
            print("[ArchivePuzzle] All three lanterns lit in sacred order! Archive Vault unlocked.")
            
            -- Open Vault Door
            local vaultDoor = archive:FindFirstChild("VaultDoor", true) :: BasePart?
            if vaultDoor then
                vaultDoor.Transparency = 0.8
                vaultDoor.CanCollide = false
            end

            if _progressionService then
                _progressionService.AwardXP(player, 300)
            end
            if _questService then
                _questService.OnCustomEvent(player, "Interact", "ArchivePuzzle")
            end
        end
    else
        -- Wrong sequence: reset after 1.5 seconds
        print(string.format("[ArchivePuzzle] Incorrect lantern sequence at step %d! Resetting...", stepIndex))
        task.delay(1.5, function()
            _archiveLanternSequence = {}
            for _, name in ipairs({ "ArchiveLantern_Root", "ArchiveLantern_Ember", "ArchiveLantern_Echo" }) do
                local l = archive:FindFirstChild(name, true)
                if l then
                    local f = l:FindFirstChild("LanternFlame", true) :: BasePart?
                    if f then
                        f.Material = Enum.Material.Glass
                        f.Color = Color3.fromRGB(60, 60, 60)
                    end
                end
            end
        end)
    end
end

----------------------------------------------------------------------
-- 3. Village Clock Tower Gear Restoration
----------------------------------------------------------------------
function WorldInteractionService.SetupClockTowerInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local clockTower = interactables:FindFirstChild("Village_ClockTower_48")
    if not clockTower then return end

    local prompt = clockTower:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        if _clockTowerRepaired then return end

        if _inventoryService and _inventoryService.GetItemCount(player, "clock_gear") >= 1 then
            _inventoryService.RemoveItem(player, "clock_gear", 1)
            _clockTowerRepaired = true
            prompt.ActionText = "Inspect Restored Clock Mechanism"
            prompt.HoldDuration = 0.5

            local clockFace = clockTower:FindFirstChild("ClockFace", true) :: BasePart?
            if clockFace then
                clockFace.Material = Enum.Material.Neon
                clockFace.Color = Color3.fromRGB(255, 230, 150)
            end

            if _progressionService then
                _progressionService.AwardXP(player, 200)
            end
            print(string.format("[WorldInteractionService] Player %s restored the Village Clock Tower escapement gear!", player.Name))
        else
            print(string.format("[WorldInteractionService] Player %s needs a Brass Clock Gear to repair the clock mechanism.", player.Name))
        end
    end)
end

----------------------------------------------------------------------
-- 4. Watchtower Telescope Landmark Discovery
----------------------------------------------------------------------
function WorldInteractionService.SetupTelescopeInteraction()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    if not tffWorld then return end
    local interactables = tffWorld:FindFirstChild("Interactables")
    if not interactables then return end

    local telescope = interactables:FindFirstChild("Prop_BrassTelescope", true)
    if not telescope then return end

    local prompt = telescope:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        if _progressionService then
            _progressionService.AwardXP(player, 50)
        end
        print(string.format("[WorldInteractionService] Player %s surveyed the valley landmarks through the Watchtower Telescope!", player.Name))
    end)
end

return WorldInteractionService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Bootstrap"}, class = "Script", source = [=====[--!strict
--[[
    Bootstrap.server.lua
    Master server bootstrap for The Forgotten Forest.
    Initializes dependencies, sets up network remotes, and starts core gameplay services.
]]

print("==================================================")
print("  THE FORGOTTEN FOREST — SERVER INITIALIZATION   ")
print("==================================================")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- 1. Ensure network remotes exist
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
RemoteRegistry.GetOrCreateRemotesFolder()

-- Create all standard events
for _, eventName in pairs(RemoteRegistry.Events) do
    RemoteRegistry.GetRemoteEvent(eventName)
end

-- Create all standard functions
for _, funcName in pairs(RemoteRegistry.Functions) do
    RemoteRegistry.GetRemoteFunction(funcName)
end

-- 2. Load service modules
local ServicesFolder = ServerScriptService.TFFServer.Services

local ProfileService = require(ServicesFolder.ProfileService)
local WorldService = require(ServicesFolder.WorldService)
local TimeCycleService = require(ServicesFolder.TimeCycleService)
local WeatherService = require(ServicesFolder.WeatherService)
local SurvivalService = require(ServicesFolder.SurvivalService)
local InventoryService = require(ServicesFolder.InventoryService)
local CraftingService = require(ServicesFolder.CraftingService)
local ProgressionService = require(ServicesFolder.ProgressionService)
local RewardService = require(ServicesFolder.RewardService)
local ResourceService = require(ServicesFolder.ResourceService)
local QuestService = require(ServicesFolder.QuestService)
local CombatService = require(ServicesFolder.CombatService)
local CreatureService = require(ServicesFolder.CreatureService)
local EventService = require(ServicesFolder.EventService)
local BossEncounterService = require(ServicesFolder.BossEncounterService)
local PlayerService = require(ServicesFolder.PlayerService)
local WorldInteractionService = require(ServicesFolder.WorldInteractionService)

local services = {
    ProfileService = ProfileService,
    WorldService = WorldService,
    TimeCycleService = TimeCycleService,
    WeatherService = WeatherService,
    SurvivalService = SurvivalService,
    InventoryService = InventoryService,
    CraftingService = CraftingService,
    ProgressionService = ProgressionService,
    RewardService = RewardService,
    ResourceService = ResourceService,
    QuestService = QuestService,
    CombatService = CombatService,
    CreatureService = CreatureService,
    EventService = EventService,
    BossEncounterService = BossEncounterService,
    PlayerService = PlayerService,
    WorldInteractionService = WorldInteractionService,
}

local orderedServiceKeys = {
    "WorldService",
    "ProfileService",
    "ProgressionService",
    "RewardService",
    "InventoryService",
    "WeatherService",
    "SurvivalService",
    "TimeCycleService",
    "ResourceService",
    "CraftingService",
    "CombatService",
    "CreatureService",
    "EventService",
    "BossEncounterService",
    "QuestService",
    "PlayerService",
    "WorldInteractionService",
}

-- 3. Phase 1: Initialize all services
print("[Bootstrap] Initializing services...")
for _, key in ipairs(orderedServiceKeys) do
    local service = services[key]
    if service and typeof(service.Init) == "function" then
        service.Init(services)
    end
end

-- 4. Phase 2: Start all services
print("[Bootstrap] Starting services...")
for _, key in ipairs(orderedServiceKeys) do
    local service = services[key]
    if service and typeof(service.Start) == "function" then
        service.Start()
    end
end

print("==================================================")
print("  THE FORGOTTEN FOREST — SERVER BOOTSTRAP READY   ")
print("==================================================")
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
    synced += 1
end
print(string.format("[SyncBible] Synced %d scripts into DataModel successfully.", synced))
return synced