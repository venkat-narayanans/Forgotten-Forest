--!strict
-- Sync batch 1 of 4
local files = {
    { path = {"ReplicatedStorage", "TFF", "Remotes", "RemoteRegistry"}, class = "ModuleScript", source = [=====[--!strict
--[[
    RemoteRegistry.lua
    Central registry and accessor for all network RemoteEvents and RemoteFunctions.
]]

local RemoteRegistry = {}

RemoteRegistry.Events = {
    -- Client to Server Requests
    RequestGather = "RequestGather",
    RequestCraft = "RequestCraft",
    RequestRevive = "RequestRevive",
    RequestInteract = "RequestInteract",
    RequestSprint = "RequestSprint",
    RequestDepositStorage = "RequestDepositStorage",
    RequestWithdrawStorage = "RequestWithdrawStorage",
    RequestClaimQuest = "RequestClaimQuest",
    RequestEquipItem = "RequestEquipItem",
    RequestUseItem = "RequestUseItem",
    RequestAttack = "RequestAttack",
    RequestDialog = "RequestDialog",

    -- Server to Client Notifications & State Sync
    SyncProfile = "SyncProfile",
    SyncStats = "SyncStats",
    SyncTimeCycle = "SyncTimeCycle",
    ShowNotification = "ShowNotification",
    DownedStateChanged = "DownedStateChanged",
    SharedStorageUpdated = "SharedStorageUpdated",
    QuestUpdated = "QuestUpdated",
    BossHealthUpdated = "BossHealthUpdated",
    CombatHitFeedback = "CombatHitFeedback",
    SyncWeather = "SyncWeather",
    WorldEventTriggered = "WorldEventTriggered",
    RegionDiscovered = "RegionDiscovered",
    SyncDialog = "SyncDialog",
}

RemoteRegistry.Functions = {
    GetInitialSnapshot = "GetInitialSnapshot",
}

function RemoteRegistry.GetOrCreateRemotesFolder(): Folder
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local tff = ReplicatedStorage:FindFirstChild("TFF")
    if not tff then
        tff = Instance.new("Folder")
        tff.Name = "TFF"
        tff.Parent = ReplicatedStorage
    end

    local remotes = tff:FindFirstChild("Remotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = tff
    end

    local eventsFolder = remotes:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = remotes
    end

    local functionsFolder = remotes:FindFirstChild("Functions")
    if not functionsFolder then
        functionsFolder = Instance.new("Folder")
        functionsFolder.Name = "Functions"
        functionsFolder.Parent = remotes
    end

    return remotes
end

function RemoteRegistry.GetRemoteEvent(name: string): RemoteEvent
    local remotes = RemoteRegistry.GetOrCreateRemotesFolder()
    local eventsFolder = remotes:WaitForChild("Events") :: Folder
    local remote = eventsFolder:FindFirstChild(name) :: RemoteEvent
    if not remote and game:GetService("RunService"):IsServer() then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = eventsFolder
    end
    return remote
end

function RemoteRegistry.GetRemoteFunction(name: string): RemoteFunction
    local remotes = RemoteRegistry.GetOrCreateRemotesFolder()
    local functionsFolder = remotes:WaitForChild("Functions") :: Folder
    local remote = functionsFolder:FindFirstChild(name) :: RemoteFunction
    if not remote and game:GetService("RunService"):IsServer() then
        remote = Instance.new("RemoteFunction")
        remote.Name = name
        remote.Parent = functionsFolder
    end
    return remote
end

return RemoteRegistry
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Config", "BalanceConfig"}, class = "ModuleScript", source = [=====[--!strict
--[[
    BalanceConfig.lua
    Central gameplay balance starting values.
]]

local BalanceConfig = {
    -- Multiplayer settings
    MaxPlayers = 12,
    TargetMinimumPlayers = 8,

    -- Player baseline attributes
    MaxHealth = 100,
    MaxStamina = 100,
    MaxWarmth = 100,
    MaxSanity = 100,

    -- Inventory
    DefaultInventorySlots = 20,

    -- Interaction
    DefaultInteractionRange = 10, -- in studs

    -- Death & Revive
    DownedDuration = 30, -- in seconds
    ReviveDuration = 4,   -- in seconds
    ReviveHealthRestored = 35,
    DeathResourceLossPercent = 20, -- 20% of eligible carried resources

    -- Economy & Currencies
    Currencies = {
        ForestCoins = "forestCoins",
        AncientTokens = "ancientTokens",
    },

    -- NPC Caps
    StandardHostileCap = 12,
    MaxSimultaneousMajorEvents = 1,
}

return BalanceConfig
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Config", "CycleConfig"}, class = "ModuleScript", source = [=====[--!strict
--[[
    CycleConfig.lua
    World day/night cycle durations and phase definitions.
]]

local CycleConfig = {
    -- Total cycle: 1,200 seconds (20 minutes)
    PhaseDurations = {
        Morning = 180,    -- 3 minutes
        Afternoon = 300,  -- 5 minutes
        Sunset = 120,     -- 2 minutes
        Night = 420,      -- 7 minutes
        Dawn = 180,       -- 3 minutes
    },

    PhaseOrder = {
        "Morning",
        "Afternoon",
        "Sunset",
        "Night",
        "Dawn",
    },

    -- Lighting targets per phase
    LightingProfiles = {
        Morning = {
            ClockTime = 8.0,
            Brightness = 2.2,
            OutdoorAmbient = Color3.fromRGB(130, 140, 130),
            FogColor = Color3.fromRGB(180, 195, 185),
            FogStart = 50,
            FogEnd = 400,
        },
        Afternoon = {
            ClockTime = 14.0,
            Brightness = 2.5,
            OutdoorAmbient = Color3.fromRGB(140, 140, 130),
            FogColor = Color3.fromRGB(190, 200, 190),
            FogStart = 80,
            FogEnd = 500,
        },
        Sunset = {
            ClockTime = 18.2,
            Brightness = 1.5,
            OutdoorAmbient = Color3.fromRGB(180, 110, 80),
            FogColor = Color3.fromRGB(195, 120, 90),
            FogStart = 40,
            FogEnd = 350,
        },
        Night = {
            ClockTime = 23.5,
            Brightness = 0.5,
            OutdoorAmbient = Color3.fromRGB(25, 38, 60), -- Deep blue palette `#17263C`
            FogColor = Color3.fromRGB(23, 38, 60),
            FogStart = 20,
            FogEnd = 250,
        },
        Dawn = {
            ClockTime = 5.8,
            Brightness = 1.2,
            OutdoorAmbient = Color3.fromRGB(150, 130, 110),
            FogColor = Color3.fromRGB(170, 150, 130),
            FogStart = 40,
            FogEnd = 300,
        },
    },
}

return CycleConfig
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Config", "MovementConfig"}, class = "ModuleScript", source = [=====[--!strict
--[[
    MovementConfig.lua
    Movement speeds, stamina rates, and key controls.
]]

local MovementConfig = {
    WalkSpeed = 16,
    SprintSpeed = 22,
    JumpPower = 50,

    -- Stamina consumption & recovery
    MaxStamina = 100,
    SprintDrainRate = 12,     -- stamina points per second
    StaminaRegenRate = 18,    -- stamina points per second
    RegenDelayAfterSprint = 1.0, -- seconds of idle before regen kicks in
    MinStaminaToStartSprint = 10,

    -- Downed movement
    DownedWalkSpeed = 0, -- Stationary downed state as per spec recommendation
}

return MovementConfig
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Config", "SurvivalConfig"}, class = "ModuleScript", source = [=====[--!strict
--[[
    SurvivalConfig.lua
    Configuration for Health, Stamina, Warmth, and Sanity survival dynamics.
]]

local SurvivalConfig = {
    MaxHealth = 100,
    MaxStamina = 100,
    MaxWarmth = 100,
    MaxSanity = 100,

    -- Sanity thresholds (atmospheric triggers)
    SanityThresholds = {
        SubtleWhispers = 70,
        Silhouettes = 45,
        Distortions = 20,
        Disorientation = 0,
    },

    -- Warmth
    WarmthDecayColdZone = 2.0,    -- points per second in cold environments
    WarmthRecoveryNearFire = 5.0,  -- points per second near active campfire

    -- Passive health recovery in Safe Haven
    SafeHavenHealthRegen = 2.0,   -- points per second
    SafeHavenSanityRegen = 3.0,   -- points per second
}

return SurvivalConfig
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "CreatureDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    CreatureDefinitions.lua
    Data-driven definitions for Watcher, Stalker, Mimic, and Forest Guardian.
]]

local Types = require(script.Parent.Parent.Types.Types)

local CreatureDefinitions: { [string]: Types.CreatureDefinition } = {
    watcher = {
        Id = "watcher",
        DisplayName = "The Watcher",
        MaxHealth = 1,
        ChaseSpeed = 0,
        PatrolSpeed = 0,
        DetectionRadius = 60,
        AttackRange = 0,
        AttackDamage = 0,
        AttackCooldown = 999,
        WindupDuration = 0,
        LeashRange = 0,
        States = { "Dormant", "Idle", "Despawn" },
    },
    stalker = {
        Id = "stalker",
        DisplayName = "The Stalker",
        MaxHealth = 100,
        ChaseSpeed = 14,
        PatrolSpeed = 8,
        DetectionRadius = 45,
        AttackRange = 4,
        AttackDamage = 12,
        AttackCooldown = 2.2,
        WindupDuration = 0.6,
        LeashRange = 90,
        States = { "Idle", "Patrol", "Investigate", "Chase", "Windup", "Attack", "Recover", "Return" },
    },
    mimic = {
        Id = "mimic",
        DisplayName = "The Mimic",
        MaxHealth = 140,
        ChaseSpeed = 16,
        PatrolSpeed = 6,
        DetectionRadius = 35,
        AttackRange = 5,
        AttackDamage = 18,
        AttackCooldown = 3.0,
        WindupDuration = 0.8,
        LeashRange = 80,
        States = { "Idle", "Patrol", "Chase", "Windup", "Attack", "Recover", "Return" },
    },
    forest_guardian = {
        Id = "forest_guardian",
        DisplayName = "Forest Guardian",
        MaxHealth = 2500,
        ChaseSpeed = 10,
        PatrolSpeed = 6,
        DetectionRadius = 120,
        AttackRange = 15,
        AttackDamage = 25,
        AttackCooldown = 4.0,
        WindupDuration = 1.2,
        LeashRange = 150,
        States = { "Dormant", "Idle", "Windup", "Attack", "Recover", "Stagger" },
    },
}

return CreatureDefinitions
]=====] },
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "ItemDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    ItemDefinitions.lua
    Central data-driven catalog for all items in The Forgotten Forest.
]]

local Types = require(script.Parent.Parent.Types.Types)

local ItemDefinitions: { [string]: Types.ItemDefinition } = {
    -- Common Resources
    wood = {
        ItemId = "wood",
        DisplayName = "Forest Timber",
        Description = "Sturdy fallen branches gathered from the forest floor.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 50,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    stone = {
        ItemId = "stone",
        DisplayName = "River Stone",
        Description = "Dense rocks useful for tool crafting and structure reinforcement.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 50,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    herb = {
        ItemId = "herb",
        DisplayName = "Soothing Moss",
        Description = "Wild medicinal herbs emitting a faint sweet scent.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 30,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    food = {
        ItemId = "food",
        DisplayName = "Wild Berries",
        Description = "Nutritious berries gathered from bushes in Whispering Woods.",
        Category = "Consumable",
        Rarity = "Common",
        StackLimit = 30,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    cloth = {
        ItemId = "cloth",
        DisplayName = "Woven Fiber",
        Description = "Durable cloth salvaged from old packs or woven from plant stalks.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 40,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    water = {
        ItemId = "water",
        DisplayName = "Spring Water",
        Description = "Clear fresh water drawn from the Safe Haven creek.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 20,
        IsQuestProtected = false,
        IsTradeable = false,
    },

    -- Uncommon Resources
    metal_scrap = {
        ItemId = "metal_scrap",
        DisplayName = "Scrap Metal",
        Description = "Corroded metal components recovered from Abandoned Village ruins.",
        Category = "Resource",
        Rarity = "Uncommon",
        StackLimit = 30,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    rope = {
        ItemId = "rope",
        DisplayName = "Braided Rope",
        Description = "Tough cordage essential for barricades and defensive traps.",
        Category = "Resource",
        Rarity = "Uncommon",
        StackLimit = 30,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    animal_material = {
        ItemId = "animal_material",
        DisplayName = "Pelt Scrap",
        Description = "Insulating animal fur remnants used for thermal gear.",
        Category = "Resource",
        Rarity = "Uncommon",
        StackLimit = 20,
        IsQuestProtected = false,
        IsTradeable = false,
    },

    -- Rare Resources
    crystal = {
        ItemId = "crystal",
        DisplayName = "Luminescent Shard",
        Description = "Glowing mineral fragments found deep in shaded groves.",
        Category = "Resource",
        Rarity = "Rare",
        StackLimit = 15,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    ancient_fragment = {
        ItemId = "ancient_fragment",
        DisplayName = "Ancient Relic Fragment",
        Description = "Inscribed stone fragment pulsating with dormant magical energy.",
        Category = "Resource",
        Rarity = "Rare",
        StackLimit = 10,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    rare_mineral = {
        ItemId = "rare_mineral",
        DisplayName = "Dark Pyrite",
        Description = "Heavy ore with unusual magnetic properties.",
        Category = "Resource",
        Rarity = "Rare",
        StackLimit = 15,
        IsQuestProtected = false,
        IsTradeable = false,
    },

    -- Crafted Consumables & Gear
    torch = {
        ItemId = "torch",
        DisplayName = "Traveler's Torch",
        Description = "Provides light and warmth while exploring dark paths.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 5,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    healing_potion = {
        ItemId = "healing_potion",
        DisplayName = "Herbal Salve",
        Description = "Restores 40 Health over 3 seconds.",
        Category = "Consumable",
        Rarity = "Common",
        StackLimit = 10,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    wooden_barricade = {
        ItemId = "wooden_barricade",
        DisplayName = "Wooden Barricade",
        Description = "Deployable obstacle to delay stalking creatures.",
        Category = "Structure",
        Rarity = "Common",
        StackLimit = 5,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    basic_trap = {
        ItemId = "basic_trap",
        DisplayName = "Snare Trap",
        Description = "Immobilizes small hostile creatures for several seconds.",
        Category = "Structure",
        Rarity = "Uncommon",
        StackLimit = 5,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    advanced_lantern = {
        ItemId = "advanced_lantern",
        DisplayName = "Aether Lantern",
        Description = "Projects a wide aura that steadies Sanity in deep forest zones.",
        Category = "Equipment",
        Rarity = "Rare",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    warm_clothing = {
        ItemId = "warm_clothing",
        DisplayName = "Explorer's Parka",
        Description = "Significantly reduces Warmth decay in cold winds and fog surges.",
        Category = "Equipment",
        Rarity = "Uncommon",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    basic_tool = {
        ItemId = "basic_tool",
        DisplayName = "Carved Hatchet",
        Description = "Increases resource gathering speed by 35%.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },

    -- Weapons & Combat Tools (Master Specification Section 6.1)
    field_knife = {
        ItemId = "field_knife",
        DisplayName = "Field Knife",
        Description = "Fast starter weapon for close-quarters defence. Base damage 12.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    wooden_spear = {
        ItemId = "wooden_spear",
        DisplayName = "Wooden Spear",
        Description = "Carved hardwood spear with 9-stud reach. Can interrupt creature attacks. Base damage 18.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    hatchet = {
        ItemId = "hatchet",
        DisplayName = "Forged Hatchet",
        Description = "Sturdy steel hatchet. Chops timber obstacles and deals 20 base damage in combat.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    keeper_blade = {
        ItemId = "keeper_blade",
        DisplayName = "Keeper Blade",
        Description = "Ancient ceremonial shortsword. Resonates near Keeper mechanisms and deals 28 damage.",
        Category = "Tool",
        Rarity = "Rare",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    hunting_bow = {
        ItemId = "hunting_bow",
        DisplayName = "Hunting Bow",
        Description = "Recurve yew bow. Fires arrows silently with ballistics drop. Base damage 22.",
        Category = "Tool",
        Rarity = "Uncommon",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    arrow = {
        ItemId = "arrow",
        DisplayName = "Hunting Arrow",
        Description = "Fletched flint-tipped arrow for the Hunting Bow.",
        Category = "Resource",
        Rarity = "Common",
        StackLimit = 50,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    flare_launcher = {
        ItemId = "flare_launcher",
        DisplayName = "Flare Launcher",
        Description = "Emergency signaling tool that illuminates the dark and disrupts hostile stalkers.",
        Category = "Tool",
        Rarity = "Rare",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    signal_flare = {
        ItemId = "signal_flare",
        DisplayName = "Signal Flare",
        Description = "Magnesium cartridge used as ammunition for the Flare Launcher.",
        Category = "Resource",
        Rarity = "Uncommon",
        StackLimit = 10,
        IsQuestProtected = false,
        IsTradeable = false,
    },
    pickaxe = {
        ItemId = "pickaxe",
        DisplayName = "Iron Pickaxe",
        Role = "Mining tool",
        Description = "Heavy pickaxe for breaking stone, metal veins, and cavern crystals. Base damage 15.",
        Category = "Tool",
        Rarity = "Common",
        StackLimit = 1,
        IsQuestProtected = false,
        IsTradeable = false,
    },
}

return ItemDefinitions
]=====] },
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
    { path = {"ReplicatedStorage", "TFF", "Shared", "Definitions", "RecipeDefinitions"}, class = "ModuleScript", source = [=====[--!strict
--[[
    RecipeDefinitions.lua
    Data-driven crafting recipe definitions for The Forgotten Forest.
]]

local Types = require(script.Parent.Parent.Types.Types)

local RecipeDefinitions: { [string]: Types.RecipeDefinition } = {
    torch = {
        RecipeId = "torch",
        DisplayName = "Traveler's Torch",
        Description = "Craft a simple torch from timber and fiber.",
        OutputItemId = "torch",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 2 },
            { ItemId = "cloth", Quantity = 1 },
        },
        StationRequired = nil, -- Can be crafted anywhere
        CraftDuration = 2.0,
        UnlockLevel = 1,
    },
    healing_potion = {
        RecipeId = "healing_potion",
        DisplayName = "Herbal Salve",
        Description = "Brew wild herbs with fresh spring water.",
        OutputItemId = "healing_potion",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "herb", Quantity = 2 },
            { ItemId = "water", Quantity = 1 },
        },
        StationRequired = nil,
        CraftDuration = 3.0,
        UnlockLevel = 1,
    },
    wooden_barricade = {
        RecipeId = "wooden_barricade",
        DisplayName = "Wooden Barricade",
        Description = "Fasten timber logs into a defensive barrier.",
        OutputItemId = "wooden_barricade",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 5 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.0,
        UnlockLevel = 2,
    },
    basic_trap = {
        RecipeId = "basic_trap",
        DisplayName = "Snare Trap",
        Description = "Rig wood and rope into a creature trap.",
        OutputItemId = "basic_trap",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 3 },
            { ItemId = "rope", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 3.5,
        UnlockLevel = 2,
    },
    advanced_lantern = {
        RecipeId = "advanced_lantern",
        DisplayName = "Aether Lantern",
        Description = "Assemble rare luminescent crystals with scrap metal framing.",
        OutputItemId = "advanced_lantern",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "crystal", Quantity = 2 },
            { ItemId = "metal_scrap", Quantity = 3 },
        },
        StationRequired = "Workbench",
        CraftDuration = 5.0,
        UnlockLevel = 4,
    },
    warm_clothing = {
        RecipeId = "warm_clothing",
        DisplayName = "Explorer's Parka",
        Description = "Tailor pelts and woven fiber into cold-weather protection.",
        OutputItemId = "warm_clothing",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "cloth", Quantity = 3 },
            { ItemId = "animal_material", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.0,
        UnlockLevel = 3,
    },
    basic_tool = {
        RecipeId = "basic_tool",
        DisplayName = "Carved Hatchet",
        Description = "Affix a shaped river stone to a carved wooden handle.",
        OutputItemId = "basic_tool",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 2 },
            { ItemId = "stone", Quantity = 2 },
        },
        StationRequired = nil,
        CraftDuration = 2.5,
        UnlockLevel = 1,
    },
    field_knife = {
        RecipeId = "field_knife",
        DisplayName = "Field Knife",
        Description = "Sharpen scrap metal into a swift defensive blade.",
        OutputItemId = "field_knife",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 1 },
            { ItemId = "metal_scrap", Quantity = 1 },
        },
        StationRequired = "Workbench",
        CraftDuration = 2.5,
        UnlockLevel = 1,
    },
    wooden_spear = {
        RecipeId = "wooden_spear",
        DisplayName = "Wooden Spear",
        Description = "Carve a long reach spear bound with braided rope.",
        OutputItemId = "wooden_spear",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 3 },
            { ItemId = "rope", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 3.0,
        UnlockLevel = 1,
    },
    hatchet = {
        RecipeId = "hatchet",
        DisplayName = "Forged Hatchet",
        Description = "Forge timber and scrap metal into an effective weapon and wood-chopping tool.",
        OutputItemId = "hatchet",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 3 },
            { ItemId = "metal_scrap", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 3.5,
        UnlockLevel = 2,
    },
    pickaxe = {
        RecipeId = "pickaxe",
        DisplayName = "Iron Pickaxe",
        Description = "Mount a heavy pick head onto timber for breaking stone and crystal nodes.",
        OutputItemId = "pickaxe",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 3 },
            { ItemId = "stone", Quantity = 2 },
            { ItemId = "metal_scrap", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 3.5,
        UnlockLevel = 2,
    },
    hunting_bow = {
        RecipeId = "hunting_bow",
        DisplayName = "Hunting Bow",
        Description = "String flexible timber with braided cord for quiet ranged attacks.",
        OutputItemId = "hunting_bow",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "wood", Quantity = 4 },
            { ItemId = "rope", Quantity = 2 },
            { ItemId = "cloth", Quantity = 1 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.0,
        UnlockLevel = 2,
    },
    arrow = {
        RecipeId = "arrow",
        DisplayName = "Hunting Arrows (x5)",
        Description = "Whittle wood shafts tipped with sharp river stones.",
        OutputItemId = "arrow",
        OutputQuantity = 5,
        Ingredients = {
            { ItemId = "wood", Quantity = 2 },
            { ItemId = "stone", Quantity = 1 },
        },
        StationRequired = nil,
        CraftDuration = 2.0,
        UnlockLevel = 1,
    },
    keeper_blade = {
        RecipeId = "keeper_blade",
        DisplayName = "Keeper Blade",
        Description = "Infuse ancient relics with scrap metal to recreate an ancient ceremonial weapon.",
        OutputItemId = "keeper_blade",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "ancient_fragment", Quantity = 2 },
            { ItemId = "metal_scrap", Quantity = 3 },
            { ItemId = "crystal", Quantity = 2 },
        },
        StationRequired = "Workbench",
        CraftDuration = 5.0,
        UnlockLevel = 3,
    },
    flare_launcher = {
        RecipeId = "flare_launcher",
        DisplayName = "Flare Launcher",
        Description = "Assemble a spring-loaded launcher to ignite luminescent signaling flares.",
        OutputItemId = "flare_launcher",
        OutputQuantity = 1,
        Ingredients = {
            { ItemId = "metal_scrap", Quantity = 4 },
            { ItemId = "crystal", Quantity = 1 },
            { ItemId = "rope", Quantity = 1 },
        },
        StationRequired = "Workbench",
        CraftDuration = 4.5,
        UnlockLevel = 3,
    },
    signal_flare = {
        RecipeId = "signal_flare",
        DisplayName = "Signal Flares (x2)",
        Description = "Mix dried herbs and scrap metal casing into emergency flares.",
        OutputItemId = "signal_flare",
        OutputQuantity = 2,
        Ingredients = {
            { ItemId = "herb", Quantity = 2 },
            { ItemId = "metal_scrap", Quantity = 1 },
        },
        StationRequired = "Workbench",
        CraftDuration = 2.5,
        UnlockLevel = 2,
    },
}

return RecipeDefinitions
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
return string.format("BATCH 1 SUCCESS: Updated %d scripts.", synced)