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
