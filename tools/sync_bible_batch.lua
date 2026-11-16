--!strict
local files = {
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
    clock_gear = {
        ItemId = "clock_gear",
        DisplayName = "Brass Clock Gear",
        Description = "A weathered brass escapement gear recovered from the Abandoned Village workshop. Fits the clock tower mechanism.",
        Category = "Quest",
        Rarity = "Uncommon",
        StackLimit = 5,
        IsQuestProtected = true,
        IsTradeable = false,
    },
    archive_key_fragment = {
        ItemId = "archive_key_fragment",
        DisplayName = "Archive Seal Fragment",
        Description = "An engraved stone tablet fragment bearing Keeper runes. Combined to open the sealed Keeper Archive.",
        Category = "Quest",
        Rarity = "Rare",
        StackLimit = 3,
        IsQuestProtected = true,
        IsTradeable = false,
    },
}

return ItemDefinitions
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
        Body = "Day 4: We reached the Split Oak. Its bark hums with low vibrations from the Heartroot beneath. Vane heard whispers in the fog that sounded like his sister's voice—the Echo Seal must have failed completely. We made camp, but something tall stood on Watcher's Bluff watching our campfire. It had no face, only hollow shadows. If you find this, turn back.",
        UnlockDiscovery = "Whispering Woods",
    },
    split_oak_carving = {
        ClueId = "split_oak_carving",
        Title = "Keeper Tree Inscription",
        Author = "Ancient Keeper Runic Text",
        Region = "Whispering Woods",
        Body = "'Here stands the Split Oak, where the Root Seal anchors the upper groves of Elderglen. When the Keepers divided, lightning split the boughs in two: one half surrendered to winter, one half sustained by living Heartroot sap. Let those who seek the Archive remember: Root before Ember, and Ember before Echo.'",
        UnlockDiscovery = "Split Oak Landmark",
    },
    village_ledger = {
        ClueId = "village_ledger",
        Title = "Town Archive Ledger",
        Author = "Archivist Helen",
        Region = "Abandoned Village",
        Body = "14th Frostfall: The Long Silence has fallen. When Elias Venn connected all five Seals at once, every lantern in Elderglen burned pale blue and all sound ceased. When breath returned, the Keepers were gone and the roots had seized the streets. Mira Vale sealed the Keeper Archive with the Three Lantern Ward (Root, Ember, Echo). The clock tower was stopped at midnight to silence its chime.",
        UnlockDiscovery = "Abandoned Village",
    },
    mira_vale_record = {
        ClueId = "mira_vale_record",
        Title = "Mira Vale's Final Testament",
        Author = "Mira Vale, Keeper Scholar",
        Region = "Abandoned Village Archive",
        Body = "'Elias was not evil—he loved Elderglen too much to watch the Heartroot slowly wither. But the forest is a living mind, not a machine to be forced into wakefulness. In forcing the five Seals together, he bound his own consciousness into the Heartroot's defense mechanism. The Forest Guardian is Elias's fractured will, defending a forest that no longer remembers peace. Can we live together again, or must we sacrifice what remains?'",
        UnlockDiscovery = "Keeper Archive",
    },
    clock_tower_note = {
        ClueId = "clock_tower_note",
        Title = "Mechanic's Work Order",
        Author = "Master Horologist Bennett",
        Region = "Abandoned Village Clock Tower",
        Body = "'The clock mechanism drives the village resonant bells. If the brass escapement gear is restored to the upper drive shaft, the chime will resonate through the valley, weakening the mist barrier blocking the gorge gateway to the Crystal Caverns.'",
        UnlockDiscovery = "Village Clock Tower",
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
            ["beacon"] = {
                prompt = "How do we repair the central beacon?",
                response = "The beacon's core cracked during the Long Silence. Gather 4 Forest Timber and 2 River Stones from our practice grounds, then interact with the beacon plinth. Lighting it will restore the light barrier, protect the camp from shadow stalkers, and uncover the Whispering Woods on your Survey Map!",
            },
            ["watchtower"] = {
                prompt = "Can I use the watchtower?",
                response = "Certainly! Climb the timber steps behind my tent. The brass telescope mounted on the upper deck lets you survey the entire valley—from the Split Oak all the way to the Village Clock Tower.",
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
            ["sanity"] = {
                prompt = "What are the whispers I hear in the woods?",
                response = "That is your Sanity slipping. The Heartroot beneath this valley stores every past fear, scream, and memory. Venture too far into the deep woods alone at night, and those memories will whisper to you. Stay near companions or campfire light to keep your mind anchored.",
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
            ["elderglen"] = {
                prompt = "What happened to Elderglen?",
                response = "A century ago, Elderglen was alive with scholars. We Keepers tended the five Seals: Root, Veil, Echo, Ember, and Heart. But Elias Venn tried to force all five to heal the Heartroot at once. The Long Silence swallowed our voices, and the forest grew over our stone.",
            },
            ["archive"] = {
                prompt = "How do I unlock the Keeper Archive?",
                response = "Mira Vale sealed the archive doors before she fled. You must observe the three puzzle lanterns outside the archway and light them in the sacred sequence: Root, Ember, then Echo. Inside lie her journals and the true records of the Long Silence.",
            },
            ["guardian"] = {
                prompt = "What is the Forest Guardian?",
                response = "It was the ancient shepherd of this forest, born of the Elder Tree. In forcing the seals, Elias Venn's own spirit was fused into its core. Now it protects a wounded Heartroot, striking down anyone who approaches.",
            },
            ["seals"] = {
                prompt = "How do I defeat it?",
                response = "Its core is protected by an invulnerability ward. You must enter the Ancient Grounds ritual circle and channel the 5 Ancient Seals: Root, Veil, Echo, Ember, and Heart. Only when all five are ignited will the Crystal Heart be exposed to your blades!",
            },
        },
    },
}

return StoryDefinitions
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