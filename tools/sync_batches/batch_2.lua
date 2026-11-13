--!strict
-- Sync batch 2 of 4
local files = {
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "StoryDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    StoryDefinitions.lua
    Data catalog for Story Clues, Lore Records, and NPC Dialogues in The Forgotten Forest (v2.0).
    Implements Master Game Specification Section 2.3, 2.4, and 2.5.
]]

export type ClueDefinition = {
    ClueId: string,
    Title: string,
    Author: string,
    Region: string,
    Body: string,
    UnlockDiscovery: string?,
}

export type DialogueDefinition = {
    NPCId: string,
    DisplayName: string,
    Title: string,
    Greeting: string,
    Topics: { [string]: { prompt: string, response: string } },
}

local StoryDefinitions = {}

StoryDefinitions.Clues = {
    safe_haven_orders = {
        ClueId = "safe_haven_orders",
        Title = "Captain's Deployment Orders",
        Author = "Captain Roderick, Expedition Leader",
        Region = "Safe Haven",
        Body = "Expedition Order #12: Safe Haven basecamp established. Maintain the central beacon fire at all costs—the light field holds the perimeter intact against forest horrors. Do not cross the Creek Ravine into Whispering Woods without a torch, warm clothing, and defensive armaments.",
        UnlockDiscovery = "Safe Haven",
    },
    scout_journal = {
        ClueId = "scout_journal",
        Title = "Scout's Final Log",
        Author = "Scout Kaelen",
        Region = "Whispering Woods",
        Body = "Day 4: We reached the Split Oak. Its bark hums with low vibrations. Vane heard whispers in the fog that sounded like his sister's voice. We made camp, but something tall stood on Watcher's Bluff watching our campfire. It had no face, only hollow shadows. If you find this, turn back.",
        UnlockDiscovery = "Whispering Woods",
    },
    split_oak_carving = {
        ClueId = "split_oak_carving",
        Title = "Keeper Tree Inscription",
        Author = "Ancient Keeper Runic Text",
        Region = "Whispering Woods",
        Body = "'When the five seals slumber, the Heartwood awakens in wrath. The roots drink the tears of the forgotten. Let the Keepers beware: touch not the pulsing core unless the five ritual plinths burn with attunement.'",
        UnlockDiscovery = "Split Oak Landmark",
    },
    village_ledger = {
        ClueId = "village_ledger",
        Title = "Town Archive Ledger",
        Author = "Archivist Helen",
        Region = "Abandoned Village",
        Body = "14th Frostfall: The council voted unanimously. We barred the main gate from the inside. The Stalkers had already reached the outer street. The clock tower was stopped at midnight to silence its chime. We buried the Keeper records under the cobblestones. The Heart Below is awake.",
        UnlockDiscovery = "Abandoned Village",
    },
    miner_warning = {
        ClueId = "miner_warning",
        Title = "Miner's Evacuation Notice",
        Author = "Chief Miner Torvald",
        Region = "Crystal Caverns",
        Body = "EMERGENCY EVACUATION: Gorge Shaft 3 is condemned. Resonant frequency from the northern plateau shattered three timber supports. The glowing crystals are growing aggressively into the rail tracks. Leave your heavy tools and withdraw to the village gate immediately.",
        UnlockDiscovery = "Crystal Caverns",
    },
    ancient_tablet = {
        ClueId = "ancient_tablet",
        Title = "Seal of the Forest Guardian",
        Author = "First Keepers of the Valley",
        Region = "Ancient Grounds",
        Body = "'Before you lies the Elder Heartwood. The Forest Guardian slumbers within its hollow core, bound by the five Megalith Seals. To defeat the corrupted nature within, all five seals must be channeled to strip its invulnerability ward.'",
        UnlockDiscovery = "Ancient Grounds",
    },
}

StoryDefinitions.Dialogues = {
    cartographer = {
        NPCId = "cartographer",
        DisplayName = "Alden",
        Title = "The Valley Cartographer",
        Greeting = "Greetings, explorer. The valley stretches over 3,300 studs to the northern basalt peaks. Press [M] at any time to consult your valley map.",
        Topics = {
            ["valley"] = {
                prompt = "Tell me about the valley layout.",
                response = "Safe Haven sits in the sheltered south. To the north lies Whispering Woods, bisected by the creek. Cross the fallen log to reach the Split Oak and Silent Pond. Beyond the gorge lies the Abandoned Village and Crystal Caverns.",
            },
            ["landmarks"] = {
                prompt = "What landmarks should I look for?",
                response = "Watch for the massive Split Oak—its canopy can be seen over the mist. Further north, the Village Clock Tower stands tall over ruined cottages. And deep below, the Crystal Grotto shines with brilliant cyan and amethyst light.",
            },
        },
    },
    medic = {
        NPCId = "medic",
        DisplayName = "Mara",
        Title = "Field Medic",
        Greeting = "Welcome back alive. The cold and damp in this valley are just as lethal as the creatures. Take care of yourself out there.",
        Topics = {
            ["warmth"] = {
                prompt = "How does Warmth work?",
                response = "When cold rain or dense fog rolls in, your warmth drops rapidly. If it reaches zero, hypothermia sets in, draining your health. Stand near our beacon fire or carry a lit torch to restore warmth.",
            },
            ["healing"] = {
                prompt = "How do I brew healing salves?",
                response = "Gather wild soothing moss near damp logs and draw spring water from the creek. Combine them at the workbench into Herbal Salves—they heal 40 health over a few seconds.",
            },
        },
    },
    old_keeper = {
        NPCId = "old_keeper",
        DisplayName = "The Old Keeper",
        Title = "Hermit of the Ruins",
        Greeting = "You walk where the living should not tread. The clock stopped long ago, traveler... yet the roots keep spreading.",
        Topics = {
            ["guardian"] = {
                prompt = "What is the Forest Guardian?",
                response = "It was the ancient shepherd of this forest, born of the Elder Tree. When the seals weakened, corruption took root in its core. Now it strikes with massive root sweeps and shockwaves.",
            },
            ["seals"] = {
                prompt = "How do I defeat it?",
                response = "Its core is protected by an invulnerability ward. You must enter the Ancient Grounds ritual circle and channel the 5 Ancient Seals. Only when all five are ignited will the Crystal Heart be exposed to your blades!",
            },
        },
    },
}

return StoryDefinitions
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "WeaponDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    WeaponDefinitions.lua
    Data catalog for all weapons and offensive tools in The Forgotten Forest (v2.0).
    Directly reflects Master Game Specification Section 6.1.
]]

local Types = require(script.Parent.Parent.Types.Types)

local WeaponDefinitions: { [string]: Types.WeaponDefinition } = {
    field_knife = {
        WeaponId = "field_knife",
        DisplayName = "Field Knife",
        Role = "Fast starter defence",
        BaseDamage = 12,
        Range = 5.0,
        Cooldown = 0.55,
        StaminaCost = 8,
        IsRanged = false,
        EffectiveAgainst = "Stalker",
        Special = "Fast, low stagger, cannot harvest trees or ore",
    },
    wooden_spear = {
        WeaponId = "wooden_spear",
        DisplayName = "Wooden Spear",
        Role = "Reach and control",
        BaseDamage = 18,
        Range = 9.0,
        Cooldown = 1.0,
        StaminaCost = 14,
        IsRanged = false,
        EffectiveAgainst = "Stalker",
        Special = "Longer reach; can interrupt basic creature attack; slower recovery",
    },
    hatchet = {
        WeaponId = "hatchet",
        DisplayName = "Forged Hatchet",
        Role = "Tool and weapon",
        BaseDamage = 20,
        Range = 6.0,
        Cooldown = 1.1,
        StaminaCost = 12,
        IsRanged = false,
        EffectiveAgainst = "Wood",
        Special = "Bonus vs wooden obstacles; primary wood-harvesting tool",
    },
    keeper_blade = {
        WeaponId = "keeper_blade",
        DisplayName = "Keeper Blade",
        Role = "Advanced melee",
        BaseDamage = 28,
        Range = 6.5,
        Cooldown = 0.8,
        StaminaCost = 16,
        IsRanged = false,
        EffectiveAgainst = "Supernatural",
        Special = "Higher stagger vs supernatural entities; resonates near Keeper mechanisms",
    },
    hunting_bow = {
        WeaponId = "hunting_bow",
        DisplayName = "Hunting Bow",
        Role = "Quiet ranged",
        BaseDamage = 22,
        Range = 120.0,
        Cooldown = 1.3,
        StaminaCost = 18,
        IsRanged = true,
        EffectiveAgainst = "Ranged",
        Special = "Quiet ranged option; projectile travel and gravity drop; requires arrows",
        ProjectileSpeed = 95.0,
        GravityMultiplier = 0.45,
        AmmoItemId = "arrow",
    },
    flare_launcher = {
        WeaponId = "flare_launcher",
        DisplayName = "Flare Launcher",
        Role = "Utility defence",
        BaseDamage = 5,
        Range = 85.0,
        Cooldown = 3.0,
        StaminaCost = 10,
        IsRanged = true,
        EffectiveAgainst = "Darkness",
        Special = "Illuminates dark areas and briefly disrupts selected creatures; cannot permanently stun bosses",
        ProjectileSpeed = 70.0,
        GravityMultiplier = 0.35,
        AmmoItemId = "signal_flare",
    },
    pickaxe = {
        WeaponId = "pickaxe",
        DisplayName = "Iron Pickaxe",
        Role = "Mining tool and blunt weapon",
        BaseDamage = 15,
        Range = 5.5,
        Cooldown = 1.05,
        StaminaCost = 12,
        IsRanged = false,
        EffectiveAgainst = "Stone",
        Special = "Primary stone, metal, and crystal harvesting tool",
    },
}

return WeaponDefinitions
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Types", "Types"}, class = "ModuleScript", source = [=====[--!strict
--[[
    Types.lua
    Core type definitions for The Forgotten Forest.
]]

export type TimePhase = "Morning" | "Afternoon" | "Sunset" | "Night" | "Dawn"

export type PlayerStats = {
    Health: number,
    MaxHealth: number,
    Stamina: number,
    MaxStamina: number,
    Warmth: number,
    MaxWarmth: number,
    Sanity: number,
    MaxSanity: number,
    IsSprinting: boolean,
    IsDowned: boolean,
    DownedTimer: number,
}

export type InventoryItem = {
    ItemId: string,
    Quantity: number,
    CustomData: { [string]: any }?,
}

export type ItemDefinition = {
    ItemId: string,
    DisplayName: string,
    Description: string,
    Category: "Resource" | "Consumable" | "Tool" | "Equipment" | "Structure" | "Quest",
    Rarity: "Common" | "Uncommon" | "Rare" | "Epic",
    StackLimit: number,
    IsQuestProtected: boolean,
    IsTradeable: boolean,
    IconAsset: string?,
}

export type RecipeIngredient = {
    ItemId: string,
    Quantity: number,
}

export type RecipeDefinition = {
    RecipeId: string,
    DisplayName: string,
    Description: string,
    OutputItemId: string,
    OutputQuantity: number,
    Ingredients: { RecipeIngredient },
    StationRequired: string?,
    CraftDuration: number,
    UnlockLevel: number?,
}

export type PlayerProfile = {
    schemaVersion: number,
    level: number,
    xp: number,
    forestCoins: number,
    ancientTokens: number,
    inventory: { InventoryItem },
    equipment: { [string]: string },
    unlockedRecipes: { [string]: boolean },
    completedQuests: { [string]: boolean },
    activeQuests: { [string]: any },
    achievements: { [string]: boolean },
    discoveries: { [string]: boolean },
    cosmetics: { [string]: boolean },
    settings: {
        reducedEffects: boolean,
        cameraShake: boolean,
    },
    lastSaveUnix: number,
}

export type CreatureState =
    | "Dormant"
    | "Idle"
    | "Patrol"
    | "Investigate"
    | "Chase"
    | "Windup"
    | "Attack"
    | "Recover"
    | "Stagger"
    | "Return"
    | "Despawn"

export type WeaponDefinition = {
    WeaponId: string,
    DisplayName: string,
    Role: string,
    BaseDamage: number,
    Range: number,
    Cooldown: number,
    StaminaCost: number,
    IsRanged: boolean,
    EffectiveAgainst: string?,
    Special: string,
    ProjectileSpeed: number?,
    GravityMultiplier: number?,
    AmmoItemId: string?,
}

export type CreatureDefinition = {
    Id: string,
    DisplayName: string,
    MaxHealth: number,
    ChaseSpeed: number,
    PatrolSpeed: number,
    DetectionRadius: number,
    AttackRange: number,
    AttackDamage: number,
    AttackCooldown: number,
    WindupDuration: number,
    LeashRange: number,
    States: { CreatureState },
}

return {}
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Util", "Signal"}, class = "ModuleScript", source = [=====[--!strict
--[[
    Signal.lua
    Lightweight, fast, typed custom event implementation.
]]

type Connection = {
    Disconnect: (self: Connection) -> (),
    Connected: boolean,
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    Wait: (self: Signal<T...>) -> T...,
    Destroy: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return (self :: any) :: Signal<T...>
end

function Signal:Connect(fn: (...any) -> ()): Connection
    local listeners = self._listeners
    if not listeners then
        return { Disconnect = function() end, Connected = false }
    end

    local connection = {
        _fn = fn,
        Connected = true,
    }

    function connection:Disconnect()
        if not self.Connected then return end
        self.Connected = false
        for i, conn in ipairs(listeners) do
            if conn == self then
                table.remove(listeners, i)
                break
            end
        end
    end

    table.insert(listeners, connection)
    return connection
end

function Signal:Once(fn: (...any) -> ()): Connection
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        fn(...)
    end)
    return conn
end

function Signal:Fire(...: any)
    local listeners = self._listeners
    if not listeners then return end

    -- Clone listeners table so handlers that disconnect during fire don't affect iteration
    local copy = table.clone(listeners)
    for _, conn in ipairs(copy) do
        if conn.Connected then
            task.spawn(conn._fn, ...)
        end
    end
end

function Signal:Wait(): ...any
    local thread = coroutine.running()
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    if self._listeners then
        table.clear(self._listeners)
        self._listeners = nil
    end
end

return Signal
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
    { path = {"ServerScriptService", "TFFServer", "Services", "BossEncounterService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    BossEncounterService.lua
    Server-authoritative multi-phase Boss Combat Director for the Forest Guardian.
    Implements Master Game Specification Section 4.5, 7.4, and Chapter 4 Endgame.
    
    Phases:
    1. Awakening (Teal surge, health sync, ritual initiation)
    2. Root Sweep (Telegraphed ground shockwaves with jump/dodge counterplay)
    3. Guardian Pulse & Root Barrier (Invulnerability shield; players must channel 5 Ancient Seals)
    4. Exposed Core (Vulnerable damage window to strike the pulsing Crystal Heart)
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)

export type BossPhase = "Dormant" | "Awakening" | "RootSweep" | "BarrierPhase" | "ExposedCore" | "Defeated"

local BossEncounterService = {}
BossEncounterService.__index = BossEncounterService

local _rewardService: any = nil
local _progressionService: any = nil
local _survivalService: any = nil

local _currentPhase: BossPhase = "Dormant"
local _bossMaxHealth = 250
local _bossCurrentHealth = 250
local _activatedSealsCount = 0
local _phaseTimer = 0
local _arenaCenter = Vector3.new(0, 7.2, -2775)
local _arenaRadius = 110

local function getPlayersInArena(): { Player }
    local inArena: { Player } = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
            local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(_arenaCenter.X, 0, _arenaCenter.Z)).Magnitude
            if dist <= _arenaRadius then
                table.insert(inArena, player)
            end
        end
    end
    return inArena
end

local function syncBossHealth()
    local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
    if bossRemote then
        bossRemote:FireAllClients(_bossCurrentHealth, _bossMaxHealth, _currentPhase)
    end
end

function BossEncounterService.Init(dependencies: { [string]: any })
    print("[BossEncounterService] Initializing BossEncounterService v2.0...")
    _rewardService = dependencies.RewardService
    _progressionService = dependencies.ProgressionService
    _survivalService = dependencies.SurvivalService
end

function BossEncounterService.Start()
    print("[BossEncounterService] BossEncounterService started.")

    -- Connect Ancient Seal channel prompts
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            local prompt = seal and seal:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                prompt.Triggered:Connect(function(player: Player)
                    BossEncounterService.ChannelSeal(player, i)
                end)
            end
        end
    end

    -- Boss director heartbeat loop (runs every 1.0s)
    task.spawn(function()
        while true do
            task.wait(1.0)
            BossEncounterService.Tick()
        end
    end)
end

function BossEncounterService.Tick()
    local playersInArena = getPlayersInArena()

    if _currentPhase == "Dormant" then
        if #playersInArena > 0 then
            BossEncounterService.StartEncounter()
        end

    elseif _currentPhase == "Awakening" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "RootSweep" then
        _phaseTimer = _phaseTimer - 1
        -- Periodically spawn telegraphed root sweep wave
        if _phaseTimer % 4 == 0 then
            BossEncounterService.ExecuteRootSweep()
        end
        if _phaseTimer <= 0 then
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "BarrierPhase" then
        _phaseTimer = _phaseTimer - 1
        if _activatedSealsCount >= 5 then
            BossEncounterService.TransitionTo("ExposedCore")
        elseif _phaseTimer <= 0 then
            -- Reset seal timer and repeat root sweeps
            BossEncounterService.TransitionTo("RootSweep")
        end

    elseif _currentPhase == "ExposedCore" then
        _phaseTimer = _phaseTimer - 1
        -- Read health directly in case modified by player combat
        local tffWorld = Workspace:FindFirstChild("TFF_World")
        local map = tffWorld and tffWorld:FindFirstChild("Map")
        local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
        if heart then
            local hp = heart:GetAttribute("Health")
            if hp then _bossCurrentHealth = hp end
        end

        if _bossCurrentHealth <= 0 then
            BossEncounterService.TransitionTo("Defeated")
        elseif _phaseTimer <= 0 then
            -- Core closes, shield re-engages
            BossEncounterService.TransitionTo("BarrierPhase")
        end

    elseif _currentPhase == "Defeated" then
        _phaseTimer = _phaseTimer - 1
        if _phaseTimer <= 0 then
            -- Reset boss after victory
            _bossCurrentHealth = _bossMaxHealth
            _currentPhase = "Dormant"
            syncBossHealth()
        end
    end
end

function BossEncounterService.StartEncounter()
    _bossCurrentHealth = _bossMaxHealth
    _currentPhase = "Awakening"
    _phaseTimer = 5

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local heart = map and map:FindFirstChild("ForestGuardianCrystalHeart")
    if heart then
        heart:SetAttribute("Health", _bossMaxHealth)
        heart:SetAttribute("BossTarget", true)
    end

    syncBossHealth()

    local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
    if eventRemote then
        eventRemote:FireAllClients(
            "THE FOREST GUARDIAN AWAKENS",
            "Ancient corruption surges through the Elder Tree! Prepare for battle!",
            10
        )
    end
    print("[BossEncounterService] Forest Guardian encounter initiated!")
end

function BossEncounterService.TransitionTo(phase: BossPhase)
    _currentPhase = phase
    print("[BossEncounterService] Phase changed to: " .. phase)

    if phase == "RootSweep" then
        _phaseTimer = 16
        syncBossHealth()

    elseif phase == "BarrierPhase" then
        _phaseTimer = 40
        _activatedSealsCount = 0
        BossEncounterService.ResetSeals()
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "ROOT BARRIER ENGAGED",
                "The Guardian is shielded! Channel the 5 Ancient Seals to shatter the ward!",
                12
            )
        end

    elseif phase == "ExposedCore" then
        _phaseTimer = 30
        syncBossHealth()

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "CRYSTAL HEART EXPOSED",
                "The ward has shattered! Strike the pulsing Crystal Heart inside the Elder Tree!",
                30
            )
        end

    elseif phase == "Defeated" then
        _phaseTimer = 180
        syncBossHealth()

        -- Distribute grand rewards to all players in arena
        local players = getPlayersInArena()
        for _, player in ipairs(players) do
            if _rewardService then
                _rewardService.GrantReward(player, "boss_victory", {
                    ancientTokens = 20,
                    forestCoins = 200,
                    items = {
                        { ItemId = "keeper_blade", Quantity = 1 },
                        { ItemId = "crystal", Quantity = 4 },
                        { ItemId = "ancient_fragment", Quantity = 3 },
                    }
                })
            end
            if _progressionService then
                _progressionService.AddExperience(player, 150)
            end
        end

        local eventRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.WorldEventTriggered)
        if eventRemote then
            eventRemote:FireAllClients(
                "FOREST GUARDIAN PURIFIED",
                "The ancient corruption has receded. The Great Valley is saved!",
                20
            )
        end
    end
end

-- Execute telegraphed Root Sweep attack
function BossEncounterService.ExecuteRootSweep()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    if not map then return end

    -- Visual telegraph arc
    local sweepPart = Instance.new("Part")
    sweepPart.Name = "BossRootSweepTelegraph"
    sweepPart.Size = Vector3.new(160, 1.5, 12)
    sweepPart.CFrame = CFrame.new(_arenaCenter.X, 7.5, _arenaCenter.Z + math.random(-60, 60))
    sweepPart.Color = Color3.fromRGB(220, 50, 40)
    sweepPart.Material = Enum.Material.Neon
    sweepPart.Transparency = 0.5
    sweepPart.CanCollide = false
    sweepPart.Anchored = true
    sweepPart.Parent = map

    -- After 1.2s telegraph, root erupts and damages players inside the strip
    task.delay(1.2, function()
        if sweepPart.Parent then
            sweepPart.Color = Color3.fromRGB(75, 45, 25)
            sweepPart.Size = Vector3.new(160, 7, 12)
            sweepPart.Transparency = 0.0

            -- Check players within hitbox
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root then
                    local pPos = root.Position
                    local sPos = sweepPart.Position
                    if math.abs(pPos.X - sPos.X) < 80 and math.abs(pPos.Z - sPos.Z) < 8 and pPos.Y < (sPos.Y + 8) then
                        if _survivalService then
                            _survivalService.ApplyDamage(player, 22)
                        end
                    end
                end
            end

            task.delay(0.8, function()
                if sweepPart.Parent then sweepPart:Destroy() end
            end)
        end
    end)
end

-- Channel Ancient Seal during Barrier Phase
function BossEncounterService.ChannelSeal(player: Player, sealIndex: number)
    if _currentPhase ~= "BarrierPhase" then return end

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")
    local seal = interactables and interactables:FindFirstChild("AncientSeal_" .. sealIndex)
    if not seal or seal:GetAttribute("Activated") == true then return end

    seal:SetAttribute("Activated", true)
    _activatedSealsCount = _activatedSealsCount + 1

    -- Turn beam bright cyan
    local beam = map and map:FindFirstChild("SealLightBeam_" .. sealIndex)
    if beam and beam:IsA("BasePart") then
        beam.Color = Color3.fromRGB(0, 255, 230)
        beam.Transparency = 0.1
    end

    if _progressionService then
        _progressionService.AddExperience(player, 20)
    end

    print(string.format("[BossEncounterService] Seal %d channeled by %s (%d/5)", sealIndex, player.Name, _activatedSealsCount))

    if _activatedSealsCount >= 5 then
        BossEncounterService.TransitionTo("ExposedCore")
    end
end

function BossEncounterService.ResetSeals()
    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    local map = tffWorld and tffWorld:FindFirstChild("Map")

    if interactables then
        for i = 1, 5 do
            local seal = interactables:FindFirstChild("AncientSeal_" .. i)
            if seal then
                seal:SetAttribute("Activated", false)
            end
            local beam = map and map:FindFirstChild("SealLightBeam_" .. i)
            if beam and beam:IsA("BasePart") then
                beam.Color = Color3.fromRGB(0, 180, 160)
                beam.Transparency = 0.6
            end
        end
    end
end

return BossEncounterService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "CombatService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    CombatService.lua
    Server-authoritative combat, weapon hit validation, attack cooldowns,
    stamina consumption, projectile/melee verification, and damage application.
    Implements Master Game Specification Section 6.1 and 6.2.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local WeaponDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.WeaponDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local Types = require(ReplicatedStorage.TFF.Shared.Types.Types)

local CombatService = {}
CombatService.__index = CombatService

local _survivalService: any = nil
local _inventoryService: any = nil
local _progressionService: any = nil
local _creatureService: any = nil
local _resourceService: any = nil

-- Player cooldown tracking: [Player] -> last attack os.clock()
local _playerLastAttack: { [Player]: number } = {}

-- Unarmed fallback definition
local UNARMED_DEF: Types.WeaponDefinition = {
    WeaponId = "unarmed",
    DisplayName = "Fists",
    Role = "Unarmed combat",
    BaseDamage = 6,
    Range = 4.5,
    Cooldown = 0.5,
    StaminaCost = 5,
    IsRanged = false,
    Special = "Basic punch",
}

function CombatService.Init(dependencies: { [string]: any })
    print("[CombatService] Initializing CombatService v2.0...")
    _survivalService = dependencies.SurvivalService
    _inventoryService = dependencies.InventoryService
    _progressionService = dependencies.ProgressionService
    _creatureService = dependencies.CreatureService
    _resourceService = dependencies.ResourceService

    -- Connect Client Attack Request
    local attackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestAttack)
    if attackRemote then
        attackRemote.OnServerEvent:Connect(function(player: Player, targetInstance: Instance?, hitPosition: Vector3?, attackDirection: Vector3?)
            CombatService.ProcessPlayerAttack(player, targetInstance, hitPosition, attackDirection)
        end)
    end
end

function CombatService.Start()
    print("[CombatService] CombatService started with full Player Combat Pipeline.")
    Players.PlayerRemoving:Connect(function(player)
        _playerLastAttack[player] = nil
    end)
end

-- Get currently held weapon or tool definition
function CombatService.GetEquippedWeapon(player: Player): Types.WeaponDefinition
    local char = player.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool then
            local def = WeaponDefinitions[tool.Name]
            if def then return def end
        end
    end
    return UNARMED_DEF
end

-- Process player attack request
function CombatService.ProcessPlayerAttack(player: Player, targetInstance: Instance?, hitPosition: Vector3?, attackDirection: Vector3?): boolean
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?
    if not root or not humanoid or humanoid.Health <= 0 then
        return false
    end

    -- Verify not downed
    if _survivalService then
        local stats = _survivalService.GetStats(player)
        if stats and stats.IsDowned then return false end
    end

    local weapon = CombatService.GetEquippedWeapon(player)
    local now = os.clock()
    local lastAttack = _playerLastAttack[player] or 0

    -- Cooldown verification
    if (now - lastAttack) < (weapon.Cooldown - 0.05) then
        return false
    end

    -- Stamina verification & consumption
    if _survivalService then
        local currentStats = _survivalService.GetStats(player)
        if currentStats and currentStats.Stamina < weapon.StaminaCost then
            return false
        end
        _survivalService.DrainStamina(player, weapon.StaminaCost)
    end

    _playerLastAttack[player] = now

    local feedbackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.CombatHitFeedback)

    -- If target is nil, handle as swing / miss
    if not targetInstance then
        if feedbackRemote then
            local missPos = root.Position + root.CFrame.LookVector * weapon.Range
            feedbackRemote:FireClient(player, missPos, 0, false, "miss", "")
        end
        return true
    end

    -- Target resolution: find humanoid or model
    local targetModel = targetInstance:FindFirstAncestorOfClass("Model")
    local targetHumanoid = targetModel and targetModel:FindFirstChildWhichIsA("Humanoid")
    local targetRoot = targetModel and targetModel:FindFirstChild("HumanoidRootPart") :: BasePart?

    -- 1. Creature Attack Resolution
    if targetModel and targetHumanoid and targetHumanoid.Health > 0 and targetModel ~= char then
        local targetPos = targetRoot and targetRoot.Position or targetModel:GetPivot().Position
        local dist = (root.Position - targetPos).Magnitude

        -- Range check with server latency buffer
        local maxAllowedRange = weapon.IsRanged and (weapon.Range + 15) or (weapon.Range + 4)
        if dist > maxAllowedRange then
            if feedbackRemote then
                feedbackRemote:FireClient(player, targetPos, 0, false, "miss", targetModel.Name)
            end
            return false
        end

        -- Calculate Damage & Crit
        local damage = weapon.BaseDamage
        local isCrit = math.random() < 0.15
        if isCrit then
            damage = math.floor(damage * 1.5)
        end

        -- Weapon bonuses against specific creature archetypes
        if weapon.WeaponId == "wooden_spear" and targetModel.Name:lower():find("stalker") then
            -- Spear interrupt / stagger
            damage = damage + 4
        elseif weapon.WeaponId == "keeper_blade" and (targetModel.Name:lower():find("guardian") or targetModel.Name:lower():find("mimic")) then
            damage = damage + 8
        end

        targetHumanoid:TakeDamage(damage)

        -- Grant XP
        if _progressionService then
            _progressionService.AddExperience(player, 12)
        end

        -- Fire hit feedback to attacker
        if feedbackRemote then
            feedbackRemote:FireClient(player, targetPos, damage, isCrit, "hit", targetModel.Name)
        end
        return true
    end

    -- 2. Boss Arena Core / Crystal Heart Resolution
    if targetInstance.Name == "ForestGuardianCrystalHeart" or targetInstance:GetAttribute("BossTarget") then
        local heartPos = (targetInstance:IsA("BasePart") and targetInstance.Position) or root.Position
        local dist = (root.Position - heartPos).Magnitude
        if dist <= (weapon.Range + 6) then
            local damage = weapon.BaseDamage
            local isCrit = math.random() < 0.2
            if isCrit then damage = math.floor(damage * 1.5) end

            local currentHp = targetInstance:GetAttribute("Health") or 250
            local newHp = math.max(0, currentHp - damage)
            targetInstance:SetAttribute("Health", newHp)

            local bossRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.BossHealthUpdated)
            if bossRemote then
                bossRemote:FireAllClients(newHp, 250, "Exposed Core")
            end

            if feedbackRemote then
                feedbackRemote:FireClient(player, heartPos, damage, isCrit, "hit", "Forest Guardian")
            end
            return true
        end
    end

    -- 3. Resource Node Chop / Mine with appropriate tool
    if targetInstance:IsA("BasePart") and CollectionService:HasTag(targetInstance, "TFF_ResourceNode") then
        local nodePos = targetInstance.Position
        local dist = (root.Position - nodePos).Magnitude
        if dist <= (weapon.Range + 4) then
            local resType = targetInstance:GetAttribute("ResourceType")
            local effTool = targetInstance:GetAttribute("EffectiveTool")

            if effTool and (weapon.WeaponId:lower():find(effTool:lower()) or weapon.DisplayName:lower():find(effTool:lower())) then
                if _resourceService then
                    local nodeId = targetInstance:GetAttribute("NodeId") or targetInstance.Name
                    _resourceService.TryGather(player, nodeId)
                end
                if feedbackRemote then
                    feedbackRemote:FireClient(player, nodePos, 0, false, "resource", resType or "Resource")
                end
                return true
            else
                if feedbackRemote then
                    feedbackRemote:FireClient(player, nodePos, 0, false, "blocked", "Requires " .. tostring(effTool))
                end
                return false
            end
        end
    end

    -- Fallback miss
    if feedbackRemote then
        local missPos = hitPosition or (root.Position + root.CFrame.LookVector * weapon.Range)
        feedbackRemote:FireClient(player, missPos, 0, false, "miss", "")
    end
    return true
end

-- Validate and apply monster/creature attack to player (server-authoritative)
function CombatService.ValidateAndApplyAttack(attacker: Model, target: Model, damage: number, maxRange: number): boolean
    local attackerRoot = attacker:FindFirstChild("HumanoidRootPart") :: BasePart?
    local targetRoot = target:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not attackerRoot or not targetRoot then return false end

    local dist = (attackerRoot.Position - targetRoot.Position).Magnitude
    if dist > maxRange then
        return false
    end

    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if targetPlayer and _survivalService then
        _survivalService.ApplyDamage(targetPlayer, damage)
        return true
    end

    local targetHumanoid = target:FindFirstChild("Humanoid") :: Humanoid?
    if targetHumanoid then
        targetHumanoid:TakeDamage(damage)
        return true
    end

    return false
end

return CombatService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "CraftingService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    CraftingService.lua
    Server-authoritative crafting system.
    Validates recipes, workbench station proximity, ingredients, and executes atomic transactions.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)
local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CraftingService = {}
CraftingService.__index = CraftingService

local _inventoryService: any = nil
local _profileService: any = nil
local _survivalService: any = nil

local function isNearStation(player: Player, stationName: string): boolean
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return false end

    for _, inst in ipairs(CollectionService:GetTagged("TFF_Interactable")) do
        if inst:IsA("BasePart") and inst:GetAttribute("Station") == stationName then
            local dist = (root.Position - inst.Position).Magnitude
            if dist <= BalanceConfig.DefaultInteractionRange + 4 then
                return true
            end
        end
    end
    return false
end

function CraftingService.Init(dependencies: { [string]: any })
    print("[CraftingService] Initializing CraftingService...")
    _inventoryService = dependencies.InventoryService
    _profileService = dependencies.ProfileService
    _survivalService = dependencies.SurvivalService

    local craftRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestCraft)
    if craftRemote then
        craftRemote.OnServerEvent:Connect(function(player: Player, recipeId: string, quantity: number)
            CraftingService.TryCraft(player, recipeId, quantity or 1)
        end)
    end
end

function CraftingService.Start()
    print("[CraftingService] CraftingService started.")
end

function CraftingService.TryCraft(player: Player, recipeId: string, quantity: number): boolean
    if quantity <= 0 or quantity > 10 then return false end
    local recipe = RecipeDefinitions[recipeId]
    if not recipe then return false end

    local stats = _survivalService.GetStats(player)
    if not stats or stats.IsDowned then return false end

    local profile = _profileService.GetProfile(player)
    if not profile then return false end

    if recipe.UnlockLevel and profile.level < recipe.UnlockLevel then
        return false
    end

    -- Station proximity validation
    if recipe.StationRequired and not isNearStation(player, recipe.StationRequired) then
        warn(string.format("[CraftingService] %s tried to craft %s without being near %s", player.Name, recipeId, recipe.StationRequired))
        return false
    end

    -- Ingredient validation
    for _, ingredient in ipairs(recipe.Ingredients) do
        local requiredAmount = ingredient.Quantity * quantity
        local currentCount = _inventoryService.GetItemCount(player, ingredient.ItemId)
        if currentCount < requiredAmount then
            return false
        end
    end

    -- Atomic deduction
    for _, ingredient in ipairs(recipe.Ingredients) do
        local toRemove = ingredient.Quantity * quantity
        local removed = _inventoryService.TryRemoveItem(player, ingredient.ItemId, toRemove)
        if not removed then
            return false
        end
    end

    -- Atomic output grant
    local totalOutput = recipe.OutputQuantity * quantity
    local added = _inventoryService.TryAddItem(player, recipe.OutputItemId, totalOutput)
    if not added then
        -- Rollback ingredients if inventory full
        for _, ingredient in ipairs(recipe.Ingredients) do
            _inventoryService.TryAddItem(player, ingredient.ItemId, ingredient.Quantity * quantity)
        end
        return false
    end

    print(string.format("[CraftingService] %s crafted %dx %s", player.Name, totalOutput, recipe.DisplayName))
    return true
end

return CraftingService
]=====] },
    { path = {"ServerScriptService", "TFFServer", "Services", "CreatureService"}, class = "ModuleScript", source = [=====[--!strict
--[[
    CreatureService.lua
    Server-authoritative creature AI, bounded pathfinding, state machines,
    and encounter director for The Stalker, The Watcher, and The Mimic.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.CreatureDefinitions)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local CreatureService = {}
CreatureService.__index = CreatureService

local _combatService: any = nil
local _worldService: any = nil
local _survivalService: any = nil

type CreatureInstance = {
    Model: Model,
    CreatureId: string,
    State: string,
    SpawnPosition: Vector3,
    CurrentTarget: Player?,
    LastAttackTime: number,
    LastRepathTime: number,
    LeashRange: number,
    DetectionRadius: number,
    AttackRange: number,
    Damage: number,
    WindupTime: number,
    Cooldown: number,
}

local _activeCreatures: { [Model]: CreatureInstance } = {}
local _templatesFolder: Folder? = nil

local function getNearestEligiblePlayer(position: Vector3, maxRadius: number): (Player?, number)
    local nearest: Player? = nil
    local minDist = maxRadius

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local humanoid = char and char:FindFirstChild("Humanoid") :: Humanoid?

        if root and humanoid and humanoid.Health > 0 then
            -- Skip players inside Safe Haven
            if not _worldService or not _worldService.IsInsideSafeZone(root.Position) then
                local dist = (root.Position - position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest, minDist
end

function CreatureService.Init(dependencies: { [string]: any })
    print("[CreatureService] Initializing CreatureService...")
    _combatService = dependencies.CombatService
    _worldService = dependencies.WorldService
    _survivalService = dependencies.SurvivalService

    local tffStorage = ServerStorage:WaitForChild("TFF")
    local templates = tffStorage:WaitForChild("Templates")
    _templatesFolder = templates:WaitForChild("Creatures") :: Folder
end

function CreatureService.Start()
    print("[CreatureService] CreatureService started.")

    -- Spawn initial Stalkers and Watcher in Whispering Woods
    task.defer(function()
        CreatureService.SpawnCreature("stalker", Vector3.new(-35, 2, -210))
        CreatureService.SpawnCreature("stalker", Vector3.new(45, 2, -250))
        CreatureService.SpawnCreature("watcher", Vector3.new(-80, 16, -290))
    end)

    -- AI State Machine simulation loop (runs every 0.3s)
    task.spawn(function()
        local dt = 0.3
        while true do
            task.wait(dt)
            local now = os.clock()

            for model, inst in pairs(_activeCreatures) do
                local root = model.PrimaryPart
                local humanoid = model:FindFirstChildWhichIsA("Humanoid")

                if not root or not humanoid or humanoid.Health <= 0 then
                    _activeCreatures[model] = nil
                    model:Destroy()
                else
                    local pos = root.Position

                    -- ==========================================
                    -- THE STALKER AI
                    -- ==========================================
                    if inst.CreatureId == "stalker" then
                        -- Check distance to spawn point (leash enforcement)
                        local distToSpawn = (pos - inst.SpawnPosition).Magnitude
                        if distToSpawn > inst.LeashRange then
                            inst.State = "Return"
                            inst.CurrentTarget = nil
                        end

                        if inst.State == "Idle" or inst.State == "Patrol" then
                            local player, dist = getNearestEligiblePlayer(pos, inst.DetectionRadius)
                            if player then
                                inst.CurrentTarget = player
                                inst.State = "Chase"
                            end

                        elseif inst.State == "Chase" then
                            local target = inst.CurrentTarget
                            local targetChar = target and target.Character
                            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?

                            if not targetRoot or (_worldService and _worldService.IsInsideSafeZone(targetRoot.Position)) then
                                inst.State = "Return"
                                inst.CurrentTarget = nil
                            else
                                local distToTarget = (targetRoot.Position - pos).Magnitude
                                if distToTarget > inst.DetectionRadius * 1.5 then
                                    inst.State = "Return"
                                    inst.CurrentTarget = nil
                                elseif distToTarget <= inst.AttackRange and (now - inst.LastAttackTime) >= inst.Cooldown then
                                    inst.State = "Windup"
                                    inst.LastAttackTime = now

                                    -- Visual telegraph cue: activate red telegraph light
                                    local head = model:FindFirstChild("Head")
                                    local light = head and head:FindFirstChild("TelegraphLight") :: PointLight?
                                    if light then light.Brightness = 3 end

                                    -- Windup timer before hit
                                    task.delay(inst.WindupTime, function()
                                        if model.Parent and inst.State == "Windup" then
                                            if light then light.Brightness = 0 end
                                            -- Execute attack
                                            local currentTargetChar = inst.CurrentTarget and inst.CurrentTarget.Character
                                            if currentTargetChar and _combatService then
                                                _combatService.ValidateAndApplyAttack(model, currentTargetChar, inst.Damage, inst.AttackRange + 3)
                                            end
                                            inst.State = "Chase"
                                        end
                                    end)
                                else
                                    -- Move towards target
                                    if (now - inst.LastRepathTime) >= 0.8 then
                                        inst.LastRepathTime = now
                                        humanoid:MoveTo(targetRoot.Position)
                                    end
                                end
                            end

                        elseif inst.State == "Return" then
                            humanoid:MoveTo(inst.SpawnPosition)
                            if (pos - inst.SpawnPosition).Magnitude <= 5 then
                                inst.State = "Idle"
                            end
                        end

                    -- ==========================================
                    -- THE WATCHER AI (Atmospheric Observer)
                    -- ==========================================
                    elseif inst.CreatureId == "watcher" then
                        local player, dist = getNearestEligiblePlayer(pos, 35)
                        if player and dist < 35 then
                            -- Player came too close -> Watcher fades / relocates
                            inst.State = "Despawn"
                            _activeCreatures[model] = nil
                            model:Destroy()
                            -- Respawns later at overlook
                            task.delay(120, function()
                                CreatureService.SpawnCreature("watcher", inst.SpawnPosition)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function CreatureService.SpawnCreature(definitionId: string, spawnPosition: Vector3): Model?
    local count = CreatureService.GetActiveCreatureCount()
    if count >= BalanceConfig.StandardHostileCap then
        warn(string.format("[CreatureService] Active creature cap reached (%d/%d). Cannot spawn %s", count, BalanceConfig.StandardHostileCap, definitionId))
        return nil
    end

    local def = CreatureDefinitions[definitionId]
    if not def or not _templatesFolder then return nil end

    local template = _templatesFolder:FindFirstChild(def.DisplayName) or _templatesFolder:FindFirstChild(def.Id:sub(1, 1):upper() .. def.Id:sub(2))
    if not template or not template:IsA("Model") then
        template = _templatesFolder:FindFirstChild("Stalker") :: Model?
    end
    if not template then return nil end

    local clone = template:Clone()
    clone:PivotTo(CFrame.new(spawnPosition))
    clone.Parent = game.Workspace:WaitForChild("TFF_World"):WaitForChild("CreatureSpawns")

    local inst: CreatureInstance = {
        Model = clone,
        CreatureId = definitionId,
        State = "Idle",
        SpawnPosition = spawnPosition,
        CurrentTarget = nil,
        LastAttackTime = 0,
        LastRepathTime = 0,
        LeashRange = def.LeashRange,
        DetectionRadius = def.DetectionRadius,
        AttackRange = def.AttackRange,
        Damage = def.AttackDamage,
        WindupTime = def.WindupDuration,
        Cooldown = def.AttackCooldown,
    }

    _activeCreatures[clone] = inst
    print(string.format("[CreatureService] Spawned %s at %s (Active: %d)", def.DisplayName, tostring(spawnPosition), count + 1))
    return clone
end

function CreatureService.GetActiveCreatureCount(): number
    local count = 0
    for _ in pairs(_activeCreatures) do
        count += 1
    end
    return count
end

function CreatureService.GetCreatureInstance(model: Model): CreatureInstance?
    return _activeCreatures[model]
end

return CreatureService
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
return string.format("BATCH 2 SUCCESS: Updated %d scripts.", synced)