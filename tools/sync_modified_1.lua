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
        Body = "EXPEDITION ORDER #12: Safe Haven basecamp established. Maintain the central beacon fire at all costs—the light field holds the perimeter intact against forest horrors.\n\nBEFORE VENTURING OUT:\n1. Open the glowing Expedition Starter Chest right beside this central beacon fire to claim your Traveler's Torch, Field Knife, Explorer's Parka (Warm Clothing), and 3x Herbal Salves.\n2. Review your Quest Log (press [Q] or click QUESTS on your HUD) and your Valley Survey Map (press [M] or click MAP).\n3. Practice gathering timber and herbs around Safe Haven, and use your Crafting Menu (press [C] or click CRAFTING) to prepare additional equipment.\n\nDo not cross the Creek Ravine into Whispering Woods without your torch equipped and warm parka donned!",
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
        Greeting = "Greetings, recruit! Before heading north into Whispering Woods, open the Expedition Starter Chest by our beacon fire to claim your torch, knife, and warm parka. Press [M] for your map, [Q] for quests, and [C] for crafting.",
        Topics = {
            ["start"] = {
                prompt = "Where do I start?",
                response = "Open the Expedition Starter Chest beside the beacon fire for your torch, field knife, and warm parka. Press [1] on your keyboard or tap your hotbar to hold the torch, and press [Q] to view your active missions!",
            },
            ["resources"] = {
                prompt = "Where do I find crafting materials?",
                response = "Safe Haven's perimeter has fallen driftwood timber, loose river stones, and soothing herbs. Practice gathering them here safely before crossing into Whispering Woods! Press [C] to open your Crafting menu.",
            },
            ["valley"] = {
                prompt = "Tell me about the valley layout.",
                response = "Safe Haven sits in the sheltered south. To the north lies Whispering Woods, bisected by the creek. Cross the fallen log bridge to reach the Split Oak and Silent Pond. Beyond the gorge lies the Abandoned Village and Crystal Caverns, leading to the Ancient Grounds.",
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
        Greeting = "Welcome back in one piece! The cold and damp in this valley are just as lethal as the shadow beasts. Always keep your Explorer's Parka equipped and carry a lit torch.",
        Topics = {
            ["warmth"] = {
                prompt = "How does Warmth work?",
                response = "When cold rain or dense fog rolls in, your warmth drops rapidly. If it reaches zero, hypothermia sets in, draining your health. Stand near our beacon fire or carry a lit torch (press [1]) to restore warmth.",
            },
            ["healing"] = {
                prompt = "How do I brew healing salves?",
                response = "Press [C] or click the CRAFTING button on your HUD. You can brew Herbal Salves anywhere from 2 Soothing Moss and 1 Spring Water. They restore 40 Health over 3 seconds. Use them with Key [F] or click their hotbar slot!",
            },
            ["defense"] = {
                prompt = "How do I defend myself?",
                response = "Equip your Field Knife from your hotbar and use left-click to attack. For larger stalkers, visit the Workbench to craft a Wooden Spear (reach 9 studs) or a Forged Hatchet!",
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
        forestCoins = 50,
        ancientTokens = 0,
        inventory = {
            { ItemId = "torch", Quantity = 1 },
            { ItemId = "field_knife", Quantity = 1 },
            { ItemId = "warm_clothing", Quantity = 1 },
            { ItemId = "healing_potion", Quantity = 3 },
            { ItemId = "wood", Quantity = 8 },
            { ItemId = "stone", Quantity = 6 },
            { ItemId = "cloth", Quantity = 4 },
            { ItemId = "herb", Quantity = 4 },
            { ItemId = "water", Quantity = 2 },
        },
        equipment = {
            mainHand = "field_knife",
            body = "warm_clothing",
        },
        unlockedRecipes = {
            torch = true,
            healing_potion = true,
            basic_tool = true,
            field_knife = true,
            wooden_spear = true,
            arrow = true,
            warm_clothing = true,
        },
        completedQuests = {},
        activeQuests = {
            q_starter_kit = { progress = 1, completed = false },
            q_first_steps = { progress = 0, completed = false },
        },
        achievements = {},
        discoveries = { ["Safe Haven"] = true },
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
    if #profile.inventory == 0 then
        -- Guarantee starter equipment is provided
        profile.inventory = {
            { ItemId = "torch", Quantity = 1 },
            { ItemId = "field_knife", Quantity = 1 },
            { ItemId = "warm_clothing", Quantity = 1 },
            { ItemId = "healing_potion", Quantity = 3 },
            { ItemId = "wood", Quantity = 8 },
            { ItemId = "stone", Quantity = 6 },
            { ItemId = "cloth", Quantity = 4 },
            { ItemId = "herb", Quantity = 4 },
            { ItemId = "water", Quantity = 2 },
        }
    end
    if not profile.equipment or not next(profile.equipment) then
        profile.equipment = { mainHand = "field_knife", body = "warm_clothing" }
    end
    if not profile.unlockedRecipes then
        profile.unlockedRecipes = {
            torch = true,
            healing_potion = true,
            basic_tool = true,
            field_knife = true,
            wooden_spear = true,
            arrow = true,
            warm_clothing = true,
        }
    else
        profile.unlockedRecipes.torch = true
        profile.unlockedRecipes.healing_potion = true
        profile.unlockedRecipes.basic_tool = true
        profile.unlockedRecipes.field_knife = true
        profile.unlockedRecipes.wooden_spear = true
        profile.unlockedRecipes.arrow = true
        profile.unlockedRecipes.warm_clothing = true
    end
    if not profile.completedQuests then profile.completedQuests = {} end
    if not profile.activeQuests or not next(profile.activeQuests) then
        profile.activeQuests = {
            q_starter_kit = { progress = 1, completed = false },
            q_first_steps = { progress = 0, completed = false },
        }
    end
    if not profile.achievements then profile.achievements = {} end
    if not profile.discoveries then profile.discoveries = { ["Safe Haven"] = true } end
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
local _inventoryService: any = nil
local _questService: any = nil

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
    _inventoryService = dependencies.InventoryService
    _questService = dependencies.QuestService
end

function PlayerService.Start()
    print("[PlayerService] PlayerService started.")
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end

    -- Hook up ProximityPrompts for NPCs, Chests, and Story Clues
    local dialogRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncDialog)
    local notificationRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.ShowNotification)

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

        -- 2. Expedition Starter Supply Chest Interaction
        elseif parentInstance.Name == "ExpeditionStarterChest" or (model and model.Name == "ExpeditionStarterChest") then
            local profile = _profileService.GetProfile(player)
            if profile then
                local alreadyClaimed = profile.hasClaimedStarterKit == true
                if not alreadyClaimed then
                    profile.hasClaimedStarterKit = true
                    if _inventoryService then
                        _inventoryService.TryAddItem(player, "torch", 1)
                        _inventoryService.TryAddItem(player, "field_knife", 1)
                        _inventoryService.TryAddItem(player, "warm_clothing", 1)
                        _inventoryService.TryAddItem(player, "healing_potion", 3)
                        _inventoryService.TryAddItem(player, "wood", 8)
                        _inventoryService.TryAddItem(player, "stone", 6)
                        _inventoryService.TryAddItem(player, "cloth", 4)
                        _inventoryService.TryAddItem(player, "herb", 4)
                        _inventoryService.TryAddItem(player, "water", 2)
                    end
                    if _questService then
                        _questService.TryClaimQuestReward(player, "q_starter_kit")
                    end
                    if notificationRemote then
                        notificationRemote:FireClient(player, "STARTER SUPPLIES CLAIMED!", "Equipped with Torch, Field Knife, Explorer's Parka, and Salves! Press [Q] for Quests, [C] for Crafting, [M] for Map.")
                    end
                else
                    -- Ensure they still have at least basic tools
                    if _inventoryService then
                        if _inventoryService.GetItemCount(player, "torch") == 0 then
                            _inventoryService.TryAddItem(player, "torch", 1)
                        end
                        if _inventoryService.GetItemCount(player, "field_knife") == 0 then
                            _inventoryService.TryAddItem(player, "field_knife", 1)
                        end
                    end
                    if notificationRemote then
                        notificationRemote:FireClient(player, "EXPEDITION SUPPLIES READY", "Your Torch, Field Knife, and Explorer's Parka are in your Hotbar and Inventory! Press [C] to Craft, [Q] for Quests.")
                    end
                end
            end

        -- 3. Story Clue Interaction
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
    print("Synced: " .. table.concat(item.path, "."))
end
return string.format("sync_modified_1.lua SUCCESS: Updated %d scripts.", synced)