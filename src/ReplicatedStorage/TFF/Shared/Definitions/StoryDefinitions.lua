--!strict
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
