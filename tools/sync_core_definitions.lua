--!strict
local RS = game:GetService("ReplicatedStorage")
local tff = RS:FindFirstChild("TFF")
local sharedFolder = tff:FindFirstChild("Shared")
local typesMod = sharedFolder:FindFirstChild("Types"):FindFirstChild("Types")
typesMod.Source = [=====[--!strict
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
]=====]

local defs = sharedFolder:FindFirstChild("Definitions")
defs:FindFirstChild("ItemDefinitions").Source = [=====[--!strict
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
]=====]
defs:FindFirstChild("RecipeDefinitions").Source = [=====[--!strict
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
]=====]

local remotesFolder = tff:FindFirstChild("Remotes")
remotesFolder:FindFirstChild("RemoteRegistry").Source = [=====[--!strict
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
]=====]

return "Updated Types, ItemDefinitions, RecipeDefinitions, RemoteRegistry in Studio!"
