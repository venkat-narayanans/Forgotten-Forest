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
    { path = {"StarterPlayer", "StarterPlayerScripts", "TFFClient", "Controllers", "InputController"}, class = "ModuleScript", source = [=====[--!strict
--[[
    InputController.lua
    Client controller for handling user movement inputs (Sprint toggle/hold),
    desktop hotkeys (1-5 hotbar slots, E interact, F use item, C crafting, Q quests, M map, B storage),
    ProximityPrompt integration, and mobile controls.
]]

local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RemoteRegistry = require(ReplicatedStorage.TFF.Remotes.RemoteRegistry)
local BalanceConfig = require(ReplicatedStorage.TFF.Shared.Config.BalanceConfig)

local InputController = {}
InputController.__index = InputController

local _isSprinting = false
local _hudController: any = nil
local _player = Players.LocalPlayer

function InputController.Init(dependencies: { [string]: any })
    print("[InputController] Initializing InputController...")
    _hudController = dependencies.HUDController
end

local function getNearestInteractable(maxDist: number): (BasePart?, string?)
    local char = _player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return nil, nil end

    local tffWorld = Workspace:FindFirstChild("TFF_World")
    local interactables = tffWorld and tffWorld:FindFirstChild("Interactables")
    if not interactables then return nil, nil end

    local nearest: BasePart? = nil
    local minDist = maxDist
    local modalType: string? = nil

    for _, obj in ipairs(interactables:GetChildren()) do
        if obj:IsA("BasePart") then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
                if obj.Name == "Workbench" then
                    modalType = "Crafting"
                elseif obj.Name == "SharedStorageChest" then
                    modalType = "Storage"
                elseif obj.Name == "QuestBoard" then
                    modalType = "Quest"
                elseif obj.Name:find("StoryClue") then
                    modalType = "Lore"
                end
            end
        end
    end
    return nearest, modalType
end

function InputController.Start()
    print("[InputController] InputController started.")

    local sprintRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestSprint)

    local function updateSprint(wantsSprint: boolean)
        if _isSprinting ~= wantsSprint then
            _isSprinting = wantsSprint
            if sprintRemote then
                sprintRemote:FireServer(wantsSprint)
            end
        end
    end

    -- Hook up ProximityPrompt interactions on client for instant UI response
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, playerWhoTriggered: Player)
        if playerWhoTriggered ~= _player then return end
        local parentInstance = prompt.Parent
        if not parentInstance then return end

        local model = parentInstance:FindFirstAncestorOfClass("Model")
        local name = parentInstance.Name
        if model and (model.Name == "ExpeditionStarterChest" or model.Name == "NPC_medic" or model.Name == "NPC_cartographer" or model.Name == "NPC_old_keeper") then
            name = model.Name
        end

        if name == "QuestBoard" then
            if _hudController then _hudController.OpenModal("Quest") end
        elseif name == "Workbench" then
            if _hudController then _hudController.OpenModal("Crafting") end
        elseif name == "SharedStorageChest" then
            if _hudController then _hudController.OpenModal("Storage") end
        elseif name == "ExpeditionStarterChest" then
            if _hudController then
                _hudController.RefreshCraftingModal()
                _hudController.UpdateObjectiveTracker("q_starter_kit")
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        -- Ignore hotkeys only if player is actively typing in a TextBox
        if gameProcessed and UserInputService:GetFocusedTextBox() then return end

        -- Sprint
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(true)

        -- Hotbar selection (Keys 1-5)
        elseif input.KeyCode == Enum.KeyCode.One then
            if _hudController then _hudController.SelectHotbarSlot(1) end
        elseif input.KeyCode == Enum.KeyCode.Two then
            if _hudController then _hudController.SelectHotbarSlot(2) end
        elseif input.KeyCode == Enum.KeyCode.Three then
            if _hudController then _hudController.SelectHotbarSlot(3) end
        elseif input.KeyCode == Enum.KeyCode.Four then
            if _hudController then _hudController.SelectHotbarSlot(4) end
        elseif input.KeyCode == Enum.KeyCode.Five then
            if _hudController then _hudController.SelectHotbarSlot(5) end

        -- Use Active Consumable Item
        elseif input.KeyCode == Enum.KeyCode.F then
            if _hudController then _hudController.UseActiveItem() end

        -- Direct Hotkey for Crafting Modal (Key 'C')
        elseif input.KeyCode == Enum.KeyCode.C then
            if _hudController then _hudController.ToggleModal("Crafting") end

        -- Direct Hotkey for Quest Log / Notice Board (Key 'Q' or 'J')
        elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.J then
            if _hudController then _hudController.ToggleModal("Quest") end

        -- Direct Hotkey for Storage (Key 'B' for Backpack/Storage)
        elseif input.KeyCode == Enum.KeyCode.B then
            if _hudController then _hudController.ToggleModal("Storage") end

        -- Interactive Map Screen (Key 'M' or Gamepad Select)
        elseif input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.ButtonSelect then
            if _hudController then _hudController.ToggleModal("Map") end

        -- Interact (Workbench, Chest, Quest Board, Lore Clue)
        elseif input.KeyCode == Enum.KeyCode.E then
            local obj, modalType = getNearestInteractable(BalanceConfig.DefaultInteractionRange + 2)
            if obj and modalType and _hudController then
                _hudController.OpenModal(modalType)
            end

        -- Close Modals
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if _hudController then _hudController.CloseAllModals() end
        end

        -- Weapon Attack / Tool Action (LMB click)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if gameProcessed then return end
            local mousePos = UserInputService:GetMouseLocation()
            local camera = Workspace.CurrentCamera
            if camera then
                local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local raycastParams = RaycastParams.new()
                if _player.Character then
                    raycastParams.FilterDescendantsInstances = { _player.Character }
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                end
                local result = Workspace:Raycast(ray.Origin, ray.Direction * 150, raycastParams)
                local targetInstance = result and result.Instance
                local hitPos = result and result.Position
                local attackRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestAttack)
                if attackRemote then
                    attackRemote:FireServer(targetInstance, hitPos, ray.Direction)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, _gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            updateSprint(false)
        end
    end)
end

return InputController
]=====] },
    { path = {"StarterPlayer", "StarterPlayerScripts", "TFFClient", "Controllers", "HUDController"}, class = "ModuleScript", source = [=====[--!strict
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
local _activeQuests: { [string]: any } = {}
local _completedQuests: { [string]: boolean } = {}

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
local _objectiveTracker: Frame? = nil
local _craftingButton: TextButton? = nil
local _questButton: TextButton? = nil

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
    _objectiveTracker = mainContainer:FindFirstChild("ObjectiveTracker") :: Frame?
    _craftingButton = mainContainer:FindFirstChild("CraftingButton") :: TextButton?
    _questButton = mainContainer:FindFirstChild("QuestButton") :: TextButton?

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

    -- HUD Action Buttons Wiring
    local mapBtn = mainContainer:FindFirstChild("MapButton") :: TextButton?
    if mapBtn then
        mapBtn.MouseButton1Click:Connect(function()
            HUDController.ToggleModal("Map")
        end)
    end

    if _craftingButton then
        _craftingButton.MouseButton1Click:Connect(function()
            HUDController.ToggleModal("Crafting")
        end)
    end

    if _questButton then
        _questButton.MouseButton1Click:Connect(function()
            HUDController.ToggleModal("Quest")
        end)
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

    -- Sync Profile, Inventory & Quests
    local syncProfileRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.SyncProfile)
    if syncProfileRemote then
        syncProfileRemote.OnClientEvent:Connect(function(profile: any)
            if profile then
                if profile.inventory then
                    _cachedInventory = profile.inventory
                    refreshHotbarUI()
                end
                if profile.activeQuests then
                    _activeQuests = profile.activeQuests
                end
                if profile.completedQuests then
                    _completedQuests = profile.completedQuests
                end
                HUDController.RefreshCraftingModal()
                HUDController.RefreshQuestModal()
                HUDController.UpdateObjectiveTracker()
            end
        end)
    end

    -- Hook Quest Updates
    local questUpdateRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.QuestUpdated)
    if questUpdateRemote then
        questUpdateRemote.OnClientEvent:Connect(function(activeQuests: any, completedQuests: any)
            if activeQuests then _activeQuests = activeQuests end
            if completedQuests then _completedQuests = completedQuests end
            HUDController.RefreshQuestModal()
            HUDController.UpdateObjectiveTracker()
        end)
    end

    -- Hook General Notifications
    local showNotifRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.ShowNotification)
    if showNotifRemote then
        showNotifRemote.OnClientEvent:Connect(function(title: string, message: string)
            HUDController.ShowBannerNotification(title, message)
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
                    HUDController.UpdateObjectiveTracker()
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

local function countInInventory(itemId: string): number
    local total = 0
    for _, item in ipairs(_cachedInventory) do
        if item.ItemId == itemId then
            total += item.Quantity
        end
    end
    return total
end

function HUDController.OpenModal(modalName: string)
    HUDController.CloseAllModals()
    if modalName == "Crafting" and _craftingModal then
        _craftingModal.Visible = true
        HUDController.RefreshCraftingModal()
    elseif modalName == "Storage" and _storageModal then
        _storageModal.Visible = true
    elseif modalName == "Quest" and _questModal then
        _questModal.Visible = true
        HUDController.RefreshQuestModal()
    elseif modalName == "Lore" and _loreModal then
        _loreModal.Visible = true
    elseif modalName == "Map" and _mapModal then
        _mapModal.Visible = true
        HUDController.UpdateMapDisplay()
    end
end

function HUDController.ToggleModal(modalName: string)
    local targetModal: Frame? = nil
    if modalName == "Crafting" then targetModal = _craftingModal
    elseif modalName == "Storage" then targetModal = _storageModal
    elseif modalName == "Quest" then targetModal = _questModal
    elseif modalName == "Lore" then targetModal = _loreModal
    elseif modalName == "Map" then targetModal = _mapModal
    end

    if targetModal then
        if targetModal.Visible then
            targetModal.Visible = false
        else
            HUDController.OpenModal(modalName)
        end
    end
end

function HUDController.ToggleMapModal()
    HUDController.ToggleModal("Map")
end

function HUDController.RefreshCraftingModal()
    if not _craftingModal then return end
    local recipeList = _craftingModal:FindFirstChild("RecipeList") :: ScrollingFrame?
    if not recipeList then return end

    local RecipeDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.RecipeDefinitions)
    local ItemDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.ItemDefinitions)

    for _, card in ipairs(recipeList:GetChildren()) do
        if card:IsA("Frame") and card.Name:sub(1, 5) == "Card_" then
            local recipeId = card.Name:sub(6)
            local recipeDef = RecipeDefinitions[recipeId]
            if recipeDef then
                local allReady = true
                local ingParts: { string } = {}

                for _, ing in ipairs(recipeDef.Ingredients) do
                    local count = countInInventory(ing.ItemId)
                    local itemDef = ItemDefinitions[ing.ItemId]
                    local name = itemDef and itemDef.DisplayName or ing.ItemId
                    if count >= ing.Quantity then
                        table.insert(ingParts, string.format("%s: %d/%d (Ready)", name, count, ing.Quantity))
                    else
                        table.insert(ingParts, string.format("%s: %d/%d (Need %d)", name, count, ing.Quantity, ing.Quantity - count))
                        allReady = false
                    end
                end

                for _, child in ipairs(card:GetChildren()) do
                    if child:IsA("TextLabel") and child.Position.Y.Offset > 15 then
                        child.Text = table.concat(ingParts, " • ")
                        child.TextColor3 = allReady and Color3.fromRGB(120, 230, 140) or Color3.fromRGB(240, 120, 120)
                    end
                end

                local craftBtn = card:FindFirstChild("CraftButton") :: TextButton?
                if craftBtn then
                    if allReady then
                        craftBtn.Text = "[ CRAFT ]"
                        craftBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
                        craftBtn.TextColor3 = Color3.fromRGB(240, 255, 240)
                    else
                        craftBtn.Text = "[ NEED MATERIALS ]"
                        craftBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
                        craftBtn.TextColor3 = Color3.fromRGB(220, 160, 160)
                    end

                    -- Clean previous listeners by storing connection tag or replacing
                    if not craftBtn:GetAttribute("Wired") then
                        craftBtn:SetAttribute("Wired", true)
                        craftBtn.MouseButton1Click:Connect(function()
                            -- Recheck readiness at click time
                            local canCraftNow = true
                            for _, ing in ipairs(recipeDef.Ingredients) do
                                if countInInventory(ing.ItemId) < ing.Quantity then
                                    canCraftNow = false
                                    break
                                end
                            end

                            if canCraftNow then
                                local craftRemote = RemoteRegistry.GetRemoteEvent(RemoteRegistry.Events.RequestCraft)
                                if craftRemote then
                                    craftRemote:FireServer(recipeId)
                                end
                            else
                                HUDController.ShowBannerNotification("CRAFTING ALERT", "Missing materials for " .. (recipeDef.DisplayName or recipeId) .. "!\nGather driftwood, stone, or herbs around Safe Haven.")
                            end
                        end)
                    end
                end
            end
        end
    end
end

function HUDController.RefreshQuestModal()
    if not _questModal then return end
    local questList = _questModal:FindFirstChild("QuestList") :: ScrollingFrame?
    if not questList then return end

    -- Clear existing quest cards
    for _, child in ipairs(questList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local QuestDefinitions = require(ReplicatedStorage.TFF.Shared.Definitions.QuestDefinitions)
    local orderedKeys = {
        "q_starter_kit",
        "q_first_steps",
        "q_prepare_for_night",
        "q_whispering_woods",
        "q_investigate_village",
        "q_ancient_seals",
        "q_helping_hand",
    }

    local yTotal = 0
    for _, qId in ipairs(orderedKeys) do
        local qDef = QuestDefinitions[qId]
        if qDef then
            local isCompleted = _completedQuests[qId] == true
            local isActive = _activeQuests[qId] ~= nil or (qId == "q_starter_kit" and not isCompleted)

            local card = Instance.new("Frame")
            card.Name = "QuestCard_" .. qId
            card.Size = UDim2.new(1, -10, 0, 84)
            card.Position = UDim2.new(0, 5, 0, yTotal)
            card.BackgroundColor3 = isCompleted and Color3.fromRGB(26, 32, 40) or (isActive and Color3.fromRGB(34, 42, 54) or Color3.fromRGB(28, 32, 42))
            card.BorderSizePixel = 0

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 6)
            cardCorner.Parent = card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Thickness = isActive and 1.5 or 1.0
            cardStroke.Color = isCompleted and Color3.fromRGB(60, 80, 70) or (isActive and Color3.fromRGB(215, 175, 75) or Color3.fromRGB(60, 70, 85))
            cardStroke.Parent = card

            -- Title & Category Badge
            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, -120, 0, 20)
            titleLbl.Position = UDim2.new(0, 10, 0, 6)
            titleLbl.BackgroundTransparency = 1
            titleLbl.Text = string.format("[%s] %s", string.upper(qDef.Category), qDef.Title)
            titleLbl.TextColor3 = isCompleted and Color3.fromRGB(130, 200, 140) or (isActive and Color3.fromRGB(255, 220, 90) or Color3.fromRGB(200, 210, 220))
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextSize = 13
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = card

            -- Description
            local descLbl = Instance.new("TextLabel")
            descLbl.Size = UDim2.new(1, -120, 0, 32)
            descLbl.Position = UDim2.new(0, 10, 0, 26)
            descLbl.BackgroundTransparency = 1
            descLbl.Text = qDef.Description
            descLbl.TextColor3 = Color3.fromRGB(190, 200, 210)
            descLbl.Font = Enum.Font.GothamMedium
            descLbl.TextSize = 11
            descLbl.TextWrapped = true
            descLbl.TextXAlignment = Enum.TextXAlignment.Left
            descLbl.Parent = card

            -- Objectives & Rewards Summary
            local rewardLbl = Instance.new("TextLabel")
            rewardLbl.Size = UDim2.new(1, -120, 0, 18)
            rewardLbl.Position = UDim2.new(0, 10, 0, 60)
            rewardLbl.BackgroundTransparency = 1
            local rewardStr = string.format("REWARDS: +%d XP  |  +%d Forest Coins", qDef.Rewards.XP, qDef.Rewards.ForestCoins)
            if qDef.Rewards.AncientTokens > 0 then
                rewardStr = rewardStr .. string.format("  |  +%d Ancient Tokens", qDef.Rewards.AncientTokens)
            end
            rewardLbl.Text = rewardStr
            rewardLbl.TextColor3 = Color3.fromRGB(150, 175, 200)
            rewardLbl.Font = Enum.Font.GothamBold
            rewardLbl.TextSize = 10
            rewardLbl.TextXAlignment = Enum.TextXAlignment.Left
            rewardLbl.Parent = card

            -- Action / Status Badge
            local statusBadge = Instance.new("TextLabel")
            statusBadge.Size = UDim2.new(0, 100, 0, 28)
            statusBadge.Position = UDim2.new(1, -108, 0, 26)
            statusBadge.Font = Enum.Font.GothamBold
            statusBadge.TextSize = 11

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 4)
            bCorner.Parent = statusBadge

            if isCompleted then
                statusBadge.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
                statusBadge.TextColor3 = Color3.fromRGB(160, 240, 170)
                statusBadge.Text = "[✓] COMPLETED"
            elseif isActive then
                statusBadge.BackgroundColor3 = Color3.fromRGB(45, 75, 110)
                statusBadge.TextColor3 = Color3.fromRGB(255, 225, 90)
                statusBadge.Text = "● ACTIVE"
            else
                statusBadge.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
                statusBadge.TextColor3 = Color3.fromRGB(160, 170, 180)
                statusBadge.Text = "LOCKED"
            end
            statusBadge.Parent = card

            card.Parent = questList
            yTotal += 92
        end
    end
    questList.CanvasSize = UDim2.new(0, 0, 0, yTotal + 20)
end

function HUDController.UpdateObjectiveTracker(overrideQuestId: string?)
    if not _objectiveTracker then return end
    local titleLbl = _objectiveTracker:FindFirstChild("ObjectiveTitle") :: TextLabel?
    local descLbl = _objectiveTracker:FindFirstChild("ObjectiveDesc") :: TextLabel?
    if not titleLbl or not descLbl then return end

    local isStarterDone = _completedQuests["q_starter_kit"] == true
    local hasTorch = false
    for _, item in ipairs(_cachedInventory) do
        if item.ItemId == "torch" then
            hasTorch = true
            break
        end
    end

    if not isStarterDone and not hasTorch then
        titleLbl.Text = "Equip for the Wilds"
        descLbl.Text = "• Claim Expedition Starter Chest by Beacon Fire\n• Press [1] for Torch, [C] to Craft, [Q] for Quests"
    elseif _currentRegionName == "Safe Haven" then
        titleLbl.Text = "First Steps into the Unknown"
        descLbl.Text = "• Practice gathering driftwood & stones around camp\n• Cross the fallen log bridge into Whispering Woods [M: Map]"
    elseif _currentRegionName == "Whispering Woods" then
        titleLbl.Text = "The Ravine Crossing"
        descLbl.Text = "• Keep your lit torch in hand to retain Warmth\n• Locate the massive Split Oak landmark to the north"
    elseif _currentRegionName == "Abandoned Village" then
        titleLbl.Text = "Echoes of the Past"
        descLbl.Text = "• Investigate Village Square & stopped Clock Tower\n• Speak with The Old Keeper on the cobblestone path"
    elseif _currentRegionName == "Crystal Caverns" then
        titleLbl.Text = "Luminescent Depths"
        descLbl.Text = "• Traverse cavern shafts past glowing crystal formations\n• Proceed toward the Ancient Grounds plateau"
    elseif _currentRegionName == "Ancient Grounds" then
        titleLbl.Text = "Shatter the Corrupted Ward"
        descLbl.Text = "• Channel all 5 Megalith Seals around the Elder Heartwood\n• Expose and strike the Forest Guardian's Crystal Heart"
    else
        titleLbl.Text = "Explore the Valley"
        descLbl.Text = "• Consult Alden, Mara, and your Quest Board [Q]"
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
return string.format("MODIFIED SYNC SUCCESS: Updated %d scripts.", synced)